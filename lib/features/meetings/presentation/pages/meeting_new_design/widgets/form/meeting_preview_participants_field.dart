import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../../config/theme/app_colors.dart';
import '../../../../../../../core/extentions/text_extensions.dart';
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
    final text = selected.isEmpty
        ? l10n.meetingCreateParticipantsHelp
        : selected.join(', ');
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
              height: 44.h,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: text
                      .s(11.sp)
                      .w(500)
                      .h(16 / 11)
                      .c(selected.isEmpty ? colors.textSub : colors.textStrong)
                      .copyWith(maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
