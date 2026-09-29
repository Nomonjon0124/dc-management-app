import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:dc_management_app/config/theme/app_colors.dart';
import 'package:dc_management_app/core/extentions/text_extensions.dart';
import 'package:dc_management_app/core/gen/assets.gen.dart';
import 'package:dc_management_app/l10n/app_localizations.dart';
import 'package:dc_management_app/features/meetings/presentation/bloc/meeting_new_design/meeting_call_preview_state.dart';
import 'package:dc_management_app/features/meetings/presentation/theme/meeting_theme_colors.dart';
import '../call/meeting_call_control_bar.dart';
import '../call/meeting_call_join_request.dart';
import '../call/meeting_call_participant_tile.dart';
import '../call/meeting_call_stickers_panel.dart';
import 'meeting_call_preview_actions.dart';

class MeetingCallPreviewStage extends StatelessWidget {
  const MeetingCallPreviewStage({
    super.key,
    required this.state,
    required this.onGrid,
    required this.onJoinRequest,
    required this.onSticker,
    required this.onStickerSelected,
    required this.onStickerClosed,
    required this.onMicrophone,
    required this.onCamera,
    required this.onHand,
    required this.onMore,
    required this.onLeave,
    required this.onMicrophoneMenu,
    required this.onCameraMenu,
    required this.onExit,
    required this.onParticipants,
  });

  final MeetingCallPreviewState state;
  final VoidCallback onGrid;
  final VoidCallback onJoinRequest;
  final VoidCallback onSticker;
  final ValueChanged<String> onStickerSelected;
  final VoidCallback onStickerClosed;
  final VoidCallback onMicrophone;
  final VoidCallback onCamera;
  final VoidCallback onHand;
  final VoidCallback onMore;
  final VoidCallback onLeave;
  final VoidCallback onMicrophoneMenu;
  final VoidCallback onCameraMenu;
  final VoidCallback onExit;
  final VoidCallback onParticipants;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(20.w, 8.h, 16.w, 8.h),
          child: Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: onJoinRequest,
                  child: Row(
                    children: [
                      Flexible(
                        child: l10n.meetingCallName
                            .s(13.sp)
                            .w(800)
                            .c(colors.textStrong),
                      ),
                      SizedBox(width: 8.w),
                      MeetingCallPreviewActions.icon(
                        Assets.icons.meetingInfo,
                        colors.iconStrong,
                        16.w,
                      ),
                    ],
                  ),
                ),
              ),
              MeetingCallPreviewActions.circleAction(
                Assets.icons.meetingPower,
                colors.errorSub,
                colors.iconWhite,
                onExit,
                l10n.meetingCallEnd,
                size: 32.w,
                iconSize: 18.w,
              ),
              SizedBox(width: 8.w),
              MeetingCallPreviewActions.circleAction(
                Assets.icons.meetingSticker,
                colors.meetingControlSurface,
                colors.iconStrong,
                onSticker,
                l10n.meetingCallStickers,
                size: 32.w,
                iconSize: 18.w,
              ),
              SizedBox(width: 8.w),
              InkWell(
                onTap: onParticipants,
                borderRadius: BorderRadius.circular(999.r),
                child: MeetingCallPreviewActions.surface(
                  color: colors.meetingControlSurface,
                  radius: 999.r,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 6.h,
                    ),
                    child: Row(
                      children: [
                        MeetingCallPreviewActions.icon(
                          Assets.icons.icUserGroup,
                          colors.iconStrong,
                          16.w,
                        ),
                        SizedBox(width: 6.w),
                        '3'.s(13.sp).w(800).c(colors.textStrong),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 8.h),
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16.r),
              child: DecoratedBox(
                decoration: BoxDecoration(color: colors.chartNeutral),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: state.speakerGrid
                          ? _GridStage(onTap: onGrid)
                          : _SingleStage(
                              state: state,
                              onGrid: onGrid,
                              onJoinRequest: onJoinRequest,
                            ),
                    ),
                    if (state.screenSharing)
                      Positioned(
                        left: 12.w,
                        top: 12.h,
                        child: MeetingCallPreviewActions.surface(
                          color: colors.backgroundElevation2Alt,
                          radius: 999.r,
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10.w,
                              vertical: 6.h,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                MeetingCallPreviewActions.icon(
                                  Assets.icons.meetingScreen,
                                  colors.accentStrong,
                                  16.w,
                                ),
                                SizedBox(width: 6.w),
                                l10n.meetingCallYouAreSharing
                                    .s(11.sp)
                                    .w(800)
                                    .c(colors.textStrong),
                              ],
                            ),
                          ),
                        ),
                      ),
                    if (state.stickersOpen)
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: MeetingCallStickersPanel(
                          onSelected: onStickerSelected,
                          onClosed: onStickerClosed,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 8.h),
        MeetingCallControlBar(
          microphoneOn: state.microphoneOn,
          cameraOn: state.cameraOn,
          handRaised: state.handRaised,
          onMicrophone: onMicrophone,
          onCamera: onCamera,
          onHand: onHand,
          onMore: onMore,
          onLeave: onLeave,
          microphoneLabel: l10n.meetingCallMicrophone,
          cameraLabel: l10n.meetingCallCamera,
          handLabel: l10n.meetingCallRaiseHand,
          moreLabel: l10n.meetingCallMore,
          leaveLabel: l10n.meetingCallLeave,
          onMicrophoneMenu: onMicrophoneMenu,
          onCameraMenu: onCameraMenu,
        ),
        SizedBox(height: 8.h),
      ],
    );
  }
}

