import 'package:dc_management_app/config/theme/app_colors.dart';
import 'package:dc_management_app/features/meetings/presentation/pages/meeting_new_design/meeting_call_preview_page.dart';
import 'package:dc_management_app/features/meetings/presentation/pages/meeting_new_design/meeting_design_preview_page.dart';
import 'package:dc_management_app/l10n/app_localizations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final size in const [
    Size(320, 568),
    Size(390, 844),
    Size(600, 960),
    Size(844, 390),
  ]) {
    testWidgets(
      'meeting design has no overflow at ${size.width}x${size.height}',
      (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          _app(const MeetingDesignPreviewPage(mode: MeetingPreviewMode.create)),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);

        await tester.pumpWidget(_app(const MeetingCallPreviewPage()));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        if (kDebugMode) {
          await tester.ensureVisible(find.text('Qo‘shilish'));
          await tester.tap(find.text('Qo‘shilish'));
          await tester.pumpAndSettle();
          await tester.ensureVisible(find.text('Demo: ruxsat berildi'));
          await tester.tap(find.text('Demo: ruxsat berildi'));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        }
      },
    );
  }

  testWidgets('chat composer remains usable with the keyboard', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_app(const MeetingCallPreviewPage()));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Qo‘shilish'));
    await tester.pumpAndSettle();
    if (!kDebugMode) return;
    await tester.tap(find.text('Demo: ruxsat berildi'));
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel('Yana'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Chat'));
    await tester.pumpAndSettle();

    final field = find.byType(TextField).last;
    await tester.tap(field);
    await tester.showKeyboard(field);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.enterText(field, 'Salom');
    await tester.testTextInput.receiveAction(TextInputAction.send);
    await tester.pumpAndSettle();
    expect(find.text('Salom'), findsOneWidget);
  });
}

Widget _app(Widget home) {
  return ScreenUtilInit(
    designSize: const Size(390, 844),
    builder: (_, _) => MaterialApp(
      theme: ThemeData(extensions: [AppColors.light()]),
      locale: const Locale('uz'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: home,
    ),
  );
}
