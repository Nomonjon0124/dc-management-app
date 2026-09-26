import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../domain/entities/meeting_room.dart';

/// Displays LiveKit/WebSocket reactions as short-lived floating stickers.
///
/// The animation follows the Figma sticker-flow note: stickers start at a
/// moderate size, launch from varied horizontal positions, get smaller while
/// moving upward, and fade before leaving the stage. The BLoC owns the active
/// list; once an item finishes, [onExpired] removes it.
class MeetingLiveReactionOverlay extends StatelessWidget {
  const MeetingLiveReactionOverlay({
    super.key,
    required this.reactions,
    required this.onExpired,
  });

  final List<MeetingRoomDataMessage> reactions;
  final ValueChanged<String> onExpired;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: reactions.isEmpty
          ? const SizedBox.shrink()
          : IgnorePointer(
              child: LayoutBuilder(
                builder: (context, constraints) => Stack(
                  clipBehavior: Clip.none,
                  children: [
                    for (final reaction in reactions)
                      _FloatingMeetingReaction(
                        key: ValueKey(reaction.id ?? reaction),
                        reaction: reaction,
                        stageWidth: constraints.maxWidth,
                        onExpired: onExpired,
                      ),
                  ],
                ),
              ),
            ),
    );
  }
}

class _FloatingMeetingReaction extends StatefulWidget {
  const _FloatingMeetingReaction({
    super.key,
    required this.reaction,
    required this.stageWidth,
    required this.onExpired,
  });

  final MeetingRoomDataMessage reaction;
  final double stageWidth;
  final ValueChanged<String> onExpired;

  @override
  State<_FloatingMeetingReaction> createState() =>
      _FloatingMeetingReactionState();
}

class _FloatingMeetingReactionState extends State<_FloatingMeetingReaction>
    with SingleTickerProviderStateMixin {
  static const _duration = Duration(milliseconds: 1800);

  late final AnimationController _controller;
  late final double _startLeft;
  late final double _drift;

  String get _reactionId => widget.reaction.id ?? widget.reaction.toString();

  @override
  void initState() {
    super.initState();
    final random = math.Random();
    final maxLeft = math.max(20.w, widget.stageWidth * 0.42 - 56.w);
    _startLeft = 20.w + random.nextDouble() * math.max(0.0, maxLeft - 20.w);
    _drift = 10 + random.nextDouble() * 19;
    _controller = AnimationController(vsync: this, duration: _duration)
      ..addStatusListener(_onAnimationStatus)
      ..forward();
  }

  void _onAnimationStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) widget.onExpired(_reactionId);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: _startLeft,
      bottom: 12.h,
      child: AnimatedBuilder(
        animation: _controller,
        child: SizedBox(
          width: 48.w,
          height: 48.w,
          child: Center(
            child: Text(
              widget.reaction.reaction ?? '',
              style: TextStyle(fontSize: 30.sp),
            ),
          ),
        ),
        builder: (context, child) {
          final progress = _controller.value;
          final fade = progress < 0.78
              ? 1.0 - progress * 0.35
              : 0.73 * (1 - (progress - 0.78) / 0.22);
          final scale = 1.0 - progress * 0.32;
          final drift = math.sin(progress * math.pi * 4) * _drift;

          return Opacity(
            opacity: fade.clamp(0.0, 1.0),
            child: Transform.translate(
              offset: Offset(drift, -300.h * progress),
              child: Transform.scale(scale: scale, child: child),
            ),
          );
        },
      ),
    );
  }
}
