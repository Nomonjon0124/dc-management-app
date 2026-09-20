import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../../config/theme/app_colors.dart';
import '../../../../../../../core/extentions/text_extensions.dart';
import '../../../../../../../core/gen/assets.gen.dart';

class MeetingPreviewActions extends StatelessWidget {
  const MeetingPreviewActions({
    super.key,
    required this.primaryLabel,
    required this.secondaryLabel,
    required this.onPrimary,
    required this.onSecondary,
  });

  final String primaryLabel;
  final String secondaryLabel;
  final VoidCallback onPrimary;
  final VoidCallback onSecondary;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ActionButton(
          label: primaryLabel,
          icon: Assets.icons.icPersonalInformationIcon,
          onTap: onPrimary,
          primary: true,
        ),
        SizedBox(height: 12.h),
        _ActionButton(
          label: secondaryLabel,
          icon: Assets.icons.icTuilconCheck,
          onTap: onSecondary,
          primary: false,
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
    required this.primary,
  });

  final String label;
  final SvgGenImage icon;
  final VoidCallback onTap;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final foreground = primary ? colors.textWhite : colors.textStrong;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: primary ? colors.accentStrong : colors.backgroundBase,
          borderRadius: BorderRadius.circular(16.r),
          border: primary
              ? null
              : Border.all(color: colors.strokeSub, width: 1.w),
        ),
        child: SizedBox(
          width: double.infinity,
          height: 52.h,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              icon.svg(
                width: 16.w,
                height: 16.w,
                colorFilter: ColorFilter.mode(foreground, BlendMode.srcIn),
              ),
              SizedBox(width: 8.w),
              Flexible(
                child: label
                    .s(15.sp)
                    .w(800)
                    .h(24 / 15)
                    .c(foreground)
                    .copyWith(maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
