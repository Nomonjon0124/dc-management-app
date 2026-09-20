import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:livekit_client/livekit_client.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../core/extentions/text_extensions.dart';
import '../../../../core/gen/assets.gen.dart';
import '../../../../core/widgets/tui_avatar.dart';
import '../../../../injection_container.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/services/livekit_media_service.dart';
import '../../domain/entities/meeting_room.dart';
import '../bloc/meeting_room_bloc.dart';
import '../bloc/meeting_room_event.dart';
import '../bloc/meeting_room_state.dart';
import 'meeting_new_design/widgets/common/meeting_preview_button.dart';
import 'meeting_new_design/widgets/common/meeting_preview_icon_button.dart';
import 'meeting_new_design/widgets/common/meeting_preview_surface.dart';

/// Production meeting room shell. UI-only preview pages intentionally remain
/// separate from this page so demo state cannot be mistaken for server state.
class MeetingRoomPage extends StatelessWidget {
  const MeetingRoomPage({super.key, required this.meetingId});

  final int meetingId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<MeetingRoomBloc>()..add(MeetingRoomStarted(meetingId)),
      child: const _MeetingRoomView(),
    );
  }
}

class _MeetingRoomView extends StatelessWidget {
  const _MeetingRoomView();

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Scaffold(
      backgroundColor: colors.backgroundBase,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) =>
              BlocBuilder<MeetingRoomBloc, MeetingRoomState>(
                builder: (context, state) => Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 760.w),
                    child: Padding(
                      padding: EdgeInsets.all(16.w),
                      child: _body(context, state, constraints),
                    ),
                  ),
                ),
              ),
        ),
      ),
    );
  }

  Widget _body(
    BuildContext context,
    MeetingRoomState state,
    BoxConstraints constraints,
  ) {
    switch (state.phase) {
      case MeetingRoomPhase.connected:
      case MeetingRoomPhase.reconnecting:
        return _connected(context, state, constraints);
      case MeetingRoomPhase.waitingOrganizer:
      case MeetingRoomPhase.waitingApproval:
      case MeetingRoomPhase.socketConnecting:
      case MeetingRoomPhase.ticketLoading:
      case MeetingRoomPhase.joiningMedia:
        return _waiting(context, state);
      case MeetingRoomPhase.rejected:
      case MeetingRoomPhase.failure:
      case MeetingRoomPhase.left:
      case MeetingRoomPhase.ended:
        return _result(context, state);
      case MeetingRoomPhase.prejoin:
        return _prejoin(context, state);
    }
  }

  Widget _prejoin(BuildContext context, MeetingRoomState state) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);
    return _scrollable(
      children: [
        _header(context, state.title, l10n.meetingCallJoinTitle),
        SizedBox(height: 18.h),
        MeetingPreviewSurface(
          color: colors.cardSurface,
          radius: 18.r,
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              children: [
                SizedBox(
                  height: 180.h,
                  width: double.infinity,
                  child: _selfPreview(context, state),
                ),
                SizedBox(height: 16.h),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 12.w,
                  runSpacing: 12.h,
                  children: [
                    MeetingPreviewIconButton(
                      asset: state.microphoneEnabled
                          ? Assets.icons.meetingMic
                          : Assets.icons.meetingMicOff,
                      background: colors.backgroundElevation2,
                      foreground: colors.iconStrong,
                      semanticLabel: l10n.meetingCallMicrophone,
                      onTap: () => context.read<MeetingRoomBloc>().add(
                        const MeetingRoomMicrophoneToggled(),
                      ),
                    ),
                    MeetingPreviewIconButton(
                      asset: state.cameraEnabled
                          ? Assets.icons.meetingVideo
                          : Assets.icons.meetingVideoOff,
                      background: colors.backgroundElevation2,
                      foreground: colors.iconStrong,
                      semanticLabel: l10n.meetingCallCamera,
                      onTap: () => context.read<MeetingRoomBloc>().add(
                        const MeetingRoomCameraToggled(),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 18.h),
                MeetingPreviewButton(
                  label: l10n.meetingCallJoin,
                  background: colors.accentStrong,
                  foreground: colors.textWhite,
                  icon: Assets.icons.meetingJoin,
                  onTap: () => context.read<MeetingRoomBloc>().add(
                    const MeetingRoomJoinRequested(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _waiting(BuildContext context, MeetingRoomState state) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);
    final isConnecting = state.isLoading;
    final title = state.phase == MeetingRoomPhase.waitingOrganizer
        ? l10n.meetingCallWaitingTitle
        : l10n.meetingCallRequestSent;
    final hint = state.phase == MeetingRoomPhase.waitingOrganizer
        ? l10n.meetingCallWaitingHint
        : l10n.meetingCallApprovalHint;
    return _scrollable(
      children: [
        _header(context, state.title, title),
        SizedBox(height: 18.h),
        MeetingPreviewSurface(
          color: colors.cardSurface,
          radius: 18.r,
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isConnecting)
                  SizedBox(
                    width: 28.w,
                    height: 28.w,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.w,
                      color: colors.accentStrong,
                    ),
                  )
                else
                  Assets.icons.meetingInfo.svg(
                    width: 34.w,
                    height: 34.w,
                    colorFilter: ColorFilter.mode(
                      colors.iconAccent,
                      BlendMode.srcIn,
                    ),
                  ),
                SizedBox(height: 16.h),
                hint.s(15.sp).w(500).c(colors.textSub).a(TextAlign.center),
                SizedBox(height: 20.h),
                MeetingPreviewButton(
                  label: l10n.meetingCallCancel,
                  background: colors.backgroundElevation2,
                  foreground: colors.textStrong,
                  onTap: () => context.read<MeetingRoomBloc>().add(
                    const MeetingRoomJoinCancelled(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _connected(
    BuildContext context,
    MeetingRoomState state,
    BoxConstraints constraints,
  ) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);
    final compact = constraints.maxWidth < 420.w;
    final crossAxisCount = constraints.maxWidth >= 700.w
        ? 3
        : state.participants.length > 1 && !compact
        ? 2
        : 1;
    return Column(
      children: [
        _header(context, state.title, l10n.meetingCallInMeeting),
        if (state.errorMessage != null)
          Padding(
            padding: EdgeInsets.only(top: 8.h),
            child: state.errorMessage!
                .s(12.sp)
                .w(500)
                .c(colors.errorStrong)
                .copyWith(maxLines: 2, overflow: TextOverflow.ellipsis),
          ),
        SizedBox(height: 12.h),
        Expanded(
          child: state.participants.isEmpty
              ? Center(
                  child: l10n.meetingCallParticipant
                      .s(14.sp)
                      .w(500)
                      .c(colors.textSub),
                )
              : GridView.builder(
                  padding: EdgeInsets.only(bottom: 12.h),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 10.w,
                    mainAxisSpacing: 10.h,
                    childAspectRatio: compact ? 1.2 : 1.35,
                  ),
                  itemCount: state.participants.length,
                  itemBuilder: (context, index) =>
                      _ParticipantTile(participant: state.participants[index]),
                ),
        ),
        if (state.phase == MeetingRoomPhase.reconnecting)
          Padding(
            padding: EdgeInsets.only(bottom: 8.h),
            child: l10n.meetingCallWaitingHint
                .s(12.sp)
                .w(500)
                .c(colors.textSub)
                .a(TextAlign.center),
          ),
        _controls(context, state),
        if (state.isHost && state.pendingRequests.isNotEmpty)
          _pendingRequests(context, state),
      ],
    );
  }

  Widget _controls(BuildContext context, MeetingRoomState state) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);
    return MeetingPreviewSurface(
      color: colors.cardSurface,
      radius: 18.r,
      child: Padding(
        padding: EdgeInsets.all(10.w),
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: 8.w,
          runSpacing: 8.h,
          children: [
            MeetingPreviewIconButton(
              asset: state.microphoneEnabled
                  ? Assets.icons.meetingMic
                  : Assets.icons.meetingMicOff,
              background: state.microphoneEnabled
                  ? colors.backgroundElevation2
                  : colors.errorStrong,
              foreground: state.microphoneEnabled
                  ? colors.iconStrong
                  : colors.iconWhite,
              semanticLabel: l10n.meetingCallMicrophone,
              onTap: () => context.read<MeetingRoomBloc>().add(
                const MeetingRoomMicrophoneToggled(),
              ),
            ),
            MeetingPreviewIconButton(
              asset: state.cameraEnabled
                  ? Assets.icons.meetingVideo
                  : Assets.icons.meetingVideoOff,
              background: state.cameraEnabled
                  ? colors.backgroundElevation2
                  : colors.errorStrong,
              foreground: state.cameraEnabled
                  ? colors.iconStrong
                  : colors.iconWhite,
              semanticLabel: l10n.meetingCallCamera,
              onTap: () => context.read<MeetingRoomBloc>().add(
                const MeetingRoomCameraToggled(),
              ),
            ),
            MeetingPreviewButton(
              label: l10n.meetingCallLeave,
              background: colors.errorStrong,
              foreground: colors.textWhite,
              icon: Assets.icons.meetingCallEnd,
              onTap: () => context.read<MeetingRoomBloc>().add(
                const MeetingRoomLeaveRequested(),
              ),
            ),
            if (state.isHost)
              MeetingPreviewButton(
                label: l10n.meetingCallEndForEveryone,
                background: colors.backgroundElevation2,
                foreground: colors.errorStrong,
                icon: Assets.icons.meetingPower,
                onTap: () => _confirmEndMeeting(context),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmEndMeeting(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final shouldEnd = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.meetingCallEndForEveryone),
        content: Text(l10n.meetingCallExitQuestion),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.meetingCallCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(l10n.meetingCallEndForEveryone),
          ),
        ],
      ),
    );
    if (shouldEnd == true && context.mounted) {
      context.read<MeetingRoomBloc>().add(const MeetingRoomEndRequested());
    }
  }

  Widget _pendingRequests(BuildContext context, MeetingRoomState state) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: EdgeInsets.only(top: 10.h),
      child: MeetingPreviewSurface(
        color: colors.cardSurface,
        radius: 18.r,
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              l10n.meetingCallWantsToJoin.s(13.sp).w(700).c(colors.textStrong),
              SizedBox(height: 8.h),
              for (final request in state.pendingRequests)
                Padding(
                  padding: EdgeInsets.only(bottom: 8.h),
                  child: Row(
                    children: [
                      TuiAvatar(
                        initial: request.username,
                        avatarUrl: request.avatar ?? '',
                        size: 32,
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: request.username
                            .s(13.sp)
                            .w(600)
                            .c(colors.textStrong)
                            .copyWith(
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                      ),
                      TextButton(
                        onPressed: () => context.read<MeetingRoomBloc>().add(
                          MeetingRoomUserRejected(request.userId),
                        ),
                        child: l10n.meetingCallReject
                            .s(12.sp)
                            .w(600)
                            .c(colors.errorStrong),
                      ),
                      TextButton(
                        onPressed: () => context.read<MeetingRoomBloc>().add(
                          MeetingRoomUserApproved(request.userId),
                        ),
                        child: l10n.meetingCallAllow
                            .s(12.sp)
                            .w(600)
                            .c(colors.accentStrong),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _result(BuildContext context, MeetingRoomState state) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);
    final ended =
        state.phase == MeetingRoomPhase.ended ||
        state.phase == MeetingRoomPhase.left;
    final title = ended
        ? l10n.meetingCallMeetingEndedTitle
        : l10n.meetingCallRequestSent;
    final message = state.errorMessage ?? l10n.meetingCallMeetingEndedHint;
    return _scrollable(
      children: [
        _header(context, state.title, title),
        SizedBox(height: 18.h),
        MeetingPreviewSurface(
          color: colors.cardSurface,
          radius: 18.r,
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                message.s(15.sp).w(500).c(colors.textSub).a(TextAlign.center),
                SizedBox(height: 20.h),
                if (ended)
                  MeetingPreviewButton(
                    label: l10n.meetingCallRejoin,
                    background: colors.accentStrong,
                    foreground: colors.textWhite,
                    onTap: () => context.read<MeetingRoomBloc>().add(
                      const MeetingRoomRetryRequested(),
                    ),
                  )
                else
                  MeetingPreviewButton(
                    label: l10n.meetingCallJoin,
                    background: colors.accentStrong,
                    foreground: colors.textWhite,
                    onTap: () => context.read<MeetingRoomBloc>().add(
                      const MeetingRoomRetryRequested(),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _header(BuildContext context, String title, String status) {
    final colors = AppColors.of(context);
    return Row(
      children: [
        Expanded(
          child: (title.isEmpty ? status : title)
              .s(18.sp)
              .w(700)
              .c(colors.textStrong)
              .copyWith(maxLines: 2, overflow: TextOverflow.ellipsis),
        ),
        SizedBox(width: 12.w),
        Flexible(
          child: status
              .s(12.sp)
              .w(600)
              .c(colors.textSub)
              .a(TextAlign.end)
              .copyWith(maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }

  Widget _selfPreview(BuildContext context, MeetingRoomState state) {
    final colors = AppColors.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.backgroundElevation3,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Center(
        child: TuiAvatar(
          initial: AppLocalizations.of(context).meetingCallYou,
          size: 84,
        ),
      ),
    );
  }

  Widget _scrollable({required List<Widget> children}) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }
}

class _ParticipantTile extends StatelessWidget {
  const _ParticipantTile({required this.participant});

  final MeetingRoomParticipant participant;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final media = getIt.isRegistered<LiveKitMediaService>()
        ? getIt<LiveKitMediaService>()
        : null;
    final track = media?.videoTrackFor(participant.identity);
    return MeetingPreviewSurface(
      color: colors.backgroundElevation3,
      radius: 16.r,
      child: Stack(
        children: [
          Positioned.fill(
            child: track != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(16.r),
                    child: VideoTrackRenderer(track, fit: VideoViewFit.cover),
                  )
                : Center(child: TuiAvatar(initial: participant.name, size: 72)),
          ),
          Positioned(
            left: 8.w,
            right: 8.w,
            bottom: 8.h,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: colors.black.withValues(alpha: 0.58),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
                child: Row(
                  children: [
                    Expanded(
                      child:
                          (participant.isLocal
                                  ? AppLocalizations.of(context).meetingCallYou
                                  : participant.name)
                              .s(12.sp)
                              .w(600)
                              .c(colors.textWhite)
                              .copyWith(
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                    ),
                    SizedBox(width: 6.w),
                    (participant.microphoneEnabled
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
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
