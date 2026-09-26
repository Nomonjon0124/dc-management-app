import '../../domain/entities/meeting_room.dart';

class MeetingRealtimeMessageModel extends MeetingRealtimeMessage {
  const MeetingRealtimeMessageModel({
    required super.type,
    super.meetingId,
    super.title,
    super.requiresApproval,
    super.organizerJoined,
    super.isHost,
    super.isApproved,
    super.message,
    super.code,
    super.status,
    super.userId,
    super.username,
    super.avatar,
    super.token,
    super.requestId,
    super.targetIdentity,
    super.trackSource,
    super.muted,
    super.actorUserId,
    super.raised,
    super.raisedAt,
    super.reaction,
    super.expiresAt,
    super.fromUserId,
    super.fromName,
  });

  factory MeetingRealtimeMessageModel.fromJson(Map<String, dynamic> json) {
    int? intValue(dynamic value) {
      if (value is num) return value.toInt();
      return int.tryParse(value?.toString() ?? '');
    }

    bool? boolValue(dynamic value) => value is bool ? value : null;
    DateTime? dateValue(dynamic value) =>
        DateTime.tryParse(value?.toString() ?? '');
    final tokenMap = json['token'] is Map
        ? (json['token'] as Map).cast<String, dynamic>()
        : json;
    final serverUrl = tokenMap['server_url']?.toString();
    final roomName = tokenMap['room_name']?.toString();
    final tokenValue = tokenMap['token']?.toString();
    final token =
        serverUrl != null &&
            serverUrl.isNotEmpty &&
            roomName != null &&
            roomName.isNotEmpty &&
            tokenValue != null &&
            tokenValue.isNotEmpty
        ? MeetingRoomToken(
            serverUrl: serverUrl,
            roomName: roomName,
            token: tokenValue,
          )
        : null;

    return MeetingRealtimeMessageModel(
      type: json['type']?.toString() ?? 'unknown',
      meetingId: intValue(json['meeting_id']),
      title: json['title']?.toString(),
      requiresApproval: boolValue(json['requires_approval']),
      organizerJoined: boolValue(json['organizer_joined']),
      isHost: boolValue(json['is_host']),
      isApproved: boolValue(json['is_approved']),
      message: json['message']?.toString(),
      code: intValue(json['code']),
      status: json['status']?.toString(),
      userId: intValue(json['user_id']),
      username: (json['username'] ?? json['full_name'])?.toString(),
      avatar: json['avatar']?.toString(),
      token: token,
      requestId: json['request_id']?.toString(),
      targetIdentity: json['target_identity']?.toString(),
      trackSource: json['track_source']?.toString(),
      muted: boolValue(json['muted']),
      actorUserId: intValue(json['actor_user_id']),
      raised: boolValue(json['raised']),
      raisedAt: dateValue(json['raised_at'] ?? json['sent_at']),
      reaction: json['reaction']?.toString(),
      expiresAt: dateValue(json['expires_at']),
      fromUserId: intValue(json['from_user_id']),
      fromName: json['from_name']?.toString(),
    );
  }
}
