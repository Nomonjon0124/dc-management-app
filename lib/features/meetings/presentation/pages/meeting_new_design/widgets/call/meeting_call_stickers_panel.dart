import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../../config/theme/app_colors.dart';
import '../../../../../../../core/extentions/text_extensions.dart';
import '../../../../../../../core/gen/assets.gen.dart';
import '../../../../../../../l10n/app_localizations.dart';
import '../common/meeting_preview_icon_button.dart';
import '../common/meeting_preview_surface.dart';

class MeetingCallStickersPanel extends StatelessWidget {
  const MeetingCallStickersPanel({
    super.key,
    required this.onSelected,
    this.onClosed,
  });

  final ValueChanged<String> onSelected;
  final VoidCallback? onClosed;

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
      radius: 18.r,
      borderColor: colors.strokeSub,
      boxShadow: [
        BoxShadow(
          color: colors.black.withValues(alpha: 0.18),
          blurRadius: 30.r,
          offset: Offset(0, 12.h),
        ),
      ],
      child: Padding(
        padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 14.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: l10n.meetingCallStickersTitle
                      .s(13.sp)
                      .w(800)
                      .c(colors.textStrong),
                ),
                l10n.meetingCallStickersDuration
                    .s(11.sp)
                    .w(500)
                    .c(colors.textSoft),
                if (onClosed != null) ...[
                  SizedBox(width: 8.w),
                  MeetingPreviewIconButton(
                    asset: Assets.icons.icClose,
                    background: colors.backgroundElevation2,
                    foreground: colors.iconSub,
                    onTap: onClosed!,
                    semanticLabel: l10n.meetingCallCloseStickers,
                    size: 24.w,
                    iconSize: 14.w,
                  ),
                ],
              ],
            ),
            SizedBox(height: 10.h),
            LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth >= 312.w ? 5 : 4;
                final totalSpacing = (columns - 1) * 8.w;
                final tileSize =
                    ((constraints.maxWidth - totalSpacing) / columns)
                        .clamp(0.0, 56.w)
                        .toDouble();
                return Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: [
                    for (final sticker in stickers)
                      InkWell(
                        onTap: () => onSelected(sticker),
                        borderRadius: BorderRadius.circular(14.r),
                        child: MeetingPreviewSurface(
                          color: colors.backgroundElevation1,
                          radius: 14.r,
                          child: SizedBox(
                            width: tileSize,
                            height: tileSize,
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
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
