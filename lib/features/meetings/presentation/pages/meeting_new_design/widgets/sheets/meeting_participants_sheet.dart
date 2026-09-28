import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../../../../config/theme/app_colors.dart';
import '../../../../../../../core/extentions/text_extensions.dart';
import '../../../../../../../core/gen/assets.gen.dart';
import '../../../../../../../core/widgets/tui_avatar.dart';
import '../../../../../../../l10n/app_localizations.dart';
import '../common/meeting_preview_icon_button.dart';

class MeetingParticipantsSheet extends StatelessWidget {
  const MeetingParticipantsSheet({
    super.key,
    required this.title,
    required this.onClose,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.participants,
  });

  final String title;
  final VoidCallback onClose;
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final List<MeetingParticipantItem> participants;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);
    final filtered = participants
        .where(
          (item) => item.name.toLowerCase().contains(searchQuery.toLowerCase()),
        )
        .toList();
    final inMeetingLabel = l10n.meetingCallInMeeting
        .s(11.sp)
        .w(800)
        .c(colors.textSoft);
    final sectionLabel = inMeetingLabel.copyWith(
      style: (inMeetingLabel.style ?? const TextStyle()).copyWith(
        letterSpacing: 0.6.w,
      ),
    );
    return Column(
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
        SizedBox(height: 10.h),
        Row(
          children: [
            Expanded(child: title.s(17.sp).w(800).c(colors.textStrong)),
            MeetingPreviewIconButton(
              asset: Assets.icons.icClose,
              background: colors.backgroundElevation2,
              foreground: colors.iconStrong,
              onTap: onClose,
              semanticLabel: l10n.meetingCallClose,
              size: 32.w,
              iconSize: 18.w,
            ),
          ],
        ),
        SizedBox(height: 14.h),
        DecoratedBox(
          decoration: BoxDecoration(
            color: colors.backgroundElevation1Alt,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
            child: Row(
              children: [
                Assets.icons.icSearch.svg(
                  width: 18.w,
                  height: 18.w,
                  colorFilter: ColorFilter.mode(
                    colors.iconSub,
                    BlendMode.srcIn,
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: TextField(
                    onChanged: onSearchChanged,
                    style: GoogleFonts.manrope(
                      color: colors.textStrong,
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      hintText: l10n.meetingCallSearchParticipant,
                      hintStyle: GoogleFonts.manrope(
                        color: colors.textSoft,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 18.h),
        sectionLabel,
        SizedBox(height: 8.h),
        for (final participant in filtered)
          _participantRow(context, participant),
      ],
    );
  }

  Widget _participantRow(
    BuildContext context,
    MeetingParticipantItem participant,
  ) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        children: [
          participant.avatar ??
              TuiAvatar(
                initial: participant.name,
                avatarUrl: participant.avatarUrl,
                size: 40,
              ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                participant.name
                    .s(13.sp)
                    .w(800)
                    .c(colors.textStrong)
                    .copyWith(maxLines: 1, overflow: TextOverflow.ellipsis),
                participant.role
                    .s(11.sp)
                    .w(500)
                    .c(colors.textSoft)
                    .copyWith(maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          if (participant.requestPending)
            DecoratedBox(
              decoration: BoxDecoration(
                color: colors.backgroundElevation2Alt,
                borderRadius: BorderRadius.circular(999.r),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                child: l10n.meetingCallRequestSent
                    .s(11.sp)
                    .w(800)
                    .c(colors.accentStrong),
              ),
            )
          else ...[
            if (participant.microphoneOn != null)
              _statusAction(
                context,
                asset: participant.microphoneOn!
                    ? Assets.icons.meetingMic
                    : Assets.icons.meetingMicOff,
                color: colors.iconSub,
                onTap: participant.onMicrophoneTap,
                semanticLabel: participant.microphoneOn!
                    ? l10n.meetingCallMicrophone
                    : l10n.meetingCallEnableMicrophone,
              ),
            if (participant.cameraOn != null) ...[
              SizedBox(width: 10.w),
              _statusAction(
                context,
                asset: participant.cameraOn!
                    ? Assets.icons.meetingVideo
                    : Assets.icons.meetingVideoOff,
                color: colors.iconSub,
                onTap: participant.onCameraTap,
                semanticLabel: participant.cameraOn!
                    ? l10n.meetingCallCamera
                    : l10n.meetingCallEnableCamera,
              ),
            ],
          ],
          if (participant.trailing != null) ...[
            SizedBox(width: 10.w),
            participant.trailing!,
          ],
        ],
      ),
    );
  }

  Widget _statusAction(
    BuildContext context, {
    required SvgGenImage asset,
    required Color color,
    required String semanticLabel,
    VoidCallback? onTap,
  }) {
    final icon = asset.svg(
      width: 18.w,
      height: 18.w,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
    if (onTap == null) return icon;
    return Semantics(
      button: true,
      label: semanticLabel,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999.r),
        child: SizedBox(
          width: 32.w,
          height: 32.w,
          child: Center(child: icon),
        ),
      ),
    );
  }
}

class MeetingParticipantItem {
  const MeetingParticipantItem({
    required this.name,
    required this.role,
    this.onMicrophoneTap,
    this.onCameraTap,
    this.requestPending = false,
    this.avatarUrl = '',
    this.avatar,
    this.microphoneOn,
    this.cameraOn,
    this.trailing,
  });

  final String name;
  final String role;
  final VoidCallback? onMicrophoneTap;
  final VoidCallback? onCameraTap;
  final bool requestPending;
  final String avatarUrl;
  final Widget? avatar;
  final bool? microphoneOn;
  final bool? cameraOn;
  final Widget? trailing;
}
