// FLUTTER / DART / THIRD-PARTIES
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:feature_discovery/feature_discovery.dart';
import 'package:notredame/core/constants/preferences_flags.dart';

// CONSTANTS
import 'package:notredame/core/constants/router_paths.dart';

// SERVICES
import 'package:notredame/core/services/navigation_service.dart';

// VIEW
import 'package:notredame/ui/views/more_view.dart';

// HELPERS
import '../../helpers.dart';
import '../../mock/managers/settings_manager_mock.dart';
import '../../mock/services/in_app_review_service_mock.dart';

void main() {
  AppIntl intl;
  NavigationService navigation;
  InAppReviewServiceMock inAppReviewServiceMock;
  SettingsManagerMock settingsManagerMock;

  group('MoreView - ', () {
    setUp(() async {
      intl = await setupAppIntl();
      navigation = setupNavigationServiceMock();
      setupCourseRepositoryMock();
      setupPreferencesServiceMock();
      setupUserRepositoryMock();
      setupCacheManagerMock();
      settingsManagerMock = setupSettingsManagerMock() as SettingsManagerMock;
      setupGithubApiMock();
      setupNetworkingServiceMock();
      setupAnalyticsServiceMock();
      inAppReviewServiceMock =
          setupInAppReviewServiceMock() as InAppReviewServiceMock;

      SettingsManagerMock.stubGetBool(
          settingsManagerMock, PreferencesFlag.discoveryMore,
          toReturn: true);
    });

    group('UI - ', () {
      testWidgets('has 1 listView and 8 listTiles',
          (WidgetTester tester) async {
        await tester.pumpWidget(
            localizedWidget(child: FeatureDiscovery(child: MoreView())));
        await tester.pumpAndSettle(const Duration(seconds: 1));

        final listview = find.byType(ListView);
        expect(listview, findsOneWidget);

        final listTile = find.byType(ListTile);
        expect(listTile, findsNWidgets(8));
      });

      group('navigation - ', () {
        testWidgets('about', (WidgetTester tester) async {
          await tester.pumpWidget(
              localizedWidget(child: FeatureDiscovery(child: MoreView())));
          await tester.pumpAndSettle(const Duration(seconds: 1));

          // Tap the button.
          await tester.tap(
              find.widgetWithText(ListTile, intl.more_about_applets_title));

          // Rebuild the widget after the state has changed.
          await tester.pump();

          verify(navigation.pushNamed(RouterPaths.about)).called(1);
        });

        testWidgets('rate us is not available', (WidgetTester tester) async {
          InAppReviewServiceMock.stubIsAvailable(inAppReviewServiceMock,
              toReturn: false);

          await tester.pumpWidget(
              localizedWidget(child: FeatureDiscovery(child: MoreView())));
          await tester.pumpAndSettle();

          // Tap the button.
          await tester
              .tap(find.widgetWithText(ListTile, intl.in_app_review_title));

          // Rebuild the widget after the state has changed.
          await tester.pumpAndSettle();

          verify(await inAppReviewServiceMock.isAvailable()).called(1);
          verifyNoMoreInteractions(inAppReviewServiceMock);
        });

        testWidgets('rate us is available', (WidgetTester tester) async {
          InAppReviewServiceMock.stubIsAvailable(inAppReviewServiceMock);

          await tester.pumpWidget(
              localizedWidget(child: FeatureDiscovery(child: MoreView())));
          await tester.pumpAndSettle();

          // Tap the button.
          await tester
              .tap(find.widgetWithText(ListTile, intl.in_app_review_title));

          // Rebuild the widget after the state has changed.
          await tester.pumpAndSettle();

          verify(await inAppReviewServiceMock.isAvailable()).called(1);
          verify(await inAppReviewServiceMock.openStoreListing()).called(1);
          verifyNoMoreInteractions(inAppReviewServiceMock);
        });

        testWidgets('contributors', (WidgetTester tester) async {
          await tester.pumpWidget(
              localizedWidget(child: FeatureDiscovery(child: MoreView())));
          await tester.pumpAndSettle(const Duration(seconds: 1));

          // Tap the button.
          await tester
              .tap(find.widgetWithText(ListTile, intl.more_contributors));

          // Rebuild the widget after the state has changed.
          await tester.pump();

          verify(navigation.pushNamed(RouterPaths.contributors)).called(1);
        });

        testWidgets('licenses', (WidgetTester tester) async {
          await tester.pumpWidget(
              localizedWidget(child: FeatureDiscovery(child: MoreView())));
          await tester.pumpAndSettle(const Duration(seconds: 1));

          // Tap the button.
          await tester.tap(
              find.widgetWithText(ListTile, intl.more_open_source_licenses));

          // Rebuild the widget after the state has changed.
          await tester.pumpAndSettle(const Duration(seconds: 1));

          expect(find.text('CLOSE'), findsOneWidget);
          expect(find.text('VIEW LICENSES'), findsOneWidget);
          expect(find.byType(AboutDialog), findsOneWidget);
        });

        testWidgets('need help', (WidgetTester tester) async {
          await tester.pumpWidget(
              localizedWidget(child: FeatureDiscovery(child: MoreView())));
          await tester.pumpAndSettle(const Duration(seconds: 1));

          // Tap the button.
          await tester.tap(find.widgetWithText(ListTile, intl.need_help));

          // Rebuild the widget after the state has changed.
          await tester.pump();

          verify(navigation.pushNamed(RouterPaths.faq, arguments: Colors.white))
              .called(1);
        });

        testWidgets('settings', (WidgetTester tester) async {
          await tester.pumpWidget(
              localizedWidget(child: FeatureDiscovery(child: MoreView())));
          await tester.pumpAndSettle(const Duration(seconds: 1));

          // Tap the button.
          await tester.tap(find.widgetWithText(ListTile, intl.settings_title));

          // Rebuild the widget after the state has changed.
          await tester.pump();

          verify(navigation.pushNamed(RouterPaths.settings)).called(1);
        });

        testWidgets('logout', (WidgetTester tester) async {
          await tester.pumpWidget(
              localizedWidget(child: FeatureDiscovery(child: MoreView())));
          await tester.pumpAndSettle(const Duration(seconds: 1));

          // Tap the button.
          await tester.tap(find.widgetWithText(ListTile, intl.more_log_out));

          // Rebuild the widget after the state has changed.
          await tester.pumpAndSettle(const Duration(seconds: 1));

          expect(find.text('Yes'), findsOneWidget);
          expect(find.text('No'), findsOneWidget);
          expect(find.byType(AlertDialog), findsOneWidget);
        });
      });

      group("golden - ", () {
        testWidgets("default view", (WidgetTester tester) async {
          tester.binding.window.physicalSizeTestValue = const Size(800, 1410);

          await tester.runAsync(() async {
            await tester.pumpWidget(
                localizedWidget(child: FeatureDiscovery(child: MoreView())));
            final Element element = tester.element(find.byType(Hero));
            final Hero widget = element.widget as Hero;
            final Image image = widget.child as Image;
            await precacheImage(image.image, element);
            await tester.pumpAndSettle();
          });
          await tester.pumpAndSettle(const Duration(seconds: 1));

          await expectLater(find.byType(MoreView),
              matchesGoldenFile(goldenFilePath("moreView_1")));
        });
      }, skip: !Platform.isLinux);
    });
  });
}
