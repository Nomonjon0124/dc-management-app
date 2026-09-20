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
  });

  final String label;
  final Color background;
  final Color foreground;
  final VoidCallback onTap;
  final SvgGenImage? icon;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    final content = SizedBox(
      height: 54.h,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            icon!.svg(
              width: 18.w,
              height: 18.w,
              colorFilter: ColorFilter.mode(foreground, BlendMode.srcIn),
            ),
            SizedBox(width: 8.w),
          ],
          Flexible(
            child: label
                .s(15.sp)
                .w(800)
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
      border: outlined ? Border.all(color: foreground, width: 1.w) : null,
    );
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: DecoratedBox(decoration: decoration, child: content),
    );
  }
}
