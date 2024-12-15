// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import 'package:notredame/domain/constants/router_paths.dart';
import 'package:notredame/ui/more/widgets/more_view.dart';
import '../../helpers.dart';
import '../app/analytics/mocks/remote_config_service_mock.dart';
import '../app/navigation/mocks/navigation_service_mock.dart';
import 'feedback/mocks/in_app_review_service_mock.dart';

void main() {
  SharedPreferences.setMockInitialValues({});
  late AppIntl intl;
  late NavigationServiceMock navigationServiceMock;
  late RemoteConfigServiceMock remoteConfigServiceMock;
  late InAppReviewServiceMock inAppReviewServiceMock;

  group('MoreView - ', () {
    setUp(() async {
      intl = await setupAppIntl();
      navigationServiceMock = setupNavigationServiceMock();
      remoteConfigServiceMock = setupRemoteConfigServiceMock();
      setupSettingsManagerMock();
      setupCourseRepositoryMock();
      setupPreferencesServiceMock();
      setupUserRepositoryMock();
      setupCacheManagerMock();
      setupLaunchUrlServiceMock();
      setupNetworkingServiceMock();
      setupAnalyticsServiceMock();
      setupFlutterToastMock();
      inAppReviewServiceMock =
          setupInAppReviewServiceMock() as InAppReviewServiceMock;

      RemoteConfigServiceMock.stubGetPrivacyPolicyEnabled(
          remoteConfigServiceMock);
    });

    group('UI - ', () {
      testWidgets('has 1 listView and 8 listTiles when privacy policy disabled',
          (WidgetTester tester) async {
        RemoteConfigServiceMock.stubGetPrivacyPolicyEnabled(
            remoteConfigServiceMock,
            toReturn: false);
        await tester.pumpWidget(
            localizedWidget(child: MoreView()));
        await tester.pumpAndSettle(const Duration(seconds: 1));

        final listview = find.byType(ListView);
        expect(listview, findsOneWidget);

        final listTile = find.byType(ListTile);
        expect(listTile, findsNWidgets(7));
      });

      testWidgets('has 1 listView and 9 listTiles when privacy policy enabled',
          (WidgetTester tester) async {
        await tester.pumpWidget(
            localizedWidget(child: MoreView()));
        await tester.pumpAndSettle(const Duration(seconds: 1));

        final listview = find.byType(ListView);
        expect(listview, findsOneWidget);

        final listTile = find.byType(ListTile);
        expect(listTile, findsNWidgets(8));
      });

      group('navigation - ', () {
        testWidgets('about', (WidgetTester tester) async {
          RemoteConfigServiceMock.stubGetPrivacyPolicyEnabled(
              remoteConfigServiceMock,
              toReturn: false);
          await tester.pumpWidget(
              localizedWidget(child: MoreView()));
          await tester.pumpAndSettle(const Duration(seconds: 1));

          // Tap the button.
          await tester.tap(
              find.widgetWithText(ListTile, intl.more_about_applets_title));

          // Rebuild the widget after the state has changed.
          await tester.pump();

          verify(navigationServiceMock.pushNamed(RouterPaths.about)).called(1);
        });

        testWidgets('rate us is not available', (WidgetTester tester) async {
          RemoteConfigServiceMock.stubGetPrivacyPolicyEnabled(
              remoteConfigServiceMock,
              toReturn: false);
          InAppReviewServiceMock.stubIsAvailable(inAppReviewServiceMock,
              toReturn: false);

          await tester.pumpWidget(
              localizedWidget(child: MoreView()));
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
          RemoteConfigServiceMock.stubGetPrivacyPolicyEnabled(
              remoteConfigServiceMock,
              toReturn: false);
          InAppReviewServiceMock.stubIsAvailable(inAppReviewServiceMock);

          await tester.pumpWidget(
              localizedWidget(child: MoreView()));
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
          RemoteConfigServiceMock.stubGetPrivacyPolicyEnabled(
              remoteConfigServiceMock,
              toReturn: false);
          await tester.pumpWidget(
              localizedWidget(child: MoreView()));
          await tester.pumpAndSettle(const Duration(seconds: 1));

          // Tap the button.
          await tester
              .tap(find.widgetWithText(ListTile, intl.more_contributors));

          // Rebuild the widget after the state has changed.
          await tester.pump();

          verify(navigationServiceMock.pushNamed(RouterPaths.contributors))
              .called(1);
        });

        testWidgets('licenses', (WidgetTester tester) async {
          RemoteConfigServiceMock.stubGetPrivacyPolicyEnabled(
              remoteConfigServiceMock,
              toReturn: false);
          await tester.pumpWidget(
              localizedWidget(child: MoreView()));
          await tester.pumpAndSettle(const Duration(seconds: 1));

          // Tap the button.
          await tester.tap(
              find.widgetWithText(ListTile, intl.more_open_source_licenses));

          // Rebuild the widget after the state has changed.
          await tester.pumpAndSettle(const Duration(seconds: 1));

          expect(find.text('Close'), findsOneWidget);
          expect(find.text('View licenses'), findsOneWidget);
          expect(find.byType(AboutDialog), findsOneWidget);
        });

        testWidgets('need help', (WidgetTester tester) async {
          RemoteConfigServiceMock.stubGetPrivacyPolicyEnabled(
              remoteConfigServiceMock,
              toReturn: false);
          await tester.pumpWidget(
              localizedWidget(child: MoreView()));
          await tester.pumpAndSettle(const Duration(seconds: 1));

          // Tap the button.
          await tester.tap(find.widgetWithText(ListTile, intl.need_help));

          // Rebuild the widget after the state has changed.
          await tester.pump();

          verify(navigationServiceMock.pushNamed(RouterPaths.faq,
                  arguments: Colors.white))
              .called(1);
        });

        testWidgets('settings', (WidgetTester tester) async {
          RemoteConfigServiceMock.stubGetPrivacyPolicyEnabled(
              remoteConfigServiceMock,
              toReturn: false);
          await tester.pumpWidget(
              localizedWidget(child: MoreView()));
          await tester.pumpAndSettle(const Duration(seconds: 1));

          // Tap the button.
          await tester.tap(find.widgetWithText(ListTile, intl.settings_title));

          // Rebuild the widget after the state has changed.
          await tester.pump();

          verify(navigationServiceMock.pushNamed(RouterPaths.settings))
              .called(1);
        });

        testWidgets('logout', (WidgetTester tester) async {
          RemoteConfigServiceMock.stubGetPrivacyPolicyEnabled(
              remoteConfigServiceMock,
              toReturn: false);
          await tester.pumpWidget(
              localizedWidget(child: MoreView()));
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
    });
  });
}
