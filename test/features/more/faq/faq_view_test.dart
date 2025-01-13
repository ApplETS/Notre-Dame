// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import 'package:notredame/features/more/faq/faq_view.dart';
import 'package:notredame/features/more/faq/models/faq.dart';
import '../../../common/helpers.dart';
import '../settings/mocks/settings_manager_mock.dart';

void main() {
  SharedPreferences.setMockInitialValues({});
  group('FaqView - ', () {
    late AppIntl appIntl;

    late SettingsManagerMock settingsManagerMock;

    setUp(() async {
      setupLaunchUrlServiceMock();
      setupNetworkingServiceMock();
      setupAnalyticsServiceMock();
      settingsManagerMock = setupSettingsManagerMock();
      appIntl = await setupAppIntl();
    });

    tearDown(() {});

    group('UI - ', () {
      testWidgets('has x ElevatedButton', (WidgetTester tester) async {
        SettingsManagerMock.stubLocale(settingsManagerMock);

        await tester.pumpWidget(localizedWidget(child: const FaqView()));

        final Faq faq = Faq();

        final action1 =
            find.text(faq.actions[0].title["en"]!, skipOffstage: false);
        final action2 =
            find.text(faq.actions[1].title["en"]!, skipOffstage: false);
        final action3 =
            find.text(faq.actions[2].title["en"]!, skipOffstage: false);
        final action4 =
            find.text(faq.actions[3].title["en"]!, skipOffstage: false);
        
        await tester.drag(find.byType(ListView), const Offset(0.0, -300));
        await tester.pump();

        expect(action1, findsOneWidget);
        expect(action2, findsOneWidget);
        expect(action3, findsOneWidget);
        expect(action4, findsOneWidget);
      });

      testWidgets('tapping "Questions About ETS Button" shows dialog',
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

        final dialog = find.byType(AlertDialog);

        expect(dialog, findsOne);
      });

      testWidgets('tapping "Cancel" closes dialog',
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

        await tester.tap(cancelButton);
        await tester.pumpAndSettle();

        dialog = find.byType(AlertDialog);
        expect(dialog, findsNothing);
      });

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

      testWidgets('has 2 subtitles', (WidgetTester tester) async {
        SettingsManagerMock.stubLocale(settingsManagerMock);

        await tester.pumpWidget(localizedWidget(child: const FaqView()));
        await tester.pumpAndSettle();

        final subtitle1 = find.text(appIntl.actions);
        expect(subtitle1, findsNWidgets(1));

        final subtitle2 = find.text(appIntl.questions_and_answers);
        expect(subtitle2, findsNWidgets(1));
      });
    });
  });
}
