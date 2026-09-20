import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:livekit_client/livekit_client.dart';

import '../../domain/entities/meeting_room.dart';

class LiveKitMediaService {
  final _events = StreamController<MeetingMediaEvent>.broadcast();

  Room? _room;
  EventsListener<RoomEvent>? _listener;
  final List<CancelListenFunc> _cancelListeners = [];
  static const _backgroundAudioChannel = MethodChannel(
    'raqamli.nazorat/meeting_audio',
  );
  bool _backgroundAudioStarted = false;

  Stream<MeetingMediaEvent> get events => _events.stream;

  Future<void> connect(MeetingRoomToken token) async {
    await disconnect();
    final room = Room(
      roomOptions: const RoomOptions(adaptiveStream: true, dynacast: true),
    );
    _room = room;
    final listener = room.createListener();
    _listener = listener;
    _bindRoomEvents(listener);
    try {
      await room.connect(token.serverUrl, token.token);
      await _startBackgroundAudio();
      _emit(
        MeetingMediaEvent(
          type: MeetingMediaEventType.connected,
          participants: _participants(),
          microphoneEnabled: _localMicrophoneEnabled(),
          cameraEnabled: _localCameraEnabled(),
        ),
      );
    } on Object catch (error) {
      _emit(
        MeetingMediaEvent(
          type: MeetingMediaEventType.failure,
          message: error.toString(),
        ),
      );
      rethrow;
    }
  }

  void _bindRoomEvents(EventsListener<RoomEvent> listener) {
    _cancelListeners.add(
      listener.on<RoomReconnectingEvent>((_) {
        _emit(
          const MeetingMediaEvent(type: MeetingMediaEventType.reconnecting),
        );
      }),
    );
    _cancelListeners.add(
      listener.on<RoomReconnectedEvent>((_) {
        _emit(
          MeetingMediaEvent(
            type: MeetingMediaEventType.reconnected,
            participants: _participants(),
            microphoneEnabled: _localMicrophoneEnabled(),
            cameraEnabled: _localCameraEnabled(),
          ),
        );
      }),
    );
    _cancelListeners.add(
      listener.on<RoomDisconnectedEvent>((_) {
        _emit(
          const MeetingMediaEvent(type: MeetingMediaEventType.disconnected),
        );
      }),
    );
    _cancelListeners.add(
      listener.on<ParticipantConnectedEvent>((_) => _emitParticipants()),
    );
    _cancelListeners.add(
      listener.on<ParticipantDisconnectedEvent>((_) => _emitParticipants()),
    );
    _cancelListeners.add(
      listener.on<TrackSubscribedEvent>((_) => _emitParticipants()),
    );
    _cancelListeners.add(
      listener.on<TrackUnsubscribedEvent>((_) => _emitParticipants()),
    );
    _cancelListeners.add(
      listener.on<TrackMutedEvent>((_) => _emitParticipants()),
    );
    _cancelListeners.add(
      listener.on<TrackUnmutedEvent>((_) => _emitParticipants()),
    );
    _cancelListeners.add(
      listener.on<ActiveSpeakersChangedEvent>((_) => _emitParticipants()),
    );
  }

  void _emitParticipants() {
    _emit(
      MeetingMediaEvent(
        type: MeetingMediaEventType.participantsChanged,
        participants: _participants(),
        microphoneEnabled: _localMicrophoneEnabled(),
        cameraEnabled: _localCameraEnabled(),
      ),
    );
  }

  List<MeetingRoomParticipant> _participants() {
    final room = _room;
    if (room == null) return const [];
    final result = <MeetingRoomParticipant>[];
    final local = room.localParticipant;
    if (local != null) result.add(_participant(local, isLocal: true));
    for (final participant in room.remoteParticipants.values) {
      result.add(_participant(participant, isLocal: false));
    }
    return result;
  }

  MeetingRoomParticipant _participant(
    Participant participant, {
    required bool isLocal,
  }) {
    final audio = participant.audioTrackPublications.isEmpty
        ? null
        : participant.audioTrackPublications.first;
    final video = participant.videoTrackPublications.isEmpty
        ? null
        : participant.videoTrackPublications.first;
    return MeetingRoomParticipant(
      identity: participant.identity,
      name: participant.name,
      isLocal: isLocal,
      isSpeaking: participant.isSpeaking,
      microphoneEnabled: audio?.muted == false,
      cameraEnabled: video?.muted == false,
      audioTrackSid: audio?.sid,
      videoTrackSid: video?.sid,
    );
  }

  bool _localMicrophoneEnabled() {
    final participant = _room?.localParticipant;
    if (participant == null || participant.audioTrackPublications.isEmpty) {
      return false;
    }
    return participant.audioTrackPublications.first.muted == false;
  }

  bool _localCameraEnabled() {
    final participant = _room?.localParticipant;
    if (participant == null || participant.videoTrackPublications.isEmpty) {
      return false;
    }
    return participant.videoTrackPublications.first.muted == false;
  }

  Future<void> setMicrophoneEnabled(bool enabled) async {
    final participant = _room?.localParticipant;
    if (participant == null) throw StateError('LiveKit xonasiga ulanilmagan');
    await participant.setMicrophoneEnabled(enabled);
    _emitParticipants();
  }

  Future<void> setCameraEnabled(bool enabled) async {
    final participant = _room?.localParticipant;
    if (participant == null) throw StateError('LiveKit xonasiga ulanilmagan');
    await participant.setCameraEnabled(enabled);
    _emitParticipants();
  }

  VideoTrack? videoTrackFor(String identity) {
    final room = _room;
    if (room == null) return null;
    final local = room.localParticipant;
    final Participant? participant = local?.identity == identity
        ? local
        : room.remoteParticipants[identity];
    if (participant == null || participant.videoTrackPublications.isEmpty) {
      return null;
    }
    return participant.videoTrackPublications.first.track as VideoTrack?;
  }

  void _emit(MeetingMediaEvent event) {
    if (!_events.isClosed) _events.add(event);
  }

  Future<void> disconnect() async {
    await _stopBackgroundAudio();
    for (final cancel in _cancelListeners) {
      await cancel();
    }
    _cancelListeners.clear();
    await _listener?.dispose();
    _listener = null;
    await _room?.disconnect();
    _room = null;
  }

  Future<void> dispose() async {
    await disconnect();
    await _events.close();
  }

  Future<void> _startBackgroundAudio() async {
    if (defaultTargetPlatform != TargetPlatform.android) return;
    try {
      await _backgroundAudioChannel.invokeMethod<void>('start');
      _backgroundAudioStarted = true;
    } on PlatformException {
      // Media connection remains usable if the optional foreground service
      // cannot start on a restricted device configuration.
    }
  }

  Future<void> _stopBackgroundAudio() async {
    if (!_backgroundAudioStarted ||
        defaultTargetPlatform != TargetPlatform.android) {
      return;
    }
    try {
      await _backgroundAudioChannel.invokeMethod<void>('stop');
    } on PlatformException {
      // Cleanup is best effort; the service is also non-sticky.
    }
    _backgroundAudioStarted = false;
  }
}
