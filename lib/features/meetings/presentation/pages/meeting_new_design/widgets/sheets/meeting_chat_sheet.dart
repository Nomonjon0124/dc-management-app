import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../../config/theme/app_colors.dart';
import '../../../../../../../core/extentions/text_extensions.dart';
import '../../../../../../../core/gen/assets.gen.dart';
import '../../../../../../../l10n/app_localizations.dart';
import '../../../../../domain/entities/meeting_room.dart';
import '../../../../theme/meeting_theme_colors.dart';

class MeetingChatSheet extends StatefulWidget {
  const MeetingChatSheet({
    super.key,
    required this.messages,
    required this.onSend,
    this.localIdentity,
  });

  final List<MeetingRoomDataMessage> messages;
  final ValueChanged<String> onSend;
  final String? localIdentity;

  @override
  State<MeetingChatSheet> createState() => _MeetingChatSheetState();
}

class _MeetingChatSheetState extends State<MeetingChatSheet> {
  late final TextEditingController _controller;
  late List<MeetingRoomDataMessage> _messages;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _messages = List<MeetingRoomDataMessage>.from(widget.messages);
  }

  @override
  void didUpdateWidget(covariant MeetingChatSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.messages != widget.messages) {
      _messages = List<MeetingRoomDataMessage>.from(widget.messages);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _send() {
    final value = _controller.text.trim();
    if (value.isEmpty) return;

    widget.onSend(value);
    setState(() {
      _messages = [
        ..._messages,
        MeetingRoomDataMessage(
          type: 'chat',
          senderIdentity: widget.localIdentity ?? 'local',
          senderName: '',
          text: value,
          sentAt: DateTime.now(),
        ),
      ];
    });
    _controller.clear();
  }

  bool _isLocal(MeetingRoomDataMessage message) =>
      widget.localIdentity != null &&
      message.senderIdentity == widget.localIdentity;

  String _time(DateTime value) {
    final local = value.toLocal();
    return '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
  }

  Widget _text(
    String value, {
    required double size,
    required int weight,
    required Color color,
    double? height,
    double? letterSpacing,
    int? maxLines,
  }) {
    final text = value.s(size.sp).w(weight).c(color);
    return text.copyWith(
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
      style: text.style?.copyWith(height: height, letterSpacing: letterSpacing),
    );
  }

  Widget _message(BuildContext context, MeetingRoomDataMessage message) {
    final colors = AppColors.of(context);
    final local = _isLocal(message);
    final name = local
        ? AppLocalizations.of(context).meetingCallYou
        : message.senderName.trim().isEmpty
        ? AppLocalizations.of(context).meetingCallParticipant
        : message.senderName.trim();
    final bubbleColor = local
        ? colors.accentStrong
        : colors.backgroundElevation1Alt;
    final textColor = local ? colors.textWhite : colors.textStrong;

    return Column(
      crossAxisAlignment: local
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: _text(
                name,
                size: 13,
                weight: 800,
                color: colors.textStrong,
                height: 20 / 13,
                maxLines: 1,
              ),
            ),
            if (message.sentAt != null) ...[
              SizedBox(width: 8.w),
              _text(
                _time(message.sentAt!),
                size: 11,
                weight: 500,
                color: colors.textSoft,
                height: 16 / 11,
                letterSpacing: .4.sp,
              ),
            ],
          ],
        ),
        SizedBox(height: 4.h),
        DecoratedBox(
          decoration: BoxDecoration(
            color: bubbleColor,
            borderRadius: BorderRadius.circular(14.r),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 270.w),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
              child: _text(
                message.text ?? '',
                size: 15,
                weight: 500,
                color: textColor,
                height: 24 / 15,
                maxLines: 8,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _emptyState(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 28.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Assets.icons.meetingChat.svg(
            width: 26.w,
            height: 26.w,
            colorFilter: ColorFilter.mode(colors.iconStrong, BlendMode.srcIn),
          ),
          SizedBox(height: 10.h),
          _text(
            l10n.meetingCallChatEmpty,
            size: 15,
            weight: 800,
            color: colors.textStrong,
            height: 24 / 15,
            maxLines: 1,
          ),
          _text(
            l10n.meetingCallChatEmptyHint,
            size: 13,
            weight: 500,
            color: colors.textSub,
            height: 20 / 13,
            maxLines: 1,
          ),
        ],
      ),
    );
  }

  Widget _input(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colors.backgroundElevation1Alt,
              borderRadius: BorderRadius.circular(999.r),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
              child: Row(
                children: [
                  Assets.icons.meetingAdd.svg(
                    width: 18.w,
                    height: 18.w,
                    colorFilter: ColorFilter.mode(
                      colors.iconSoft,
                      BlendMode.srcIn,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      maxLines: 1,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(),
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w500,
                        height: 24 / 15,
                        color: colors.textStrong,
                      ),
                      decoration: InputDecoration(
                        isDense: true,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        hintText: l10n.meetingCallMessageHint,
                        hintStyle: TextStyle(
                          fontFamily: 'Manrope',
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w500,
                          height: 24 / 15,
                          color: colors.textSoft,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(width: 10.w),
        Semantics(
          button: true,
          label: l10n.meetingCallSendMessage,
          child: GestureDetector(
            onTap: _send,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: colors.accentStrong,
                shape: BoxShape.circle,
              ),
              child: SizedBox(
                width: 44.w,
                height: 44.w,
                child: Center(
                  child: Assets.icons.meetingSend.svg(
                    width: 20.w,
                    height: 20.w,
                    colorFilter: ColorFilter.mode(
                      colors.iconWhite,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);
    final messages = _messages
        .where((message) => message.text?.trim().isNotEmpty == true)
        .toList();

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: 34.h + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * .78,
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: colors.backgroundElevation2Alt,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                    child: SizedBox(width: 36.w, height: 4.h),
                  ),
                ),
                SizedBox(height: 14.h),
                Row(
                  children: [
                    Expanded(
                      child: _text(
                        l10n.meetingCallChat,
                        size: 17,
                        weight: 800,
                        color: colors.textStrong,
                        height: 28 / 17,
                        maxLines: 1,
                      ),
                    ),
                    Semantics(
                      button: true,
                      label: l10n.meetingCallClose,
                      child: GestureDetector(
                        onTap: Navigator.of(context).pop,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: colors.meetingControlSurface,
                            shape: BoxShape.circle,
                          ),
                          child: SizedBox(
                            width: 32.w,
                            height: 32.w,
                            child: Center(
                              child: Assets.icons.icClose.svg(
                                width: 18.w,
                                height: 18.w,
                                colorFilter: ColorFilter.mode(
                                  colors.iconSoft,
                                  BlendMode.srcIn,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 14.h),
                _text(
                  l10n.meetingCallChatNote,
                  size: 13,
                  weight: 500,
                  color: colors.textSoft,
                  height: 20 / 13,
                  maxLines: 2,
                ),
                if (messages.isEmpty)
                  _emptyState(context)
                else
                  Flexible(
                    fit: FlexFit.loose,
                    child: ListView.separated(
                      shrinkWrap: true,
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      itemCount: messages.length,
                      separatorBuilder: (_, _) => SizedBox(height: 14.h),
                      itemBuilder: (_, index) =>
                          _message(context, messages[index]),
                    ),
                  ),
                _input(context),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
