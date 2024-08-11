// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:notredame/features/app/navigation/navigation_service.dart';
import 'package:notredame/features/more/settings/choose_language_view.dart';
import 'package:notredame/features/more/settings/settings_manager.dart';
import '../../../common/helpers.dart';

void main() {
  late AppIntl intl;
  group('SettingsView - ', () {
    setUp(() async {
      intl = await setupAppIntl();
      setupNavigationServiceMock();
      setupSettingsManagerMock();
    });

    tearDown(() {
      unregister<NavigationService>();
      unregister<SettingsManager>();
    });

    group('UI - ', () {
      testWidgets('has an icon, title and subtitle',
          (WidgetTester tester) async {
        await tester.pumpWidget(localizedWidget(child: ChooseLanguageView()));
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.language), findsOneWidget);
        expect(find.text(intl.choose_language_title), findsOneWidget);
        expect(find.text(intl.choose_language_subtitle), findsOneWidget);
      });

      testWidgets('has a listView', (WidgetTester tester) async {
        await tester.pumpWidget(localizedWidget(child: ChooseLanguageView()));
        await tester.pumpAndSettle();

        final listview = find.byType(ListView);
        expect(listview, findsWidgets);
      });
    });
  });
}
