import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../../config/theme/app_colors.dart';
import '../../../../../../../core/extentions/text_extensions.dart';
import '../../../../../../../core/gen/assets.gen.dart';
import '../../../../../../../l10n/app_localizations.dart';
import '../../../../theme/meeting_theme_colors.dart';

class MeetingMoreSheetAction {
  const MeetingMoreSheetAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.destructive = false,
  });

  final SvgGenImage icon;
  final String label;
  final VoidCallback onTap;
  final bool destructive;
}

class MeetingMoreSheet extends StatelessWidget {
  const MeetingMoreSheet({
    super.key,
    required this.actions,
    required this.onClose,
  });

  final List<MeetingMoreSheetAction> actions;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 34.h),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.9,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: colors.backgroundElevation2Alt,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                  child: SizedBox(width: 36.w, height: 4.h),
                ),
                SizedBox(height: 14.h),
                Row(
                  children: [
                    Expanded(
                      child: l10n.meetingCallMore
                          .s(17.sp)
                          .w(800)
                          .c(colors.textStrong),
                    ),
                    Semantics(
                      button: true,
                      label: l10n.meetingCallClose,
                      child: Material(
                        color: colors.meetingControlSurface,
                        shape: const CircleBorder(),
                        child: InkWell(
                          onTap: onClose,
                          customBorder: const CircleBorder(),
                          child: SizedBox(
                            width: 32.w,
                            height: 32.w,
                            child: Center(
                              child: Assets.icons.icClose.svg(
                                width: 18.w,
                                height: 18.w,
                                colorFilter: ColorFilter.mode(
                                  colors.iconStrong,
                                  BlendMode.srcIn,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 14.h),
                for (var index = 0; index < actions.length; index++) ...[
                  if (index == actions.length - 1 && index > 0)
                    Padding(
                      padding: EdgeInsets.only(bottom: 14.h),
                      child: SizedBox(
                        width: double.infinity,
                        height: 1.h,
                        child: ColoredBox(color: colors.strokeSub),
                      ),
                    ),
                  _ActionRow(action: actions[index]),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({required this.action});

  final MeetingMoreSheetAction action;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final foreground = action.destructive
        ? colors.errorStrong
        : colors.textStrong;

    return InkWell(
      onTap: action.onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 4.h),
        child: Row(
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: action.destructive
                    ? colors.meetingDestructiveSurface
                    : colors.backgroundElevation1Alt,
                shape: BoxShape.circle,
              ),
              child: SizedBox(
                width: 44.w,
                height: 44.w,
                child: Center(
                  child: action.icon.svg(
                    width: 20.w,
                    height: 20.w,
                    colorFilter: ColorFilter.mode(
                      action.destructive
                          ? colors.errorStrong
                          : colors.iconStrong,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: action.label
                  .s(15.sp)
                  .w(800)
                  .c(foreground)
                  .copyWith(maxLines: 2, overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      ),
    );
  }
}
