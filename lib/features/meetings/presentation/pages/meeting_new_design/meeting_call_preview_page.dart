import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../config/theme/app_colors.dart';
import '../../../../../core/extentions/text_extensions.dart';
import '../../../../../core/gen/assets.gen.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../../injection_container.dart';
import '../../../domain/entities/meeting_room.dart';
import '../../bloc/meeting_new_design/meeting_call_preview_bloc.dart';
import '../../bloc/meeting_new_design/meeting_call_preview_event.dart';
import '../../bloc/meeting_new_design/meeting_call_preview_state.dart';
import '../../theme/meeting_theme_colors.dart';
import 'widgets/common/meeting_preview_avatar.dart';
import 'widgets/common/meeting_preview_button.dart';
import 'widgets/common/meeting_ended_result.dart';
import 'widgets/common/meeting_preview_icon_button.dart';
import 'widgets/common/meeting_preview_surface.dart';
import 'widgets/call/meeting_call_stickers_panel.dart';
import 'widgets/call/meeting_call_control_bar.dart';
import 'widgets/call/meeting_call_participant_tile.dart';
import 'widgets/call/meeting_call_join_request.dart';
import 'widgets/sheets/meeting_chat_sheet.dart';
import 'widgets/sheets/meeting_more_sheet.dart';
import 'widgets/sheets/meeting_permission_dialog.dart';

/// UI-only meeting walkthrough; media and moderation are not connected yet.
class MeetingCallPreviewPage extends StatelessWidget {
  const MeetingCallPreviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt.isRegistered<MeetingCallPreviewBloc>()
          ? getIt<MeetingCallPreviewBloc>()
          : MeetingCallPreviewBloc(),
      child: const _MeetingCallPreviewView(),
    );
  }
}

typedef _Phase = MeetingCallPreviewPhase;
typedef _Sheet = MeetingCallPreviewSheet;

class _MeetingCallPreviewView extends StatefulWidget {
  const _MeetingCallPreviewView();

  @override
  State<_MeetingCallPreviewView> createState() =>
      _MeetingCallPreviewViewState();
}

class _MeetingCallPreviewViewState extends State<_MeetingCallPreviewView> {
  late final MeetingCallPreviewBloc _bloc;
  final _searchController = TextEditingController();

  MeetingCallPreviewState get _previewState => _bloc.state;
  _Phase get _phase => _previewState.phase;
  bool get _micOn => _previewState.microphoneOn;
  bool get _cameraOn => _previewState.cameraOn;
  bool get _handRaised => _previewState.handRaised;
  bool get _speakerGrid => _previewState.speakerGrid;
  bool get _joinRequest => _previewState.joinRequest;
  bool get _screenSharing => _previewState.screenSharing;
  bool get _stickersOpen => _previewState.stickersOpen;
  bool get _frontCamera => _previewState.frontCamera;
  bool get _blurBackground => _previewState.blurBackground;
  String get _microphoneDevice => _previewState.microphoneDevice;
  String get _speakerDevice => _previewState.speakerDevice;
  List<String> get _reactions => _previewState.reactions;
  List<String> get _messages => _previewState.messages;

