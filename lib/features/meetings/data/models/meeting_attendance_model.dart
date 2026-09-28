import '../../domain/entities/meeting_attendance.dart';
import 'meeting_date_parser.dart';

/// [MeetingAttendance] JSON serializatsiyasi (`/meeting-attendance/`).
class MeetingAttendanceModel extends MeetingAttendance {
  const MeetingAttendanceModel({
    required super.id,
    required super.meetingId,
    required super.meetingTitle,
    required super.isAttended,
    required super.isExcused,
    required super.absenceReason,
    required super.userId,
    super.userName,
    super.userPosition,
    super.userAvatar,
    super.meetingStartTime,
    super.joinedAt,
    super.leftAt,
    super.durationMinutes,
    super.lateMinutes,
    super.reasonDeadline,
    super.canSubmitReason,
  });

  factory MeetingAttendanceModel.fromJson(Map<String, dynamic> json) {
    final userInfo = json['user_info'];
    final userMap = userInfo is Map
        ? userInfo.cast<String, dynamic>()
        : const <String, dynamic>{};
    final userId = userMap.isNotEmpty
        ? (userMap['id'] as num?)?.toInt()
        : (json['user'] as num?)?.toInt();

    String pick(List<String> keys) {
      for (final k in keys) {
        final v = userMap[k];
        if (v != null && v.toString().isNotEmpty) return v.toString();
      }
      return '';
    }

    return MeetingAttendanceModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      meetingId: (json['meeting'] as num?)?.toInt(),
      meetingTitle: json['meeting_title']?.toString() ?? '',
      isAttended: (json['is_attended'] as bool?) ?? false,
      isExcused: (json['is_excused'] as bool?) ?? false,
      absenceReason: json['absence_reason']?.toString() ?? '',
      userId: userId,
      userName: pick(['username', 'full_name', 'name']),
      userPosition: pick(['position']),
      userAvatar: pick(['avatar']),
      meetingStartTime: parseMeetingWallClock(
        json['meeting_start_time']?.toString() ?? '',
      ),
      joinedAt: DateTime.tryParse(json['joined_at']?.toString() ?? ''),
      leftAt: DateTime.tryParse(json['left_at']?.toString() ?? ''),
      durationMinutes: (json['duration_minutes'] as num?)?.toInt() ?? 0,
      lateMinutes: (json['late_minutes'] as num?)?.toInt() ?? 0,
      reasonDeadline: DateTime.tryParse(
        json['reason_deadline']?.toString() ?? '',
      ),
      canSubmitReason: json['can_submit_reason'] as bool? ?? false,
    );
  }
}
