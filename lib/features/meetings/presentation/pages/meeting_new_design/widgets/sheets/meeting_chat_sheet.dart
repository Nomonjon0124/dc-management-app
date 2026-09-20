import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../../config/theme/app_colors.dart';
import '../../../../../../../core/extentions/text_extensions.dart';
import '../../../../../../../core/gen/assets.gen.dart';
import '../../../../../../../l10n/app_localizations.dart';

class MeetingChatSheet extends StatefulWidget {
  const MeetingChatSheet({
    super.key,
    required this.messages,
    required this.onSend,
  });

  final List<String> messages;
  final ValueChanged<String> onSend;

  @override
  State<MeetingChatSheet> createState() => _MeetingChatSheetState();
}

class _MeetingChatSheetState extends State<MeetingChatSheet> {
  late final TextEditingController _controller;
  late List<String> _messages;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _messages = List<String>.from(widget.messages);
  }

  @override
  void didUpdateWidget(covariant MeetingChatSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.messages != widget.messages) {
      _messages = List<String>.from(widget.messages);
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
    setState(() => _messages.add(value));
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * .78,
      ),
      child: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? Center(
                    child: l10n.meetingCallChatEmpty
                        .s(15.sp)
                        .w(800)
                        .c(colors.textStrong),
                  )
                : ListView.builder(
                    itemCount: _messages.length,
                    itemBuilder: (context, index) => Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 8.h),
                        child: Text(_messages[index]),
                      ),
                    ),
                  ),
          ),
          SafeArea(
            top: false,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    maxLines: 1,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _send(),
                    decoration: InputDecoration(
                      hintText: l10n.meetingCallMessageHint,
                      filled: true,
                      fillColor: colors.backgroundElevation1Alt,
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                InkWell(
                  onTap: _send,
                  child: Assets.icons.meetingSend.svg(
                    width: 20.w,
                    height: 20.w,
                    colorFilter: ColorFilter.mode(
                      colors.accentStrong,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
