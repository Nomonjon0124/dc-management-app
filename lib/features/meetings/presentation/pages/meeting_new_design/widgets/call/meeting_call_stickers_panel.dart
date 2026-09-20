import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../../config/theme/app_colors.dart';
import '../../../../../../../core/extentions/text_extensions.dart';
import '../../../../../../../l10n/app_localizations.dart';
import '../common/meeting_preview_surface.dart';

class MeetingCallStickersPanel extends StatelessWidget {
  const MeetingCallStickersPanel({super.key, required this.onSelected});

  final ValueChanged<String> onSelected;

  static const stickers = [
    '👍',
    '👏',
    '🤝',
    '🎉',
    '😀',
    '😂',
    '😮',
    '🤔',
    '🙌',
    '✅',
  ];

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);
    return MeetingPreviewSurface(
      color: colors.overlaySurface,
      radius: 16.r,
      child: Padding(
        padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 14.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            l10n.meetingCallStickersTitle.s(13.sp).w(800).c(colors.textStrong),
            SizedBox(height: 10.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: [
                for (final sticker in stickers)
                  InkWell(
                    onTap: () => onSelected(sticker),
                    borderRadius: BorderRadius.circular(12.r),
                    child: MeetingPreviewSurface(
                      color: colors.backgroundElevation1,
                      radius: 12.r,
                      child: SizedBox(
                        width: 54.w,
                        height: 54.w,
                        child: Center(
                          child: Text(
                            sticker,
                            style: TextStyle(fontSize: 28.sp),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
