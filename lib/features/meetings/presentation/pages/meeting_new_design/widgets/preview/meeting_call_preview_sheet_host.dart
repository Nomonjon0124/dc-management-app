import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:dc_management_app/config/theme/app_colors.dart';
import 'package:dc_management_app/core/extentions/text_extensions.dart';
import 'package:dc_management_app/core/gen/assets.gen.dart';
import 'package:dc_management_app/features/meetings/domain/entities/meeting_room.dart';
import 'package:dc_management_app/features/meetings/presentation/bloc/meeting_new_design/meeting_call_preview_event.dart';
import 'package:dc_management_app/features/meetings/presentation/bloc/meeting_new_design/meeting_call_preview_state.dart';
import 'package:dc_management_app/features/meetings/presentation/theme/meeting_theme_colors.dart';
import 'package:dc_management_app/l10n/app_localizations.dart';
import '../sheets/meeting_chat_sheet.dart';
import '../sheets/meeting_more_sheet.dart';
import 'meeting_call_preview_actions.dart';

/// Owns the modal lifecycle for the preview page. The production meeting room
/// has its own sheet host; keeping this adapter local prevents preview-only
/// state and demo data from leaking into production widgets.
class MeetingCallPreviewSheetHost {
  const MeetingCallPreviewSheetHost._();

  static Future<void> show(
    BuildContext context, {
    required MeetingCallPreviewSheet sheet,
    required MeetingCallPreviewState state,
    required ValueChanged<MeetingCallPreviewEvent> onEvent,
    required ValueChanged<MeetingCallPreviewSheet> onSheet,
    required Future<void> Function({required bool camera}) onPermission,
    bool includeEndForEveryone = true,
  }) async {
    final colors = AppColors.of(context);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: colors.overlaySurface,
      barrierColor: colors.black.withValues(alpha: 0.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (sheetContext) => _SheetBody(
        sheet: sheet,
        state: state,
        onEvent: onEvent,
        onSheet: onSheet,
        onPermission: onPermission,
        includeEndForEveryone: includeEndForEveryone,
        sheetContext: sheetContext,
      ),
    );
  }
}

class _SheetBody extends StatefulWidget {
  const _SheetBody({
    required this.sheet,
    required this.state,
    required this.onEvent,
    required this.onSheet,
    required this.onPermission,
    required this.includeEndForEveryone,
    required this.sheetContext,
  });

  final MeetingCallPreviewSheet sheet;
  final MeetingCallPreviewState state;
  final ValueChanged<MeetingCallPreviewEvent> onEvent;
  final ValueChanged<MeetingCallPreviewSheet> onSheet;
  final Future<void> Function({required bool camera}) onPermission;
  final bool includeEndForEveryone;
  final BuildContext sheetContext;

  @override
  State<_SheetBody> createState() => _SheetBodyState();
}

