import 'package:equatable/equatable.dart';

abstract class MeetingDesignPreviewEvent extends Equatable {
  const MeetingDesignPreviewEvent();

  @override
  List<Object?> get props => const [];
}

class MeetingDesignApprovalChanged extends MeetingDesignPreviewEvent {
  const MeetingDesignApprovalChanged(this.value);

  final bool value;

  @override
  List<Object?> get props => [value];
}

class MeetingDesignProjectSelected extends MeetingDesignPreviewEvent {
  const MeetingDesignProjectSelected(this.value);

  final String? value;

  @override
  List<Object?> get props => [value];
}

class MeetingDesignParticipantsChanged extends MeetingDesignPreviewEvent {
  const MeetingDesignParticipantsChanged(this.values);

  final Set<String> values;

  @override
  List<Object?> get props => [values];
}

class MeetingDesignPreviewSubmitted extends MeetingDesignPreviewEvent {
  const MeetingDesignPreviewSubmitted();
}
