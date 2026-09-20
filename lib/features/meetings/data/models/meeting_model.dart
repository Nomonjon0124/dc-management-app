import '../../../tasks/domain/entities/task_form_options.dart';
import '../../domain/entities/meeting.dart';

/// [Meeting] JSON serializatsiyasi (`/meetings/`).
///
/// Backend kontrakti to‘liq aniq emas — `project` va `organizer` int (id) yoki
/// ichma-ich (nested) obyekt bo‘lishi mumkin, shu bois har ikkisi ham bardoshli
/// o‘qiladi. `attended` — `meeting_attendance` ro‘yxatidan (agar berilgan
/// `currentUserId`ga mos yozuv topilsa) yoki tekis `attended`/`is_attended`
/// maydonidan olinadi.
class MeetingModel extends Meeting {
  const MeetingModel({
    required super.id,
    required super.title,
    required super.uid,
    super.projectId,
    required super.projectName,
    super.description,
    super.link,
    super.penaltyPercentage,
    required super.startDate,
    super.durationMinutes,
    super.organizerId,
    required super.organizerName,
    required super.organizerRole,
    super.participantIds,
    super.participantsInfo,
    required super.participantName,
    required super.participantPosition,
    super.participantAvatar,
    required super.isCompleted,
    required super.reason,
    required super.attended,
    super.requiresApproval,
  });

  factory MeetingModel.fromJson(
    Map<String, dynamic> json, {
    int? currentUserId,
  }) {
    String str(dynamic v) => v?.toString() ?? '';

    String pick(List<String> keys, [Map<String, dynamic>? src]) {
      final map = src ?? json;
      for (final k in keys) {
        final v = map[k];
        if (v != null && v.toString().isNotEmpty) return v.toString();
      }
      return '';
    }

    int? intValue(dynamic value) {
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value);
      return null;
    }

    // ── Project nomi: nested {name/title} yoki tekis project_name ──────────
    String projectName() {
      final p = json['project'];
      if (p is Map) return pick(['name', 'title'], p.cast<String, dynamic>());
      return pick(['project_name', 'project_title']);
    }

    int? projectId() {
      final p = json['project'];
      if (p is Map) return intValue(p['id']);
      return intValue(p);
    }

    // Sxemada `participants` writeOnly (javobda kelmaydi) — qatnashchilar
    // `participants_info`dan (UserShort ro'yxati) o'qiladi.
    List<ProjectMember> participantsInfo() {
      final list = json['participants_info'];
      if (list is! List) return const [];
      return [
        for (final e in list)
          if (e is Map)
            ProjectMember(
              id: intValue(e['id']) ?? 0,
              username: pick([
                'username',
                'full_name',
                'name',
              ], e.cast<String, dynamic>()),
              position: pick(['position'], e.cast<String, dynamic>()),
              avatar: pick(['avatar'], e.cast<String, dynamic>()),
            ),
      ];
    }

    List<int> participantIds(List<ProjectMember> info) {
      final participants = json['participants'];
      if (participants is List) {
        final ids = participants.map(intValue).whereType<int>().toList();
        if (ids.isNotEmpty) return ids;
      }
      return [for (final m in info) m.id];
    }

    // ── Organizer: nested {full_name/username, role/position} ──────────────
    final organizer = json['organizer'];
    final orgMap = organizer is Map
        ? organizer.cast<String, dynamic>()
        : const {};
    final organizerName = orgMap.isNotEmpty
        ? pick([
            'full_name',
            'name',
            'username',
          ], orgMap.cast<String, dynamic>())
        : pick(['organizer_name']);
    final organizerRole = orgMap.isNotEmpty
        ? pick([
            'role',
            'active_role',
            'position',
          ], orgMap.cast<String, dynamic>())
        : pick(['organizer_role']);

    final organizerId = orgMap.isNotEmpty
        ? intValue(orgMap['id'])
        : intValue(organizer);

    Map<String, dynamic> organizerParticipantInfo() {
      final participants = json['participants_info'];
      if (participants is List) {
        for (final participant in participants) {
          if (participant is! Map) continue;
          final participantMap = participant.cast<String, dynamic>();
          if (intValue(participantMap['id']) == organizerId) {
            return participantMap;
          }
        }
      }
      return const <String, dynamic>{};
    }

    final participantMap = organizerParticipantInfo();
    final participantName = participantMap.isNotEmpty
        ? pick(['username', 'full_name', 'name'], participantMap)
        : pick(['participant_name']);
    final participantPosition = participantMap.isNotEmpty
        ? pick(['position'], participantMap)
        : pick(['participant_position']);
    final participantAvatar = participantMap.isNotEmpty
        ? pick(['avatar'], participantMap)
        : pick(['participant_avatar']);

    // ── Attendance: joriy foydalanuvchining yozuvi ─────────────────────────
    bool? attended() {
      final list = json['meeting_attendance'];
      if (list is List) {
        for (final e in list) {
          if (e is! Map) continue;
          final m = e.cast<String, dynamic>();
          final uid = (m['user'] is Map)
              ? (m['user']['id'] as num?)?.toInt()
              : (m['user'] as num?)?.toInt();
          if (currentUserId != null && uid != currentUserId) continue;
          final a = m['is_attended'] ?? m['attended'];
          if (a is bool) return a;
          // Agar currentUserId berilmagan bo‘lsa — birinchi yozuvni olamiz.
          if (currentUserId == null && a is bool) return a;
        }
      }
      final flat = json['attended'] ?? json['is_attended'];
      if (flat is bool) return flat;
      return null;
    }

    final info = participantsInfo();

    return MeetingModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: pick(['title', 'name']),
      uid: pick(['uid', 'code', 'meeting_uid']),
      projectId: projectId(),
      projectName: projectName(),
      description: str(json['description']),
      link: str(json['link']),
      penaltyPercentage: json['penalty_percentage']?.toString(),
      startDate: DateTime.tryParse(
        pick(['start_time', 'start_date', 'date', 'datetime']),
      ),
      durationMinutes: intValue(json['duration_minutes']),
      organizerId: organizerId,
      organizerName: organizerName,
      organizerRole: organizerRole,
      participantIds: participantIds(info),
      participantsInfo: info,
      participantName: participantName,
      participantPosition: participantPosition,
      participantAvatar: participantAvatar,
      isCompleted:
          (json['is_completed'] as bool?) ??
          (json['is_complate'] as bool?) ??
          false,
      reason: str(json['reason']),
      attended: attended(),
      requiresApproval: json['requires_approval'] is bool
          ? json['requires_approval'] as bool
          : null,
    );
  }
}
