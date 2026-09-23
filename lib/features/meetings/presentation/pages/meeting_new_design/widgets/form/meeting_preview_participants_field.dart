import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../../config/theme/app_colors.dart';
import '../../../../../../../core/extentions/text_extensions.dart';
import '../../../../../../../core/gen/assets.gen.dart';
import '../../../../../../../core/widgets/app_filter_components.dart';
import '../../../../../../../l10n/app_localizations.dart';

class MeetingPreviewParticipantsField extends StatelessWidget {
  const MeetingPreviewParticipantsField({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final Set<String> selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppFilterFieldLabel(label),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12.r),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colors.backgroundBase,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: colors.strokeSub, width: 1.w),
            ),
            child: SizedBox(
              width: double.infinity,
              child: selected.isEmpty
                  ? ConstrainedBox(
                      constraints: BoxConstraints(minHeight: 82.h),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          l10n.meetingCreateParticipantsHelp
                              .s(11.sp)
                              .w(500)
                              .h(16 / 11)
                              .c(colors.textSub)
                              .copyWith(
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                          SizedBox(height: 7.h),
                          DecoratedBox(
                            decoration: BoxDecoration(
                              color: colors.backgroundElevation3,
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.w,
                                vertical: 5.h,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Assets.icons.icPlus.svg(
                                    width: 12.w,
                                    height: 12.w,
                                    colorFilter: ColorFilter.mode(
                                      colors.iconStrong,
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                  SizedBox(width: 2.w),
                                  l10n.meetingCreateParticipantsAdd
                                      .s(11.sp)
                                      .w(500)
                                      .h(16 / 11)
                                      .c(colors.textStrong),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 10.h,
                      ),
                      child: selected
                          .join(', ')
                          .s(12.sp)
                          .w(500)
                          .h(18 / 12)
                          .c(colors.textStrong)
                          .copyWith(
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}