  @override
  void initState() {
    super.initState();
    _bloc = context.read<MeetingCallPreviewBloc>();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MeetingCallPreviewBloc, MeetingCallPreviewState>(
      builder: (context, state) {
        final colors = AppColors.of(context);
        return Scaffold(
          backgroundColor: colors.backgroundElevation1,
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) => _phase == _Phase.call
                  ? _callBody(constraints)
                  : _phase == _Phase.ended
                  ? _endedBody()
                  : _prejoinBody(constraints),
            ),
          ),
        );
      },
    );
  }

  Widget _endedBody() {
    final l10n = AppLocalizations.of(context);
    return MeetingEndedResult(
      title: l10n.meetingCallMeetingEndedTitle,
      message: l10n.meetingCallMeetingEndedHint,
      rejoinLabel: l10n.meetingCallRejoin,
      homeLabel: l10n.meetingCallHome,
      onRejoin: () => _bloc.add(const MeetingCallApproved()),
      onHome: () => Navigator.of(context).maybePop(),
    );
  }

  Widget _prejoinBody(BoxConstraints constraints) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);
    final compactHeight = constraints.maxHeight < 600.h;
    final stageHeight = compactHeight
        ? constraints.maxHeight * 0.7
        : (constraints.maxHeight * 0.55).clamp(260.h, 400.h);
    final avatarSize = math.min(88.w, constraints.maxHeight * 0.22);
    final actionSize = math.min(48.w, constraints.maxHeight * 0.13);
    final actionIconSize = math.min(20.w, constraints.maxHeight * 0.06);

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.only(bottom: 12.h),
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: constraints.maxHeight),
        child: Column(
          children: [
            _header(
              _phase == _Phase.waiting
                  ? l10n.meetingCallWaitingTitle
                  : l10n.meetingCallJoinTitle,
            ),
            SizedBox(height: 8.h),
            SizedBox(
              height: stageHeight,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: colors.chartNeutral,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: SizedBox.expand(
                    child: SingleChildScrollView(
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _avatar(
                                Assets.images.meetingSelf.path,
                                avatarSize,
                              ),
                              SizedBox(height: 20.h),
                              l10n.meetingCallCameraOff
                                  .s(13.sp)
                                  .w(500)
                                  .c(colors.textDisabled),
                              SizedBox(height: 20.h),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _circleAction(
                                    _micOn
                                        ? Assets.icons.meetingMic
                                        : Assets.icons.meetingMicOff,
                                    _micOn
                                        ? colors.meetingControlSurface
                                        : colors.errorStrong,
                                    _micOn
                                        ? colors.iconStrong
                                        : colors.iconWhite,
                                    () => _bloc.add(
                                      const MeetingCallMicrophoneToggled(),
                                    ),
                                    l10n.meetingCallMicrophone,
                                    size: actionSize,
                                    iconSize: actionIconSize,
                                  ),
                                  SizedBox(width: 12.w),
                                  _circleAction(
                                    _cameraOn
                                        ? Assets.icons.meetingVideo
                                        : Assets.icons.meetingVideoOff,
                                    _cameraOn
                                        ? colors.meetingControlSurface
                                        : colors.errorStrong,
                                    _cameraOn
                                        ? colors.iconStrong
                                        : colors.iconWhite,
                                    () => _bloc.add(
                                      const MeetingCallCameraToggled(),
                                    ),
                                    l10n.meetingCallCamera,
                                    size: actionSize,
                                    iconSize: actionIconSize,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 12.h),
              child: _phase == _Phase.waiting ? _waitingPanel() : _joinPanel(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _joinPanel() {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        l10n.meetingCallSampleTitle.s(20.sp).w(800).c(colors.textStrong),
        SizedBox(height: 14.h),
        _surface(
          color: colors.backgroundElevation1Alt,
          child: InkWell(
            onTap: () {
              Clipboard.setData(const ClipboardData(text: 'rn-mtg-4821'));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.meetingCallCodeCopied)),
              );
            },
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
              child: Row(
                children: [
                  _icon(Assets.icons.meetingCopy, colors.iconStrong, 16.w),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: 'rn-mtg-4821'.s(15.sp).w(800).c(colors.textStrong),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(height: 14.h),
        _wideButton(
          l10n.meetingCallJoin,
          colors.accentStrong,
          colors.textWhite,
          () => _bloc.add(const MeetingCallJoinRequested()),
          icon: Assets.icons.meetingJoin,
        ),
        SizedBox(height: 14.h),
        l10n.meetingCallApprovalHint.s(13.sp).w(500).c(colors.textSoft),
      ],
    );
  }

  Widget _waitingPanel() {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        Semantics(
          button: kDebugMode,
          label: l10n.meetingCallPreviewApprove,
          child: InkWell(
            onTap: kDebugMode
                ? () => _bloc.add(const MeetingCallApproved())
                : null,
            borderRadius: BorderRadius.circular(12.r),
            child: _surface(
              color: colors.backgroundElevation1Alt,
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Row(
                  children: [
                    _icon(Assets.icons.icTuilconTime, colors.iconStrong, 24.w),
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
                          l10n.meetingCallWaitingHint
                              .s(13.sp)
                              .w(500)
                              .c(colors.textSub),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 16.h),
        _wideButton(
          l10n.meetingCallCancel,
          colors.meetingControlSurface,
          colors.textStrong,
          () => _bloc.add(const MeetingCallCancelled()),
          icon: Assets.icons.icClose,
        ),
        if (kDebugMode) ...[
          SizedBox(height: 12.h),
          TextButton(
            onPressed: () => _bloc.add(const MeetingCallApproved()),
            child: Text(l10n.meetingCallPreviewApprove),
          ),
        ],
      ],
    );
  }

  Widget _callBody(BoxConstraints constraints) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(20.w, 8.h, 16.w, 8.h),
          child: Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => _bloc.add(const MeetingCallJoinRequestToggled()),
                  child: Row(
                    children: [
                      Flexible(
                        child: l10n.meetingCallName
                            .s(13.sp)
                            .w(800)
                            .c(colors.textStrong),
                      ),
                      SizedBox(width: 8.w),
                      _icon(Assets.icons.meetingInfo, colors.iconStrong, 16.w),
                    ],
                  ),
                ),
              ),
              _circleAction(
                Assets.icons.meetingPower,
                colors.errorSub,
                colors.iconWhite,
                () => _showSheet(_Sheet.exit),
                l10n.meetingCallEnd,
                size: 32.w,
                iconSize: 18.w,
              ),
              SizedBox(width: 8.w),
              _circleAction(
                Assets.icons.meetingSticker,
                colors.meetingControlSurface,
                colors.iconStrong,
                () => _bloc.add(const MeetingCallStickerPanelToggled()),
                l10n.meetingCallStickers,
                size: 32.w,
                iconSize: 18.w,
              ),
              SizedBox(width: 8.w),
              InkWell(
                onTap: () => _showSheet(_Sheet.participants),
                borderRadius: BorderRadius.circular(999.r),
                child: _surface(
                  color: colors.meetingControlSurface,
                  radius: 999.r,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 6.h,
                    ),
                    child: Row(
                      children: [
                        _icon(
                          Assets.icons.icUserGroup,
                          colors.iconStrong,
                          16.w,
                        ),
                        SizedBox(width: 6.w),
                        '3'.s(13.sp).w(800).c(colors.textStrong),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 8.h),
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16.r),
              child: DecoratedBox(
                decoration: BoxDecoration(color: colors.chartNeutral),
                child: SizedBox.expand(
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: _speakerGrid ? _gridStage() : _singleStage(),
                      ),
                      if (_screenSharing)
                        Positioned(
                          left: 12.w,
                          top: 12.h,
                          child: _surface(
                            color: colors.backgroundElevation2Alt,
                            radius: 999.r,
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10.w,
                                vertical: 6.h,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _icon(
                                    Assets.icons.meetingScreen,
                                    colors.accentStrong,
                                    16.w,
                                  ),
                                  SizedBox(width: 6.w),
                                  l10n.meetingCallYouAreSharing
                                      .s(11.sp)
                                      .w(800)
                                      .c(colors.textStrong),
                                ],
                              ),
                            ),
                          ),
                        ),
                      if (_stickersOpen)
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: _stickersPanel(),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 8.h),
        _controlBar(),
        SizedBox(height: 8.h),
      ],
    );
  }

  Widget _singleStage() {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);
    final selfTileColor = colors.backgroundBase.computeLuminance() < 0.5
        ? colors.backgroundBase2
        : Color.alphaBlend(
            colors.black.withValues(alpha: 0.08),
            colors.textStrong,
          );
    return Stack(
      children: [
        Center(child: _avatar(Assets.images.meetingDilnoza.path, 88.w)),
        Positioned(
          right: 12.w,
          top: 12.h,
          child: InkWell(
            onTap: () => _bloc.add(const MeetingCallGridToggled()),
            child: _surface(
              color: selfTileColor,
              radius: 12.r,
              child: SizedBox(
                width: 96.w,
                height: 128.h,
                child: Stack(
                  children: [
                    Center(
                      child: _avatar(Assets.images.meetingSelf.path, 40.w),
                    ),
                    Positioned(
                      left: 9.w,
                      bottom: 10.h,
                      child: l10n.meetingCallYou
                          .s(11.sp)
                          .w(500)
                          .c(colors.textWhite),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Positioned(
          left: 12.w,
          bottom: 12.h,
          child: _reactions.isEmpty
              ? _nameTag(l10n.meetingCallDilnoza)
              : _reactionNameTag(_reactions.last, l10n.meetingCallDilnoza),
        ),
        if (_reactions.isNotEmpty)
          Positioned(
            left: 20.w,
            top: 28.h,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final reaction in _reactions)
                  Padding(
                    padding: EdgeInsets.only(bottom: 6.h),
                    child: Text(reaction, style: TextStyle(fontSize: 28.sp)),
                  ),
              ],
            ),
          ),
        if (_handRaised)
          Positioned(
            top: 16.h,
            left: 12.w,
            right: 12.w,
            child: _surface(
              color: colors.successSoft,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                child: Row(
                  children: [
                    _icon(Assets.icons.meetingHand, colors.successStrong, 20.w),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: l10n.meetingCallRaisedNotice
                          .s(13.sp)
                          .w(700)
                          .c(colors.textStrong),
                    ),
                  ],
                ),
              ),
            ),
          ),
        if (_joinRequest)
          Positioned(top: 0, left: 0, right: 0, child: _joinRequestCard()),
      ],
    );
  }

  Widget _gridStage() {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);
    return ColoredBox(
      color: colors.backgroundElevation2Alt,
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: InkWell(
          onTap: () => _bloc.add(const MeetingCallGridToggled()),
          child: Column(
            children: [
              Expanded(
                child: _speakerTile(
                  Assets.images.meetingDilnoza.path,
                  l10n.meetingCallDilnoza,
                  active: true,
                ),
              ),
              SizedBox(height: 12.h),
              Expanded(
                child: _speakerTile(
                  Assets.images.meetingSelf.path,
                  l10n.meetingCallSelfName,
                ),
              ),
              SizedBox(height: 12.h),
              Expanded(
                child: _speakerTile(
                  Assets.images.meetingBekzod.path,
                  l10n.meetingCallBekzod,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _speakerTile(String asset, String name, {bool active = false}) {
    return MeetingCallParticipantTile(
      assetPath: asset,
      name: name,
      active: active,
    );
  }

  Widget _joinRequestCard() {
    return MeetingCallJoinRequest(
      onReject: () => _bloc.add(const MeetingCallJoinRequestToggled()),
      onAllow: () => _bloc.add(const MeetingCallJoinRequestToggled()),
    );
  }

  Widget _controlBar() {
    final l10n = AppLocalizations.of(context);
    return MeetingCallControlBar(
      microphoneOn: _micOn,
      cameraOn: _cameraOn,
      handRaised: _handRaised,
      onMicrophone: () => _bloc.add(const MeetingCallMicrophoneToggled()),
      onCamera: () => _bloc.add(const MeetingCallCameraToggled()),
      onHand: () => _bloc.add(const MeetingCallHandToggled()),
      onMore: () => _showSheet(_Sheet.more),
      onLeave: () => _showSheet(_Sheet.exit),
      microphoneLabel: l10n.meetingCallMicrophone,
      cameraLabel: l10n.meetingCallCamera,
      handLabel: l10n.meetingCallRaiseHand,
      moreLabel: l10n.meetingCallMore,
      leaveLabel: l10n.meetingCallLeave,
      onMicrophoneMenu: () => _showSheet(_Sheet.devices),
      onCameraMenu: () => _showSheet(_Sheet.camera),
    );
  }

  Future<void> _showSheet(
    _Sheet sheet, {
    bool includeEndForEveryone = true,
  }) async {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);
    _bloc.add(MeetingCallSheetOpened(sheet));
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: colors.overlaySurface,
      barrierColor: colors.black.withValues(alpha: 0.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (sheetContext) {
        if (sheet == _Sheet.chat) return _chatContent();
        if (sheet == _Sheet.more) return _moreContent(sheetContext);
        return SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              20.w,
              10.h,
              20.w,
              20.h + MediaQuery.viewInsetsOf(sheetContext).bottom,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.sizeOf(sheetContext).height * 0.9,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: colors.backgroundElevation2Alt,
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                      child: SizedBox(width: 36.w, height: 4.h),
                    ),
                    SizedBox(height: 14.h),
                    Row(
                      children: [
                        Expanded(
                          child: _sheetTitle(
                            sheet,
                            l10n,
                          ).s(17.sp).w(800).c(colors.textStrong),
                        ),
                        _circleAction(
                          Assets.icons.icClose,
                          colors.meetingControlSurface,
                          colors.iconStrong,
                          () => Navigator.pop(sheetContext),
                          l10n.meetingCallClose,
                          size: 32.w,
                          iconSize: 18.w,
                        ),
                      ],
                    ),
                    SizedBox(height: 14.h),
                    if (sheet == _Sheet.participants) _participantsContent(),
                    if (sheet == _Sheet.devices) _devicesContent(),
                    if (sheet == _Sheet.exit)
                      _exitContent(sheetContext, includeEndForEveryone),
                    if (sheet == _Sheet.details) _detailsContent(),
                    if (sheet == _Sheet.shareScreen)
                      _shareScreenContent(sheetContext),
                    if (sheet == _Sheet.camera) _cameraContent(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
    if (mounted) _bloc.add(const MeetingCallSheetClosed());
  }

  String _sheetTitle(_Sheet sheet, AppLocalizations l10n) {
    switch (sheet) {
      case _Sheet.participants:
        return l10n.meetingCallParticipantsCount;
      case _Sheet.chat:
        return l10n.meetingCallChat;
      case _Sheet.more:
        return l10n.meetingCallMore;
      case _Sheet.devices:
        return l10n.meetingCallMicAndSpeaker;
      case _Sheet.exit:
        return l10n.meetingCallExitQuestion;
      case _Sheet.details:
        return l10n.meetingCallDetails;
      case _Sheet.shareScreen:
        return l10n.meetingCallShareScreen;
      case _Sheet.camera:
        return l10n.meetingCallCameraAndBackground;
    }
  }

  Widget _devicesContent() {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);
    return StatefulBuilder(
      builder: (context, setSheetState) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel(l10n.meetingCallMicrophoneSection),
          SizedBox(height: 8.h),
          _deviceRow(
            Assets.icons.meetingMic,
            l10n.meetingCallIphoneMicrophone,
            _microphoneDevice == 'iphone',
            () {
              _bloc.add(const MeetingCallMicrophoneDeviceSelected('iphone'));
              setSheetState(() {});
            },
          ),
          _deviceRow(
            Assets.icons.meetingMic,
            l10n.meetingCallAirpods,
            _microphoneDevice == 'airpods',
            () {
              _bloc.add(const MeetingCallMicrophoneDeviceSelected('airpods'));
              setSheetState(() {});
            },
          ),
          _deviceRow(
            Assets.icons.meetingMic,
            l10n.meetingCallWiredHeadset,
            _microphoneDevice == 'wired',
            () {
              _bloc.add(const MeetingCallMicrophoneDeviceSelected('wired'));
              setSheetState(() {});
            },
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10.h),
            child: Divider(color: colors.strokeSub, height: 1.h),
          ),
          _sectionLabel(l10n.meetingCallSpeakerSection),
          SizedBox(height: 8.h),
          _deviceRow(
            Assets.icons.meetingMic,
            l10n.meetingCallIphoneSpeaker,
            _speakerDevice == 'iphone',
            () {
              _bloc.add(const MeetingCallSpeakerDeviceSelected('iphone'));
              setSheetState(() {});
            },
          ),
          _deviceRow(
            Assets.icons.meetingMic,
            l10n.meetingCallAirpods,
            _speakerDevice == 'airpods',
            () {
              _bloc.add(const MeetingCallSpeakerDeviceSelected('airpods'));
              setSheetState(() {});
            },
          ),
        ],
      ),
    );
  }

  Widget _exitContent(BuildContext sheetContext, bool includeEndForEveryone) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        l10n.meetingCallExitHint.s(15.sp).w(500).c(colors.textSub).h(1.6),
        SizedBox(height: 14.h),
        _wideButton(
          l10n.meetingCallLeave,
          colors.errorStrong,
          colors.textWhite,
          () => _finishFromSheet(sheetContext),
          icon: Assets.icons.meetingCallEnd,
        ),
        if (includeEndForEveryone) ...[
          SizedBox(height: 10.h),
          _outlinedButton(
            l10n.meetingCallEndForEveryone,
            colors.errorStrong,
            () => _finishFromSheet(sheetContext),
            icon: Assets.icons.meetingPower,
          ),
        ],
        SizedBox(height: 10.h),
        _wideButton(
          l10n.meetingCallCancel,
          colors.meetingControlSurface,
          colors.textStrong,
          () => Navigator.pop(sheetContext),
          icon: Assets.icons.icClose,
        ),
      ],
    );
  }

  void _finishFromSheet(BuildContext sheetContext) {
    Navigator.pop(sheetContext);
    if (mounted) _bloc.add(const MeetingCallLeaveRequested());
  }

  Widget _detailsContent() {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        l10n.meetingCallDetailsHint.s(13.sp).w(500).c(colors.textSub),
        SizedBox(height: 12.h),
        _surface(
          color: colors.backgroundElevation1Alt,
          child: Padding(
            padding: EdgeInsets.all(12.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: _sectionLabel(l10n.meetingCallJoinDetails)),
                    _surface(
                      color: colors.backgroundElevation2Alt,
                      radius: 999.r,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 5.h,
                        ),
                        child: l10n.meetingCallMeetingLink
                            .s(11.sp)
                            .w(700)
                            .c(colors.textStrong),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                InkWell(
                  onTap: () {
                    Clipboard.setData(
                      const ClipboardData(
                        text: 'raqamli-boshqaruv.uz/meetings/33',
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(10.r),
                  child: _detailRow(
                    Assets.icons.meetingCopy,
                    'raqamli-boshqaruv.uz/meetings/33',
                    colors.accentStrong,
                    showTrailingIcon: true,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 12.h),
        _surface(
          color: colors.backgroundElevation1Alt,
          child: Padding(
            padding: EdgeInsets.all(12.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionLabel(l10n.meetingCallMeetingParams),
                SizedBox(height: 8.h),
                _detailRow(
                  Assets.icons.meetingInfo,
                  l10n.meetingCallOfficialUid,
                  colors.iconSub,
                  value: l10n.meetingCallMeetingUid,
                ),
                _detailRow(
                  Assets.icons.meetingInfo,
                  l10n.meetingCallMeetingTopic,
                  colors.iconSub,
                  value: l10n.meetingCallTopicValue,
                ),
                _detailRow(
                  Assets.icons.icCalendar,
                  l10n.meetingCallStartTime,
                  colors.iconSub,
                  value: l10n.meetingCallStartValue,
                ),
                _detailRow(
                  Assets.icons.icLock,
                  l10n.meetingCallSecurityAccess,
                  colors.iconSub,
                  value: l10n.meetingCallDirectJoin,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _shareScreenContent(BuildContext sheetContext) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        _optionRow(
          Assets.icons.meetingCallEnd,
          l10n.meetingCallStopSharing,
          colors.errorStrong,
          colors.errorDisabled,
          () {
            _bloc.add(const MeetingCallScreenSharingChanged(false));
            Navigator.pop(sheetContext);
          },
        ),
        SizedBox(height: 8.h),
        _optionRow(
          Assets.icons.icArrowRight,
          l10n.meetingCallChooseAnotherScreen,
          colors.iconStrong,
          colors.meetingControlSurface,
          () {
            _bloc.add(const MeetingCallScreenSharingChanged(true));
            Navigator.pop(sheetContext);
          },
        ),
      ],
    );
  }

  Widget _cameraContent() {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);
    return StatefulBuilder(
      builder: (context, setSheetState) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel(l10n.meetingCallCameraSection),
          SizedBox(height: 8.h),
          _deviceRow(
            Assets.icons.meetingVideo,
            l10n.meetingCallFrontCamera,
            _frontCamera,
            () {
              _bloc.add(const MeetingCallCameraSelected(true));
              setSheetState(() {});
            },
          ),
          _deviceRow(
            Assets.icons.meetingVideo,
            l10n.meetingCallRearCamera,
            !_frontCamera,
            () {
              _bloc.add(const MeetingCallCameraSelected(false));
              setSheetState(() {});
            },
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10.h),
            child: Divider(color: colors.strokeSub, height: 1.h),
          ),
          _sectionLabel(l10n.meetingCallBackgroundSection),
          SizedBox(height: 8.h),
          _deviceRow(
            Assets.icons.meetingVideo,
            l10n.meetingCallBlurBackground,
            _blurBackground,
            () {
              _bloc.add(const MeetingCallBackgroundSelected(true));
              setSheetState(() {});
            },
          ),
          _deviceRow(
            Assets.icons.meetingVideo,
            l10n.meetingCallNoBackground,
            !_blurBackground,
            () {
              _bloc.add(const MeetingCallBackgroundSelected(false));
              setSheetState(() {});
            },
          ),
          _deviceRow(
            Assets.icons.meetingVideo,
            l10n.meetingCallOfficeBackgrounds,
            false,
            () {},
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String label) =>
      label.s(11.sp).w(800).c(AppColors.of(context).textSoft);

  Widget _deviceRow(
    SvgGenImage icon,
    String label,
    bool selected,
    VoidCallback onTap,
  ) {
    final colors = AppColors.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: _surface(
        color: selected ? colors.meetingControlSurface : colors.overlaySurface,
        radius: 12.r,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          child: Row(
            children: [
              _icon(icon, selected ? colors.iconStrong : colors.iconSub, 18.w),
              SizedBox(width: 12.w),
              Expanded(child: label.s(15.sp).w(500).c(colors.textSub)),
              if (selected)
                _icon(Assets.icons.icTuilconCheck, colors.accentStrong, 18.w),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(
    SvgGenImage icon,
    String label,
    Color iconColor, {
    String? value,
    bool showTrailingIcon = false,
  }) {
    final colors = AppColors.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        children: [
          _surface(
            color: colors.backgroundElevation2Alt,
            radius: 8.r,
            child: SizedBox(
              width: 28.w,
              height: 28.w,
              child: Center(child: _icon(icon, iconColor, 16.w)),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                label.s(11.sp).w(500).c(colors.textSoft),
                if (value != null) value.s(13.sp).w(800).c(colors.textStrong),
              ],
            ),
          ),
          if (showTrailingIcon)
            _icon(Assets.icons.meetingCopy, colors.iconSub, 18.w),
        ],
      ),
    );
  }

  Widget _optionRow(
    SvgGenImage icon,
    String label,
    Color foreground,
    Color background,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999.r),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        child: Row(
          children: [
            _surface(
              color: background,
              radius: 999.r,
              child: SizedBox(
                width: 44.w,
                height: 44.w,
                child: Center(child: _icon(icon, foreground, 18.w)),
              ),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: label
                  .s(15.sp)
                  .w(800)
                  .c(foreground)
                  .copyWith(maxLines: 2, overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      ),
    );
  }

  Widget _participantsContent() {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);
    return StatefulBuilder(
      builder: (context, setSheetState) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _surface(
            color: colors.backgroundElevation1Alt,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 14.w),
              child: Row(
                children: [
                  _icon(Assets.icons.icSearch, colors.iconSub, 18.w),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (query) {
                        _bloc.add(MeetingCallParticipantSearchChanged(query));
                        setSheetState(() {});
                      },
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: l10n.meetingCallSearchParticipant,
                        hintStyle: TextStyle(
                          fontSize: 13.sp,
                          color: colors.textSoft,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 18.h),
          l10n.meetingCallInMeeting.s(11.sp).w(800).c(colors.textSoft),
          SizedBox(height: 8.h),
          for (final person in [
            (
              l10n.meetingCallSelfName,
              Assets.images.meetingSelf.path,
              l10n.meetingCallOrganizer,
              false,
              true,
            ),
            (
              l10n.meetingCallDilnoza,
              Assets.images.meetingDilnoza.path,
              l10n.meetingCallParticipant,
              true,
              false,
            ),
            (
              l10n.meetingCallBekzod,
              Assets.images.meetingBekzod.path,
              l10n.meetingCallParticipant,
              false,
              false,
            ),
          ])
            if (person.$1.toLowerCase().contains(
              _searchController.text.toLowerCase(),
            ))
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8.h),
                child: Row(
                  children: [
                    _avatar(person.$2, 40.w),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          person.$1.s(13.sp).w(800).c(colors.textStrong),
                          person.$3.s(11.sp).w(500).c(colors.textSub),
                        ],
                      ),
                    ),
                    if (person.$4)
                      _surface(
                        color: colors.backgroundElevation2Alt,
                        radius: 999.r,
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 5.h,
                          ),
                          child: l10n.meetingCallRequestSent
                              .s(11.sp)
                              .w(800)
                              .c(colors.accentStrong),
                        ),
                      )
                    else if (person.$5)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Semantics(
                            button: true,
                            label: l10n.meetingCallMicrophone,
                            child: InkWell(
                              onTap: () => _showRequestDialog(camera: false),
                              borderRadius: BorderRadius.circular(999.r),
                              child: _icon(
                                Assets.icons.meetingMic,
                                colors.iconSub,
                                18.w,
                              ),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Semantics(
                            button: true,
                            label: l10n.meetingCallCamera,
                            child: InkWell(
                              onTap: () => _showRequestDialog(camera: true),
                              borderRadius: BorderRadius.circular(999.r),
                              child: _icon(
                                Assets.icons.meetingVideo,
                                colors.iconSub,
                                18.w,
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
        ],
      ),
    );
  }

  Future<void> _showRequestDialog({required bool camera}) async {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);
    await showDialog<void>(
      context: context,
      barrierColor: colors.black.withValues(alpha: 0.5),
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: MeetingPermissionDialog(
          title: camera
              ? l10n.meetingCallCameraRequestTitle
              : l10n.meetingCallMicRequestTitle,
          requesterName: l10n.meetingCallRequester,
          requesterRole: l10n.meetingCallOrganizerRequested,
          message: camera
              ? l10n.meetingCallCameraRequestHint
              : l10n.meetingCallMicRequestHint,
          declineLabel: l10n.meetingCallNotNow,
          enableLabel: camera
              ? l10n.meetingCallEnableCamera
              : l10n.meetingCallEnableMicrophone,
          permissionIcon: camera
              ? Assets.icons.meetingVideo
              : Assets.icons.meetingMic,
          enableIcon: camera
              ? Assets.icons.meetingVideo
              : Assets.icons.meetingMic,
          requesterAvatar: _avatar(Assets.images.meetingSelf.path, 32),
          onDecline: () => Navigator.pop(dialogContext),
          onEnable: () {
            _bloc.add(MeetingCallPermissionAccepted(camera: camera));
            Navigator.pop(dialogContext);
          },
        ),
      ),
    );
  }

  Widget _chatContent() => MeetingChatSheet(
    messages: [
      for (final message in _messages)
        MeetingRoomDataMessage(
          type: 'chat',
          senderIdentity: 'local',
          senderName: '',
          text: message,
          sentAt: DateTime.now(),
        ),
    ],
    localIdentity: 'local',
    onSend: (message) => _bloc.add(MeetingCallChatMessageSent(message)),
  );

  Widget _moreContent(BuildContext sheetContext) {
    final l10n = AppLocalizations.of(context);
    return MeetingMoreSheet(
      onClose: () => Navigator.pop(sheetContext),
      actions: [
        MeetingMoreSheetAction(
          icon: Assets.icons.meetingScreen,
          label: l10n.meetingCallShareScreen,
          onTap: () {
            Navigator.pop(sheetContext);
            _bloc.add(const MeetingCallScreenSharingChanged(true));
            _showSheet(_Sheet.shareScreen);
          },
        ),
        MeetingMoreSheetAction(
          icon: Assets.icons.meetingChat,
          label: l10n.meetingCallChat,
          onTap: () {
            Navigator.pop(sheetContext);
            _showSheet(_Sheet.chat);
          },
        ),
        MeetingMoreSheetAction(
          icon: Assets.icons.meetingSticker,
          label: l10n.meetingCallStickers,
          onTap: () {
            Navigator.pop(sheetContext);
            _bloc.add(const MeetingCallStickerPanelToggled());
          },
        ),
        MeetingMoreSheetAction(
          icon: Assets.icons.icUserGroup,
          label: l10n.meetingCallParticipants,
          onTap: () {
            Navigator.pop(sheetContext);
            _showSheet(_Sheet.participants);
          },
        ),
        MeetingMoreSheetAction(
          icon: Assets.icons.meetingInfo,
          label: l10n.meetingDetailTitle,
          onTap: () {
            Navigator.pop(sheetContext);
            _showSheet(_Sheet.details);
          },
        ),
        MeetingMoreSheetAction(
          icon: Assets.icons.meetingPower,
          label: l10n.meetingCallLeave,
          destructive: true,
          onTap: () {
            Navigator.pop(sheetContext);
            _showSheet(_Sheet.exit, includeEndForEveryone: false);
          },
        ),
      ],
    );
  }

  Widget _header(String title) {
    final colors = AppColors.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 12.h),
      child: Row(
        children: [
          Expanded(child: title.s(17.sp).w(800).c(colors.textStrong)),
          _circleAction(
            Assets.icons.icClose,
            colors.meetingControlSurface,
            colors.iconStrong,
            () => Navigator.of(context).maybePop(),
            AppLocalizations.of(context).meetingCallClose,
            size: 32.w,
            iconSize: 18.w,
          ),
        ],
      ),
    );
  }

  Widget _nameTag(String name) {
    final colors = AppColors.of(context);
    return _surface(
      color: colors.black.withValues(alpha: 0.62),
      radius: 8.r,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        child: name.s(13.sp).w(500).c(colors.textWhite),
      ),
    );
  }

  Widget _reactionNameTag(String reaction, String name) {
    final colors = AppColors.of(context);
    return _surface(
      color: colors.black.withValues(alpha: 0.62),
      radius: 8.r,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(reaction, style: TextStyle(fontSize: 14.sp)),
            SizedBox(width: 8.w),
            name.s(13.sp).w(500).c(colors.textWhite),
          ],
        ),
      ),
    );
  }

  Widget _stickersPanel() {
    return MeetingCallStickersPanel(
      onSelected: (sticker) => _bloc.add(MeetingCallStickerSelected(sticker)),
      onClosed: () => _bloc.add(const MeetingCallStickerPanelToggled()),
    );
  }

  Widget _wideButton(
    String label,
    Color background,
    Color foreground,
    VoidCallback onTap, {
    SvgGenImage? icon,
  }) {
    return MeetingPreviewButton(
      label: label,
      background: background,
      foreground: foreground,
      onTap: onTap,
      icon: icon,
    );
  }

  Widget _outlinedButton(
    String label,
    Color color,
    VoidCallback onTap, {
    SvgGenImage? icon,
  }) {
    return MeetingPreviewButton(
      label: label,
      background: Colors.transparent,
      foreground: color,
      onTap: onTap,
      icon: icon,
      outlined: true,
    );
  }

  Widget _circleAction(
    SvgGenImage asset,
    Color background,
    Color foreground,
    VoidCallback onTap,
    String label, {
    double? size,
    double? iconSize,
  }) {
    return MeetingPreviewIconButton(
      asset: asset,
      background: background,
      foreground: foreground,
      onTap: onTap,
      semanticLabel: label,
      size: size,
      iconSize: iconSize,
    );
  }

  Widget _avatar(String path, double size) =>
      MeetingPreviewAvatar(assetPath: path, size: size);

  Widget _icon(SvgGenImage asset, Color color, double size) => asset.svg(
    width: size,
    height: size,
    colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
  );

  Widget _surface({
    required Color color,
    required Widget child,
    double? radius,
  }) => MeetingPreviewSurface(color: color, radius: radius, child: child);
}
