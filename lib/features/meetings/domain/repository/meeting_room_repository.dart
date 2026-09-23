import '../entities/meeting_room.dart';

abstract interface class MeetingRoomRepository {
  Stream<MeetingRealtimeMessage> get events;

  Stream<MeetingMediaEvent> get mediaEvents;

  Future<void> open(int meetingId);

  Future<void> requestToJoin();

  Future<void> approve(int userId);

  Future<void> reject(int userId);

  Future<void> requestToken();

  Future<void> connectMedia(MeetingRoomToken token);

  Future<void> setMicrophoneEnabled(bool enabled);

  Future<void> setCameraEnabled(bool enabled);

  Future<void> setHandRaised(bool raised);

  Future<void> sendChatMessage(String message);

  Future<void> sendReaction(String reaction);

  Future<void> setScreenShareEnabled(bool enabled);

  Future<void> setAudioInputDevice(String deviceId);

  Future<void> setAudioOutputDevice(String deviceId);

  Future<void> setVideoInputDevice(String deviceId);

  Future<void> setCameraPosition(MeetingCameraPosition position);

  Future<void> close();
}
