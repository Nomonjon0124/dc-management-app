import 'package:equatable/equatable.dart';

import '../../../tasks/domain/entities/task_form_options.dart';

/// Bitta yig‘ilish (`/meetings/`).
///
/// Backend kontrakti to‘liq tasdiqlanmagan (loyiha hujjatlari bilan farq
/// qilishi mumkin) — [MeetingModel.fromJson] bir nechta nomzod kalitni
/// bardoshli o‘qiydi. Bu yerda UI ko‘rsatadigan maydonlar to‘plangan.
class Meeting extends Equatable {
  const Meeting({
    required this.id,
    required this.title,
    required this.uid,
    this.projectId,
    required this.projectName,
    this.description = '',
    this.link = '',
    this.penaltyPercentage,
    required this.startDate,
    this.durationMinutes,
    this.organizerId,
    required this.organizerName,
    required this.organizerRole,
    this.participantIds = const [],
    this.participantsInfo = const [],
    required this.participantName,
    required this.participantPosition,
    this.participantAvatar = '',
    required this.isCompleted,
    required this.reason,
    required this.attended,
    this.requiresApproval,
  });

  final int id;

  /// Yig‘ilish nomi (masalan "Dashboard redesign").
  final String title;

  /// Ko‘rsatiladigan UID (masalan "M12575") — bo‘lmasa bo‘sh.
  final String uid;

  final int? projectId;

  /// Tegishli loyiha nomi (kartada ost-yozuv).
  final String projectName;

  final String description;
  final String link;
  final String? penaltyPercentage;

  /// Boshlanish vaqti.
  final DateTime? startDate;

  final int? durationMinutes;

  /// Tashkilotchi id (`organizer`) — joriy foydalanuvchi tashkilotchi
  /// bo'lsa detail'da "yakunlash" oqimi ochiladi.
  final int? organizerId;

  /// Tashkilotchi ismi + roli (karta pastki qatori).
  final String organizerName;
  final String organizerRole;

  final List<int> participantIds;

  /// Qatnashchilar ro'yxati (`participants_info`, UserShort) — `participants`
  /// writeOnly, javobda kelmaydi; ko'rsatish uchun shu ishlatiladi.
  final List<ProjectMember> participantsInfo;

  final String participantName;
  final String participantPosition;
  final String participantAvatar;

  final bool isCompleted;

  /// Qatnashmaslik sababi (bo‘lsa).
  final String reason;

  /// Joriy foydalanuvchi qatnashganmi: `true` (qatnashdi) / `false`
  /// (qatnashmadi) / `null` (noma‘lum) — kartadagi nishonni tanlaydi.
  final bool? attended;

  /// Tashkilotchi tasdig‘i talab qilinadimi. Eski response’larda yo‘q bo‘lishi
  /// mumkin, shu sababli nullable saqlanadi.
  final bool? requiresApproval;

  @override
  List<Object?> get props => [
    id,
    title,
    uid,
    projectId,
    projectName,
    description,
    link,
    penaltyPercentage,
    startDate,
    durationMinutes,
    organizerId,
    organizerName,
    organizerRole,
    participantIds,
    participantsInfo,
    participantName,
    participantPosition,
    participantAvatar,
    isCompleted,
    reason,
    attended,
    requiresApproval,
  ];
}
