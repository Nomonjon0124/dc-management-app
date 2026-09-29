import 'package:flutter/material.dart';

/// Legacy no-op wrapper. Preview sharing content now lives in
/// `widgets/preview/meeting_call_preview_sheet_host.dart`.
@Deprecated('Use the preview sheet host or production share sheet instead.')
class MeetingShareScreenSheet extends StatelessWidget {
  const MeetingShareScreenSheet({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => child;
}
