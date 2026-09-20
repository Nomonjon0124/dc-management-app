import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MeetingPreviewSurface extends StatelessWidget {
  const MeetingPreviewSurface({
    super.key,
    required this.color,
    required this.child,
    this.radius,
  });

  final Color color;
  final Widget child;
  final double? radius;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular((radius ?? 12.r)),
      ),
      child: child,
    );
  }
}
