// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:notredame/features/app/widgets/need_help_notice_dialog.dart';

// Project imports:
import 'package:shared_preferences/shared_preferences.dart';
import '../../../common/helpers.dart';
import '../../more/settings/mocks/settings_manager_mock.dart';

void main() {
  SharedPreferences.setMockInitialValues({});
  group('NeedHelpNoticeDialog - ', () {
    late SettingsManagerMock settingsManagerMock;

    setUp(() async {
      setupLaunchUrlServiceMock();
      setupNetworkingServiceMock();

      settingsManagerMock = setupSettingsManagerMock();
    });

    tearDown(() {});

    testWidgets('tapping "Cancel" closes dialog', (WidgetTester tester) async {
      SettingsManagerMock.stubLocale(settingsManagerMock);

      NeedHelpNoticeDialog dialog =
          NeedHelpNoticeDialog(openMail: () {}, launchWebsite: () {});

      await tester.pumpWidget(localizedWidget(child: dialog));
      await tester.pumpAndSettle();

      final cancelButton = find.byIcon(Icons.cancel);
      expect(cancelButton, findsAny);

      await tester.tap(cancelButton);
      await tester.pumpAndSettle();

      testWidgets('tapping outside dialog closes it',
          (WidgetTester tester) async {
        SettingsManagerMock.stubLocale(settingsManagerMock);

        await tester.pumpWidget(localizedWidget(child: const FaqView()));
        
        final Faq faq = Faq();

        await tester.drag(find.byType(ListView), const Offset(0.0, -500));
        await tester.pumpAndSettle();

        final questionsAbtETSMobileBtn =
            find.widgetWithText(ElevatedButton, faq.actions[3].title["en"]!);
        expect(questionsAbtETSMobileBtn, findsOneWidget);
        
        await tester.tap(questionsAbtETSMobileBtn);
        await tester.pumpAndSettle();

        Finder dialog = find.byType(AlertDialog);
        expect(dialog, findsOne);

        final cancelButton = find.byIcon(Icons.cancel);
        expect(cancelButton, findsAny);

        await tester.tapAt(Offset.zero);
        await tester.pumpAndSettle();

        dialog = find.byType(AlertDialog);
        expect(dialog, findsNothing);
      });
      final dialogFound = find.byType(dialog.runtimeType);
      expect(dialogFound, findsNothing);
    });
  });
}
