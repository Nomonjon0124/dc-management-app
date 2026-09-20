import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../../config/theme/app_colors.dart';
import '../../../../../../../core/widgets/app_filter_components.dart';

class MeetingPreviewTextArea extends StatelessWidget {
  const MeetingPreviewTextArea({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    required this.readOnly,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppFilterFieldLabel(label),
        DecoratedBox(
          decoration: BoxDecoration(
            color: colors.backgroundBase,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: colors.strokeSub, width: 1.w),
          ),
          child: SizedBox(
            height: 78.h,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              child: TextField(
                controller: controller,
                readOnly: readOnly,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                  height: 20 / 13,
                  color: colors.textStrong,
                ),
                decoration: InputDecoration.collapsed(
                  hintText: hint,
                  hintStyle: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                    height: 20 / 13,
                    color: colors.textSub,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
