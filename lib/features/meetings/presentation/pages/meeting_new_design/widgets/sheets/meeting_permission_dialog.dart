import 'package:flutter/material.dart';

class MeetingPermissionDialog extends StatelessWidget {
  const MeetingPermissionDialog({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Dialog(child: child);
}
