/// Full request body for `POST /meetings/` and `PUT /meetings/{id}/`.
///
/// Meeting links are not client-managed. The backend generates the meeting
/// UID/room when the record is created, so [link] remains only as a
/// backwards-compatible value for old callers and is omitted from requests.
class MeetingForm {
  const MeetingForm({
    this.project,
    required this.title,
    required this.description,
    this.link = '',
    this.penaltyPercentage,
    required this.startTime,
    required this.durationMinutes,
    this.participants = const [],
    this.requiresApproval = false,
  });

  final int? project;
  final String title;
  final String description;
  final String link;
  final String? penaltyPercentage;
  final DateTime startTime;
  final int durationMinutes;
  final List<int> participants;
  final bool requiresApproval;
}

/// Partial request body for `PATCH /meetings/{id}/`.
class MeetingPatch {
  const MeetingPatch({
    this.project,
    this.title,
    this.description,
    this.link,
    this.penaltyPercentage,
    this.startTime,
    this.durationMinutes,
    this.participants,
    this.requiresApproval,
  });

  final int? project;
  final String? title;
  final String? description;
  final String? link;
  final String? penaltyPercentage;
  final DateTime? startTime;
  final int? durationMinutes;
  final List<int>? participants;
  final bool? requiresApproval;
}
