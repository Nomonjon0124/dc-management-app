import 'package:equatable/equatable.dart';

abstract class MeetingRoomEvent extends Equatable {
  const MeetingRoomEvent();

  @override
  List<Object?> get props => [];
}

class MeetingRoomStarted extends MeetingRoomEvent {
  const MeetingRoomStarted(this.meetingId);

  final int meetingId;

  @override
  List<Object?> get props => [meetingId];
}

class MeetingRoomJoinRequested extends MeetingRoomEvent {
  const MeetingRoomJoinRequested();
}

class MeetingRoomJoinCancelled extends MeetingRoomEvent {
  const MeetingRoomJoinCancelled();
}

class MeetingRoomUserApproved extends MeetingRoomEvent {
  const MeetingRoomUserApproved(this.userId);

  final int userId;

  @override
  List<Object?> get props => [userId];
}

class MeetingRoomUserRejected extends MeetingRoomEvent {
  const MeetingRoomUserRejected(this.userId);

  final int userId;

  @override
  List<Object?> get props => [userId];
}

class MeetingRoomLeaveRequested extends MeetingRoomEvent {
  const MeetingRoomLeaveRequested();
}

class MeetingRoomEndRequested extends MeetingRoomEvent {
  const MeetingRoomEndRequested();
}

class MeetingRoomRetryRequested extends MeetingRoomEvent {
  const MeetingRoomRetryRequested();
}

class MeetingRoomMicrophoneToggled extends MeetingRoomEvent {
  const MeetingRoomMicrophoneToggled();
}

class MeetingRoomCameraToggled extends MeetingRoomEvent {
  const MeetingRoomCameraToggled();
}
