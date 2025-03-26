// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import 'package:notredame/ui/more/faq/models/faq.dart';
import 'package:notredame/ui/more/faq/widgets/faq_view.dart';
import '../../../../data/mocks/repositories/settings_repository_mock.dart';
import '../../../../helpers.dart';

void main() {
  SharedPreferences.setMockInitialValues({});
  group('FaqView - ', () {
    late AppIntl appIntl;

    late SettingsRepositoryMock settingsManagerMock;

    setUp(() async {
      setupLaunchUrlServiceMock();
      setupNetworkingServiceMock();
      setupRemoteConfigServiceMock();

      settingsManagerMock = setupSettingsManagerMock();
      appIntl = await setupAppIntl();
    });

    tearDown(() {});

    group('UI - ', () {
      testWidgets('has x ElevatedButton', (WidgetTester tester) async {
        SettingsRepositoryMock.stubLocale(settingsManagerMock);

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
        SettingsRepositoryMock.stubLocale(settingsManagerMock);

        await tester.pumpWidget(localizedWidget(child: const FaqView()));

        final Faq faq = Faq();

        await tester.drag(find.byType(ListView), const Offset(0.0, -500));
        await tester.pumpAndSettle();

        final questionsAbtETSMobileBtn =
            find.widgetWithText(Card, faq.actions[3].title["en"]!);
        expect(questionsAbtETSMobileBtn, findsOneWidget);

        await tester.tap(questionsAbtETSMobileBtn);
        await tester.pumpAndSettle();

        final dialog = find.byType(AlertDialog);

        expect(dialog, findsOne);
      });

      testWidgets('has 2 subtitles', (WidgetTester tester) async {
        SettingsRepositoryMock.stubLocale(settingsManagerMock);

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
