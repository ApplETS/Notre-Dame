// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// CONSTANTS
import 'package:notredame/core/constants/router_paths.dart';

// SERVICES
import 'package:notredame/core/services/navigation_service.dart';

// VIEW
import 'package:notredame/ui/views/more_view.dart';

// OTHER
import 'package:feature_discovery/feature_discovery.dart';

// HELPERS
import '../../helpers.dart';

void main() {
  AppIntl intl;
  NavigationService navigation;
  group('MoreView - ', () {
    setUp(() async {
      intl = await setupAppIntl();
      navigation = setupNavigationServiceMock();
      setupCourseRepositoryMock();
      setupPreferencesServiceMock();
      setupUserRepositoryMock();
      setupCacheManagerMock();
      setupSettingsManagerMock();
      setupGithubApiMock();
    });

    tearDown(() {});

    group('UI - ', () {
      testWidgets('has 1 listView and 6 listTiles',
          (WidgetTester tester) async {
        await tester.pumpWidget(localizedWidget(child: FeatureDiscovery(child: MoreView())));
        await tester.pumpAndSettle();

        final listview = find.byType(ListView);
        expect(listview, findsOneWidget);

        final listTile = find.byType(ListTile);
        expect(listTile, findsNWidgets(6));
      });

      group('navigation - ', () {
        testWidgets('about', (WidgetTester tester) async {
          await tester.pumpWidget(localizedWidget(child: FeatureDiscovery(child: MoreView())));
          await tester.pumpAndSettle();

          // Tap the button.
          await tester.tap(
              find.widgetWithText(ListTile, intl.more_about_applets_title));

          // Rebuild the widget after the state has changed.
          await tester.pump();

          verify(navigation.pushNamed(RouterPaths.about)).called(1);
        });

        testWidgets('contributors', (WidgetTester tester) async {
          await tester.pumpWidget(localizedWidget(child: FeatureDiscovery(child: MoreView())));
          await tester.pumpAndSettle();

          // Tap the button.
          await tester
              .tap(find.widgetWithText(ListTile, intl.more_contributors));

          // Rebuild the widget after the state has changed.
          await tester.pump();

          verify(navigation.pushNamed(RouterPaths.contributors)).called(1);
        });

        testWidgets('licenses', (WidgetTester tester) async {
          await tester.pumpWidget(localizedWidget(child: FeatureDiscovery(child: MoreView())));
          await tester.pumpAndSettle();

          // Tap the button.
          await tester.tap(
              find.widgetWithText(ListTile, intl.more_open_source_licenses));

          // Rebuild the widget after the state has changed.
          await tester.pumpAndSettle();

          expect(find.text('CLOSE'), findsOneWidget);
          expect(find.text('VIEW LICENSES'), findsOneWidget);
          expect(find.byType(AboutDialog), findsOneWidget);
        });

        testWidgets('settings', (WidgetTester tester) async {
          await tester.pumpWidget(localizedWidget(child: FeatureDiscovery(child: MoreView())));
          await tester.pumpAndSettle();

          // Tap the button.
          await tester.tap(find.widgetWithText(ListTile, intl.settings_title));

          // Rebuild the widget after the state has changed.
          await tester.pump();

          verify(navigation.pushNamed(RouterPaths.settings)).called(1);
        });

        testWidgets('logout', (WidgetTester tester) async {
          await tester.pumpWidget(localizedWidget(child: FeatureDiscovery(child: MoreView())));
          await tester.pumpAndSettle();

          // Tap the button.
          await tester.tap(find.widgetWithText(ListTile, intl.more_log_out));

          // Rebuild the widget after the state has changed.
          await tester.pumpAndSettle();

          expect(find.text('Yes'), findsOneWidget);
          expect(find.text('No'), findsOneWidget);
          expect(find.byType(AlertDialog), findsOneWidget);
        });
      });

      group("golden - ", () {
        testWidgets("default view", (WidgetTester tester) async {
          tester.binding.window.physicalSizeTestValue = const Size(800, 1410);

          await tester.pumpWidget(localizedWidget(child: FeatureDiscovery(child: MoreView())));
          await tester.pumpAndSettle();

          await expectLater(find.byType(MoreView),
              matchesGoldenFile(goldenFilePath("moreView_1")));
        });
      });
    });
  });
}
