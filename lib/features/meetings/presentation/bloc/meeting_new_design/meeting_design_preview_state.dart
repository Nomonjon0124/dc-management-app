import 'package:equatable/equatable.dart';

class MeetingDesignPreviewState extends Equatable {
  const MeetingDesignPreviewState({
    this.requiresApproval = false,
    this.project,
    this.participants = const <String>{},
    this.submitted = false,
  });

  final bool requiresApproval;
  final String? project;
  final Set<String> participants;
  final bool submitted;

  MeetingDesignPreviewState copyWith({
    bool? requiresApproval,
    String? project,
    bool clearProject = false,
    Set<String>? participants,
    bool? submitted,
  }) {
    return MeetingDesignPreviewState(
      requiresApproval: requiresApproval ?? this.requiresApproval,
      project: clearProject ? null : project ?? this.project,
      participants: participants ?? this.participants,
      submitted: submitted ?? this.submitted,
    );
  }

  @override
  List<Object?> get props => [
    requiresApproval,
    project,
    participants,
    submitted,
  ];
}
