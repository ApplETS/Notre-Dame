// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

// Project imports:
import 'package:notredame/locator.dart';
import 'package:notredame/ui/core/ui/navigation_menu/navigation_menu.dart';
import 'package:notredame/ui/core/ui/root_view.dart';
import 'package:notredame/ui/dashboard/widgets/dashboard_view.dart';
import 'package:notredame/ui/ets/widgets/ets_view.dart';
import '../../../data/mocks/repositories/settings_repository_mock.dart';
import '../../../data/mocks/services/analytics_service_mock.dart';
import '../../../helpers.dart';

void main() {
  late AnalyticsServiceMock analyticsServiceMock;

  group('RootView - ', () {
    setUp(() {
      setupAppIntl();
      setupBroadcastMessageRepositoryMock();
      setupRemoteConfigServiceMock();
      setupCourseRepositoryMock();
      setupDynamicMessagesServiceMock();
      setupPreferencesServiceMock();
      setupCacheManagerMock();
      setupNetworkingServiceMock();
      setupListSessionsRepositoryMock();
      analyticsServiceMock = setupAnalyticsServiceMock();
      setupInAppReviewServiceMock();
      setupQuickLinkRepositoryMock();
      setupScheduleServiceMock();

      // Stub the date time now
      final settingRepository = setupSettingsRepositoryMock();
      SettingsRepositoryMock.stubDateTimeNow(settingRepository, toReturn: DateTime.now());
    });

    tearDown(() {
      locator.reset();
    });

    testWidgets('Initial view is DashboardView', (WidgetTester tester) async {
      await tester.pumpWidget(localizedWidget(child: const RootView()));
      expect(find.byType(DashboardView), findsOneWidget);
    });

    testWidgets('Tapping navigation items switches views', (WidgetTester tester) async {
      await tester.pumpWidget(localizedWidget(child: const RootView()));

      await tester.tap(find.byIcon(Icons.account_balance_outlined).first);
      verify(analyticsServiceMock.logEvent("RootView", "ets clicked"));
      await tester.pumpAndSettle();
      expect(find.byType(ETSView), findsOneWidget);
    });

    testWidgets('BottomNavigationBar is visible in portrait', (WidgetTester tester) async {
      await tester.pumpWidget(
        localizedWidget(
          child: const MediaQuery(
            data: MediaQueryData(size: Size(800, 400)),
            child: Scaffold(body: RootView()),
          ),
        ),
      );
      expect(find.byType(NavigationMenu), findsOneWidget);
    });

    testWidgets('NavigationRail is visible in landscape', (WidgetTester tester) async {
      await tester.pumpWidget(
        localizedWidget(
          child: const MediaQuery(
            data: MediaQueryData(size: Size(400, 800)),
            child: Scaffold(body: RootView()),
          ),
        ),
      );

      expect(find.byType(NavigationMenu), findsOneWidget);
    });
  });
}
