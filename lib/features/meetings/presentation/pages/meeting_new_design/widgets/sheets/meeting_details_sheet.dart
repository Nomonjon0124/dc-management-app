import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../../config/theme/app_colors.dart';
import '../../../../../../../core/extentions/text_extensions.dart';
import '../../../../../../../core/gen/assets.gen.dart';
import '../../../../../../../l10n/app_localizations.dart';
import '../../../../../domain/entities/meeting.dart';

/// Figma 4145:2192 dagi yig'ilish ma'lumotlari sheet'i.
///
/// Sheet backenddan kelgan [meeting] ma'lumotlarini ko'rsatadi. [meeting]
/// hali yuklanmagan holatda ham ekran buzilmasligi uchun qiymatlar `—` bilan
/// ko'rsatiladi.
class MeetingDetailsSheet extends StatelessWidget {
  const MeetingDetailsSheet({
    super.key,
    required this.meeting,
    this.fallbackTitle = '',
    this.onClose,
  });

  final Meeting? meeting;
  final String fallbackTitle;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);
    final link = _linkValue();
    final title = _value(meeting?.title, fallback: fallbackTitle);

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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: colors.backgroundElevation2Alt,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                    child: SizedBox(width: 36.w, height: 4.h),
                  ),
                ),
                SizedBox(height: 14.h),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          l10n.meetingCallDetails
                              .s(17.sp)
                              .w(800)
                              .c(colors.textStrong)
                              .copyWith(
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                          SizedBox(height: 2.h),
                          l10n.meetingCallDetailsHint
                              .s(13.sp)
                              .w(500)
                              .c(colors.textSub)
                              .copyWith(
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                        ],
                      ),
                    ),
                    SizedBox(width: 12.w),
                    _closeButton(context, colors),
                  ],
                ),
                SizedBox(height: 14.h),
                _joinInformation(context, colors, l10n, link),
                SizedBox(height: 12.h),
                _meetingParameters(context, colors, l10n, title),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _closeButton(BuildContext context, AppColors colors) {
    return Material(
      color: colors.backgroundElevation2,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onClose ?? () => Navigator.of(context).pop(),
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 32.w,
          height: 32.w,
          child: Center(
            child: Assets.icons.icClose.svg(
              width: 18.w,
              height: 18.w,
              colorFilter: ColorFilter.mode(colors.iconStrong, BlendMode.srcIn),
            ),
          ),
        ),
      ),
    );
  }

  Widget _joinInformation(
    BuildContext context,
    AppColors colors,
    AppLocalizations l10n,
    String link,
  ) {
    return _card(
      context,
      colors,
      padding: EdgeInsets.all(14.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _sectionLabel(l10n.meetingCallJoinDetails, colors),
              ),
              _pill(l10n.meetingCallMeetingLink, colors),
            ],
          ),
          SizedBox(height: 10.h),
          _copyableLink(context, colors, link),
        ],
      ),
    );
  }

  Widget _meetingParameters(
    BuildContext context,
    AppColors colors,
    AppLocalizations l10n,
    String title,
  ) {
    return _card(
      context,
      colors,
      padding: EdgeInsets.all(14.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel(l10n.meetingCallMeetingParams, colors),
          SizedBox(height: 6.h),
          _parameterRow(
            context,
            colors,
            icon: Assets.icons.meetingInfo,
            label: l10n.meetingCallOfficialUid,
            value: _value(meeting?.uid),
            copyValue: meeting?.uid,
          ),
          _parameterRow(
            context,
            colors,
            icon: Assets.icons.meetingInfo,
            label: l10n.meetingCallMeetingTopic,
            value: title,
          ),
          _parameterRow(
            context,
            colors,
            icon: Assets.icons.icCalendar,
            label: l10n.meetingCallStartTime,
            value: _startValue(l10n),
          ),
          _parameterRow(
            context,
            colors,
            icon: Assets.icons.icLock,
            label: l10n.meetingCallSecurityAccess,
            value: meeting?.requiresApproval == true
                ? l10n.meetingCallApprovalHint
                : l10n.meetingCallDirectJoin,
          ),
        ],
      ),
    );
  }

  Widget _copyableLink(BuildContext context, AppColors colors, String link) {
    return InkWell(
      onTap: () => Clipboard.setData(ClipboardData(text: link)),
      borderRadius: BorderRadius.circular(10.r),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.overlaySurface,
          border: Border.all(color: colors.strokeSub, width: 1.w),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Assets.icons.meetingCopy.svg(
                width: 16.w,
                height: 16.w,
                colorFilter: ColorFilter.mode(colors.iconSub, BlendMode.srcIn),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _displayLink(link)
                    .s(13.sp)
                    .w(800)
                    .c(colors.accentStrong)
                    .copyWith(maxLines: 2, overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _parameterRow(
    BuildContext context,
    AppColors colors, {
    required SvgGenImage icon,
    required String label,
    required String value,
    String? copyValue,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 3.h),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.overlaySurface,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: colors.backgroundElevation2Alt,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: SizedBox(
                  width: 28.w,
                  height: 28.w,
                  child: Center(
                    child: icon.svg(
                      width: 16.w,
                      height: 16.w,
                      colorFilter: ColorFilter.mode(
                        colors.iconSub,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    label
                        .s(11.sp)
                        .w(500)
                        .c(colors.textSoft)
                        .copyWith(maxLines: 1, overflow: TextOverflow.ellipsis),
                    value
                        .s(13.sp)
                        .w(800)
                        .c(colors.textStrong)
                        .copyWith(maxLines: 2, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              if (copyValue?.trim().isNotEmpty == true)
                InkWell(
                  onTap: () =>
                      Clipboard.setData(ClipboardData(text: copyValue!.trim())),
                  borderRadius: BorderRadius.circular(6.r),
                  child: Padding(
                    padding: EdgeInsets.all(2.w),
                    child: Assets.icons.meetingCopy.svg(
                      width: 16.w,
                      height: 16.w,
                      colorFilter: ColorFilter.mode(
                        colors.iconSub,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _card(
    BuildContext context,
    AppColors colors, {
    required EdgeInsets padding,
    required Widget child,
  }) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.backgroundElevation1,
        border: Border.all(color: colors.strokeSub, width: 1.w),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Padding(padding: padding, child: child),
    );
  }

  Widget _sectionLabel(String value, AppColors colors) {
    final text = value.s(11.sp).w(800).c(colors.textSoft);
    return text.copyWith(
      style: text.style!.copyWith(letterSpacing: 0.6),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _pill(String value, AppColors colors) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.backgroundElevation2Alt,
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
        child: value
            .s(11.sp)
            .w(800)
            .c(colors.textStrong)
            .copyWith(maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
    );
  }

  String _startValue(AppLocalizations l10n) {
    final start = meeting?.startDate?.toLocal();
    if (start == null) return '—';
    final value = _formatDate(start);
    final minutes = meeting?.durationMinutes;
    if (minutes == null || minutes <= 0) return value;
    return '$value, $minutes ${l10n.meetingCallMinutes}';
  }

  String _linkValue() {
    final link = meeting?.link.trim() ?? '';
    if (link.isNotEmpty) return link;
    final id = meeting?.id ?? 0;
    return id > 0 ? 'raqamli-boshqaruv.uz/meetings/$id' : '—';
  }

  String _displayLink(String value) => value
      .replaceFirst(RegExp(r'^https?://', caseSensitive: false), '')
      .trim();

  String _value(String? value, {String fallback = '—'}) {
    final normalized = value?.trim() ?? '';
    return normalized.isEmpty ? fallback : normalized;
  }

  String _formatDate(DateTime date) {
    String two(int value) => value.toString().padLeft(2, '0');
    return '${two(date.day)}.${two(date.month)}.${date.year} '
        '${two(date.hour)}:${two(date.minute)}';
  }
}
