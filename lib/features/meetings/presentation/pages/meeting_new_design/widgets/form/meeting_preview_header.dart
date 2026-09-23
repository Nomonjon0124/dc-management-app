import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../../config/theme/app_colors.dart';
import '../../../../../../../core/extentions/text_extensions.dart';
import '../../../../../../../core/gen/assets.gen.dart';

class MeetingPreviewHeader extends StatelessWidget {
  const MeetingPreviewHeader({
    super.key,
    required this.title,
    this.roundClose = false,
  });

  final String title;
  final bool roundClose;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      child: Row(
        children: [
          SizedBox(width: roundClose ? 32.w : 16.w),
          Expanded(
            child: title
                .s(17.sp)
                .w(800)
                .h(28 / 17)
                .c(colors.textStrong)
                .a(TextAlign.center)
                .copyWith(maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
          InkWell(
            onTap: () => Navigator.of(context).maybePop(),
            borderRadius: BorderRadius.circular(roundClose ? 999.r : 8.r),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: roundClose
                    ? colors.backgroundElevation2
                    : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: SizedBox(
                width: roundClose ? 32.w : 16.w,
                height: roundClose ? 32.w : 16.w,
                child: Center(
                  child: Assets.icons.icClose.svg(
                    width: 16.w,
                    height: 16.w,
                    colorFilter: ColorFilter.mode(
                      colors.iconStrong,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
