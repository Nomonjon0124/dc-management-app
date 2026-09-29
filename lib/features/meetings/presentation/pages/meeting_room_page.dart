import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/entity/routes.dart';
import '../../../../config/theme/app_colors.dart';
import '../../../../core/extentions/text_extensions.dart';
import '../../../../core/gen/assets.gen.dart';
import '../../../../core/widgets/tui_avatar.dart';
import '../../../../injection_container.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/services/livekit_media_service.dart';
import '../../domain/entities/meeting.dart';
import '../../domain/entities/meeting_room.dart';
import '../../domain/entities/meeting_filter.dart';
import '../../domain/usecases/get_meetings_usecase.dart';
import '../bloc/meeting_room_bloc.dart';
import '../bloc/meeting_room_event.dart';
import '../bloc/meeting_room_state.dart';
import 'meeting_new_design/widgets/call/meeting_call_control_bar.dart';
import 'meeting_new_design/widgets/call/meeting_call_join_request.dart';
import 'meeting_new_design/widgets/call/meeting_call_participant_tile.dart';
import 'meeting_new_design/widgets/call/meeting_call_stage.dart';
import 'meeting_new_design/widgets/call/meeting_call_stickers_panel.dart';
import 'meeting_new_design/widgets/call/meeting_call_top_bar.dart';
import 'meeting_new_design/widgets/common/meeting_preview_button.dart';
import 'meeting_new_design/widgets/common/meeting_ended_result.dart';
import 'meeting_new_design/widgets/common/meeting_preview_icon_button.dart';
import 'meeting_new_design/widgets/common/meeting_preview_surface.dart';
import 'meeting_new_design/widgets/form/meeting_preview_header.dart';
import 'meeting_new_design/widgets/sheets/meeting_details_sheet.dart';
import 'meeting_new_design/widgets/sheets/meeting_exit_sheet.dart';
import 'meeting_new_design/widgets/sheets/meeting_chat_sheet.dart';
import 'meeting_new_design/widgets/sheets/meeting_more_sheet.dart';
import 'meeting_new_design/widgets/sheets/meeting_participants_sheet.dart';
import 'meeting_new_design/widgets/sheets/meeting_permission_dialog.dart';
import '../widgets/meeting_live_reaction_overlay.dart';

/// Production meeting room. The meeting WebSocket and LiveKit remain owned by
/// [MeetingRoomBloc]; this page only renders the Figma-aligned UI for its state.
class MeetingRoomPage extends StatelessWidget {
  const MeetingRoomPage({
    super.key,
    required this.meetingId,
    this.initialMeeting,
  });

  final int meetingId;
  final Meeting? initialMeeting;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<MeetingRoomBloc>()
        ..add(MeetingRoomStarted(meetingId, initialMeeting: initialMeeting)),
      child: const _MeetingRoomView(),
    );
  }
}

/// Resolves a shared UID link before opening the numeric meeting room route.
class MeetingRoomLookupPage extends StatefulWidget {
  const MeetingRoomLookupPage({super.key, required this.reference});

  final String reference;

  @override
  State<MeetingRoomLookupPage> createState() => _MeetingRoomLookupPageState();
}

class _MeetingRoomLookupPageState extends State<MeetingRoomLookupPage> {
  late final Future<List<Meeting>> _lookup;

  @override
  void initState() {
    super.initState();
    _lookup = getIt<GetMeetingsUseCase>()(MeetingFilter(uid: widget.reference));
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: colors.backgroundBase,
      body: SafeArea(
        child: FutureBuilder<List<Meeting>>(
          future: _lookup,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return Center(
                child: CircularProgressIndicator(color: colors.accentStrong),
              );
            }
            final meetings = snapshot.data ?? const <Meeting>[];
            Meeting? meeting;
            for (final item in meetings) {
              if (item.uid.toLowerCase() == widget.reference.toLowerCase()) {
                meeting = item;
                break;
              }
            }
            if (meeting == null || snapshot.hasError) {
              return _lookupFailure(context, l10n);
            }
            return MeetingRoomPage(
              meetingId: meeting.id,
              initialMeeting: meeting,
            );
          },
        ),
      ),
    );
  }

  Widget _lookupFailure(BuildContext context, AppLocalizations l10n) {
    final colors = AppColors.of(context);
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            l10n.commonError
                .s(15.sp)
                .w(700)
                .c(colors.textStrong)
                .a(TextAlign.center),
            SizedBox(height: 16.h),
            MeetingPreviewButton(
              label: l10n.meetingCallHome,
              background: colors.accentStrong,
              foreground: colors.textWhite,
              icon: Assets.icons.icArrowLeftLarge,
              onTap: () => context.goNamed(Routes.meetings.name),
            ),
          ],
        ),
      ),
    );
  }
}

class _MeetingRoomView extends StatefulWidget {
  const _MeetingRoomView();

  @override
  State<_MeetingRoomView> createState() => _MeetingRoomViewState();
}

class _MeetingRoomViewState extends State<_MeetingRoomView> {
  bool _stickersOpen = false;

  void _toggleStickers() {
    setState(() => _stickersOpen = !_stickersOpen);
  }

