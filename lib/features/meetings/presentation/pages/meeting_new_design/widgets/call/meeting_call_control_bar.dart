import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../../config/theme/app_colors.dart';
import '../../../../../../../core/gen/assets.gen.dart';

class MeetingCallControlBar extends StatelessWidget {
  const MeetingCallControlBar({
    super.key,
    required this.microphoneOn,
    required this.cameraOn,
    required this.handRaised,
    required this.onMicrophone,
    required this.onCamera,
    required this.onHand,
    required this.onMore,
    required this.onLeave,
    required this.microphoneLabel,
    required this.cameraLabel,
    required this.handLabel,
    required this.moreLabel,
    required this.leaveLabel,
    this.onMicrophoneMenu,
    this.onCameraMenu,
  });

  final bool microphoneOn;
  final bool cameraOn;
  final bool handRaised;
  final VoidCallback onMicrophone;
  final VoidCallback onCamera;
  final VoidCallback onHand;
  final VoidCallback onMore;
  final VoidCallback onLeave;
  final String microphoneLabel;
  final String cameraLabel;
  final String handLabel;
  final String moreLabel;
  final String leaveLabel;
  final VoidCallback? onMicrophoneMenu;
  final VoidCallback? onCameraMenu;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final preferredWidth =
            (16.w * 2) +
            (12.w * 2) +
            (10.w * 4) +
            (64.w * 2) +
            (48.w * 2) +
            70.w;
        final metricsScale = math.min(
          1.0,
          constraints.maxWidth / preferredWidth,
        );
        final outerPadding = 16.w * metricsScale;
        final innerPadding = 12.w * metricsScale;
        final gap = 10.w * metricsScale;
        final buttonHeight = 44.h * metricsScale;
        final iconSize = 20.w * metricsScale;
        final caretSize = 12.w * metricsScale;
        final contentGap = 5.w * metricsScale;
        final dividerWidth = 1.w * metricsScale;
        final dividerHeight = 16.h * metricsScale;
        final buttonWidths = [
          64.w * metricsScale,
          64.w * metricsScale,
          48.w * metricsScale,
          48.w * metricsScale,
          70.w * metricsScale,
        ];

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: outerPadding),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colors.white,
              borderRadius: BorderRadius.circular(999.r),
              boxShadow: [
                BoxShadow(
                  color: colors.textStrong.withValues(alpha: 0.1),
                  blurRadius: 18.r,
                  offset: Offset(0, 6.h),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(innerPadding),
              child: Row(
                children: [
                  _barButton(
                    context,
                    microphoneOn
                        ? Assets.icons.meetingMic
                        : Assets.icons.meetingMicOff,
                    buttonWidths[0],
                    onMicrophone,
                    microphoneLabel,
                    iconSize: iconSize,
                    caretSize: caretSize,
                    buttonHeight: buttonHeight,
                    contentGap: contentGap,
                    dividerWidth: dividerWidth,
                    dividerHeight: dividerHeight,
                    dangerous: !microphoneOn,
                    caret: true,
                    caretOnTap: onMicrophoneMenu,
                  ),
                  SizedBox(width: gap),
                  _barButton(
                    context,
                    cameraOn
                        ? Assets.icons.meetingVideo
                        : Assets.icons.meetingVideoOff,
                    buttonWidths[1],
                    onCamera,
                    cameraLabel,
                    iconSize: iconSize,
                    caretSize: caretSize,
                    buttonHeight: buttonHeight,
                    contentGap: contentGap,
                    dividerWidth: dividerWidth,
                    dividerHeight: dividerHeight,
                    dangerous: !cameraOn,
                    caret: true,
                    caretOnTap: onCameraMenu,
                  ),
                  SizedBox(width: gap),
                  _barButton(
                    context,
                    Assets.icons.meetingHand,
                    buttonWidths[2],
                    onHand,
                    handLabel,
                    iconSize: iconSize,
                    caretSize: caretSize,
                    buttonHeight: buttonHeight,
                    contentGap: contentGap,
                    dividerWidth: dividerWidth,
                    dividerHeight: dividerHeight,
                    selected: handRaised,
                  ),
                  SizedBox(width: gap),
                  _barButton(
                    context,
                    Assets.icons.icMoreVertical,
                    buttonWidths[3],
                    onMore,
                    moreLabel,
                    iconSize: iconSize,
                    caretSize: caretSize,
                    buttonHeight: buttonHeight,
                    contentGap: contentGap,
                    dividerWidth: dividerWidth,
                    dividerHeight: dividerHeight,
                  ),
                  SizedBox(width: gap),
                  _barButton(
                    context,
                    Assets.icons.meetingCallEnd,
                    buttonWidths[4],
                    onLeave,
                    leaveLabel,
                    iconSize: iconSize,
                    caretSize: caretSize,
                    buttonHeight: buttonHeight,
                    contentGap: contentGap,
                    dividerWidth: dividerWidth,
                    dividerHeight: dividerHeight,
                    dangerous: true,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _barButton(
    BuildContext context,
    SvgGenImage asset,
    double width,
    VoidCallback onTap,
    String label, {
    required double iconSize,
    required double caretSize,
    required double buttonHeight,
    required double contentGap,
    required double dividerWidth,
    required double dividerHeight,
    bool dangerous = false,
    bool selected = false,
    bool caret = false,
    VoidCallback? caretOnTap,
  }) {
    final colors = AppColors.of(context);
    final foreground = dangerous || selected
        ? colors.iconWhite
        : colors.iconStrong;
    final background = dangerous
        ? colors.errorStrong
        : selected
        ? colors.accentStrong
        : colors.backgroundElevation2;
    return Semantics(
      button: true,
      label: label,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(999.r),
        ),
        child: SizedBox(
          width: width,
          height: buttonHeight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(999.r),
                child: asset.svg(
                  width: iconSize,
                  height: iconSize,
                  colorFilter: ColorFilter.mode(foreground, BlendMode.srcIn),
                ),
              ),
              if (caret) ...[
                SizedBox(width: contentGap),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: colors.textSoft.withValues(alpha: 0.35),
                  ),
                  child: SizedBox(width: dividerWidth, height: dividerHeight),
                ),
                SizedBox(width: contentGap),
                InkWell(
                  onTap: caretOnTap ?? onTap,
                  borderRadius: BorderRadius.circular(999.r),
                  child: RotatedBox(
                    quarterTurns: 3,
                    child: Assets.icons.icArrowRight.svg(
                      width: caretSize,
                      height: caretSize,
                      colorFilter: ColorFilter.mode(
                        foreground,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
