/// Full request body for `POST /meetings/` and `PUT /meetings/{id}/`.
class MeetingForm {
  const MeetingForm({
    this.project,
    required this.title,
    required this.description,
    required this.link,
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
