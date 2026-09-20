import 'package:dc_management_app/config/theme/app_colors.dart';
import 'package:dc_management_app/features/meetings/presentation/pages/meeting_call_preview_page.dart';
import 'package:dc_management_app/l10n/app_localizations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('meeting preview walks through joining and call panels', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(390, 844),
        builder: (_, _) => MaterialApp(
          theme: ThemeData(extensions: [AppColors.light()]),
          locale: const Locale('uz'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const MeetingCallPreviewPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Uchrashuvga qo‘shilish'), findsOneWidget);

    await tester.tap(find.text('Qo‘shilish'));
    await tester.pumpAndSettle();
    expect(find.text('Ruxsat kutilmoqda'), findsOneWidget);

    if (kDebugMode) {
      await tester.tap(find.text('Demo: ruxsat berildi'));
      await tester.pumpAndSettle();
      expect(find.text('Meet nomi'), findsOneWidget);

      await tester.tap(find.text('3'));
      await tester.pumpAndSettle();
      expect(find.text('Ishtirokchilar (3)'), findsOneWidget);

      await tester.tap(find.bySemanticsLabel('Yopish'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Siz'));
      await tester.pumpAndSettle();
      expect(find.text('Bekzod Qodirov'), findsOneWidget);

      await tester.tap(find.text('Dilnoza Sattorova'));
      await tester.pumpAndSettle();
      await tester.tap(find.bySemanticsLabel('Yana'));
      await tester.pumpAndSettle();
      expect(find.text('Ekranni ulashish'), findsOneWidget);

      await tester.tap(find.text('Ekranni ulashish'));
      await tester.pumpAndSettle();
      expect(find.text('Siz ekranni ulashyapsiz'), findsOneWidget);

      await tester.tap(find.bySemanticsLabel('Yopish'));
      await tester.pumpAndSettle();
      await tester.tap(find.bySemanticsLabel('Chiqish'));
      await tester.pumpAndSettle();
      expect(find.text('Uchrashuvdan chiqasizmi?'), findsOneWidget);

      await tester.tap(find.text('Chiqish'));
      await tester.pumpAndSettle();
      expect(find.text('Siz uchrashuvdan chiqdingiz'), findsOneWidget);
    }
  });
}
