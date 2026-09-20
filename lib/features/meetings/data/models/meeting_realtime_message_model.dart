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
  });

  factory MeetingRealtimeMessageModel.fromJson(Map<String, dynamic> json) {
    int? intValue(dynamic value) {
      if (value is num) return value.toInt();
      return int.tryParse(value?.toString() ?? '');
    }

    bool? boolValue(dynamic value) => value is bool ? value : null;
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
      username: json['username']?.toString(),
      avatar: json['avatar']?.toString(),
      token: token,
    );
  }
}
