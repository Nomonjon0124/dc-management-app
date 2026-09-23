import '../../domain/entities/meeting_room.dart';
import '../../domain/repository/meeting_room_repository.dart';
import '../data_sources/meeting_realtime_data_source.dart';
import '../services/livekit_media_service.dart';

class MeetingRoomRepositoryImpl implements MeetingRoomRepository {
  MeetingRoomRepositoryImpl({
    required MeetingRealtimeDataSource realtime,
    required LiveKitMediaService media,
  }) : _realtime = realtime,
       _media = media;

  final MeetingRealtimeDataSource _realtime;
  final LiveKitMediaService _media;

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
  Future<void> requestToken() => _realtime.send(const {'action': 'get_token'});

  @override
  Future<void> connectMedia(MeetingRoomToken token) => _media.connect(token);

  @override
  Future<void> setMicrophoneEnabled(bool enabled) =>
      _media.setMicrophoneEnabled(enabled);

  @override
  Future<void> setCameraEnabled(bool enabled) =>
      _media.setCameraEnabled(enabled);

  @override
  Future<void> setHandRaised(bool raised) => _media.setHandRaised(raised);

  @override
  Future<void> sendChatMessage(String message) =>
      _media.sendChatMessage(message);

  @override
  Future<void> sendReaction(String reaction) => _media.sendReaction(reaction);

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
