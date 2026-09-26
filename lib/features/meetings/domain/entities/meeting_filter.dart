import 'package:equatable/equatable.dart';

/// Query params for `GET /meetings/`.
class MeetingFilter extends Equatable {
  const MeetingFilter({
    this.isCompleted,
    this.ordering,
    this.organizerId,
    this.page,
    this.projectId,
    this.search,
    this.uid,
    this.startDateGte,
    this.startDateLte,
  });

  static const empty = MeetingFilter();

  final bool? isCompleted;
  final String? ordering;
  final int? organizerId;
  final int? page;
  final int? projectId;
  final String? search;
  final String? uid;
  final DateTime? startDateGte;
  final DateTime? startDateLte;

  bool get hasActiveFilters =>
      isCompleted != null ||
      organizerId != null ||
      projectId != null ||
      uid != null ||
      startDateGte != null ||
      startDateLte != null;

  MeetingFilter copyWithSearch(String search) => MeetingFilter(
    isCompleted: isCompleted,
    ordering: ordering,
    organizerId: organizerId,
    page: page,
    projectId: projectId,
    search: search,
    uid: uid,
    startDateGte: startDateGte,
    startDateLte: startDateLte,
  );

  MeetingFilter copyWithFilters({
    bool? isCompleted,
    int? organizerId,
    int? projectId,
    DateTime? startDateGte,
    DateTime? startDateLte,
  }) => MeetingFilter(
    isCompleted: isCompleted,
    ordering: ordering,
    organizerId: organizerId,
    page: page,
    projectId: projectId,
    search: search,
    uid: uid,
    startDateGte: startDateGte,
    startDateLte: startDateLte,
  );

  @override
  List<Object?> get props => [
    isCompleted,
    ordering,
    organizerId,
    page,
    projectId,
    search,
    uid,
    startDateGte,
    startDateLte,
  ];
}
