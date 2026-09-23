import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../../config/theme/app_colors.dart';
import '../../../../../../../core/gen/assets.gen.dart';
import '../../../../../../../core/widgets/app_filter_components.dart';

class MeetingPreviewField extends StatelessWidget {
  const MeetingPreviewField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    required this.readOnly,
    this.keyboardType,
    this.inputFormatters,
    this.trailingIcon,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final bool readOnly;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final SvgGenImage? trailingIcon;

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
            height: 44.h,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              child: Row(
                children: [
                  Expanded(
                    child: Center(
                      child: TextField(
                        controller: controller,
                        readOnly: readOnly,
                        keyboardType: keyboardType,
                        inputFormatters: inputFormatters,
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w500,
                          height: 20 / 13,
                          color: colors.textStrong,
                        ),
                        cursorColor: colors.accentSub,
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
                  if (trailingIcon != null)
                    trailingIcon!.svg(
                      width: 16.w,
                      height: 16.w,
                      colorFilter: ColorFilter.mode(
                        colors.iconSub,
                        BlendMode.srcIn,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
