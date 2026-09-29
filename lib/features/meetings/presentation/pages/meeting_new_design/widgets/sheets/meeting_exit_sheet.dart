import 'package:flutter/material.dart';

/// Legacy no-op wrapper. Preview exit content now lives in
/// `widgets/preview/meeting_call_preview_sheet_host.dart`.
@Deprecated('Use the preview sheet host or production exit sheet instead.')
class MeetingExitSheet extends StatelessWidget {
  const MeetingExitSheet({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => child;
}
