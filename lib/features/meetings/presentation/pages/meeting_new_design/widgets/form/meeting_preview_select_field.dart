import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../../config/theme/app_colors.dart';
import '../../../../../../../core/extentions/text_extensions.dart';
import '../../../../../../../core/gen/assets.gen.dart';
import '../../../../../../../core/widgets/app_filter_components.dart';

class MeetingPreviewSelectField extends StatelessWidget {
  const MeetingPreviewSelectField({
    super.key,
    required this.label,
    required this.onTap,
    this.value,
    this.hint,
    this.icon,
  });

  final String label;
  final String? value;
  final String? hint;
  final SvgGenImage? icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppFilterFieldLabel(label),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12.r),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colors.backgroundBase,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: colors.strokeSub, width: 1.w),
            ),
            child: SizedBox(
              height: 44.h,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                child: Row(
                  children: [
                    Expanded(
                      child: (value ?? hint ?? '')
                          .s(13.sp)
                          .w(500)
                          .h(20 / 13)
                          .c(value == null ? colors.textSub : colors.textStrong)
                          .copyWith(
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                    ),
                    (icon ?? Assets.icons.icTuilconChervonDown).svg(
                      width: 16.w,
                      height: 16.w,
                      colorFilter: ColorFilter.mode(
                        colors.iconSub,
                        BlendMode.srcIn,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
