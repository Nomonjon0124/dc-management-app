import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../../config/theme/app_colors.dart';
import '../../../../../../../core/extentions/text_extensions.dart';
import '../../../../../../../l10n/app_localizations.dart';

class MeetingParticipantsSheet extends StatelessWidget {
  const MeetingParticipantsSheet({
    super.key,
    required this.searchQuery,
    required this.onSearchChanged,
    required this.participants,
  });

  final String searchQuery;
  final ValueChanged<String> onSearchChanged;
  final List<MeetingParticipantItem> participants;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n = AppLocalizations.of(context);
    final filtered = participants
        .where(
          (item) => item.name.toLowerCase().contains(searchQuery.toLowerCase()),
        )
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          onChanged: onSearchChanged,
          decoration: InputDecoration(
            hintText: l10n.meetingCallSearchParticipant,
            prefixIcon: Padding(
              padding: EdgeInsets.all(12.w),
              child: const SizedBox.shrink(),
            ),
          ),
        ),
        SizedBox(height: 12.h),
        for (final participant in filtered)
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: participant.name
                .s(13.sp)
                .w(800)
                .c(colors.textStrong)
                .copyWith(maxLines: 1, overflow: TextOverflow.ellipsis),
            subtitle: participant.role.s(11.sp).w(500).c(colors.textSub),
            trailing: participant.trailing,
          ),
      ],
    );
  }
}

class MeetingParticipantItem {
  const MeetingParticipantItem({
    required this.name,
    required this.role,
    this.trailing,
  });

  final String name;
  final String role;
  final Widget? trailing;
}