class _SingleStage extends StatelessWidget {
  const _SingleStage({
    required this.state,
    required this.onGrid,
    required this.onJoinRequest,
  });

  final MeetingCallPreviewState state;
  final VoidCallback onGrid;
  final VoidCallback onJoinRequest;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);
    final selfTileColor = colors.backgroundBase.computeLuminance() < 0.5
        ? colors.backgroundBase2
        : Color.alphaBlend(
            colors.black.withValues(alpha: 0.08),
            colors.textStrong,
          );
    return Stack(
      children: [
        Center(
          child: MeetingCallPreviewActions.avatar(
            Assets.images.meetingDilnoza.path,
            88.w,
          ),
        ),
        Positioned(
          right: 12.w,
          top: 12.h,
          child: InkWell(
            onTap: onGrid,
            child: MeetingCallPreviewActions.surface(
              color: selfTileColor,
              radius: 12.r,
              child: SizedBox(
                width: 96.w,
                height: 128.h,
                child: Stack(
                  children: [
                    Center(
                      child: MeetingCallPreviewActions.avatar(
                        Assets.images.meetingSelf.path,
                        40.w,
                      ),
                    ),
                    Positioned(
                      left: 9.w,
                      bottom: 10.h,
                      child: l10n.meetingCallYou
                          .s(11.sp)
                          .w(500)
                          .c(colors.textWhite),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Positioned(
          left: 12.w,
          bottom: 12.h,
          child: state.reactions.isEmpty
              ? MeetingCallPreviewNameTag(name: l10n.meetingCallDilnoza)
              : MeetingCallPreviewNameTag(
                  name: l10n.meetingCallDilnoza,
                  reaction: state.reactions.last,
                ),
        ),
        if (state.reactions.isNotEmpty)
          Positioned(
            left: 20.w,
            top: 28.h,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final reaction in state.reactions)
                  Padding(
                    padding: EdgeInsets.only(bottom: 6.h),
                    child: Text(reaction, style: TextStyle(fontSize: 28.sp)),
                  ),
              ],
            ),
          ),
        if (state.handRaised)
          Positioned(
            top: 16.h,
            left: 12.w,
            right: 12.w,
            child: MeetingCallPreviewActions.surface(
              color: colors.successSoft,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                child: Row(
                  children: [
                    MeetingCallPreviewActions.icon(
                      Assets.icons.meetingHand,
                      colors.successStrong,
                      20.w,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: l10n.meetingCallRaisedNotice
                          .s(13.sp)
                          .w(700)
                          .c(colors.textStrong),
                    ),
                  ],
                ),
              ),
            ),
          ),
        if (state.joinRequest)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: MeetingCallJoinRequest(
              onReject: onJoinRequest,
              onAllow: onJoinRequest,
            ),
          ),
      ],
    );
  }
}

class _GridStage extends StatelessWidget {
  const _GridStage({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);
    return ColoredBox(
      color: colors.backgroundElevation2Alt,
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: InkWell(
          onTap: onTap,
          child: Column(
            children: [
              Expanded(
                child: MeetingCallParticipantTile(
                  assetPath: Assets.images.meetingDilnoza.path,
                  name: l10n.meetingCallDilnoza,
                  active: true,
                ),
              ),
              SizedBox(height: 12.h),
              Expanded(
                child: MeetingCallParticipantTile(
                  assetPath: Assets.images.meetingSelf.path,
                  name: l10n.meetingCallSelfName,
                ),
              ),
              SizedBox(height: 12.h),
              Expanded(
                child: MeetingCallParticipantTile(
                  assetPath: Assets.images.meetingBekzod.path,
                  name: l10n.meetingCallBekzod,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
