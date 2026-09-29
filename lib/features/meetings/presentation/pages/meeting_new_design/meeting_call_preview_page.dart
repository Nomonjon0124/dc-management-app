import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../config/theme/app_colors.dart';
import '../../../../../core/gen/assets.gen.dart';
import '../../../../../injection_container.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../bloc/meeting_new_design/meeting_call_preview_bloc.dart';
import '../../bloc/meeting_new_design/meeting_call_preview_event.dart';
import '../../bloc/meeting_new_design/meeting_call_preview_state.dart';
import 'widgets/sheets/meeting_permission_dialog.dart';
import 'widgets/preview/meeting_call_preview_prejoin.dart';
import 'widgets/preview/meeting_call_preview_sheet_host.dart';
import 'widgets/preview/meeting_call_preview_stage.dart';

/// UI-only meeting walkthrough; media and moderation are not connected yet.
///
/// This page owns only BLoC wiring and phase routing. Preview presentation is
/// split into prejoin, stage, and sheet-host widgets.
class MeetingCallPreviewPage extends StatelessWidget {
  const MeetingCallPreviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt.isRegistered<MeetingCallPreviewBloc>()
          ? getIt<MeetingCallPreviewBloc>()
          : MeetingCallPreviewBloc(),
      child: const _MeetingCallPreviewView(),
    );
  }
}

class _MeetingCallPreviewView extends StatefulWidget {
  const _MeetingCallPreviewView();

  @override
  State<_MeetingCallPreviewView> createState() =>
      _MeetingCallPreviewViewState();
}

class _MeetingCallPreviewViewState extends State<_MeetingCallPreviewView> {
  late final MeetingCallPreviewBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = context.read<MeetingCallPreviewBloc>();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MeetingCallPreviewBloc, MeetingCallPreviewState>(
      builder: (context, state) {
        final colors = AppColors.of(context);
        return Scaffold(
          backgroundColor: colors.backgroundElevation1,
          body: SafeArea(
            child: state.phase == MeetingCallPreviewPhase.call
                ? MeetingCallPreviewStage(
                    state: state,
                    onGrid: () => _bloc.add(const MeetingCallGridToggled()),
                    onJoinRequest: () =>
                        _bloc.add(const MeetingCallJoinRequestToggled()),
                    onSticker: () =>
                        _bloc.add(const MeetingCallStickerPanelToggled()),
                    onStickerSelected: (sticker) =>
                        _bloc.add(MeetingCallStickerSelected(sticker)),
                    onStickerClosed: () =>
                        _bloc.add(const MeetingCallStickerPanelToggled()),
                    onMicrophone: () =>
                        _bloc.add(const MeetingCallMicrophoneToggled()),
                    onCamera: () => _bloc.add(const MeetingCallCameraToggled()),
                    onHand: () => _bloc.add(const MeetingCallHandToggled()),
                    onMore: () => _showSheet(MeetingCallPreviewSheet.more),
                    onLeave: () => _showSheet(MeetingCallPreviewSheet.exit),
                    onMicrophoneMenu: () =>
                        _showSheet(MeetingCallPreviewSheet.devices),
                    onCameraMenu: () =>
                        _showSheet(MeetingCallPreviewSheet.camera),
                    onExit: () => _showSheet(MeetingCallPreviewSheet.exit),
                    onParticipants: () =>
                        _showSheet(MeetingCallPreviewSheet.participants),
                  )
                : MeetingCallPreviewPrejoin(
                    phase: state.phase,
                    microphoneOn: state.microphoneOn,
                    cameraOn: state.cameraOn,
                    onMicrophone: () =>
                        _bloc.add(const MeetingCallMicrophoneToggled()),
                    onCamera: () => _bloc.add(const MeetingCallCameraToggled()),
                    onJoin: () => _bloc.add(const MeetingCallJoinRequested()),
                    onCancel: () => _bloc.add(const MeetingCallCancelled()),
                    onApprove: () => _bloc.add(const MeetingCallApproved()),
                    onClose: () => Navigator.of(context).maybePop(),
                    onRejoin: () => _bloc.add(const MeetingCallApproved()),
                    onHome: () => Navigator.of(context).maybePop(),
                  ),
          ),
        );
      },
    );
  }

  Future<void> _showSheet(
    MeetingCallPreviewSheet sheet, {
    bool includeEndForEveryone = true,
  }) async {
    _bloc.add(MeetingCallSheetOpened(sheet));
    await MeetingCallPreviewSheetHost.show(
      context,
      sheet: sheet,
      state: _bloc.state,
      onEvent: _bloc.add,
      onSheet: (nextSheet) => _showSheet(nextSheet),
      onPermission: _showPermissionDialog,
      includeEndForEveryone: includeEndForEveryone,
    );
    if (mounted) _bloc.add(const MeetingCallSheetClosed());
  }

  Future<void> _showPermissionDialog({required bool camera}) async {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);
    await showDialog<void>(
      context: context,
      barrierColor: colors.black.withValues(alpha: 0.5),
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
        child: MeetingPermissionDialog(
          title: camera
              ? l10n.meetingCallCameraRequestTitle
              : l10n.meetingCallMicRequestTitle,
          requesterName: l10n.meetingCallRequester,
          requesterRole: l10n.meetingCallOrganizerRequested,
          message: camera
              ? l10n.meetingCallCameraRequestHint
              : l10n.meetingCallMicRequestHint,
          declineLabel: l10n.meetingCallNotNow,
          enableLabel: camera
              ? l10n.meetingCallEnableCamera
              : l10n.meetingCallEnableMicrophone,
          permissionIcon: camera
              ? Assets.icons.meetingVideo
              : Assets.icons.meetingMic,
          enableIcon: camera
              ? Assets.icons.meetingVideo
              : Assets.icons.meetingMic,
          onDecline: () => Navigator.pop(dialogContext),
          onEnable: () {
            _bloc.add(MeetingCallPermissionAccepted(camera: camera));
            Navigator.pop(dialogContext);
          },
        ),
      ),
    );
  }
}
