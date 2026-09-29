import 'package:flutter/material.dart';

/// Legacy no-op wrapper. Preview camera content now lives in
/// `widgets/preview/meeting_call_preview_sheet_host.dart`.
@Deprecated('Use the preview sheet host or production camera sheet instead.')
class MeetingCameraSheet extends StatelessWidget {
  const MeetingCameraSheet({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => child;
}
