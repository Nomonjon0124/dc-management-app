import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:livekit_client/livekit_client.dart';

import '../../../../../../../config/theme/app_colors.dart';
import '../../../../../../../core/extentions/text_extensions.dart';
import '../../../../../../../core/gen/assets.gen.dart';
import '../../../../../../../core/widgets/tui_avatar.dart';
import '../common/meeting_preview_avatar.dart';

class MeetingCallParticipantTile extends StatelessWidget {
  const MeetingCallParticipantTile({
    super.key,
    required this.name,
    this.assetPath,
    this.avatarUrl = '',
    this.track,
    this.isLocal = false,
    this.microphoneOn = false,
    this.cameraOn = false,
    this.handRaised = false,
    this.active = false,
    this.avatarSize = 56,
    this.backgroundColor,
    this.showMicrophone = true,
    this.showCamera = false,
    this.compactLabel = false,
    this.avatarAlignment = Alignment.center,
    this.avatarPadding = EdgeInsets.zero,
  });

  final String name;
  final String? assetPath;
  final String avatarUrl;
  final VideoTrack? track;
  final bool isLocal;
  final bool microphoneOn;
  final bool cameraOn;
  final bool handRaised;
  final bool active;
  final double avatarSize;
  final Color? backgroundColor;
  final bool showMicrophone;
  final bool showCamera;
  final bool compactLabel;
  final Alignment avatarAlignment;
  final EdgeInsets avatarPadding;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor ?? colors.chartNeutral,
        gradient: active
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [colors.accentStrong, colors.chartNeutral],
              )
            : null,
        border: active
            ? Border.all(color: colors.accentSoft, width: 2.w)
            : null,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: track != null && cameraOn
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12.r),
                    child: VideoTrackRenderer(track!, fit: VideoViewFit.cover),
                  )
                : Align(
                    alignment: avatarAlignment,
                    child: Padding(
                      padding: avatarPadding,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: active
                              ? [
                                  BoxShadow(
                                    color: colors.accentSoft,
                                    blurRadius: 18.r,
                                    spreadRadius: 6.r,
                                  ),
                                ]
                              : null,
                        ),
                        child: assetPath == null
                            ? TuiAvatar(
                                initial: name,
                                avatarUrl: avatarUrl,
                                size: avatarSize,
                              )
                            : MeetingPreviewAvatar(
                                assetPath: assetPath!,
                                size: avatarSize.w,
                              ),
                      ),
                    ),
                  ),
          ),
          Positioned(
            left: 12.w,
            right: 12.w,
            bottom: 16.h,
            child: compactLabel
                ? Align(
                    alignment: Alignment.bottomLeft,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: 220.w),
                      child: _nameLabel(
                        name,
                        colors,
                        mainAxisSize: MainAxisSize.min,
                      ),
                    ),
                  )
                : _nameLabel(name, colors),
          ),
        ],
      ),
    );
  }

  Widget _nameLabel(
    String name,
    AppColors colors, {
    MainAxisSize mainAxisSize = MainAxisSize.max,
  }) {
    final labelText = name
        .s(12.sp)
        .w(500)
        .c(colors.textWhite)
        .copyWith(maxLines: 1, overflow: TextOverflow.ellipsis);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.black.withValues(alpha: 0.58),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
        child: Row(
          mainAxisSize: mainAxisSize,
          children: [
            if (mainAxisSize == MainAxisSize.min)
              Flexible(child: labelText)
            else
              Expanded(child: labelText),
            if (showMicrophone) ...[
              SizedBox(width: 6.w),
              (microphoneOn
                      ? Assets.icons.meetingMic
                      : Assets.icons.meetingMicOff)
                  .svg(
                    width: 14.w,
                    height: 14.w,
                    colorFilter: ColorFilter.mode(
                      colors.iconWhite,
                      BlendMode.srcIn,
                    ),
                  ),
            ],
            if (handRaised) ...[
              SizedBox(width: 6.w),
              Assets.icons.meetingHand.svg(
                width: 14.w,
                height: 14.w,
                colorFilter: ColorFilter.mode(
                  colors.successStrong,
                  BlendMode.srcIn,
                ),
              ),
            ],
            if (showCamera) ...[
              SizedBox(width: 6.w),
              (cameraOn
                      ? Assets.icons.meetingVideo
                      : Assets.icons.meetingVideoOff)
                  .svg(
                    width: 14.w,
                    height: 14.w,
                    colorFilter: ColorFilter.mode(
                      colors.iconWhite,
                      BlendMode.srcIn,
                    ),
                  ),
            ],
          ],
        ),
      ),
    );
  }
}
