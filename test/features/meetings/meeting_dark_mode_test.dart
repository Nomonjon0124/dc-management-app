import 'package:dc_management_app/config/theme/app_colors.dart';
import 'package:dc_management_app/config/theme/app_theme.dart';
import 'package:dc_management_app/core/gen/assets.gen.dart';
import 'package:dc_management_app/features/meetings/domain/entities/meeting.dart';
import 'package:dc_management_app/features/meetings/domain/entities/meeting_attendance.dart';
import 'package:dc_management_app/features/meetings/presentation/pages/meeting_new_design/meeting_design_preview_page.dart';
import 'package:dc_management_app/features/meetings/presentation/pages/meeting_new_design/meeting_call_preview_page.dart';
import 'package:dc_management_app/features/meetings/presentation/pages/meeting_new_design/widgets/call/meeting_call_join_request.dart';
import 'package:dc_management_app/features/meetings/presentation/pages/meeting_new_design/widgets/sheets/meeting_permission_dialog.dart';
import 'package:dc_management_app/features/meetings/presentation/theme/meeting_theme_colors.dart';
import 'package:dc_management_app/features/meetings/presentation/widgets/meeting_card.dart';
import 'package:dc_management_app/features/meetings/presentation/widgets/meeting_excuse_row.dart';
import 'package:dc_management_app/l10n/app_localizations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('meeting semantic surfaces map to dark-safe tokens', () {
    final light = AppColors.light();
    final dark = AppColors.dark();

    expect(light.meetingControlSurface, light.backgroundElevation2);
    expect(dark.meetingControlSurface, dark.backgroundElevation2Alt);
    expect(light.meetingControlBarSurface, light.white);
    expect(dark.meetingControlBarSurface, dark.black);
    expect(light.meetingDestructiveSurface, light.errorSoft);
    expect(dark.meetingDestructiveSurface, dark.errorDisabled);
  });

  testWidgets('permission and join-request cards render in dark mode', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      _darkApp(
        Material(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                MeetingCallJoinRequest(
                  onReject: () {},
                  onAllow: () {},
                  participantName: 'Ali Valiyev',
                ),
                const SizedBox(height: 16),
                MeetingPermissionDialog(
                  title: 'Kamerani yoqasizmi?',
                  requesterName: 'Ali Valiyev',
                  requesterRole: 'Tashkilotchi, hozir so‘radi',
                  message:
                      'Qaror sizniki. Istamasangiz, kamerani o‘chiq qoldiring.',
                  declineLabel: 'Hozircha yo‘q',
                  enableLabel: 'Kamerani yoqish',
                  onDecline: () {},
                  onEnable: () {},
                  permissionIcon: Assets.icons.meetingVideo,
                  enableIcon: Assets.icons.meetingVideo,
                ),
              ],
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('Kamerani yoqasizmi?'), findsOneWidget);
    expect(find.text('Ali Valiyev'), findsWidgets);
  });

  testWidgets('meeting preview keeps dark mode stable through call sheets', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_darkApp(const MeetingCallPreviewPage()));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Qo‘shilish'));
    await tester.pumpAndSettle();
    if (!kDebugMode) return;

    await tester.tap(find.text('Demo: ruxsat berildi'));
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel('Yana'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Chat'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    await tester.tap(find.bySemanticsLabel('Yopish'));
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel('Yana'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ishtirokchilar'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('meeting list, reason row and form preview render in dark mode', (
    tester,
  ) async {
    await tester.pumpWidget(
      _darkApp(
        Material(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                MeetingCard(
                  meeting: Meeting(
                    id: 1,
                    title: 'Haftalik meeting',
                    uid: 'M-001',
                    projectName: 'Raqamli Nazorat',
                    startDate: DateTime(2026, 9, 29, 10),
                    organizerName: 'Ali Valiyev',
                    organizerRole: 'Tashkilotchi',
                    participantName: 'Madina Karimova',
                    participantPosition: 'Dasturchi',
                    isCompleted: false,
                    reason: '',
                    attended: null,
                  ),
                  onTap: () {},
                ),
                const SizedBox(height: 16),
                MeetingExcuseRow(
                  row: const MeetingAttendance(
                    id: 1,
                    meetingId: 1,
                    meetingTitle: 'Haftalik meeting',
                    isAttended: false,
                    isExcused: false,
                    absenceReason: 'Shaxsiy sabab',
                    userId: 2,
                    userName: 'Madina Karimova',
                    userPosition: 'Dasturchi',
                  ),
                  busy: false,
                  rejected: false,
                  onApprove: () {},
                  onReject: () {},
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(
      _darkApp(const MeetingDesignPreviewPage(mode: MeetingPreviewMode.create)),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}

Widget _darkApp(Widget home) {
  return ScreenUtilInit(
    designSize: const Size(390, 844),
    builder: (_, _) => MaterialApp(
      theme: AppTheme.dark,
      locale: const Locale('uz'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: home,
    ),
  );
}
