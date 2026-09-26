import 'package:equatable/equatable.dart';

import '../../domain/entities/meeting.dart';
import '../../domain/entities/meeting_room.dart';

abstract class MeetingRoomEvent extends Equatable {
  const MeetingRoomEvent();

  @override
  List<Object?> get props => [];
}

class MeetingRoomStarted extends MeetingRoomEvent {
  const MeetingRoomStarted(this.meetingId, {this.initialMeeting});

  final int meetingId;
  final Meeting? initialMeeting;

  @override
  List<Object?> get props => [meetingId, initialMeeting];
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

class MeetingRoomHandToggled extends MeetingRoomEvent {
  const MeetingRoomHandToggled();
}

class MeetingRoomChatMessageSent extends MeetingRoomEvent {
  const MeetingRoomChatMessageSent(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class MeetingRoomReactionSent extends MeetingRoomEvent {
  const MeetingRoomReactionSent(this.reaction);

  final String reaction;

  @override
  List<Object?> get props => [reaction];
}

class MeetingRoomReactionExpired extends MeetingRoomEvent {
  const MeetingRoomReactionExpired(this.reactionId);

  final String reactionId;

  @override
  List<Object?> get props => [reactionId];
}

class MeetingRoomParticipantMuted extends MeetingRoomEvent {
  const MeetingRoomParticipantMuted({
    required this.targetIdentity,
    required this.trackSource,
  });

  final String targetIdentity;
  final String trackSource;

  @override
  List<Object?> get props => [targetIdentity, trackSource];
}

class MeetingRoomUnmuteRequested extends MeetingRoomEvent {
  const MeetingRoomUnmuteRequested({
    required this.targetIdentity,
    required this.trackSource,
  });

  final String targetIdentity;
  final String trackSource;

  @override
  List<Object?> get props => [targetIdentity, trackSource];
}

class MeetingRoomUnmuteResponseSent extends MeetingRoomEvent {
  const MeetingRoomUnmuteResponseSent({
    required this.requestId,
    required this.trackSource,
    required this.accept,
  });

  final String requestId;
  final String trackSource;
  final bool accept;

  @override
  List<Object?> get props => [requestId, trackSource, accept];
}

class MeetingRoomScreenShareToggled extends MeetingRoomEvent {
  const MeetingRoomScreenShareToggled({required this.enabled});

  final bool enabled;

  @override
  List<Object?> get props => [enabled];
}

class MeetingRoomAudioInputSelected extends MeetingRoomEvent {
  const MeetingRoomAudioInputSelected(this.deviceId);

  final String deviceId;

  @override
  List<Object?> get props => [deviceId];
}

class MeetingRoomAudioOutputSelected extends MeetingRoomEvent {
  const MeetingRoomAudioOutputSelected(this.deviceId);

  final String deviceId;

  @override
  List<Object?> get props => [deviceId];
}

class MeetingRoomVideoInputSelected extends MeetingRoomEvent {
  const MeetingRoomVideoInputSelected(this.deviceId);

  final String deviceId;

  @override
  List<Object?> get props => [deviceId];
}

class MeetingRoomCameraPositionSelected extends MeetingRoomEvent {
  const MeetingRoomCameraPositionSelected(this.position);

  final MeetingCameraPosition position;

  @override
  List<Object?> get props => [position];
}
