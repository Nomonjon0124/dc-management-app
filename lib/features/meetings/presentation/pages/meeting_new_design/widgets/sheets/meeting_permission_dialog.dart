import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../../config/theme/app_colors.dart';
import '../../../../../../../core/extentions/text_extensions.dart';
import '../../../../../../../core/gen/assets.gen.dart';
import '../../../../../../../core/widgets/tui_avatar.dart';

/// Figma-aligned dialog used for microphone and camera enable requests.
///
/// The widget is rendered as content only so it can be used in both a native
/// [Dialog] and the in-meeting overlay without duplicating the UI.
class MeetingPermissionDialog extends StatelessWidget {
  const MeetingPermissionDialog({
    super.key,
    required this.title,
    required this.requesterName,
    required this.requesterRole,
    required this.message,
    required this.declineLabel,
    required this.enableLabel,
    required this.onDecline,
    required this.onEnable,
    required this.permissionIcon,
    required this.enableIcon,
    this.avatarUrl = '',
    this.requesterAvatar,
  });

  final String title;
  final String requesterName;
  final String requesterRole;
  final String message;
  final String declineLabel;
  final String enableLabel;
  final VoidCallback onDecline;
  final VoidCallback onEnable;
  final SvgGenImage permissionIcon;
  final SvgGenImage enableIcon;
  final String avatarUrl;
  final Widget? requesterAvatar;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.overlaySurface,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: colors.textStrong.withValues(alpha: 0.24),
            blurRadius: 44.r,
            offset: Offset(0, 18.h),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(18.w, 18.h, 18.w, 18.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                permissionIcon.svg(
                  width: 24.w,
                  height: 24.w,
                  colorFilter: ColorFilter.mode(
                    colors.iconStrong,
                    BlendMode.srcIn,
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: title
                      .s(18.sp)
                      .w(800)
                      .c(colors.textStrong)
                      .copyWith(maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            _requester(context),
            SizedBox(height: 12.h),
            message.s(14.sp).w(500).c(colors.textSub).h(1.5),
            SizedBox(height: 10.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _actionButton(
                    label: declineLabel,
                    icon: Assets.icons.icClose,
                    background: colors.backgroundElevation1Alt,
                    foreground: colors.textStrong,
                    onTap: onDecline,
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: _actionButton(
                    label: enableLabel,
                    icon: enableIcon,
                    background: colors.accentStrong,
                    foreground: colors.textWhite,
                    onTap: onEnable,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _requester(BuildContext context) {
    final colors = AppColors.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.backgroundElevation1Alt,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(10.w, 8.h, 12.w, 8.h),
        child: Row(
          children: [
            requesterAvatar ??
                TuiAvatar(
                  initial: requesterName,
                  avatarUrl: avatarUrl,
                  size: 32,
                ),
            SizedBox(width: 8.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  requesterName
                      .s(13.sp)
                      .w(800)
                      .c(colors.textStrong)
                      .copyWith(maxLines: 1, overflow: TextOverflow.ellipsis),
                  requesterRole
                      .s(11.sp)
                      .w(500)
                      .c(colors.textSoft)
                      .copyWith(maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionButton({
    required String label,
    required SvgGenImage icon,
    required Color background,
    required Color foreground,
    required VoidCallback onTap,
  }) {
    return Semantics(
      button: true,
      label: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14.r),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(14.r),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 10.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                icon.svg(
                  width: 17.w,
                  height: 17.w,
                  colorFilter: ColorFilter.mode(foreground, BlendMode.srcIn),
                ),
                SizedBox(width: 6.w),
                Flexible(
                  child: label
                      .s(12.sp)
                      .w(800)
                      .c(foreground)
                      .a(TextAlign.center)
                      .h(1.15)
                      .copyWith(maxLines: 2, overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