  void _closeStickers() {
    if (_stickersOpen) setState(() => _stickersOpen = false);
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Scaffold(
      backgroundColor: colors.backgroundElevation1,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) =>
              BlocBuilder<MeetingRoomBloc, MeetingRoomState>(
                builder: (context, state) {
                  final connected =
                      state.phase == MeetingRoomPhase.connected ||
                      state.phase == MeetingRoomPhase.reconnecting;
                  final body = _body(context, state, constraints);
                  return Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: 900.w),
                      child: connected
                          ? body
                          : Padding(padding: EdgeInsets.all(16.w), child: body),
                    ),
                  );
                },
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
      case MeetingRoomPhase.prejoin:
        return _prejoin(context, state, constraints);
      case MeetingRoomPhase.waitingOrganizer:
      case MeetingRoomPhase.waitingApproval:
      case MeetingRoomPhase.ticketLoading:
      case MeetingRoomPhase.socketConnecting:
      case MeetingRoomPhase.joiningMedia:
        return _waiting(context, state, constraints);
      case MeetingRoomPhase.connected:
      case MeetingRoomPhase.reconnecting:
        return _connected(context, state, constraints);
      case MeetingRoomPhase.rejected:
      case MeetingRoomPhase.failure:
      case MeetingRoomPhase.left:
      case MeetingRoomPhase.ended:
        return _result(context, state);
    }
  }

  Widget _prejoin(
    BuildContext context,
    MeetingRoomState state,
    BoxConstraints constraints,
  ) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);
    final compact = constraints.maxWidth > constraints.maxHeight;
    final avatarSize = compact ? 56.0 : 88.0;
    final stageHeight = compact ? constraints.maxHeight * 0.82 : 400.h;
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: constraints.maxHeight),
        child: Column(
          children: [
            MeetingPreviewHeader(
              title: l10n.meetingCallJoinTitle,
              roundClose: true,
            ),
            SizedBox(height: 8.h),
            MeetingCallStage(
              child: ColoredBox(
                color: colors.chartNeutral,
                child: SizedBox(
                  height: stageHeight,
                  width: double.infinity,
                  child: Stack(
                    children: [
                      Align(
                        alignment: Alignment.topCenter,
                        child: Padding(
                          padding: EdgeInsets.only(
                            top: compact ? stageHeight * 0.2 : 116.h,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TuiAvatar(
                                initial:
                                    state.meeting?.participantName.isNotEmpty ==
                                        true
                                    ? state.meeting!.participantName
                                    : l10n.meetingCallYou,
                                avatarUrl:
                                    state.meeting?.participantAvatar ?? '',
                                size: avatarSize,
                              ),
                              SizedBox(height: 16.h),
                              (state.cameraEnabled
                                      ? l10n.meetingCallCamera
                                      : l10n.meetingCallCameraOff)
                                  .s(13.sp)
                                  .w(500)
                                  .c(colors.textSoft),
                            ],
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: EdgeInsets.only(bottom: 20.h),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              MeetingPreviewIconButton(
                                asset: state.microphoneEnabled
                                    ? Assets.icons.meetingMic
                                    : Assets.icons.meetingMicOff,
                                background: state.microphoneEnabled
                                    ? colors.backgroundElevation1
                                    : colors.errorStrong,
                                foreground: state.microphoneEnabled
                                    ? colors.iconStrong
                                    : colors.iconWhite,
                                semanticLabel: l10n.meetingCallMicrophone,
                                size: compact ? 40.w : null,
                                iconSize: compact ? 18.w : null,
                                onTap: () => context
                                    .read<MeetingRoomBloc>()
                                    .add(const MeetingRoomMicrophoneToggled()),
                              ),
                              SizedBox(width: 12.w),
                              MeetingPreviewIconButton(
                                asset: state.cameraEnabled
                                    ? Assets.icons.meetingVideo
                                    : Assets.icons.meetingVideoOff,
                                background: state.cameraEnabled
                                    ? colors.backgroundElevation1
                                    : colors.errorStrong,
                                foreground: state.cameraEnabled
                                    ? colors.iconStrong
                                    : colors.iconWhite,
                                semanticLabel: l10n.meetingCallCamera,
                                size: compact ? 40.w : null,
                                iconSize: compact ? 18.w : null,
                                onTap: () => context
                                    .read<MeetingRoomBloc>()
                                    .add(const MeetingRoomCameraToggled()),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Align(
              alignment: Alignment.centerLeft,
              child:
                  (state.title.isEmpty
                          ? l10n.meetingCallSampleTitle
                          : state.title)
                      .s(20.sp)
                      .w(800)
                      .c(colors.textStrong)
                      .copyWith(maxLines: 2, overflow: TextOverflow.ellipsis),
            ),
            SizedBox(height: 12.h),
            MeetingPreviewSurface(
              color: colors.backgroundElevation1Alt,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                child: Row(
                  children: [
                    Assets.icons.meetingCopy.svg(
                      width: 18.w,
                      height: 18.w,
                      colorFilter: ColorFilter.mode(
                        colors.iconSub,
                        BlendMode.srcIn,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    (state.meeting?.uid.isNotEmpty == true
                            ? state.meeting!.uid
                            : l10n.meetingCallMeetingUid)
                        .s(15.sp)
                        .w(800)
                        .c(colors.textStrong),
                  ],
                ),
              ),
            ),
            SizedBox(height: 14.h),
            MeetingPreviewButton(
              label: l10n.meetingCallJoin,
              background: colors.accentStrong,
              foreground: colors.textWhite,
              icon: Assets.icons.meetingJoin,
              onTap: () => context.read<MeetingRoomBloc>().add(
                const MeetingRoomJoinRequested(),
              ),
            ),
            SizedBox(height: 12.h),
            l10n.meetingCallApprovalHint
                .s(12.sp)
                .w(500)
                .c(colors.textSub)
                .a(TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _previewStage(
    BuildContext context,
    MeetingRoomState state,
    BoxConstraints constraints,
  ) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);
    final compact = constraints.maxWidth > constraints.maxHeight;
    final avatarSize = compact ? 56.0 : 88.0;
    final stageHeight = compact ? constraints.maxHeight * 0.82 : 400.h;
    return MeetingCallStage(
      child: ColoredBox(
        color: colors.chartNeutral,
        child: SizedBox(
          height: stageHeight,
          width: double.infinity,
          child: Stack(
            children: [
              Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: EdgeInsets.only(
                    top: compact ? stageHeight * 0.2 : 116.h,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TuiAvatar(
                        initial:
                            state.meeting?.participantName.isNotEmpty == true
                            ? state.meeting!.participantName
                            : l10n.meetingCallYou,
                        avatarUrl: state.meeting?.participantAvatar ?? '',
                        size: avatarSize,
                      ),
                      SizedBox(height: 16.h),
                      l10n.meetingCallCameraOff
                          .s(13.sp)
                          .w(500)
                          .c(colors.textSoft),
                    ],
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: EdgeInsets.only(bottom: 20.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      MeetingPreviewIconButton(
                        asset: state.microphoneEnabled
                            ? Assets.icons.meetingMic
                            : Assets.icons.meetingMicOff,
                        background: state.microphoneEnabled
                            ? colors.backgroundElevation1
                            : colors.errorStrong,
                        foreground: state.microphoneEnabled
                            ? colors.iconStrong
                            : colors.iconWhite,
                        semanticLabel: l10n.meetingCallMicrophone,
                        size: compact ? 40.w : null,
                        iconSize: compact ? 18.w : null,
                        onTap: () => context.read<MeetingRoomBloc>().add(
                          const MeetingRoomMicrophoneToggled(),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      MeetingPreviewIconButton(
                        asset: state.cameraEnabled
                            ? Assets.icons.meetingVideo
                            : Assets.icons.meetingVideoOff,
                        background: state.cameraEnabled
                            ? colors.backgroundElevation1
                            : colors.errorStrong,
                        foreground: state.cameraEnabled
                            ? colors.iconStrong
                            : colors.iconWhite,
                        semanticLabel: l10n.meetingCallCamera,
                        size: compact ? 40.w : null,
                        iconSize: compact ? 18.w : null,
                        onTap: () => context.read<MeetingRoomBloc>().add(
                          const MeetingRoomCameraToggled(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _waiting(
    BuildContext context,
    MeetingRoomState state,
    BoxConstraints constraints,
  ) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);
    final isConnecting = state.isLoading;
    final waitingForOrganizer =
        state.phase == MeetingRoomPhase.waitingOrganizer;
    final title = waitingForOrganizer
        ? l10n.meetingCallWaitingTitle
        : l10n.meetingCallWaitingTitle;
    final hint = waitingForOrganizer
        ? l10n.meetingCallWaitingHint
        : l10n.meetingCallWaitingHint;
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        children: [
          MeetingPreviewHeader(title: title, roundClose: true),
          SizedBox(height: 8.h),
          _previewStage(context, state, constraints),
          SizedBox(height: 20.h),
          MeetingPreviewSurface(
            color: colors.backgroundBase,
            radius: 12.r,
            borderColor: colors.strokeSub,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: Row(
                children: [
                  if (isConnecting)
                    SizedBox(
                      width: 24.w,
                      height: 24.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.w,
                        color: colors.accentStrong,
                      ),
                    )
                  else
                    Assets.icons.icTuilconTime.svg(
                      width: 24.w,
                      height: 24.w,
                      colorFilter: ColorFilter.mode(
                        colors.iconStrong,
                        BlendMode.srcIn,
                      ),
                    ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        l10n.meetingCallRequestSent
                            .s(15.sp)
                            .w(800)
                            .c(colors.textStrong),
                        SizedBox(height: 4.h),
                        hint.s(13.sp).w(500).c(colors.textSub),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16.h),
          MeetingPreviewButton(
            label: l10n.meetingCallCancel,
            background: colors.backgroundElevation2,
            foreground: colors.textStrong,
            icon: Assets.icons.icClose,
            onTap: () => context.read<MeetingRoomBloc>().add(
              const MeetingRoomJoinCancelled(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _connected(
    BuildContext context,
    MeetingRoomState state,
    BoxConstraints constraints,
  ) {
    final l10n = AppLocalizations.of(context);
    final media = getIt<LiveKitMediaService>();
    final compact = constraints.maxWidth < 420.w;
    final displayError = state.error == MeetingRoomError.screenShareFailed
        ? l10n.meetingCallScreenShareError
        : state.errorMessage;
    final crossAxisCount = constraints.maxWidth >= 700.w
        ? 3
        : state.participants.length > 1 && !compact
        ? 2
        : 1;
    final floatingParticipant = _floatingParticipant(state);
    return Stack(
      children: [
        Column(
          children: [
            MeetingCallTopBar(
              title: state.title.isEmpty
                  ? l10n.meetingCallInMeeting
                  : state.title,
              participantCount: '${state.participants.length}',
              onTitleTap: () => _showDetails(context, state),
              onEndTap: () => _showExit(context, state),
              onParticipantsTap: () => _showParticipants(context, state),
              endLabel: l10n.meetingCallEnd,
            ),
            if (displayError != null)
              Padding(
                padding: EdgeInsets.only(top: 4.h),
                child: displayError
                    .s(12.sp)
                    .w(500)
                    .c(AppColors.of(context).errorStrong)
                    .a(TextAlign.center)
                    .copyWith(maxLines: 2, overflow: TextOverflow.ellipsis),
              ),
            SizedBox(height: 8.h),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: MeetingCallStage(
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: _speakerStage(
                          context,
                          state,
                          media,
                          crossAxisCount,
                          compact,
                          l10n,
                        ),
                      ),
                      if (floatingParticipant != null)
                        Positioned(
                          right: 12.w,
                          top: 12.h,
                          child: SizedBox(
                            width: 96.w,
                            height: 128.h,
                            child: _participantTile(
                              context,
                              floatingParticipant,
                              media,
                              l10n,
                              meeting: state.meeting,
                              avatarSize: 40,
                              backgroundColor: floatingParticipant.isLocal
                                  ? AppColors.of(context).meetingLocalTile
                                  : AppColors.of(context).chartNeutral,
                              showMicrophone: false,
                              showCamera: false,
                              compactLabel: true,
                              smallLabel: true,
                            ),
                          ),
                        ),
                      if (state.isHost && state.pendingRequests.isNotEmpty)
                        Positioned(
                          left: 0,
                          right: 0,
                          top: 0,
                          child: _pendingRequestOverlay(context, state),
                        ),
                      if (state.handRaiseNoticeName != null)
                        Positioned(
                          top: 16.h,
                          left: 12.w,
                          right: 12.w,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: AppColors.of(context).successSoft,
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                                vertical: 10.h,
                              ),
                              child: Row(
                                children: [
                                  Assets.icons.meetingHand.svg(
                                    width: 20.w,
                                    height: 20.w,
                                    colorFilter: ColorFilter.mode(
                                      AppColors.of(context).successStrong,
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                  SizedBox(width: 8.w),
                                  Expanded(
                                    child: l10n
                                        .meetingCallRaisedBy(
                                          state.handRaiseNoticeName!,
                                        )
                                        .s(13.sp)
                                        .w(700)
                                        .c(AppColors.of(context).textStrong),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      MeetingLiveReactionOverlay(
                        reactions: state.reactions,
                        onExpired: (reactionId) => context
                            .read<MeetingRoomBloc>()
                            .add(MeetingRoomReactionExpired(reactionId)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (state.phase == MeetingRoomPhase.reconnecting)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8.h),
                child: l10n.meetingCallWaitingHint
                    .s(12.sp)
                    .w(500)
                    .c(AppColors.of(context).textSub)
                    .a(TextAlign.center),
              ),
            SizedBox(height: 8.h),
            MeetingCallControlBar(
              microphoneOn: state.microphoneEnabled,
              cameraOn: state.cameraEnabled,
              handRaised: state.handRaised,
              onMicrophone: () => context.read<MeetingRoomBloc>().add(
                const MeetingRoomMicrophoneToggled(),
              ),
              onCamera: () => context.read<MeetingRoomBloc>().add(
                const MeetingRoomCameraToggled(),
              ),
              onHand: () => context.read<MeetingRoomBloc>().add(
                const MeetingRoomHandToggled(),
              ),
              onMore: () => _showMore(context, state),
              onLeave: () => _showExit(context, state),
              microphoneLabel: l10n.meetingCallMicrophone,
              cameraLabel: l10n.meetingCallCamera,
              handLabel: l10n.meetingCallRaiseHand,
              moreLabel: l10n.meetingCallMore,
              leaveLabel: l10n.meetingCallLeave,
              onMicrophoneMenu: () => _showDevices(context, state),
              onCameraMenu: () => _showCamera(context, state),
            ),
          ],
        ),
        if (_stickersOpen) ...[
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _closeStickers,
              child: const SizedBox.expand(),
            ),
          ),
          Positioned(
            left: 8.w,
            right: 8.w,
            bottom: 78.h,
            child: MeetingCallStickersPanel(
              onSelected: (reaction) => context.read<MeetingRoomBloc>().add(
                MeetingRoomReactionSent(reaction),
              ),
              onClosed: _closeStickers,
            ),
          ),
        ],
        if (!state.isHost && state.pendingUnmuteRequests.isNotEmpty)
          Positioned.fill(
            child: ColoredBox(
              color: AppColors.of(context).black.withValues(alpha: 0.18),
              child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  child: _unmuteRequestOverlay(context, state),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _speakerStage(
    BuildContext context,
    MeetingRoomState state,
    LiveKitMediaService media,
    int crossAxisCount,
    bool compact,
    AppLocalizations l10n,
  ) {
    final colors = AppColors.of(context);
    final remote = state.participants.where((p) => !p.isLocal).toList();
    final screenParticipant = state.participants
        .cast<MeetingRoomParticipant?>()
        .firstWhere(
          (participant) => participant?.screenSharing == true,
          orElse: () => null,
        );
    if (screenParticipant != null) {
      return _participantTile(
        context,
        screenParticipant,
        media,
        l10n,
        meeting: state.meeting,
        avatarSize: 56,
        showMicrophone: true,
        screenShare: true,
        allowActions: state.isHost,
      );
    }
    if (remote.isEmpty) {
      if (compact && state.participants.isNotEmpty) {
        return _participantTile(
          context,
          state.participants.first,
          media,
          l10n,
          meeting: state.meeting,
          avatarSize: 56,
          showMicrophone: false,
          allowActions: false,
        );
      }
      return ColoredBox(
        color: colors.chartNeutral,
        child: Center(
          child: l10n.meetingCallParticipant.s(14.sp).w(500).c(colors.textSoft),
        ),
      );
    }
    final speaker = remote.firstWhere(
      (participant) => participant.isSpeaking,
      orElse: () => remote.first,
    );
    if (remote.length == 1) {
      final primary = _singleStageParticipant(state, speaker);
      return _participantTile(
        context,
        primary,
        media,
        l10n,
        meeting: state.meeting,
        avatarSize: 88,
        avatarAlignment: Alignment.topCenter,
        avatarPadding: EdgeInsets.only(top: 128.h),
        showMicrophone: false,
        showCamera: false,
        compactLabel: false,
        allowActions: state.isHost,
      );
    }
    final gridParticipants = compact
        ? _mobileParticipantOrder(
            state.participants,
            speaker,
            state.pinnedParticipantIdentity,
          )
        : remote;
    return ColoredBox(
      color: colors.backgroundElevation2Alt,
      child: LayoutBuilder(
        builder: (context, stageConstraints) {
          final paddingHorizontal = compact ? 12.w : 8.w;
          final paddingVertical = compact ? 12.h : 8.h;
          final gap = compact ? 12.h : 10.h;
          final rows =
              (gridParticipants.length + crossAxisCount - 1) / crossAxisCount;
          final availableHeight =
              stageConstraints.maxHeight -
              (paddingVertical * 2) -
              (gap * (rows.ceil() - 1));
          final mobileTileHeight = rows > 0
              ? availableHeight / rows
              : stageConstraints.maxHeight;
          return GridView.builder(
            padding: EdgeInsets.symmetric(
              horizontal: paddingHorizontal,
              vertical: paddingVertical,
            ),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: compact ? 0 : 10.w,
              mainAxisSpacing: gap,
              mainAxisExtent: compact
                  ? math.max(0.0, mobileTileHeight).toDouble()
                  : null,
              childAspectRatio: 1.35,
            ),
            itemCount: gridParticipants.length,
            itemBuilder: (context, index) => _participantTile(
              context,
              gridParticipants[index],
              media,
              l10n,
              meeting: state.meeting,
              avatarSize: 56,
              showMicrophone: true,
              showCamera: false,
              smallLabel: true,
              allowActions: state.isHost,
            ),
          );
        },
      ),
    );
  }

  List<MeetingRoomParticipant> _mobileParticipantOrder(
    List<MeetingRoomParticipant> participants,
    MeetingRoomParticipant activeSpeaker,
    String? pinnedIdentity,
  ) {
    final ordered = <MeetingRoomParticipant>[];
    final pinned = _participantByIdentity(participants, pinnedIdentity);
    if (pinned != null) ordered.add(pinned);
    if (!ordered.contains(activeSpeaker)) ordered.add(activeSpeaker);
    ordered.addAll(
      participants.where((participant) => !ordered.contains(participant)),
    );
    return ordered;
  }

  MeetingRoomParticipant? _floatingParticipant(MeetingRoomState state) {
    final local = _participantByIdentity(
      state.participants,
      state.participants
          .where((participant) => participant.isLocal)
          .firstOrNull
          ?.identity,
    );
    if (local == null || state.participants.length != 2) return null;
    final remote = state.participants.firstWhere(
      (participant) => !participant.isLocal,
      orElse: () => local,
    );
    final activeSpeaker = remote;
    final primary = _singleStageParticipant(state, activeSpeaker);
    return state.participants.firstWhere(
      (participant) => participant.identity != primary.identity,
      orElse: () => local,
    );
  }

  MeetingRoomParticipant _singleStageParticipant(
    MeetingRoomState state,
    MeetingRoomParticipant activeSpeaker,
  ) =>
      _participantByIdentity(
        state.participants,
        state.pinnedParticipantIdentity,
      ) ??
      activeSpeaker;

  MeetingRoomParticipant? _participantByIdentity(
    List<MeetingRoomParticipant> participants,
    String? identity,
  ) {
    if (identity == null || identity.isEmpty) return null;
    for (final participant in participants) {
      if (participant.identity == identity) return participant;
    }
    return null;
  }

  Widget _participantTile(
    BuildContext context,
    MeetingRoomParticipant participant,
    LiveKitMediaService media,
    AppLocalizations l10n, {
    required Meeting? meeting,
    required double avatarSize,
    Color? backgroundColor,
    required bool showMicrophone,
    bool? showCamera,
    bool compactLabel = false,
    bool screenShare = false,
    bool allowActions = false,
    Alignment avatarAlignment = Alignment.center,
    EdgeInsets avatarPadding = EdgeInsets.zero,
    bool smallLabel = false,
  }) {
    final localName = participant.name.trim();
    final name = participant.isLocal
        ? localName.isEmpty ||
                  localName.toLowerCase() ==
                      l10n.meetingCallYou.toLowerCase() ||
                  localName.toLowerCase() == 'you'
              ? l10n.meetingCallYou
              : '$localName (${l10n.meetingCallYou.toLowerCase()})'
        : participant.name;
    final tile = AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: participant.isSpeaking
            ? [
                BoxShadow(
                  color: AppColors.of(
                    context,
                  ).accentSoft.withValues(alpha: 0.55),
                  blurRadius: 26.r,
                  spreadRadius: 7.r,
                ),
              ]
            : null,
      ),
      child: MeetingCallParticipantTile(
        name: name,
        isLocal: participant.isLocal,
        microphoneOn: participant.microphoneEnabled,
        cameraOn: screenShare
            ? participant.screenSharing
            : participant.cameraEnabled,
        handRaised: participant.handRaised,
        active: participant.isSpeaking,
        track: media.videoTrackFor(
          participant.identity,
          screenShare: screenShare,
        ),
        avatarUrl: _avatarForParticipant(meeting, participant),
        avatarSize: avatarSize,
        backgroundColor: backgroundColor,
        showMicrophone: showMicrophone,
        showCamera: showCamera ?? !participant.isLocal,
        compactLabel: compactLabel,
        smallLabel: smallLabel,
        avatarAlignment: avatarAlignment,
        avatarPadding: avatarPadding,
        videoFit: meetingParticipantVideoFit(screenShare: screenShare),
        enableTemporaryZoom: screenShare,
      ),
    );
    return GestureDetector(
      onLongPress: () => _showParticipantActions(context, participant),
      child: tile,
    );
  }

  String _avatarForParticipant(
    Meeting? meeting,
    MeetingRoomParticipant participant,
  ) {
    for (final member in meeting?.participantsInfo ?? const []) {
      if ((participant.userId != null && member.id == participant.userId) ||
          member.username == participant.name ||
          '${member.id}' == participant.identity) {
        return member.avatar;
      }
    }
    return '';
  }

  String _avatarForUnmuteRequest(
    Meeting? meeting,
    MeetingTrackUnmuteRequest request,
  ) {
    for (final member in meeting?.participantsInfo ?? const []) {
      if ((request.fromUserId != null && member.id == request.fromUserId) ||
          (request.fromName?.isNotEmpty == true &&
              member.username == request.fromName)) {
        return member.avatar;
      }
    }
    return '';
  }

  Widget _unmuteRequestOverlay(BuildContext context, MeetingRoomState state) {
    final request = state.pendingUnmuteRequests.first;
    final l10n = AppLocalizations.of(context);
    final isCamera = request.trackSource == 'camera';
    final bloc = context.read<MeetingRoomBloc>();
    final requesterName = request.fromName?.trim().isNotEmpty == true
        ? request.fromName!.trim()
        : l10n.meetingCallRequester;
    return MeetingPermissionDialog(
      title: isCamera
          ? l10n.meetingCallCameraRequestTitle
          : l10n.meetingCallMicRequestTitle,
      requesterName: requesterName,
      requesterRole: l10n.meetingCallOrganizerRequested,
      message: isCamera
          ? l10n.meetingCallCameraRequestHint
          : l10n.meetingCallMicRequestHint,
      enableLabel: isCamera
          ? l10n.meetingCallEnableCamera
          : l10n.meetingCallEnableMicrophone,
      permissionIcon: isCamera
          ? Assets.icons.meetingVideo
          : Assets.icons.meetingMic,
      enableIcon: isCamera
          ? Assets.icons.meetingVideo
          : Assets.icons.meetingMic,
      avatarUrl: _avatarForUnmuteRequest(state.meeting, request),
      declineLabel: l10n.meetingCallNotNow,
      onDecline: () => bloc.add(
        MeetingRoomUnmuteResponseSent(
          requestId: request.requestId,
          trackSource: request.trackSource,
          accept: false,
        ),
      ),
      onEnable: () {
        bloc.add(
          MeetingRoomUnmuteResponseSent(
            requestId: request.requestId,
            trackSource: request.trackSource,
            accept: true,
          ),
        );
        bloc.add(
          isCamera
              ? const MeetingRoomCameraToggled()
              : const MeetingRoomMicrophoneToggled(),
        );
      },
    );
  }

  Future<void> _showParticipantActions(
    BuildContext context,
    MeetingRoomParticipant participant,
  ) async {
    final l10n = AppLocalizations.of(context);
    final bloc = context.read<MeetingRoomBloc>();
    final pinned = bloc.state.pinnedParticipantIdentity == participant.identity;
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.of(context).overlaySurface,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              participant.name
                  .s(17.sp)
                  .w(800)
                  .c(AppColors.of(context).textStrong),
              SizedBox(height: 12.h),
              _sheetAction(
                context,
                icon: Assets.icons.meetingPin,
                label: pinned
                    ? l10n.meetingCallUnpinParticipant
                    : l10n.meetingCallPinParticipant,
                onTap: () {
                  Navigator.pop(sheetContext);
                  bloc.add(
                    MeetingRoomParticipantPinToggled(participant.identity),
                  );
                },
              ),
              if (bloc.state.isHost &&
                  !participant.isLocal &&
                  participant.microphoneEnabled)
                _sheetAction(
                  context,
                  icon: Assets.icons.meetingMicOff,
                  label: l10n.meetingCallMicrophone,
                  onTap: () {
                    Navigator.pop(sheetContext);
                    bloc.add(
                      MeetingRoomParticipantMuted(
                        targetIdentity: participant.identity,
                        trackSource: 'microphone',
                      ),
                    );
                  },
                )
              else if (bloc.state.isHost && !participant.isLocal)
                _sheetAction(
                  context,
                  icon: Assets.icons.meetingMic,
                  label: l10n.meetingCallEnableMicrophone,
                  onTap: () {
                    Navigator.pop(sheetContext);
                    bloc.add(
                      MeetingRoomUnmuteRequested(
                        targetIdentity: participant.identity,
                        trackSource: 'microphone',
                      ),
                    );
                  },
                ),
              if (bloc.state.isHost &&
                  !participant.isLocal &&
                  participant.cameraEnabled)
                _sheetAction(
                  context,
                  icon: Assets.icons.meetingVideoOff,
                  label: l10n.meetingCallCamera,
                  onTap: () {
                    Navigator.pop(sheetContext);
                    bloc.add(
                      MeetingRoomParticipantMuted(
                        targetIdentity: participant.identity,
                        trackSource: 'camera',
                      ),
                    );
                  },
                )
              else if (bloc.state.isHost && !participant.isLocal)
                _sheetAction(
                  context,
                  icon: Assets.icons.meetingVideo,
                  label: l10n.meetingCallEnableCamera,
                  onTap: () {
                    Navigator.pop(sheetContext);
                    bloc.add(
                      MeetingRoomUnmuteRequested(
                        targetIdentity: participant.identity,
                        trackSource: 'camera',
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _pendingRequestOverlay(BuildContext context, MeetingRoomState state) {
    final request = state.pendingRequests.first;
    return MeetingCallJoinRequest(
      participantName: request.username,
      avatarUrl: _avatarForJoinRequest(state.meeting, request),
      onReject: () => context.read<MeetingRoomBloc>().add(
        MeetingRoomUserRejected(request.userId),
      ),
      onAllow: () => context.read<MeetingRoomBloc>().add(
        MeetingRoomUserApproved(request.userId),
      ),
    );
  }

  String _avatarForJoinRequest(
    Meeting? meeting,
    MeetingRoomJoinRequest request,
  ) {
    if (request.avatar?.isNotEmpty == true) return request.avatar!;
    for (final member in meeting?.participantsInfo ?? const []) {
      if (member.id == request.userId) return member.avatar;
    }
    return '';
  }

  Widget _result(BuildContext context, MeetingRoomState state) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);
    final ended =
        state.phase == MeetingRoomPhase.ended ||
        state.phase == MeetingRoomPhase.left;
    if (ended) {
      return MeetingEndedResult(
        title: l10n.meetingCallMeetingEndedTitle,
        message: l10n.meetingCallMeetingEndedHint,
        rejoinLabel: l10n.meetingCallRejoin,
        homeLabel: l10n.meetingCallHome,
        onRejoin: () => context.read<MeetingRoomBloc>().add(
          const MeetingRoomRetryRequested(),
        ),
        onHome: () => Navigator.of(context).maybePop(),
      );
    }
    final title = l10n.meetingCallRequestSent;
    final message = state.errorMessage ?? l10n.meetingCallMeetingEndedHint;
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        children: [
          MeetingPreviewHeader(
            title: state.title.isEmpty ? title : state.title,
          ),
          SizedBox(height: 18.h),
          MeetingPreviewSurface(
            color: colors.backgroundElevation1Alt,
            radius: 18.r,
            child: Padding(
              padding: EdgeInsets.all(24.w),
              child: Column(
                children: [
                  title.s(20.sp).w(800).c(colors.textStrong),
                  SizedBox(height: 8.h),
                  message.s(15.sp).w(500).c(colors.textSub).a(TextAlign.center),
                  SizedBox(height: 20.h),
                  MeetingPreviewButton(
                    label: ended
                        ? l10n.meetingCallRejoin
                        : l10n.meetingCallJoin,
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
      ),
    );
  }

  Future<void> _showParticipants(
    BuildContext context,
    MeetingRoomState state,
  ) async {
    var query = '';
    final bloc = context.read<MeetingRoomBloc>();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.of(context).overlaySurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (sheetContext) => BlocProvider.value(
        value: bloc,
        child: StatefulBuilder(
          builder: (context, setState) =>
              BlocBuilder<MeetingRoomBloc, MeetingRoomState>(
                builder: (context, current) {
                  final l10n = AppLocalizations.of(context);
                  return SafeArea(
                    top: false,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        20.w,
                        10.h,
                        20.w,
                        34.h + MediaQuery.viewInsetsOf(context).bottom,
                      ),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: MediaQuery.sizeOf(context).height * 0.9,
                        ),
                        child: SingleChildScrollView(
                          child: MeetingParticipantsSheet(
                            title:
                                '${l10n.meetingCallParticipants} (${current.participants.length})',
                            onClose: () => Navigator.pop(sheetContext),
                            searchQuery: query,
                            onSearchChanged: (value) =>
                                setState(() => query = value),
                            participants: [
                              for (final participant in current.participants)
                                MeetingParticipantItem(
                                  name: participant.isLocal
                                      ? '${participant.name.isEmpty ? l10n.meetingCallSelfName : participant.name} (${l10n.meetingCallYou.toLowerCase()})'
                                      : participant.name,
                                  role: participant.isLocal
                                      ? l10n.meetingCallOrganizer
                                      : l10n.meetingCallParticipant,
                                  avatarUrl: _avatarForParticipant(
                                    current.meeting,
                                    participant,
                                  ),
                                  microphoneOn: participant.microphoneEnabled,
                                  cameraOn: participant.cameraEnabled,
                                  requestPending: current
                                      .pendingUnmuteTargetKeys
                                      .any(
                                        (key) => key.startsWith(
                                          '${participant.identity}::',
                                        ),
                                      ),
                                  onMicrophoneTap:
                                      current.isHost && !participant.isLocal
                                      ? () => bloc.add(
                                          participant.microphoneEnabled
                                              ? MeetingRoomParticipantMuted(
                                                  targetIdentity:
                                                      participant.identity,
                                                  trackSource: 'microphone',
                                                )
                                              : MeetingRoomUnmuteRequested(
                                                  targetIdentity:
                                                      participant.identity,
                                                  trackSource: 'microphone',
                                                ),
                                        )
                                      : null,
                                  onCameraTap:
                                      current.isHost && !participant.isLocal
                                      ? () => bloc.add(
                                          participant.cameraEnabled
                                              ? MeetingRoomParticipantMuted(
                                                  targetIdentity:
                                                      participant.identity,
                                                  trackSource: 'camera',
                                                )
                                              : MeetingRoomUnmuteRequested(
                                                  targetIdentity:
                                                      participant.identity,
                                                  trackSource: 'camera',
                                                ),
                                        )
                                      : null,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
        ),
      ),
    );
  }

  Future<void> _showDetails(BuildContext context, MeetingRoomState state) {
    final meeting = state.meeting;
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.of(context).overlaySurface,
      builder: (sheetContext) => MeetingDetailsSheet(
        meeting: meeting,
        fallbackTitle: state.title,
        onClose: () => Navigator.pop(sheetContext),
      ),
    );
  }

  Future<void> _showMore(BuildContext context, MeetingRoomState state) async {
    final l10n = AppLocalizations.of(context);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.of(context).overlaySurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (sheetContext) => MeetingMoreSheet(
        onClose: () => Navigator.pop(sheetContext),
        actions: [
          MeetingMoreSheetAction(
            icon: Assets.icons.meetingScreen,
            label: l10n.meetingCallShareScreen,
            onTap: () {
              Navigator.pop(sheetContext);
              _showScreenShare(context, state);
            },
          ),
          MeetingMoreSheetAction(
            icon: Assets.icons.meetingChat,
            label: l10n.meetingCallChat,
            onTap: () {
              Navigator.pop(sheetContext);
              _showChat(context, state);
            },
          ),
          MeetingMoreSheetAction(
            icon: Assets.icons.meetingSticker,
            label: l10n.meetingCallStickers,
            onTap: () {
              Navigator.pop(sheetContext);
              _toggleStickers();
            },
          ),
          MeetingMoreSheetAction(
            icon: Assets.icons.icUserGroup,
            label: l10n.meetingCallParticipants,
            onTap: () {
              Navigator.pop(sheetContext);
              _showParticipants(context, state);
            },
          ),
          MeetingMoreSheetAction(
            icon: Assets.icons.meetingInfo,
            label: l10n.meetingCallDetails,
            onTap: () {
              Navigator.pop(sheetContext);
              _showDetails(context, state);
            },
          ),
          MeetingMoreSheetAction(
            icon: Assets.icons.meetingPower,
            label: l10n.meetingCallLeave,
            destructive: true,
            onTap: () {
              Navigator.pop(sheetContext);
              _showExit(context, state);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _showChat(BuildContext context, MeetingRoomState state) async {
    final bloc = context.read<MeetingRoomBloc>();
    String? localIdentity;
    for (final participant in state.participants) {
      if (participant.isLocal) {
        localIdentity = participant.identity;
        break;
      }
    }
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.of(context).overlaySurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (sheetContext) => SafeArea(
        child: BlocProvider.value(
          value: bloc,
          child: BlocBuilder<MeetingRoomBloc, MeetingRoomState>(
            builder: (context, current) => MeetingChatSheet(
              messages: current.messages,
              localIdentity: localIdentity,
              onSend: (message) => context.read<MeetingRoomBloc>().add(
                MeetingRoomChatMessageSent(message),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showScreenShare(
    BuildContext context,
    MeetingRoomState state,
  ) async {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: colors.overlaySurface,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              MeetingPreviewButton(
                label: state.screenSharing
                    ? l10n.meetingCallStopSharing
                    : l10n.meetingCallShareScreen,
                background: state.screenSharing
                    ? colors.errorStrong
                    : colors.accentStrong,
                foreground: colors.textWhite,
                icon: state.screenSharing
                    ? Assets.icons.meetingCallEnd
                    : Assets.icons.meetingScreen,
                onTap: () {
                  context.read<MeetingRoomBloc>().add(
                    MeetingRoomScreenShareToggled(
                      enabled: !state.screenSharing,
                    ),
                  );
                  Navigator.pop(sheetContext);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showDevices(
    BuildContext context,
    MeetingRoomState state,
  ) async {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: colors.overlaySurface,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                l10n.meetingCallMicrophoneSection
                    .s(12.sp)
                    .w(800)
                    .c(colors.textSoft),
                SizedBox(height: 8.h),
                ..._deviceRows(
                  context,
                  state.audioInputs,
                  state.selectedAudioInputId,
                  (id) => MeetingRoomAudioInputSelected(id),
                ),
                SizedBox(height: 16.h),
                l10n.meetingCallSpeakerSection
                    .s(12.sp)
                    .w(800)
                    .c(colors.textSoft),
                SizedBox(height: 8.h),
                ..._deviceRows(
                  context,
                  state.audioOutputs,
                  state.selectedAudioOutputId,
                  (id) => MeetingRoomAudioOutputSelected(id),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showCamera(BuildContext context, MeetingRoomState state) async {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: colors.overlaySurface,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                l10n.meetingCallCameraSection
                    .s(12.sp)
                    .w(800)
                    .c(colors.textSoft),
                SizedBox(height: 8.h),
                ..._deviceRows(
                  context,
                  state.videoInputs,
                  state.selectedVideoInputId,
                  (id) => MeetingRoomVideoInputSelected(id),
                ),
                SizedBox(height: 16.h),
                _sheetAction(
                  context,
                  icon: Assets.icons.meetingVideo,
                  label: l10n.meetingCallFrontCamera,
                  onTap: () {
                    context.read<MeetingRoomBloc>().add(
                      MeetingRoomCameraPositionSelected(
                        MeetingCameraPosition.front,
                      ),
                    );
                    Navigator.pop(sheetContext);
                  },
                ),
                _sheetAction(
                  context,
                  icon: Assets.icons.meetingVideo,
                  label: l10n.meetingCallRearCamera,
                  onTap: () {
                    context.read<MeetingRoomBloc>().add(
                      MeetingRoomCameraPositionSelected(
                        MeetingCameraPosition.back,
                      ),
                    );
                    Navigator.pop(sheetContext);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _deviceRows(
    BuildContext context,
    List<MeetingMediaDevice> devices,
    String? selectedId,
    MeetingRoomEvent Function(String id) eventBuilder,
  ) {
    final colors = AppColors.of(context);
    if (devices.isEmpty) {
      return [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 8.h),
          child: AppLocalizations.of(
            context,
          ).meetingCallDeviceUnavailable.s(13.sp).w(500).c(colors.textSub),
        ),
      ];
    }
    return [
      for (final device in devices)
        _sheetAction(
          context,
          icon: Assets.icons.meetingMic,
          label: device.label.isEmpty
              ? AppLocalizations.of(context).meetingCallDefaultDevice
              : device.label,
          trailing: device.id == selectedId
              ? Assets.icons.icCheck.svg(
                  width: 18.w,
                  height: 18.w,
                  colorFilter: ColorFilter.mode(
                    colors.accentStrong,
                    BlendMode.srcIn,
                  ),
                )
              : null,
          onTap: () {
            context.read<MeetingRoomBloc>().add(eventBuilder(device.id));
            Navigator.pop(context);
          },
        ),
    ];
  }

  Widget _sheetAction(
    BuildContext context, {
    required SvgGenImage icon,
    required String label,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    final colors = AppColors.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        child: Row(
          children: [
            icon.svg(
              width: 20.w,
              height: 20.w,
              colorFilter: ColorFilter.mode(colors.iconStrong, BlendMode.srcIn),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: label
                  .s(14.sp)
                  .w(700)
                  .c(colors.textStrong)
                  .copyWith(maxLines: 2, overflow: TextOverflow.ellipsis),
            ),
            if (trailing != null) ...[const Spacer(), trailing],
          ],
        ),
      ),
    );
  }

  Future<void> _showExit(BuildContext context, MeetingRoomState state) async {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: colors.overlaySurface,
      builder: (sheetContext) => MeetingExitSheet(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 24.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                l10n.meetingCallExitQuestion
                    .s(18.sp)
                    .w(800)
                    .c(colors.textStrong),
                SizedBox(height: 16.h),
                MeetingPreviewButton(
                  label: l10n.meetingCallLeave,
                  background: colors.errorStrong,
                  foreground: colors.textWhite,
                  icon: Assets.icons.meetingCallEnd,
                  onTap: () {
                    Navigator.pop(sheetContext);
                    context.read<MeetingRoomBloc>().add(
                      const MeetingRoomLeaveRequested(),
                    );
                  },
                ),
                if (state.isHost) ...[
                  SizedBox(height: 10.h),
                  MeetingPreviewButton(
                    label: l10n.meetingCallEndForEveryone,
                    background: colors.backgroundElevation2,
                    foreground: colors.errorStrong,
                    icon: Assets.icons.meetingPower,
                    onTap: () {
                      Navigator.pop(sheetContext);
                      context.read<MeetingRoomBloc>().add(
                        const MeetingRoomEndRequested(),
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
