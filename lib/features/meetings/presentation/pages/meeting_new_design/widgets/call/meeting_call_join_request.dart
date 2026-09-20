import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../../config/theme/app_colors.dart';
import '../../../../../../../core/extentions/text_extensions.dart';
import '../../../../../../../core/gen/assets.gen.dart';
import '../../../../../../../l10n/app_localizations.dart';
import '../common/meeting_preview_avatar.dart';
import '../common/meeting_preview_button.dart';
import '../common/meeting_preview_surface.dart';

class MeetingCallJoinRequest extends StatelessWidget {
  const MeetingCallJoinRequest({
    super.key,
    required this.onReject,
    required this.onAllow,
  });

  final VoidCallback onReject;
  final VoidCallback onAllow;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);
    return MeetingPreviewSurface(
      color: colors.overlaySurface,
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Column(
          children: [
            Row(
              children: [
                MeetingPreviewAvatar(
                  assetPath: Assets.images.meetingDilnoza.path,
                  size: 36.w,
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      l10n.meetingCallDilnoza
                          .s(13.sp)
                          .w(800)
                          .c(colors.textStrong),
                      l10n.meetingCallWantsToJoin
                          .s(11.sp)
                          .w(500)
                          .c(colors.textSub),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            Row(
              children: [
                Expanded(
                  child: MeetingPreviewButton(
                    label: l10n.meetingCallReject,
                    background: colors.backgroundElevation2,
                    foreground: colors.textStrong,
                    onTap: onReject,
                    icon: Assets.icons.icClose,
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: MeetingPreviewButton(
                    label: l10n.meetingCallAllow,
                    background: colors.accentStrong,
                    foreground: colors.textWhite,
                    onTap: onAllow,
                    icon: Assets.icons.icTuilconCheck,
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
