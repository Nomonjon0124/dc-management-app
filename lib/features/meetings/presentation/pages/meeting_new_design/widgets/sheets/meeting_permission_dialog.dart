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
        color: colors.white,
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
        padding: EdgeInsets.fromLTRB(20.w, 22.h, 20.w, 20.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            permissionIcon.svg(
              width: 26.w,
              height: 26.w,
              colorFilter: ColorFilter.mode(
                colors.accentStrong,
                BlendMode.srcIn,
              ),
            ),
            SizedBox(height: 14.h),
            title.s(20.sp).w(800).c(colors.textStrong).h(1.2),
            SizedBox(height: 14.h),
            _requester(context),
            SizedBox(height: 14.h),
            message.s(15.sp).w(500).c(colors.textSub).h(1.6),
            SizedBox(height: 4.h),
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
        color: colors.backgroundElevation1,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(12.w, 10.h, 14.w, 10.h),
        child: Row(
          children: [
            requesterAvatar ??
                TuiAvatar(
                  initial: requesterName,
                  avatarUrl: avatarUrl,
                  size: 32,
                ),
            SizedBox(width: 10.w),
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
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 13.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                icon.svg(
                  width: 18.w,
                  height: 18.w,
                  colorFilter: ColorFilter.mode(foreground, BlendMode.srcIn),
                ),
                SizedBox(width: 8.w),
                Flexible(
                  child: label
                      .s(13.sp)
                      .w(800)
                      .c(foreground)
                      .a(TextAlign.center)
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
