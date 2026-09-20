import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../../core/gen/assets.gen.dart';

class MeetingPreviewIconButton extends StatelessWidget {
  const MeetingPreviewIconButton({
    super.key,
    required this.asset,
    required this.background,
    required this.foreground,
    required this.onTap,
    required this.semanticLabel,
    this.size,
    this.iconSize,
  });

  final SvgGenImage asset;
  final Color background;
  final Color foreground;
  final VoidCallback onTap;
  final String semanticLabel;
  final double? size;
  final double? iconSize;

  @override
  Widget build(BuildContext context) {
    final dimension = size ?? 48.w;
    return Semantics(
      button: true,
      label: semanticLabel,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999.r),
        child: DecoratedBox(
          decoration: BoxDecoration(color: background, shape: BoxShape.circle),
          child: SizedBox(
            width: dimension,
            height: dimension,
            child: Center(
              child: asset.svg(
                width: iconSize ?? 20.w,
                height: iconSize ?? 20.w,
                colorFilter: ColorFilter.mode(foreground, BlendMode.srcIn),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
