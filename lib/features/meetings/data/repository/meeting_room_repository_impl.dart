import '../../domain/entities/meeting_room.dart';
import '../../domain/repository/meeting_room_repository.dart';
import '../../../../core/constants/storage_keys.dart';
import '../../../../core/services/storage_service.dart';
import '../data_sources/meeting_realtime_data_source.dart';
import '../services/livekit_media_service.dart';

class MeetingRoomRepositoryImpl implements MeetingRoomRepository {
  MeetingRoomRepositoryImpl({
    required MeetingRealtimeDataSource realtime,
    required LiveKitMediaService media,
    StorageService? storage,
  }) : _realtime = realtime,
       _media = media,
       _storage = storage;

  final MeetingRealtimeDataSource _realtime;
  final LiveKitMediaService _media;
  final StorageService? _storage;

  @override
  Stream<MeetingRealtimeMessage> get events => _realtime.events;

  @override
  Stream<MeetingMediaEvent> get mediaEvents => _media.events;

  @override
  Future<void> open(int meetingId) => _realtime.open(meetingId);

  @override
  Future<void> requestToJoin() =>
      _realtime.send(const {'action': 'ask_to_join'});

  @override
  Future<void> approve(int userId) => _realtime.send({
    'action': 'admit',
    'user_id': userId,
    'decision': 'approve',
  });

  @override
  Future<void> reject(int userId) => _realtime.send({
    'action': 'admit',
    'user_id': userId,
    'decision': 'reject',
  });

  @override
  Future<void> requestToken({
    String? deviceId,
    String? deviceName,
  }) => _realtime.send({
    'action': 'get_token',
    if ((deviceId ?? _storage?.getString(StorageKeys.deviceId))?.isNotEmpty ??
        false)
      'device_id': deviceId ?? _storage?.getString(StorageKeys.deviceId),
    'device_name': deviceName ?? 'Mobile',
  });

  @override
  Future<void> connectMedia(MeetingRoomToken token) => _media.connect(token);

  @override
  Future<void> setMicrophoneEnabled(bool enabled) =>
      _media.setMicrophoneEnabled(enabled);

  @override
  Future<void> setCameraEnabled(bool enabled) =>
      _media.setCameraEnabled(enabled);

  @override
  Future<void> setHandRaised(bool raised) =>
      _realtime.send({'action': 'hand_raise', 'raised': raised});

  @override
  Future<void> sendChatMessage(String message) =>
      _media.sendChatMessage(message);

  @override
  Future<void> sendReaction(String reaction) =>
      _realtime.send({'action': 'send_reaction', 'reaction': reaction});

  @override
  Future<void> moderateTrack({
    required String targetIdentity,
    required String trackSource,
  }) => _realtime.send({
    'action': 'moderate_track',
    'target_identity': targetIdentity,
    'track_source': trackSource,
    'operation': 'mute',
  });

  @override
  Future<void> requestTrackUnmute({
    required String targetIdentity,
    required String trackSource,
  }) => _realtime.send({
    'action': 'request_track_unmute',
    'target_identity': targetIdentity,
    'track_source': trackSource,
  });

  @override
  Future<void> respondTrackUnmute({
    required String requestId,
    required String trackSource,
    required bool accept,
  }) => _realtime.send({
    'action': 'respond_track_unmute_request',
    'request_id': requestId,
    'decision': accept ? 'accept' : 'reject',
    'track_source': trackSource,
  });

  @override
  Future<void> setScreenShareEnabled(bool enabled) =>
      _media.setScreenShareEnabled(enabled);

  @override
  Future<void> setAudioInputDevice(String deviceId) =>
      _media.setAudioInputDevice(deviceId);

  @override
  Future<void> setAudioOutputDevice(String deviceId) =>
      _media.setAudioOutputDevice(deviceId);

  @override
  Future<void> setVideoInputDevice(String deviceId) =>
      _media.setVideoInputDevice(deviceId);

  @override
  Future<void> setCameraPosition(MeetingCameraPosition position) =>
      _media.setCameraPosition(position);

  @override
  Future<void> close() async {
    await _media.disconnect();
    await _realtime.close();
  }
}
