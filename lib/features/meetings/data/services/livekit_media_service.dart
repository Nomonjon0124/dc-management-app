import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:livekit_client/livekit_client.dart';

import '../../domain/entities/meeting_room.dart';

class LiveKitMediaService {
  final _events = StreamController<MeetingMediaEvent>.broadcast();

  Room? _room;
  EventsListener<RoomEvent>? _listener;
  StreamSubscription<List<MediaDevice>>? _deviceSubscription;
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
      await _emitDevices();
      _deviceSubscription = Hardware.instance.onDeviceChange.stream.listen(
        (devices) => _emitDevices(
          devices
              .map(
                (device) => MeetingMediaDevice(
                  id: device.deviceId,
                  label: device.label,
                  kind: device.kind,
                ),
              )
              .toList(growable: false),
        ),
      );
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
    _cancelListeners.add(listener.on<DataReceivedEvent>(_onDataReceived));
    _cancelListeners.add(
      listener.on<TrackPublishedEvent>((_) => _emitParticipants()),
    );
    _cancelListeners.add(
      listener.on<TrackUnpublishedEvent>((_) => _emitParticipants()),
    );
  }

  void _onDataReceived(DataReceivedEvent event) {
    try {
      final decoded = jsonDecode(utf8.decode(event.data));
      if (decoded is! Map) return;
      final sender = event.participant;
      if (sender == null) return;
      final data = decoded.cast<String, dynamic>();
      final type = data['type']?.toString();
      if (type != 'chat' && type != 'hand_raise' && type != 'reaction') {
        return;
      }
      _emit(
        MeetingMediaEvent(
          type: MeetingMediaEventType.dataReceived,
          dataMessage: MeetingRoomDataMessage(
            type: type!,
            senderIdentity: sender.identity,
            senderName: sender.name,
            text: data['text']?.toString(),
            reaction: data['reaction']?.toString(),
            raised: data['raised'] is bool ? data['raised'] as bool : null,
            sentAt: DateTime.tryParse(data['sent_at']?.toString() ?? ''),
          ),
        ),
      );
    } on Object {
      // Ignore malformed data packets from clients using an older protocol.
    }
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
    final audio = participant.getTrackPublicationBySource(
      TrackSource.microphone,
    );
    final video = participant.getTrackPublicationBySource(TrackSource.camera);
    final screen = participant.getTrackPublicationBySource(
      TrackSource.screenShareVideo,
    );
    return MeetingRoomParticipant(
      identity: participant.identity,
      name: participant.name,
      isLocal: isLocal,
      isSpeaking: participant.isSpeaking,
      microphoneEnabled: audio?.muted == false,
      cameraEnabled: video?.muted == false,
      audioTrackSid: audio?.sid,
      videoTrackSid: video?.sid,
      screenShareTrackSid: screen?.sid,
      screenSharing: screen?.muted == false,
    );
  }

  bool _localMicrophoneEnabled() {
    final participant = _room?.localParticipant;
    return participant
            ?.getTrackPublicationBySource(TrackSource.microphone)
            ?.muted ==
        false;
  }

  bool _localCameraEnabled() {
    final participant = _room?.localParticipant;
    return participant
            ?.getTrackPublicationBySource(TrackSource.camera)
            ?.muted ==
        false;
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

  Future<void> setHandRaised(bool raised) async {
    await publishData(<String, dynamic>{
      'type': 'hand_raise',
      'raised': raised,
      'sent_at': DateTime.now().toUtc().toIso8601String(),
    });
  }

  Future<void> sendChatMessage(String message) async {
    await publishData(<String, dynamic>{
      'type': 'chat',
      'text': message,
      'sent_at': DateTime.now().toUtc().toIso8601String(),
    });
  }

  Future<void> sendReaction(String reaction) async {
    await publishData(<String, dynamic>{
      'type': 'reaction',
      'reaction': reaction,
      'sent_at': DateTime.now().toUtc().toIso8601String(),
    }, reliable: false);
  }

  Future<void> setScreenShareEnabled(bool enabled) async {
    final participant = _room?.localParticipant;
    if (!enabled) {
      try {
        if (participant == null) {
          throw StateError('LiveKit xonasiga ulanilmagan');
        }
        await participant.setScreenShareEnabled(false);
      } finally {
        await _stopScreenShareForegroundService();
      }
      _emitParticipants();
      return;
    }

    if (participant == null) {
      throw StateError('LiveKit xonasiga ulanilmagan');
    }

    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        // LiveKit exposes this as experimental while Android capture APIs settle.
        // ignore: experimental_member_use
        final granted = await Hardware.instance.requestCapturePermission();
        if (!granted) return;
        await _startScreenShareForegroundService();
      }
      await participant.setScreenShareEnabled(true);
    } on Object {
      await _stopScreenShareForegroundService();
      rethrow;
    }
    _emitParticipants();
  }

  Future<List<MeetingMediaDevice>> enumerateDevices() async {
    final devices = await Hardware.instance.enumerateDevices();
    final result = devices
        .map(
          (device) => MeetingMediaDevice(
            id: device.deviceId,
            label: device.label,
            kind: device.kind,
          ),
        )
        .toList(growable: false);
    _emitDevices(result);
    return result;
  }

  Future<void> setAudioInputDevice(String deviceId) async {
    final room = _room;
    if (room == null) throw StateError('LiveKit xonasiga ulanilmagan');
    final device = await _findDevice(deviceId, 'audioinput');
    await room.setAudioInputDevice(device);
    await _emitDevices();
  }

  Future<void> setAudioOutputDevice(String deviceId) async {
    final room = _room;
    if (room == null) throw StateError('LiveKit xonasiga ulanilmagan');
    final device = await _findDevice(deviceId, 'audiooutput');
    await room.setAudioOutputDevice(device);
    await _emitDevices();
  }

  Future<void> setVideoInputDevice(String deviceId) async {
    final room = _room;
    if (room == null) throw StateError('LiveKit xonasiga ulanilmagan');
    final device = await _findDevice(deviceId, 'videoinput');
    await room.setVideoInputDevice(device);
    await _emitDevices();
  }

  Future<void> setCameraPosition(MeetingCameraPosition position) async {
    final participant = _room?.localParticipant;
    final publication = participant?.getTrackPublicationBySource(
      TrackSource.camera,
    );
    final track = publication?.track;
    if (track is! LocalVideoTrack) {
      throw StateError('Kamera track topilmadi');
    }
    await track.setCameraPosition(
      position == MeetingCameraPosition.front
          ? CameraPosition.front
          : CameraPosition.back,
    );
    _emitParticipants();
  }

  Future<MediaDevice> _findDevice(String deviceId, String kind) async {
    final devices = await Hardware.instance.enumerateDevices();
    return devices.firstWhere(
      (device) => device.deviceId == deviceId && device.kind == kind,
      orElse: () => throw StateError('Qurilma topilmadi'),
    );
  }

  Future<void> publishData(
    Map<String, dynamic> data, {
    bool reliable = true,
  }) async {
    final participant = _room?.localParticipant;
    if (participant == null) throw StateError('LiveKit xonasiga ulanilmagan');
    await participant.publishData(
      utf8.encode(jsonEncode({'version': 1, ...data})),
      reliable: reliable,
      topic: 'meeting',
    );
  }

  VideoTrack? videoTrackFor(String identity, {bool screenShare = false}) {
    final room = _room;
    if (room == null) return null;
    final local = room.localParticipant;
    final Participant? participant = local?.identity == identity
        ? local
        : room.remoteParticipants[identity];
    final publication = participant?.getTrackPublicationBySource(
      screenShare ? TrackSource.screenShareVideo : TrackSource.camera,
    );
    if (publication == null || publication.muted) return null;
    final track = publication.track;
    return track is VideoTrack ? track : null;
  }

  Future<void> _emitDevices([List<MeetingMediaDevice>? devices]) async {
    final values =
        devices ??
        (await Hardware.instance.enumerateDevices())
            .map(
              (device) => MeetingMediaDevice(
                id: device.deviceId,
                label: device.label,
                kind: device.kind,
              ),
            )
            .toList(growable: false);
    _emit(
      MeetingMediaEvent(
        type: MeetingMediaEventType.devicesChanged,
        audioInputs: values
            .where((device) => device.kind == 'audioinput')
            .toList(),
        audioOutputs: values
            .where((device) => device.kind == 'audiooutput')
            .toList(),
        videoInputs: values
            .where((device) => device.kind == 'videoinput')
            .toList(),
      ),
    );
  }

  void _emit(MeetingMediaEvent event) {
    if (!_events.isClosed) _events.add(event);
  }

  Future<void> disconnect() async {
    await _stopScreenShareForegroundService();
    await _stopBackgroundAudio();
    await _deviceSubscription?.cancel();
    _deviceSubscription = null;
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

  Future<void> _startScreenShareForegroundService() async {
    if (defaultTargetPlatform != TargetPlatform.android) return;
    await _backgroundAudioChannel.invokeMethod<void>(
      'startScreenShareForegroundService',
    );
  }

  Future<void> _stopScreenShareForegroundService() async {
    if (defaultTargetPlatform != TargetPlatform.android) return;
    try {
      await _backgroundAudioChannel.invokeMethod<void>(
        'stopScreenShareForegroundService',
      );
    } on PlatformException {
      // Cleanup is best effort when the service has already stopped.
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
