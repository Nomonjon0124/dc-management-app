import 'dart:collection';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'meeting_design_preview_event.dart';
import 'meeting_design_preview_state.dart';

class MeetingDesignPreviewBloc
    extends Bloc<MeetingDesignPreviewEvent, MeetingDesignPreviewState> {
  MeetingDesignPreviewBloc({bool requiresApproval = false, String? project})
    : super(
        MeetingDesignPreviewState(
          requiresApproval: requiresApproval,
          project: project,
        ),
      ) {
    on<MeetingDesignApprovalChanged>(
      (event, emit) => emit(state.copyWith(requiresApproval: event.value)),
    );
    on<MeetingDesignProjectSelected>(
      (event, emit) => emit(
        event.value == null
            ? state.copyWith(clearProject: true)
            : state.copyWith(project: event.value),
      ),
    );
    on<MeetingDesignParticipantsChanged>(
      (event, emit) =>
          emit(state.copyWith(participants: UnmodifiableSetView(event.values))),
    );
    on<MeetingDesignPreviewSubmitted>(
      (_, emit) => emit(state.copyWith(submitted: true)),
    );
  }
}
