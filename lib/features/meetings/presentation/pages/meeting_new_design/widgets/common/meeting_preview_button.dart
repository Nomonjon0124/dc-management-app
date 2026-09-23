import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../../core/extentions/text_extensions.dart';
import '../../../../../../../core/gen/assets.gen.dart';

class MeetingPreviewButton extends StatelessWidget {
  const MeetingPreviewButton({
    super.key,
    required this.label,
    required this.background,
    required this.foreground,
    required this.onTap,
    this.icon,
    this.outlined = false,
    this.height,
    this.iconSize,
    this.textSize,
    this.textWeight = 800,
    this.borderColor,
  });

  final String label;
  final Color background;
  final Color foreground;
  final VoidCallback onTap;
  final SvgGenImage? icon;
  final bool outlined;
  final double? height;
  final double? iconSize;
  final double? textSize;
  final int textWeight;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final content = SizedBox(
      height: height ?? 54.h,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            icon!.svg(
              width: iconSize ?? 18.w,
              height: iconSize ?? 18.w,
              colorFilter: ColorFilter.mode(foreground, BlendMode.srcIn),
            ),
            SizedBox(width: 8.w),
          ],
          Flexible(
            child: label
                .s(textSize ?? 15.sp)
                .w(textWeight)
                .c(foreground)
                .a(TextAlign.center)
                .copyWith(maxLines: 2, overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
    final decoration = BoxDecoration(
      color: outlined ? Colors.transparent : background,
      borderRadius: BorderRadius.circular(12.r),
      border: outlined || borderColor != null
          ? Border.all(color: borderColor ?? foreground, width: 1.w)
          : null,
    );
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: DecoratedBox(decoration: decoration, child: content),
    );
  }
}
