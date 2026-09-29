import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:dc_management_app/config/theme/app_colors.dart';
import 'package:dc_management_app/core/gen/assets.gen.dart';
import 'package:dc_management_app/features/meetings/presentation/theme/meeting_theme_colors.dart';
import '../common/meeting_preview_avatar.dart';
import '../common/meeting_preview_button.dart';
import '../common/meeting_preview_icon_button.dart';
import '../common/meeting_preview_surface.dart';

class MeetingCallPreviewActions {
  const MeetingCallPreviewActions._();

  static Widget icon(SvgGenImage asset, Color color, double size) => asset.svg(
    width: size,
    height: size,
    colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
  );

  static Widget avatar(String path, double size) =>
      MeetingPreviewAvatar(assetPath: path, size: size);

  static Widget surface({
    required Color color,
    required Widget child,
    double? radius,
  }) => MeetingPreviewSurface(color: color, radius: radius, child: child);

  static Widget button(
    String label,
    Color background,
    Color foreground,
    VoidCallback onTap, {
    SvgGenImage? icon,
  }) => MeetingPreviewButton(
    label: label,
    background: background,
    foreground: foreground,
    onTap: onTap,
    icon: icon,
  );

  static Widget outlinedButton(
    String label,
    Color color,
    VoidCallback onTap, {
    SvgGenImage? icon,
  }) => MeetingPreviewButton(
    label: label,
    background: Colors.transparent,
    foreground: color,
    onTap: onTap,
    icon: icon,
    outlined: true,
  );

  static Widget circleAction(
    SvgGenImage asset,
    Color background,
    Color foreground,
    VoidCallback onTap,
    String label, {
    double? size,
    double? iconSize,
  }) => MeetingPreviewIconButton(
    asset: asset,
    background: background,
    foreground: foreground,
    onTap: onTap,
    semanticLabel: label,
    size: size,
    iconSize: iconSize,
  );
}

class MeetingCallPreviewHeader extends StatelessWidget {
  const MeetingCallPreviewHeader({
    super.key,
    required this.title,
    required this.onClose,
  });

  final String title;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 12.h),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 17.sp,
                fontWeight: FontWeight.w800,
                color: colors.textStrong,
              ),
            ),
          ),
          MeetingCallPreviewActions.circleAction(
            Assets.icons.icClose,
            colors.meetingControlSurface,
            colors.iconStrong,
            onClose,
            'Yopish',
            size: 32.w,
            iconSize: 18.w,
          ),
        ],
      ),
    );
  }
}

class MeetingCallPreviewNameTag extends StatelessWidget {
  const MeetingCallPreviewNameTag({
    super.key,
    required this.name,
    this.reaction,
  });

  final String name;
  final String? reaction;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return MeetingCallPreviewActions.surface(
      color: colors.black.withValues(alpha: 0.62),
      radius: 8.r,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (reaction != null)
              Text(reaction!, style: TextStyle(fontSize: 14.sp)),
            if (reaction != null) SizedBox(width: 8.w),
            Flexible(
              child: Text(
                name,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                  color: colors.textWhite,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
