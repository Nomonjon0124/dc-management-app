import 'package:flutter/material.dart';

class MeetingPreviewAvatar extends StatelessWidget {
  const MeetingPreviewAvatar({
    super.key,
    required this.assetPath,
    required this.size,
  });

  final String assetPath;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Image.asset(
        assetPath,
        width: size,
        height: size,
        fit: BoxFit.cover,
      ),
    );
  }
}