class _SheetBodyState extends State<_SheetBody> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(
      text: widget.state.participantSearch,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _title(AppLocalizations l10n) {
    switch (widget.sheet) {
      case MeetingCallPreviewSheet.participants:
        return l10n.meetingCallParticipantsCount;
      case MeetingCallPreviewSheet.chat:
        return l10n.meetingCallChat;
      case MeetingCallPreviewSheet.more:
        return l10n.meetingCallMore;
      case MeetingCallPreviewSheet.devices:
        return l10n.meetingCallMicAndSpeaker;
      case MeetingCallPreviewSheet.exit:
        return l10n.meetingCallExitQuestion;
      case MeetingCallPreviewSheet.details:
        return l10n.meetingCallDetails;
      case MeetingCallPreviewSheet.shareScreen:
        return l10n.meetingCallShareScreen;
      case MeetingCallPreviewSheet.camera:
        return l10n.meetingCallCameraAndBackground;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (widget.sheet == MeetingCallPreviewSheet.chat) return _chat(l10n);
    if (widget.sheet == MeetingCallPreviewSheet.more) return _more(l10n);
    final colors = AppColors.of(context);
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20.w,
          10.h,
          20.w,
          20.h + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.9,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                MeetingCallPreviewActions.surface(
                  color: colors.backgroundElevation2Alt,
                  radius: 2.r,
                  child: SizedBox(width: 36.w, height: 4.h),
                ),
                SizedBox(height: 14.h),
                Row(
                  children: [
                    Expanded(
                      child: _title(l10n).s(17.sp).w(800).c(colors.textStrong),
                    ),
                    MeetingCallPreviewActions.circleAction(
                      Assets.icons.icClose,
                      colors.meetingControlSurface,
                      colors.iconStrong,
                      () => Navigator.pop(context),
                      l10n.meetingCallClose,
                      size: 32.w,
                      iconSize: 18.w,
                    ),
                  ],
                ),
                SizedBox(height: 14.h),
                _content(l10n),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _content(AppLocalizations l10n) {
    switch (widget.sheet) {
      case MeetingCallPreviewSheet.participants:
        return _participants(l10n);
      case MeetingCallPreviewSheet.devices:
        return _devices(l10n);
      case MeetingCallPreviewSheet.exit:
        return _exit(l10n);
      case MeetingCallPreviewSheet.details:
        return _details(l10n);
      case MeetingCallPreviewSheet.shareScreen:
        return _shareScreen(l10n);
      case MeetingCallPreviewSheet.camera:
        return _camera(l10n);
      case MeetingCallPreviewSheet.chat:
      case MeetingCallPreviewSheet.more:
        return const SizedBox.shrink();
    }
  }

  Widget _chat(AppLocalizations l10n) => MeetingChatSheet(
    messages: [
      for (final message in widget.state.messages)
        MeetingRoomDataMessage(
          type: 'chat',
          senderIdentity: 'local',
          senderName: '',
          text: message,
          sentAt: DateTime.now(),
        ),
    ],
    localIdentity: 'local',
    onSend: (message) => widget.onEvent(MeetingCallChatMessageSent(message)),
  );

  Widget _more(AppLocalizations l10n) => MeetingMoreSheet(
    onClose: () => Navigator.pop(context),
    actions: [
      MeetingMoreSheetAction(
        icon: Assets.icons.meetingScreen,
        label: l10n.meetingCallShareScreen,
        onTap: () {
          Navigator.pop(context);
          widget.onEvent(const MeetingCallScreenSharingChanged(true));
          widget.onSheet(MeetingCallPreviewSheet.shareScreen);
        },
      ),
      MeetingMoreSheetAction(
        icon: Assets.icons.meetingChat,
        label: l10n.meetingCallChat,
        onTap: () {
          Navigator.pop(context);
          widget.onSheet(MeetingCallPreviewSheet.chat);
        },
      ),
      MeetingMoreSheetAction(
        icon: Assets.icons.meetingSticker,
        label: l10n.meetingCallStickers,
        onTap: () {
          Navigator.pop(context);
          widget.onEvent(const MeetingCallStickerPanelToggled());
        },
      ),
      MeetingMoreSheetAction(
        icon: Assets.icons.icUserGroup,
        label: l10n.meetingCallParticipants,
        onTap: () {
          Navigator.pop(context);
          widget.onSheet(MeetingCallPreviewSheet.participants);
        },
      ),
      MeetingMoreSheetAction(
        icon: Assets.icons.meetingInfo,
        label: l10n.meetingDetailTitle,
        onTap: () {
          Navigator.pop(context);
          widget.onSheet(MeetingCallPreviewSheet.details);
        },
      ),
      MeetingMoreSheetAction(
        icon: Assets.icons.meetingPower,
        label: l10n.meetingCallLeave,
        destructive: true,
        onTap: () {
          Navigator.pop(context);
          widget.onSheet(MeetingCallPreviewSheet.exit);
        },
      ),
    ],
  );

  Widget _participants(AppLocalizations l10n) {
    final colors = AppColors.of(context);
    final people = [
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
    ];
    final query = _searchController.text.toLowerCase();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MeetingCallPreviewActions.surface(
          color: colors.backgroundElevation1Alt,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w),
            child: Row(
              children: [
                MeetingCallPreviewActions.icon(
                  Assets.icons.icSearch,
                  colors.iconSub,
                  18.w,
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      widget.onEvent(
                        MeetingCallParticipantSearchChanged(value),
                      );
                      setState(() {});
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
        for (final person in people)
          if (person.$1.toLowerCase().contains(query))
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8.h),
              child: Row(
                children: [
                  MeetingCallPreviewActions.avatar(person.$2, 40.w),
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
                    MeetingCallPreviewActions.surface(
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
                            onTap: () => widget.onPermission(camera: false),
                            child: MeetingCallPreviewActions.icon(
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
                            onTap: () => widget.onPermission(camera: true),
                            child: MeetingCallPreviewActions.icon(
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
    );
  }

  Widget _devices(AppLocalizations l10n) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _section(l10n.meetingCallMicrophoneSection),
      _row(
        Assets.icons.meetingMic,
        l10n.meetingCallIphoneMicrophone,
        widget.state.microphoneDevice == 'iphone',
        () =>
            widget.onEvent(const MeetingCallMicrophoneDeviceSelected('iphone')),
      ),
      _row(
        Assets.icons.meetingMic,
        l10n.meetingCallAirpods,
        widget.state.microphoneDevice == 'airpods',
        () => widget.onEvent(
          const MeetingCallMicrophoneDeviceSelected('airpods'),
        ),
      ),
      _row(
        Assets.icons.meetingMic,
        l10n.meetingCallWiredHeadset,
        widget.state.microphoneDevice == 'wired',
        () =>
            widget.onEvent(const MeetingCallMicrophoneDeviceSelected('wired')),
      ),
      Divider(color: AppColors.of(context).strokeSub, height: 20.h),
      _section(l10n.meetingCallSpeakerSection),
      _row(
        Assets.icons.meetingMic,
        l10n.meetingCallIphoneSpeaker,
        widget.state.speakerDevice == 'iphone',
        () => widget.onEvent(const MeetingCallSpeakerDeviceSelected('iphone')),
      ),
      _row(
        Assets.icons.meetingMic,
        l10n.meetingCallAirpods,
        widget.state.speakerDevice == 'airpods',
        () => widget.onEvent(const MeetingCallSpeakerDeviceSelected('airpods')),
      ),
    ],
  );

  Widget _exit(AppLocalizations l10n) {
    final colors = AppColors.of(context);
    void finish() {
      Navigator.pop(context);
      widget.onEvent(const MeetingCallLeaveRequested());
    }

    return Column(
      children: [
        l10n.meetingCallExitHint.s(15.sp).w(500).c(colors.textSub).h(1.6),
        SizedBox(height: 14.h),
        MeetingCallPreviewActions.button(
          l10n.meetingCallLeave,
          colors.errorStrong,
          colors.textWhite,
          finish,
          icon: Assets.icons.meetingCallEnd,
        ),
        if (widget.includeEndForEveryone) ...[
          SizedBox(height: 10.h),
          MeetingCallPreviewActions.outlinedButton(
            l10n.meetingCallEndForEveryone,
            colors.errorStrong,
            finish,
            icon: Assets.icons.meetingPower,
          ),
        ],
        SizedBox(height: 10.h),
        MeetingCallPreviewActions.button(
          l10n.meetingCallCancel,
          colors.meetingControlSurface,
          colors.textStrong,
          () => Navigator.pop(context),
          icon: Assets.icons.icClose,
        ),
      ],
    );
  }

  Widget _details(AppLocalizations l10n) {
    final colors = AppColors.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        l10n.meetingCallDetailsHint.s(13.sp).w(500).c(colors.textSub),
        SizedBox(height: 12.h),
        MeetingCallPreviewActions.surface(
          color: colors.backgroundElevation1Alt,
          child: Padding(
            padding: EdgeInsets.all(12.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: _section(l10n.meetingCallJoinDetails)),
                    MeetingCallPreviewActions.surface(
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
                _detail(
                  Assets.icons.meetingCopy,
                  'raqamli-boshqaruv.uz/meetings/33',
                  colors.accentStrong,
                  value: null,
                  onTap: () => Clipboard.setData(
                    const ClipboardData(
                      text: 'raqamli-boshqaruv.uz/meetings/33',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 12.h),
        MeetingCallPreviewActions.surface(
          color: colors.backgroundElevation1Alt,
          child: Padding(
            padding: EdgeInsets.all(12.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _section(l10n.meetingCallMeetingParams),
                _detail(
                  Assets.icons.meetingInfo,
                  l10n.meetingCallOfficialUid,
                  colors.iconSub,
                  value: l10n.meetingCallMeetingUid,
                ),
                _detail(
                  Assets.icons.meetingInfo,
                  l10n.meetingCallMeetingTopic,
                  colors.iconSub,
                  value: l10n.meetingCallTopicValue,
                ),
                _detail(
                  Assets.icons.icCalendar,
                  l10n.meetingCallStartTime,
                  colors.iconSub,
                  value: l10n.meetingCallStartValue,
                ),
                _detail(
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

  Widget _shareScreen(AppLocalizations l10n) {
    final colors = AppColors.of(context);
    return Column(
      children: [
        _option(
          Assets.icons.meetingCallEnd,
          l10n.meetingCallStopSharing,
          colors.errorStrong,
          colors.errorDisabled,
          () {
            widget.onEvent(const MeetingCallScreenSharingChanged(false));
            Navigator.pop(context);
          },
        ),
        SizedBox(height: 8.h),
        _option(
          Assets.icons.icArrowRight,
          l10n.meetingCallChooseAnotherScreen,
          colors.iconStrong,
          colors.meetingControlSurface,
          () {
            widget.onEvent(const MeetingCallScreenSharingChanged(true));
            Navigator.pop(context);
          },
        ),
      ],
    );
  }

  Widget _camera(AppLocalizations l10n) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _section(l10n.meetingCallCameraSection),
      _row(
        Assets.icons.meetingVideo,
        l10n.meetingCallFrontCamera,
        widget.state.frontCamera,
        () => widget.onEvent(const MeetingCallCameraSelected(true)),
      ),
      _row(
        Assets.icons.meetingVideo,
        l10n.meetingCallRearCamera,
        !widget.state.frontCamera,
        () => widget.onEvent(const MeetingCallCameraSelected(false)),
      ),
      Divider(color: AppColors.of(context).strokeSub, height: 20.h),
      _section(l10n.meetingCallBackgroundSection),
      _row(
        Assets.icons.meetingVideo,
        l10n.meetingCallBlurBackground,
        widget.state.blurBackground,
        () => widget.onEvent(const MeetingCallBackgroundSelected(true)),
      ),
      _row(
        Assets.icons.meetingVideo,
        l10n.meetingCallNoBackground,
        !widget.state.blurBackground,
        () => widget.onEvent(const MeetingCallBackgroundSelected(false)),
      ),
      _row(
        Assets.icons.meetingVideo,
        l10n.meetingCallOfficeBackgrounds,
        false,
        () {},
      ),
    ],
  );

  Widget _section(String text) =>
      text.s(11.sp).w(800).c(AppColors.of(context).textSoft);

  Widget _row(
    SvgGenImage icon,
    String label,
    bool selected,
    VoidCallback onTap,
  ) {
    final colors = AppColors.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: MeetingCallPreviewActions.surface(
        color: selected ? colors.meetingControlSurface : colors.overlaySurface,
        radius: 12.r,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          child: Row(
            children: [
              MeetingCallPreviewActions.icon(
                icon,
                selected ? colors.iconStrong : colors.iconSub,
                18.w,
              ),
              SizedBox(width: 12.w),
              Expanded(child: label.s(15.sp).w(500).c(colors.textSub)),
              if (selected)
                MeetingCallPreviewActions.icon(
                  Assets.icons.icTuilconCheck,
                  colors.accentStrong,
                  18.w,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detail(
    SvgGenImage icon,
    String label,
    Color iconColor, {
    String? value,
    VoidCallback? onTap,
  }) {
    final colors = AppColors.of(context);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 4.h),
        child: Row(
          children: [
            MeetingCallPreviewActions.surface(
              color: colors.backgroundElevation2Alt,
              radius: 8.r,
              child: SizedBox(
                width: 28.w,
                height: 28.w,
                child: Center(
                  child: MeetingCallPreviewActions.icon(icon, iconColor, 16.w),
                ),
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
            if (onTap != null)
              MeetingCallPreviewActions.icon(
                Assets.icons.meetingCopy,
                colors.iconSub,
                18.w,
              ),
          ],
        ),
      ),
    );
  }

  Widget _option(
    SvgGenImage icon,
    String label,
    Color foreground,
    Color background,
    VoidCallback onTap,
  ) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(999.r),
    child: Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        children: [
          MeetingCallPreviewActions.surface(
            color: background,
            radius: 999.r,
            child: SizedBox(
              width: 44.w,
              height: 44.w,
              child: Center(
                child: MeetingCallPreviewActions.icon(icon, foreground, 18.w),
              ),
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
