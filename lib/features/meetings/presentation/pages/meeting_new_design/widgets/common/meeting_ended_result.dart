import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../../config/theme/app_colors.dart';
import '../../../../../../../core/extentions/text_extensions.dart';
import '../../../../../../../core/gen/assets.gen.dart';
import 'meeting_preview_button.dart';

class MeetingEndedResult extends StatelessWidget {
  const MeetingEndedResult({
    super.key,
    required this.title,
    required this.message,
    required this.rejoinLabel,
    required this.homeLabel,
    required this.onRejoin,
    required this.onHome,
  });

  final String title;
  final String message;
  final String rejoinLabel;
  final String homeLabel;
  final VoidCallback onRejoin;
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 40.w),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 310.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: colors.backgroundElevation2Alt,
                  shape: BoxShape.circle,
                ),
                child: SizedBox(
                  width: 64.w,
                  height: 64.w,
                  child: Center(
                    child: Assets.icons.meetingEndedCheck.svg(
                      width: 30.w,
                      height: 30.w,
                      colorFilter: ColorFilter.mode(
                        colors.accentStrong,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 14.h),
              title
                  .s(20.sp)
                  .w(800)
                  .c(colors.textStrong)
                  .h(24 / 20)
                  .a(TextAlign.center),
              SizedBox(height: 14.h),
              message
                  .s(15.sp)
                  .w(500)
                  .c(colors.textSub)
                  .h(24 / 15)
                  .a(TextAlign.center)
                  .copyWith(maxLines: 2, overflow: TextOverflow.ellipsis),
              SizedBox(height: 14.h),
              Padding(
                padding: EdgeInsets.only(top: 6.h),
                child: Column(
                  children: [
                    MeetingPreviewButton(
                      label: rejoinLabel,
                      background: colors.accentStrong,
                      foreground: colors.textWhite,
                      onTap: onRejoin,
                      icon: Assets.icons.meetingEndedRefresh,
                    ),
                    SizedBox(height: 10.h),
                    MeetingPreviewButton(
                      label: homeLabel,
                      background: colors.backgroundElevation2,
                      foreground: colors.textStrong,
                      borderColor: colors.strokeSub,
                      onTap: onHome,
                      icon: Assets.icons.meetingEndedHome,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
