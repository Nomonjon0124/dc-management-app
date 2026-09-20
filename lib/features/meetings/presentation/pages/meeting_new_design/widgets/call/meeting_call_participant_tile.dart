import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../../config/theme/app_colors.dart';
import '../../../../../../../core/extentions/text_extensions.dart';
import '../common/meeting_preview_avatar.dart';

class MeetingCallParticipantTile extends StatelessWidget {
  const MeetingCallParticipantTile({
    super.key,
    required this.assetPath,
    required this.name,
    this.active = false,
  });

  final String assetPath;
  final String name;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.chartNeutral,
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
          Center(
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
              child: MeetingPreviewAvatar(assetPath: assetPath, size: 56.w),
            ),
          ),
          Positioned(
            left: 12.w,
            right: 12.w,
            bottom: 10.h,
            child: name
                .s(12.sp)
                .w(500)
                .c(colors.textWhite)
                .copyWith(maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}
