import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../../config/theme/app_colors.dart';
import '../../../../../../../core/gen/assets.gen.dart';
import '../common/meeting_preview_icon_button.dart';

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

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MeetingPreviewIconButton(
              asset: microphoneOn
                  ? Assets.icons.meetingMic
                  : Assets.icons.meetingMicOff,
              background: microphoneOn
                  ? colors.backgroundElevation2
                  : colors.errorStrong,
              foreground: microphoneOn ? colors.iconStrong : colors.iconWhite,
              onTap: onMicrophone,
              semanticLabel: microphoneLabel,
            ),
            SizedBox(width: 8.w),
            MeetingPreviewIconButton(
              asset: cameraOn
                  ? Assets.icons.meetingVideo
                  : Assets.icons.meetingVideoOff,
              background: cameraOn
                  ? colors.backgroundElevation2
                  : colors.errorStrong,
              foreground: cameraOn ? colors.iconStrong : colors.iconWhite,
              onTap: onCamera,
              semanticLabel: cameraLabel,
            ),
            SizedBox(width: 8.w),
            MeetingPreviewIconButton(
              asset: Assets.icons.meetingHand,
              background: handRaised
                  ? colors.accentStrong
                  : colors.backgroundElevation2,
              foreground: handRaised ? colors.iconWhite : colors.iconStrong,
              onTap: onHand,
              semanticLabel: handLabel,
            ),
            SizedBox(width: 8.w),
            MeetingPreviewIconButton(
              asset: Assets.icons.icMoreVertical,
              background: colors.backgroundElevation2,
              foreground: colors.iconStrong,
              onTap: onMore,
              semanticLabel: moreLabel,
            ),
            SizedBox(width: 8.w),
            MeetingPreviewIconButton(
              asset: Assets.icons.meetingCallEnd,
              background: colors.errorStrong,
              foreground: colors.iconWhite,
              onTap: onLeave,
              semanticLabel: leaveLabel,
              size: 56.w,
            ),
          ],
        ),
      ),
    );
  }
}
