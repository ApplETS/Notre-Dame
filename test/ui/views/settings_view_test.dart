// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:feature_discovery/feature_discovery.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:notredame/core/services/networking_service.dart';
import 'package:notredame/ui/views/settings_view.dart';
import '../../helpers.dart';
import '../../mock/services/analytics_service_mock.dart';

void main() {
  late AppIntl intl;

  group('SettingsView - ', () {
    setUp(() async {
      intl = await setupAppIntl();
      setupNavigationServiceMock();
      setupNetworkingServiceMock();
      setupCacheManagerMock();
      setupSettingsManagerMock();
      setupAnalyticsServiceMock();
    });

    tearDown(() {
      unregister<NetworkingService>();
      unregister<AnalyticsServiceMock>();
    });

    group('UI - ', () {
      testWidgets('has 1 listView and 4 listTiles and 1 divider',
          (WidgetTester tester) async {
        await tester.pumpWidget(
            localizedWidget(child: FeatureDiscovery(child: SettingsView())));
        await tester.pumpAndSettle();

        final listview = find.byType(ListView);
        expect(listview, findsOneWidget);

        final listTile = find.byType(ListTile);
        expect(listTile, findsNWidgets(4));

        final divider = find.byType(Divider);
        expect(divider, findsOneWidget);
      });

      group('Theme button - ', () {
        testWidgets('light theme', (WidgetTester tester) async {
          await tester.pumpWidget(
              localizedWidget(child: FeatureDiscovery(child: SettingsView())));
          await tester.pumpAndSettle();

          // Tap the button.
          await tester.tap(
              find.widgetWithText(ListTile, intl.settings_dark_theme_pref));

          // Rebuild the widget after the state has changed.
          await tester.pumpAndSettle();

          expect(find.text(intl.light_theme), findsOneWidget);
          expect(find.text(intl.dark_theme), findsOneWidget);

          // Tap the button.
          await tester.tap(find.text(intl.light_theme));
          // Rebuild the widget after the state has changed.
          await tester.pumpAndSettle();

          expect(find.byIcon(Icons.wb_sunny), findsOneWidget);
        });

        testWidgets('dark theme', (WidgetTester tester) async {
          await tester.pumpWidget(
              localizedWidget(child: FeatureDiscovery(child: SettingsView())));
          await tester.pumpAndSettle();

          // Tap the button.
          await tester.tap(
              find.widgetWithText(ListTile, intl.settings_dark_theme_pref));

          // Rebuild the widget after the state has changed.
          await tester.pumpAndSettle();

          expect(find.text(intl.light_theme), findsOneWidget);
          expect(find.text(intl.dark_theme), findsOneWidget);

          // Tap the button.
          await tester.tap(find.text(intl.dark_theme));
          // Rebuild the widget after the state has changed.
          await tester.pumpAndSettle();

          expect(find.byIcon(Icons.nightlight_round), findsOneWidget);
        });

        testWidgets('system theme', (WidgetTester tester) async {
          await tester.pumpWidget(
              localizedWidget(child: FeatureDiscovery(child: SettingsView())));
          await tester.pumpAndSettle();

          // Tap the button.
          await tester.tap(
              find.widgetWithText(ListTile, intl.settings_dark_theme_pref));

          // Rebuild the widget after the state has changed.
          await tester.pumpAndSettle();

          expect(find.text(intl.light_theme), findsOneWidget);
          expect(find.text(intl.dark_theme), findsOneWidget);

          // Tap the button.
          await tester.tap(find.text(intl.system_theme).last);
          // Rebuild the widget after the state has changed.
          await tester.pumpAndSettle();

          expect(find.byIcon(Icons.brightness_auto), findsOneWidget);
        });
      });

      group('Language button - ', () {
        testWidgets('french', (WidgetTester tester) async {
          await tester.pumpWidget(
              localizedWidget(child: FeatureDiscovery(child: SettingsView())));
          await tester.pumpAndSettle();

          // Tap the button.
          await tester
              .tap(find.widgetWithText(ListTile, intl.settings_language_pref));

          // Rebuild the widget after the state has changed.
          await tester.pumpAndSettle();

          expect(find.text(intl.settings_french), findsOneWidget);
          expect(find.text(intl.settings_english), findsOneWidget);

          // Tap the button.
          await tester.tap(find.text(intl.settings_french).last);
          // Rebuild the widget after the state has changed.
          await tester.pumpAndSettle();

          expect(find.text(intl.settings_french), findsOneWidget);
        });

        testWidgets('english', (WidgetTester tester) async {
          await tester.pumpWidget(
              localizedWidget(child: FeatureDiscovery(child: SettingsView())));
          await tester.pumpAndSettle();

          // Tap the button.
          await tester
              .tap(find.widgetWithText(ListTile, intl.settings_language_pref));

          // Rebuild the widget after the state has changed.
          await tester.pumpAndSettle();

          expect(find.text(intl.settings_french), findsOneWidget);
          expect(find.text(intl.settings_english), findsOneWidget);

          // Tap the button.
          await tester.tap(find.text(intl.settings_english));
          // Rebuild the widget after the state has changed.
          await tester.pumpAndSettle();

          expect(find.text(intl.settings_english), findsOneWidget);
        });
      });

      group("golden - ", () {
        testWidgets("default view", (WidgetTester tester) async {
          tester.binding.window.physicalSizeTestValue = const Size(800, 1410);

          await tester.pumpWidget(
              localizedWidget(child: FeatureDiscovery(child: SettingsView())));
          await tester.pumpAndSettle();

          await expectLater(find.byType(SettingsView),
              matchesGoldenFile(goldenFilePath("settingsView_1")));
        });
      }, skip: !Platform.isLinux);
    });
  });
}
