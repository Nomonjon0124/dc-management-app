import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../../config/theme/app_colors.dart';
import '../../../../../../../core/extentions/text_extensions.dart';
import '../../../../../../../core/gen/assets.gen.dart';
import '../common/meeting_preview_icon_button.dart';

class MeetingCallTopBar extends StatelessWidget {
  const MeetingCallTopBar({
    super.key,
    required this.title,
    required this.participantCount,
    required this.onTitleTap,
    required this.onEndTap,
    required this.onStickerTap,
    required this.onParticipantsTap,
    required this.endLabel,
    required this.stickerLabel,
    this.showSticker = true,
  });

  final String title;
  final String participantCount;
  final VoidCallback onTitleTap;
  final VoidCallback onEndTap;
  final VoidCallback onStickerTap;
  final VoidCallback onParticipantsTap;
  final String endLabel;
  final String stickerLabel;
  final bool showSticker;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 16.w, 12.h),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: onTitleTap,
              child: Row(
                children: [
                  Flexible(
                    child: title
                        .s(13.sp)
                        .w(800)
                        .c(colors.textStrong)
                        .copyWith(maxLines: 1, overflow: TextOverflow.ellipsis),
                  ),
                  SizedBox(width: 8.w),
                  Assets.icons.meetingInfo.svg(
                    width: 16.w,
                    height: 16.w,
                    colorFilter: ColorFilter.mode(
                      colors.iconStrong,
                      BlendMode.srcIn,
                    ),
                  ),
                ],
              ),
            ),
          ),
          MeetingPreviewIconButton(
            asset: Assets.icons.meetingPower,
            background: colors.errorSub,
            foreground: colors.iconWhite,
            onTap: onEndTap,
            semanticLabel: endLabel,
            size: 32.w,
            iconSize: 18.w,
          ),
          if (showSticker) ...[
            SizedBox(width: 8.w),
            MeetingPreviewIconButton(
              asset: Assets.icons.meetingSticker,
              background: colors.backgroundElevation2,
              foreground: colors.iconStrong,
              onTap: onStickerTap,
              semanticLabel: stickerLabel,
              size: 32.w,
              iconSize: 18.w,
            ),
          ],
          SizedBox(width: 8.w),
          InkWell(
            onTap: onParticipantsTap,
            borderRadius: BorderRadius.circular(999.r),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: colors.backgroundElevation2,
                borderRadius: BorderRadius.circular(999.r),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                child: Row(
                  children: [
                    Assets.icons.icUserGroup.svg(
                      width: 16.w,
                      height: 16.w,
                      colorFilter: ColorFilter.mode(
                        colors.iconStrong,
                        BlendMode.srcIn,
                      ),
                    ),
                    SizedBox(width: 6.w),
                    participantCount.s(13.sp).w(800).c(colors.textStrong),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
