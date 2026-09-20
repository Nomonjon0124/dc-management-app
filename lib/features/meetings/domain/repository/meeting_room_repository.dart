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

  Future<void> close();
}
