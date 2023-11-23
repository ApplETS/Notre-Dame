// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:notredame/core/constants/faq.dart';
import 'package:notredame/core/managers/settings_manager.dart';
import 'package:notredame/ui/views/faq_view.dart';
import '../../helpers.dart';
import '../../mock/managers/settings_manager_mock.dart';

void main() {
  group('FaqView - ', () {
    AppIntl appIntl;

    SettingsManager settingsManager;

    setUp(() async {
      setupLaunchUrlServiceMock();
      settingsManager = setupSettingsManagerMock();
      appIntl = await setupAppIntl();
    });

    tearDown(() {});

    group('UI - ', () {
      testWidgets('has x ElevatedButton', (WidgetTester tester) async {
        SettingsManagerMock.stubLocale(settingsManager as SettingsManagerMock);

        await tester.pumpWidget(localizedWidget(child: const FaqView()));
        await tester.pumpAndSettle();

        final elevatedButton = find.byType(ElevatedButton, skipOffstage: false);

        final Faq faq = Faq();
        final numberOfButtons = faq.actions.length;
        expect(elevatedButton, findsNWidgets(numberOfButtons));
      });

      testWidgets('has 2 subtitles', (WidgetTester tester) async {
        SettingsManagerMock.stubLocale(settingsManager as SettingsManagerMock);

        await tester.pumpWidget(localizedWidget(child: const FaqView()));
        await tester.pumpAndSettle();

        final subtitle1 = find.text(appIntl.actions);
        expect(subtitle1, findsNWidgets(1));

        final subtitle2 = find.text(appIntl.questions_and_answers);
        expect(subtitle2, findsNWidgets(1));
      });

      testWidgets('has 1 title', (WidgetTester tester) async {
        SettingsManagerMock.stubLocale(settingsManager as SettingsManagerMock);

        await tester.pumpWidget(localizedWidget(child: const FaqView()));
        await tester.pumpAndSettle();

        final title = find.text(appIntl.need_help);

        expect(title, findsOneWidget);
      });
    });

    group("golden - ", () {
      testWidgets("default view", (WidgetTester tester) async {
        SettingsManagerMock.stubLocale(settingsManager as SettingsManagerMock);
        tester.binding.window.physicalSizeTestValue = const Size(1800, 2410);

        await tester.pumpWidget(localizedWidget(child: const FaqView()));
        await tester.pumpAndSettle();

        await expectLater(find.byType(FaqView),
            matchesGoldenFile(goldenFilePath("FaqView_1")));
      });
    }, skip: !Platform.isLinux);
  });
}
