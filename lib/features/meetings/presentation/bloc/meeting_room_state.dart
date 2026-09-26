import 'package:equatable/equatable.dart';

import '../../domain/entities/meeting.dart';
import '../../domain/entities/meeting_room.dart';

enum MeetingRoomError { screenShareFailed }

class MeetingRoomState extends Equatable {
  const MeetingRoomState({
    this.meetingId,
    this.meeting,
    this.phase = MeetingRoomPhase.prejoin,
    this.title = '',
    this.requiresApproval = false,
    this.organizerJoined = false,
    this.isHost = false,
    this.isApproved = false,
    this.microphoneEnabled = true,
    this.cameraEnabled = false,
    this.handRaised = false,
    this.screenSharing = false,
    this.participants = const [],
    this.pendingRequests = const [],
    this.pendingUnmuteRequests = const [],
    this.messages = const [],
    this.reactions = const [],
    this.audioInputs = const [],
    this.audioOutputs = const [],
    this.videoInputs = const [],
    this.selectedAudioInputId,
    this.selectedAudioOutputId,
    this.selectedVideoInputId,
    this.error,
    this.errorMessage,
  });

  final int? meetingId;
  final Meeting? meeting;
  final MeetingRoomPhase phase;
  final String title;
  final bool requiresApproval;
  final bool organizerJoined;
  final bool isHost;
  final bool isApproved;
  final bool microphoneEnabled;
  final bool cameraEnabled;
  final bool handRaised;
  final bool screenSharing;
  final List<MeetingRoomParticipant> participants;
  final List<MeetingRoomJoinRequest> pendingRequests;
  final List<MeetingTrackUnmuteRequest> pendingUnmuteRequests;
  final List<MeetingRoomDataMessage> messages;
  final List<MeetingRoomDataMessage> reactions;
  final List<MeetingMediaDevice> audioInputs;
  final List<MeetingMediaDevice> audioOutputs;
  final List<MeetingMediaDevice> videoInputs;
  final String? selectedAudioInputId;
  final String? selectedAudioOutputId;
  final String? selectedVideoInputId;
  final MeetingRoomError? error;
  final String? errorMessage;

  bool get isLoading =>
      phase == MeetingRoomPhase.ticketLoading ||
      phase == MeetingRoomPhase.socketConnecting ||
      phase == MeetingRoomPhase.joiningMedia;

  MeetingRoomState copyWith({
    int? meetingId,
    Meeting? meeting,
    MeetingRoomPhase? phase,
    String? title,
    bool? requiresApproval,
    bool? organizerJoined,
    bool? isHost,
    bool? isApproved,
    bool? microphoneEnabled,
    bool? cameraEnabled,
    bool? handRaised,
    bool? screenSharing,
    List<MeetingRoomParticipant>? participants,
    List<MeetingRoomJoinRequest>? pendingRequests,
    List<MeetingTrackUnmuteRequest>? pendingUnmuteRequests,
    List<MeetingRoomDataMessage>? messages,
    List<MeetingRoomDataMessage>? reactions,
    List<MeetingMediaDevice>? audioInputs,
    List<MeetingMediaDevice>? audioOutputs,
    List<MeetingMediaDevice>? videoInputs,
    String? selectedAudioInputId,
    String? selectedAudioOutputId,
    String? selectedVideoInputId,
    MeetingRoomError? error,
    String? errorMessage,
    bool clearError = false,
  }) {
    return MeetingRoomState(
      meetingId: meetingId ?? this.meetingId,
      meeting: meeting ?? this.meeting,
      phase: phase ?? this.phase,
      title: title ?? this.title,
      requiresApproval: requiresApproval ?? this.requiresApproval,
      organizerJoined: organizerJoined ?? this.organizerJoined,
      isHost: isHost ?? this.isHost,
      isApproved: isApproved ?? this.isApproved,
      microphoneEnabled: microphoneEnabled ?? this.microphoneEnabled,
      cameraEnabled: cameraEnabled ?? this.cameraEnabled,
      handRaised: handRaised ?? this.handRaised,
      screenSharing: screenSharing ?? this.screenSharing,
      participants: participants ?? this.participants,
      pendingRequests: pendingRequests ?? this.pendingRequests,
      pendingUnmuteRequests:
          pendingUnmuteRequests ?? this.pendingUnmuteRequests,
      messages: messages ?? this.messages,
      reactions: reactions ?? this.reactions,
      audioInputs: audioInputs ?? this.audioInputs,
      audioOutputs: audioOutputs ?? this.audioOutputs,
      videoInputs: videoInputs ?? this.videoInputs,
      selectedAudioInputId: selectedAudioInputId ?? this.selectedAudioInputId,
      selectedAudioOutputId:
          selectedAudioOutputId ?? this.selectedAudioOutputId,
      selectedVideoInputId: selectedVideoInputId ?? this.selectedVideoInputId,
      error: clearError ? null : error ?? this.error,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    meetingId,
    meeting,
    phase,
    title,
    requiresApproval,
    organizerJoined,
    isHost,
    isApproved,
    microphoneEnabled,
    cameraEnabled,
    handRaised,
    screenSharing,
    participants,
    pendingRequests,
    pendingUnmuteRequests,
    messages,
    reactions,
    audioInputs,
    audioOutputs,
    videoInputs,
    selectedAudioInputId,
    selectedAudioOutputId,
    selectedVideoInputId,
    error,
    errorMessage,
  ];
}
