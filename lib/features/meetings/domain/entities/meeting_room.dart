import 'package:equatable/equatable.dart';

enum MeetingRoomPhase {
  prejoin,
  ticketLoading,
  socketConnecting,
  waitingOrganizer,
  waitingApproval,
  joiningMedia,
  connected,
  reconnecting,
  rejected,
  left,
  ended,
  failure,
}

enum MeetingMediaEventType {
  connected,
  reconnecting,
  reconnected,
  disconnected,
  participantsChanged,
  localMediaChanged,
  failure,
  dataReceived,
  devicesChanged,
}

enum MeetingCameraPosition { front, back }

class MeetingRoomToken extends Equatable {
  const MeetingRoomToken({
    required this.serverUrl,
    required this.roomName,
    required this.token,
  });

  final String serverUrl;
  final String roomName;
  final String token;

  @override
  List<Object?> get props => [serverUrl, roomName, token];
}

class MeetingRoomParticipant extends Equatable {
  const MeetingRoomParticipant({
    required this.identity,
    required this.name,
    required this.isLocal,
    required this.isSpeaking,
    required this.microphoneEnabled,
    required this.cameraEnabled,
    this.audioTrackSid,
    this.videoTrackSid,
    this.screenShareTrackSid,
    this.handRaised = false,
    this.screenSharing = false,
  });

  final String identity;
  final String name;
  final bool isLocal;
  final bool isSpeaking;
  final bool microphoneEnabled;
  final bool cameraEnabled;
  final String? audioTrackSid;
  final String? videoTrackSid;
  final String? screenShareTrackSid;
  final bool handRaised;
  final bool screenSharing;

  @override
  List<Object?> get props => [
    identity,
    name,
    isLocal,
    isSpeaking,
    microphoneEnabled,
    cameraEnabled,
    audioTrackSid,
    videoTrackSid,
    screenShareTrackSid,
    handRaised,
    screenSharing,
  ];
}

class MeetingRoomDataMessage extends Equatable {
  const MeetingRoomDataMessage({
    required this.type,
    required this.senderIdentity,
    required this.senderName,
    this.text,
    this.reaction,
    this.raised,
    this.sentAt,
  });

  final String type;
  final String senderIdentity;
  final String senderName;
  final String? text;
  final String? reaction;
  final bool? raised;
  final DateTime? sentAt;

  @override
  List<Object?> get props => [
    type,
    senderIdentity,
    senderName,
    text,
    reaction,
    raised,
    sentAt,
  ];
}

class MeetingRoomJoinRequest extends Equatable {
  const MeetingRoomJoinRequest({
    required this.userId,
    required this.username,
    this.avatar,
  });

  final int userId;
  final String username;
  final String? avatar;

  @override
  List<Object?> get props => [userId, username, avatar];
}

class MeetingRealtimeMessage extends Equatable {
  const MeetingRealtimeMessage({
    required this.type,
    this.meetingId,
    this.title,
    this.requiresApproval,
    this.organizerJoined,
    this.isHost,
    this.isApproved,
    this.message,
    this.code,
    this.status,
    this.userId,
    this.username,
    this.avatar,
    this.token,
  });

  final String type;
  final int? meetingId;
  final String? title;
  final bool? requiresApproval;
  final bool? organizerJoined;
  final bool? isHost;
  final bool? isApproved;
  final String? message;
  final int? code;
  final String? status;
  final int? userId;
  final String? username;
  final String? avatar;
  final MeetingRoomToken? token;

  @override
  List<Object?> get props => [
    type,
    meetingId,
    title,
    requiresApproval,
    organizerJoined,
    isHost,
    isApproved,
    message,
    code,
    status,
    userId,
    username,
    avatar,
    token,
  ];
}

class MeetingMediaEvent extends Equatable {
  const MeetingMediaEvent({
    required this.type,
    this.participants = const [],
    this.microphoneEnabled,
    this.cameraEnabled,
    this.message,
    this.dataMessage,
    this.audioInputs = const [],
    this.audioOutputs = const [],
    this.videoInputs = const [],
  });

  final MeetingMediaEventType type;
  final List<MeetingRoomParticipant> participants;
  final bool? microphoneEnabled;
  final bool? cameraEnabled;
  final String? message;
  final MeetingRoomDataMessage? dataMessage;
  final List<MeetingMediaDevice> audioInputs;
  final List<MeetingMediaDevice> audioOutputs;
  final List<MeetingMediaDevice> videoInputs;

  @override
  List<Object?> get props => [
    type,
    participants,
    microphoneEnabled,
    cameraEnabled,
    message,
    dataMessage,
    audioInputs,
    audioOutputs,
    videoInputs,
  ];
}

class MeetingMediaDevice extends Equatable {
  const MeetingMediaDevice({
    required this.id,
    required this.label,
    required this.kind,
  });

  final String id;
  final String label;
  final String kind;

  @override
  List<Object?> get props => [id, label, kind];
}
