import 'dart:collection';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'meeting_call_preview_event.dart';
import 'meeting_call_preview_state.dart';

class MeetingCallPreviewBloc
    extends Bloc<MeetingCallPreviewEvent, MeetingCallPreviewState> {
  MeetingCallPreviewBloc() : super(const MeetingCallPreviewState()) {
    on<MeetingCallJoinRequested>(
      (_, emit) => emit(state.copyWith(phase: MeetingCallPreviewPhase.waiting)),
    );
    on<MeetingCallApproved>(
      (_, emit) => emit(state.copyWith(phase: MeetingCallPreviewPhase.call)),
    );
    on<MeetingCallCancelled>(
      (_, emit) => emit(state.copyWith(phase: MeetingCallPreviewPhase.prejoin)),
    );
    on<MeetingCallLeaveRequested>(
      (_, emit) => emit(state.copyWith(phase: MeetingCallPreviewPhase.ended)),
    );
    on<MeetingCallRejoinRequested>(
      (_, emit) => emit(state.copyWith(phase: MeetingCallPreviewPhase.call)),
    );
    on<MeetingCallMicrophoneToggled>(
      (_, emit) => emit(state.copyWith(microphoneOn: !state.microphoneOn)),
    );
    on<MeetingCallCameraToggled>(
      (_, emit) => emit(state.copyWith(cameraOn: !state.cameraOn)),
    );
    on<MeetingCallHandToggled>(
      (_, emit) => emit(state.copyWith(handRaised: !state.handRaised)),
    );
    on<MeetingCallGridToggled>(
      (_, emit) => emit(state.copyWith(speakerGrid: !state.speakerGrid)),
    );
    on<MeetingCallJoinRequestToggled>(
      (_, emit) => emit(state.copyWith(joinRequest: !state.joinRequest)),
    );
    on<MeetingCallScreenSharingChanged>(
      (event, emit) => emit(state.copyWith(screenSharing: event.value)),
    );
    on<MeetingCallStickerPanelToggled>(
      (_, emit) => emit(state.copyWith(stickersOpen: !state.stickersOpen)),
    );
    on<MeetingCallStickerSelected>(_onStickerSelected);
    on<MeetingCallSheetOpened>(
      (event, emit) => emit(state.copyWith(activeSheet: event.sheet)),
    );
    on<MeetingCallSheetClosed>(
      (_, emit) => emit(state.copyWith(clearActiveSheet: true)),
    );
    on<MeetingCallMicrophoneDeviceSelected>(
      (event, emit) => emit(state.copyWith(microphoneDevice: event.device)),
    );
    on<MeetingCallSpeakerDeviceSelected>(
      (event, emit) => emit(state.copyWith(speakerDevice: event.device)),
    );
    on<MeetingCallCameraSelected>(
      (event, emit) => emit(state.copyWith(frontCamera: event.front)),
    );
    on<MeetingCallBackgroundSelected>(
      (event, emit) => emit(state.copyWith(blurBackground: event.blur)),
    );
    on<MeetingCallParticipantSearchChanged>(
      (event, emit) => emit(state.copyWith(participantSearch: event.query)),
    );
    on<MeetingCallChatMessageSent>(_onMessageSent);
    on<MeetingCallPermissionAccepted>(_onPermissionAccepted);
  }

  void _onStickerSelected(
    MeetingCallStickerSelected event,
    Emitter<MeetingCallPreviewState> emit,
  ) {
    final reactions = List<String>.from(state.reactions)..add(event.sticker);
    if (reactions.length > 3) reactions.removeAt(0);
    emit(
      state.copyWith(
        reactions: UnmodifiableListView(reactions),
        stickersOpen: false,
      ),
    );
  }

  void _onMessageSent(
    MeetingCallChatMessageSent event,
    Emitter<MeetingCallPreviewState> emit,
  ) {
    final message = event.message.trim();
    if (message.isEmpty) return;
    emit(
      state.copyWith(
        messages: UnmodifiableListView([...state.messages, message]),
      ),
    );
  }

  void _onPermissionAccepted(
    MeetingCallPermissionAccepted event,
    Emitter<MeetingCallPreviewState> emit,
  ) {
    emit(
      state.copyWith(
        cameraOn: event.camera ? true : state.cameraOn,
        microphoneOn: event.camera ? state.microphoneOn : true,
      ),
    );
  }
}
