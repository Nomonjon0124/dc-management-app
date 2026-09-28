import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:livekit_client/livekit_client.dart';

import '../../../../../../../config/theme/app_colors.dart';
import '../../../../../../../core/extentions/text_extensions.dart';
import '../../../../../../../core/gen/assets.gen.dart';
import '../../../../../../../core/widgets/tui_avatar.dart';
import '../common/meeting_preview_avatar.dart';

VideoViewFit meetingParticipantVideoFit({required bool screenShare}) =>
    screenShare ? VideoViewFit.contain : VideoViewFit.cover;

class MeetingCallParticipantTile extends StatelessWidget {
  const MeetingCallParticipantTile({
    super.key,
    required this.name,
    this.assetPath,
    this.avatarUrl = '',
    this.track,
    this.isLocal = false,
    this.microphoneOn = false,
    this.cameraOn = false,
    this.handRaised = false,
    this.active = false,
    this.avatarSize = 56,
    this.backgroundColor,
    this.showMicrophone = true,
    this.showCamera = false,
    this.compactLabel = false,
    this.smallLabel = false,
    this.avatarAlignment = Alignment.center,
    this.avatarPadding = EdgeInsets.zero,
    this.videoFit = VideoViewFit.cover,
    this.enableTemporaryZoom = false,
  });

  final String name;
  final String? assetPath;
  final String avatarUrl;
  final VideoTrack? track;
  final bool isLocal;
  final bool microphoneOn;
  final bool cameraOn;
  final bool handRaised;
  final bool active;
  final double avatarSize;
  final Color? backgroundColor;
  final bool showMicrophone;
  final bool showCamera;
  final bool compactLabel;
  final bool smallLabel;
  final Alignment avatarAlignment;
  final EdgeInsets avatarPadding;
  final VideoViewFit videoFit;
  final bool enableTemporaryZoom;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor ?? colors.chartNeutral,
        gradient: active
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colors.accentStrong.withValues(alpha: 0.38),
                  Colors.transparent,
                ],
              )
            : null,
        border: active
            ? Border.all(color: colors.accentSoft, width: 2.5.w)
            : null,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: track != null && cameraOn
                ? _videoTrack(track!)
                : Align(
                    alignment: avatarAlignment,
                    child: Padding(
                      padding: avatarPadding,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: active
                              ? [
                                  BoxShadow(
                                    color: colors.accentSoft,
                                    blurRadius: 18.r,
                                    spreadRadius: 6.r,
                                  ),
                                ]
                              : null,
                        ),
                        child: assetPath == null
                            ? TuiAvatar(
                                initial: name,
                                avatarUrl: avatarUrl,
                                size: avatarSize,
                              )
                            : MeetingPreviewAvatar(
                                assetPath: assetPath!,
                                size: avatarSize.w,
                              ),
                      ),
                    ),
                  ),
          ),
          Positioned(
            left: 12.w,
            right: 12.w,
            bottom: 16.h,
            child: Align(
              alignment: Alignment.bottomLeft,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 280.w),
                child: _nameLabel(name, colors, smallLabel: smallLabel),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _videoTrack(VideoTrack track) {
    final video = ClipRRect(
      borderRadius: BorderRadius.circular(12.r),
      child: VideoTrackRenderer(track, fit: videoFit),
    );
    if (!enableTemporaryZoom) return video;
    return MeetingTemporaryZoomViewer(resetKey: track, child: video);
  }

  Widget _nameLabel(String name, AppColors colors, {bool smallLabel = false}) {
    final labelText = name
        .s((smallLabel ? 11 : 13).sp)
        .w(500)
        .c(colors.textWhite)
        .copyWith(maxLines: 1, overflow: TextOverflow.ellipsis);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.black.withValues(alpha: 0.58),
        borderRadius: BorderRadius.circular((smallLabel ? 6 : 8).r),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: (smallLabel ? 8 : 12).w,
          vertical: (smallLabel ? 4 : 6).h,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(child: labelText),
            if (showMicrophone) ...[
              SizedBox(width: 6.w),
              if (active && microphoneOn)
                _SpeakingBars(color: colors.accentSoft)
              else
                (microphoneOn
                        ? Assets.icons.meetingMic
                        : Assets.icons.meetingMicOff)
                    .svg(
                      width: 14.w,
                      height: 14.w,
                      colorFilter: ColorFilter.mode(
                        colors.iconWhite,
                        BlendMode.srcIn,
                      ),
                    ),
            ],
            if (handRaised) ...[
              SizedBox(width: 6.w),
              Assets.icons.meetingHand.svg(
                width: 14.w,
                height: 14.w,
                colorFilter: ColorFilter.mode(
                  colors.successStrong,
                  BlendMode.srcIn,
                ),
              ),
            ],
            if (showCamera) ...[
              SizedBox(width: 6.w),
              (cameraOn
                      ? Assets.icons.meetingVideo
                      : Assets.icons.meetingVideoOff)
                  .svg(
                    width: 14.w,
                    height: 14.w,
                    colorFilter: ColorFilter.mode(
                      colors.iconWhite,
                      BlendMode.srcIn,
                    ),
                  ),
            ],
          ],
        ),
      ),
    );
  }
}

class MeetingTemporaryZoomViewer extends StatefulWidget {
  const MeetingTemporaryZoomViewer({
    super.key,
    required this.child,
    this.resetKey,
    this.transformationController,
    this.maxScale = 3,
  });

  final Widget child;
  final Object? resetKey;
  final TransformationController? transformationController;
  final double maxScale;

  @override
  State<MeetingTemporaryZoomViewer> createState() =>
      _MeetingTemporaryZoomViewerState();
}

class _MeetingTemporaryZoomViewerState
    extends State<MeetingTemporaryZoomViewer> {
  late TransformationController _controller;
  var _ownsController = false;

  @override
  void initState() {
    super.initState();
    _setController(widget.transformationController);
  }

  @override
  void didUpdateWidget(covariant MeetingTemporaryZoomViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.transformationController != widget.transformationController) {
      if (_ownsController) _controller.dispose();
      _setController(widget.transformationController);
    }
    if (!identical(oldWidget.resetKey, widget.resetKey)) _reset();
  }

  @override
  void dispose() {
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  void _setController(TransformationController? controller) {
    _controller = controller ?? TransformationController();
    _ownsController = controller == null;
  }

  void _reset() {
    _controller.value = Matrix4.identity();
  }

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      transformationController: _controller,
      minScale: 1,
      maxScale: widget.maxScale,
      scaleEnabled: true,
      panEnabled: false,
      onInteractionEnd: (_) => _reset(),
      child: widget.child,
    );
  }
}

class _SpeakingBars extends StatefulWidget {
  const _SpeakingBars({required this.color});

  final Color color;

  @override
  State<_SpeakingBars> createState() => _SpeakingBarsState();
}

class _SpeakingBarsState extends State<_SpeakingBars>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 620),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final progress = Curves.easeInOut.transform(_controller.value);
        final heights = [
          5.h + (5.h * progress),
          7.h + (7.h * progress),
          5.h + (4.h * progress),
        ];
        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            for (var index = 0; index < heights.length; index++) ...[
              if (index > 0) SizedBox(width: 2.w),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: widget.color,
                  borderRadius: BorderRadius.circular(1.r),
                ),
                child: SizedBox(width: 2.w, height: heights[index]),
              ),
            ],
          ],
        );
      },
    );
  }
}
