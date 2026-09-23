import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MeetingPreviewSurface extends StatelessWidget {
  const MeetingPreviewSurface({
    super.key,
    required this.color,
    required this.child,
    this.radius,
    this.borderColor,
    this.boxShadow,
  });

  final Color color;
  final Widget child;
  final double? radius;
  final Color? borderColor;
  final List<BoxShadow>? boxShadow;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular((radius ?? 12.r)),
        boxShadow: boxShadow,
        border: borderColor == null
            ? null
            : Border.all(color: borderColor!, width: 1.w),
      ),
      child: child,
    );
  }
}
