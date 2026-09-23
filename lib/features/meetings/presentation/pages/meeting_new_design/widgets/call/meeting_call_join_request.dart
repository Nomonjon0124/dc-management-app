import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../../config/theme/app_colors.dart';
import '../../../../../../../core/extentions/text_extensions.dart';
import '../../../../../../../core/gen/assets.gen.dart';
import '../../../../../../../core/widgets/tui_avatar.dart';
import '../../../../../../../l10n/app_localizations.dart';
import '../common/meeting_preview_avatar.dart';
import '../common/meeting_preview_button.dart';

class MeetingCallJoinRequest extends StatelessWidget {
  const MeetingCallJoinRequest({
    super.key,
    required this.onReject,
    required this.onAllow,
    this.participantName,
    this.avatarUrl = '',
  });

  final VoidCallback onReject;
  final VoidCallback onAllow;
  final String? participantName;
  final String avatarUrl;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: colors.textStrong.withValues(alpha: 0.18),
            blurRadius: 28.r,
            offset: Offset(0, 10.h),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(14.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                participantName == null
                    ? MeetingPreviewAvatar(
                        assetPath: Assets.images.meetingDilnoza.path,
                        size: 40.w,
                      )
                    : TuiAvatar(
                        initial: participantName!,
                        avatarUrl: avatarUrl,
                        size: 40,
                      ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      (participantName ?? l10n.meetingCallDilnoza)
                          .s(15.sp)
                          .w(800)
                          .c(colors.textStrong),
                      l10n.meetingCallWantsToJoin
                          .s(13.sp)
                          .w(500)
                          .c(colors.textSub),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: MeetingPreviewButton(
                    label: l10n.meetingCallReject,
                    background: colors.backgroundElevation2,
                    foreground: colors.textStrong,
                    onTap: onReject,
                    icon: Assets.icons.icClose,
                    height: 44.h,
                    iconSize: 16.w,
                    textSize: 13.sp,
                    borderColor: colors.strokeSub,
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: MeetingPreviewButton(
                    label: l10n.meetingCallAllow,
                    background: colors.accentStrong,
                    foreground: colors.textWhite,
                    onTap: onAllow,
                    icon: Assets.icons.icTuilconCheck,
                    height: 44.h,
                    iconSize: 16.w,
                    textSize: 13.sp,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
