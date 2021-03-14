// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// VIEW
import 'package:notredame/ui/views/choose_language_view.dart';

import '../../helpers.dart';

void main() {
  AppIntl intl;
  group('SettingsView - ', () {
    setUp(() async {
      intl = await setupAppIntl();
      setupNavigationServiceMock();
      setupCacheManagerMock();
      setupSettingsManagerMock();
    });

    tearDown(() {});

    group('UI - ', () {
      testWidgets('has an icon, title and subtitle',
          (WidgetTester tester) async {
        await tester.pumpWidget(localizedWidget(child: ChooseLanguageView()));
        await tester.pumpAndSettle();

        expect(find.text(intl.choose_language_title), findsOneWidget);
        expect(find.text(intl.choose_language_subtitle), findsOneWidget);
        expect(find.byIcon(Icons.language), findsOneWidget);
      });

      testWidgets('has a listView',
          (WidgetTester tester) async {
        await tester.pumpWidget(localizedWidget(child: ChooseLanguageView()));
        await tester.pumpAndSettle();

        final listview = find.byType(ListView);
        expect(listview, findsOneWidget);
      });
    });
  });
}
