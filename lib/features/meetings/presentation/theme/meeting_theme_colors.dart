import 'package:flutter/material.dart';

import '../../../../config/theme/app_colors.dart';

/// Meeting UI surface mapping.
///
/// The shared dark palette keeps [AppColors.backgroundElevation2] as a light
/// legacy value for other features. Meeting controls need a dark neutral
/// surface in dark mode, so this feature resolves the semantic role locally.
extension MeetingThemeColors on AppColors {
  bool get meetingIsDark => backgroundBase.computeLuminance() < 0.5;

  Color get meetingControlSurface =>
      meetingIsDark ? backgroundElevation2Alt : backgroundElevation2;

  Color get meetingDestructiveSurface =>
      meetingIsDark ? errorDisabled : errorSoft;
}
