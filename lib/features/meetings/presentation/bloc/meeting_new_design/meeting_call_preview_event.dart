import 'package:equatable/equatable.dart';

import 'meeting_call_preview_state.dart';

abstract class MeetingCallPreviewEvent extends Equatable {
  const MeetingCallPreviewEvent();

  @override
  List<Object?> get props => const [];
}

class MeetingCallJoinRequested extends MeetingCallPreviewEvent {
  const MeetingCallJoinRequested();
}

class MeetingCallApproved extends MeetingCallPreviewEvent {
  const MeetingCallApproved();
}

class MeetingCallCancelled extends MeetingCallPreviewEvent {
  const MeetingCallCancelled();
}

class MeetingCallLeaveRequested extends MeetingCallPreviewEvent {
  const MeetingCallLeaveRequested();
}

class MeetingCallRejoinRequested extends MeetingCallPreviewEvent {
  const MeetingCallRejoinRequested();
}

class MeetingCallMicrophoneToggled extends MeetingCallPreviewEvent {
  const MeetingCallMicrophoneToggled();
}

class MeetingCallCameraToggled extends MeetingCallPreviewEvent {
  const MeetingCallCameraToggled();
}

class MeetingCallHandToggled extends MeetingCallPreviewEvent {
  const MeetingCallHandToggled();
}

class MeetingCallGridToggled extends MeetingCallPreviewEvent {
  const MeetingCallGridToggled();
}

class MeetingCallJoinRequestToggled extends MeetingCallPreviewEvent {
  const MeetingCallJoinRequestToggled();
}

class MeetingCallScreenSharingChanged extends MeetingCallPreviewEvent {
  const MeetingCallScreenSharingChanged(this.value);

  final bool value;

  @override
  List<Object?> get props => [value];
}

class MeetingCallStickerPanelToggled extends MeetingCallPreviewEvent {
  const MeetingCallStickerPanelToggled();
}

class MeetingCallStickerSelected extends MeetingCallPreviewEvent {
  const MeetingCallStickerSelected(this.sticker);

  final String sticker;

  @override
  List<Object?> get props => [sticker];
}

class MeetingCallSheetOpened extends MeetingCallPreviewEvent {
  const MeetingCallSheetOpened(this.sheet);

  final MeetingCallPreviewSheet sheet;

  @override
  List<Object?> get props => [sheet];
}

class MeetingCallSheetClosed extends MeetingCallPreviewEvent {
  const MeetingCallSheetClosed();
}

class MeetingCallMicrophoneDeviceSelected extends MeetingCallPreviewEvent {
  const MeetingCallMicrophoneDeviceSelected(this.device);

  final String device;

  @override
  List<Object?> get props => [device];
}

class MeetingCallSpeakerDeviceSelected extends MeetingCallPreviewEvent {
  const MeetingCallSpeakerDeviceSelected(this.device);

  final String device;

  @override
  List<Object?> get props => [device];
}

class MeetingCallCameraSelected extends MeetingCallPreviewEvent {
  const MeetingCallCameraSelected(this.front);

  final bool front;

  @override
  List<Object?> get props => [front];
}

class MeetingCallBackgroundSelected extends MeetingCallPreviewEvent {
  const MeetingCallBackgroundSelected(this.blur);

  final bool blur;

  @override
  List<Object?> get props => [blur];
}

class MeetingCallParticipantSearchChanged extends MeetingCallPreviewEvent {
  const MeetingCallParticipantSearchChanged(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}

class MeetingCallChatMessageSent extends MeetingCallPreviewEvent {
  const MeetingCallChatMessageSent(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class MeetingCallPermissionAccepted extends MeetingCallPreviewEvent {
  const MeetingCallPermissionAccepted({required this.camera});

  final bool camera;

  @override
  List<Object?> get props => [camera];
}
