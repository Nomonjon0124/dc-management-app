import 'package:equatable/equatable.dart';

import '../../domain/entities/meeting_room.dart';

class MeetingRoomState extends Equatable {
  const MeetingRoomState({
    this.meetingId,
    this.phase = MeetingRoomPhase.prejoin,
    this.title = '',
    this.requiresApproval = false,
    this.organizerJoined = false,
    this.isHost = false,
    this.isApproved = false,
    this.microphoneEnabled = false,
    this.cameraEnabled = false,
    this.participants = const [],
    this.pendingRequests = const [],
    this.errorMessage,
  });

  final int? meetingId;
  final MeetingRoomPhase phase;
  final String title;
  final bool requiresApproval;
  final bool organizerJoined;
  final bool isHost;
  final bool isApproved;
  final bool microphoneEnabled;
  final bool cameraEnabled;
  final List<MeetingRoomParticipant> participants;
  final List<MeetingRoomJoinRequest> pendingRequests;
  final String? errorMessage;

  bool get isLoading =>
      phase == MeetingRoomPhase.ticketLoading ||
      phase == MeetingRoomPhase.socketConnecting ||
      phase == MeetingRoomPhase.joiningMedia;

  MeetingRoomState copyWith({
    int? meetingId,
    MeetingRoomPhase? phase,
    String? title,
    bool? requiresApproval,
    bool? organizerJoined,
    bool? isHost,
    bool? isApproved,
    bool? microphoneEnabled,
    bool? cameraEnabled,
    List<MeetingRoomParticipant>? participants,
    List<MeetingRoomJoinRequest>? pendingRequests,
    String? errorMessage,
    bool clearError = false,
  }) {
    return MeetingRoomState(
      meetingId: meetingId ?? this.meetingId,
      phase: phase ?? this.phase,
      title: title ?? this.title,
      requiresApproval: requiresApproval ?? this.requiresApproval,
      organizerJoined: organizerJoined ?? this.organizerJoined,
      isHost: isHost ?? this.isHost,
      isApproved: isApproved ?? this.isApproved,
      microphoneEnabled: microphoneEnabled ?? this.microphoneEnabled,
      cameraEnabled: cameraEnabled ?? this.cameraEnabled,
      participants: participants ?? this.participants,
      pendingRequests: pendingRequests ?? this.pendingRequests,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    meetingId,
    phase,
    title,
    requiresApproval,
    organizerJoined,
    isHost,
    isApproved,
    microphoneEnabled,
    cameraEnabled,
    participants,
    pendingRequests,
    errorMessage,
  ];
}
