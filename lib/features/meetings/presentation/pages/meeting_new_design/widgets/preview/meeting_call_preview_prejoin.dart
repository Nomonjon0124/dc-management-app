import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:dc_management_app/config/theme/app_colors.dart';
import 'package:dc_management_app/core/extentions/text_extensions.dart';
import 'package:dc_management_app/core/gen/assets.gen.dart';
import 'package:dc_management_app/l10n/app_localizations.dart';
import 'package:dc_management_app/features/meetings/presentation/bloc/meeting_new_design/meeting_call_preview_state.dart';
import 'package:dc_management_app/features/meetings/presentation/theme/meeting_theme_colors.dart';
import '../common/meeting_ended_result.dart';
import 'meeting_call_preview_actions.dart';

class MeetingCallPreviewPrejoin extends StatelessWidget {
  const MeetingCallPreviewPrejoin({
    super.key,
    required this.phase,
    required this.microphoneOn,
    required this.cameraOn,
    required this.onMicrophone,
    required this.onCamera,
    required this.onJoin,
    required this.onCancel,
    required this.onApprove,
    required this.onClose,
    required this.onRejoin,
    required this.onHome,
  });

  final MeetingCallPreviewPhase phase;
  final bool microphoneOn;
  final bool cameraOn;
  final VoidCallback onMicrophone;
  final VoidCallback onCamera;
  final VoidCallback onJoin;
  final VoidCallback onCancel;
  final VoidCallback onApprove;
  final VoidCallback onClose;
  final VoidCallback onRejoin;
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) {
    if (phase == MeetingCallPreviewPhase.ended) {
      final l10n = AppLocalizations.of(context);
      return MeetingEndedResult(
        title: l10n.meetingCallMeetingEndedTitle,
        message: l10n.meetingCallMeetingEndedHint,
        rejoinLabel: l10n.meetingCallRejoin,
        homeLabel: l10n.meetingCallHome,
        onRejoin: onRejoin,
        onHome: onHome,
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final compactHeight = constraints.maxHeight < 600.h;
        final stageHeight = compactHeight
            ? constraints.maxHeight * 0.7
            : (constraints.maxHeight * 0.55).clamp(260.h, 400.h);
        final avatarSize = math.min(88.w, constraints.maxHeight * 0.22);
        final colors = AppColors.of(context);
        final l10n = AppLocalizations.of(context);
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.only(bottom: 12.h),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              children: [
                MeetingCallPreviewHeader(
                  title: phase == MeetingCallPreviewPhase.waiting
                      ? l10n.meetingCallWaitingTitle
                      : l10n.meetingCallJoinTitle,
                  onClose: onClose,
                ),
                SizedBox(height: 8.h),
                SizedBox(
                  height: stageHeight,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: colors.chartNeutral,
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Center(
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 16.h),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                MeetingCallPreviewActions.avatar(
                                  Assets.images.meetingSelf.path,
                                  avatarSize,
                                ),
                                SizedBox(height: 20.h),
                                l10n.meetingCallCameraOff
                                    .s(13.sp)
                                    .w(500)
                                    .c(colors.textDisabled),
                                SizedBox(height: 20.h),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    MeetingCallPreviewActions.circleAction(
                                      microphoneOn
                                          ? Assets.icons.meetingMic
                                          : Assets.icons.meetingMicOff,
                                      microphoneOn
                                          ? colors.meetingControlSurface
                                          : colors.errorStrong,
                                      microphoneOn
                                          ? colors.iconStrong
                                          : colors.iconWhite,
                                      onMicrophone,
                                      l10n.meetingCallMicrophone,
                                      size: math.min(
                                        48.w,
                                        constraints.maxHeight * 0.13,
                                      ),
                                      iconSize: math.min(
                                        20.w,
                                        constraints.maxHeight * 0.06,
                                      ),
                                    ),
                                    SizedBox(width: 12.w),
                                    MeetingCallPreviewActions.circleAction(
                                      cameraOn
                                          ? Assets.icons.meetingVideo
                                          : Assets.icons.meetingVideoOff,
                                      cameraOn
                                          ? colors.meetingControlSurface
                                          : colors.errorStrong,
                                      cameraOn
                                          ? colors.iconStrong
                                          : colors.iconWhite,
                                      onCamera,
                                      l10n.meetingCallCamera,
                                      size: math.min(
                                        48.w,
                                        constraints.maxHeight * 0.13,
                                      ),
                                      iconSize: math.min(
                                        20.w,
                                        constraints.maxHeight * 0.06,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 12.h),
                  child: phase == MeetingCallPreviewPhase.waiting
                      ? _WaitingPanel(onCancel: onCancel, onApprove: onApprove)
                      : _JoinPanel(onJoin: onJoin),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _JoinPanel extends StatelessWidget {
  const _JoinPanel({required this.onJoin});

  final VoidCallback onJoin;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        l10n.meetingCallSampleTitle.s(20.sp).w(800).c(colors.textStrong),
        SizedBox(height: 14.h),
        MeetingCallPreviewActions.surface(
          color: colors.backgroundElevation1Alt,
          child: InkWell(
            onTap: () {
              Clipboard.setData(const ClipboardData(text: 'rn-mtg-4821'));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.meetingCallCodeCopied)),
              );
            },
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
              child: Row(
                children: [
                  MeetingCallPreviewActions.icon(
                    Assets.icons.meetingCopy,
                    colors.iconStrong,
                    16.w,
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: 'rn-mtg-4821'.s(15.sp).w(800).c(colors.textStrong),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(height: 14.h),
        MeetingCallPreviewActions.button(
          l10n.meetingCallJoin,
          colors.accentStrong,
          colors.textWhite,
          onJoin,
          icon: Assets.icons.meetingJoin,
        ),
        SizedBox(height: 14.h),
        l10n.meetingCallApprovalHint.s(13.sp).w(500).c(colors.textSoft),
      ],
    );
  }
}

class _WaitingPanel extends StatelessWidget {
  const _WaitingPanel({required this.onCancel, required this.onApprove});

  final VoidCallback onCancel;
  final VoidCallback onApprove;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        Semantics(
          button: kDebugMode,
          label: l10n.meetingCallPreviewApprove,
          child: InkWell(
            onTap: kDebugMode ? onApprove : null,
            borderRadius: BorderRadius.circular(12.r),
            child: MeetingCallPreviewActions.surface(
              color: colors.backgroundElevation1Alt,
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Row(
                  children: [
                    MeetingCallPreviewActions.icon(
                      Assets.icons.icTuilconTime,
                      colors.iconStrong,
                      24.w,
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          l10n.meetingCallRequestSent
                              .s(15.sp)
                              .w(800)
                              .c(colors.textStrong),
                          SizedBox(height: 4.h),
                          l10n.meetingCallWaitingHint
                              .s(13.sp)
                              .w(500)
                              .c(colors.textSub),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 16.h),
        MeetingCallPreviewActions.button(
          l10n.meetingCallCancel,
          colors.meetingControlSurface,
          colors.textStrong,
          onCancel,
          icon: Assets.icons.icClose,
        ),
        if (kDebugMode) ...[
          SizedBox(height: 12.h),
          TextButton(
            onPressed: onApprove,
            child: Text(l10n.meetingCallPreviewApprove),
          ),
        ],
      ],
    );
  }
}
