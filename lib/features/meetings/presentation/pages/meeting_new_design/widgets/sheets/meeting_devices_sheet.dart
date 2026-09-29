import 'package:flutter/material.dart';

/// Legacy no-op wrapper. Preview device content now lives in
/// `widgets/preview/meeting_call_preview_sheet_host.dart`.
@Deprecated('Use the preview sheet host or production devices sheet instead.')
class MeetingDevicesSheet extends StatelessWidget {
  const MeetingDevicesSheet({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => child;
}
