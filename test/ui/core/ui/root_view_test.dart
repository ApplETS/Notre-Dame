// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

// Project imports:
import 'package:notredame/data/repositories/broadcast_message_repository.dart';
import 'package:notredame/data/repositories/course_repository.dart';
import 'package:notredame/data/repositories/quick_link_repository.dart';
import 'package:notredame/data/repositories/settings_repository.dart';
import 'package:notredame/data/services/analytics_service.dart';
import 'package:notredame/data/services/cache_service.dart';
import 'package:notredame/data/services/in_app_review_service.dart';
import 'package:notredame/data/services/networking_service.dart';
import 'package:notredame/data/services/preferences_service.dart';
import 'package:notredame/data/services/remote_config_service.dart';
import 'package:notredame/ui/core/ui/root_view.dart';
import 'package:notredame/ui/dashboard/view/dashboard_view.dart';
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
      setupPreferencesServiceMock();
      setupCacheManagerMock();
      setupNetworkingServiceMock();
      analyticsServiceMock = setupAnalyticsServiceMock();
      setupInAppReviewServiceMock();
      setupQuickLinkRepositoryMock();

      // Stub the date time now
      final settingRepository = setupSettingsRepositoryMock();
      SettingsRepositoryMock.stubDateTimeNow(settingRepository, toReturn: DateTime.now());
    });

    tearDown(() {
      unregister<BroadcastMessageRepository>();
      unregister<RemoteConfigService>();
      unregister<CourseRepository>();
      unregister<PreferencesService>();
      unregister<CacheService>();
      unregister<NetworkingService>();
      unregister<AnalyticsService>();
      unregister<InAppReviewService>();
      unregister<QuickLinkRepository>();
      unregister<SettingsRepository>();
    });

    testWidgets('Initial view is DashboardView', (WidgetTester tester) async {
      await tester.pumpWidget(localizedWidget(child: RootView()));
      expect(find.byType(DashboardView), findsOneWidget);
    });

    testWidgets('Tapping navigation items switches views', (WidgetTester tester) async {
      await tester.pumpWidget(localizedWidget(child: RootView()));

      await tester.tap(find.byIcon(Icons.account_balance_outlined).first);
      verify(analyticsServiceMock.logEvent("RootView", "ets clicked"));
      await tester.pumpAndSettle();
      expect(find.byType(ETSView), findsOneWidget);
    });

    testWidgets('BottomNavigationBar is visible', (WidgetTester tester) async {
      await tester.pumpWidget(localizedWidget(child: RootView()));
      final flexWidget = tester.widget<Flex>(find.byType(Flex).first);
      expect(flexWidget.direction, Axis.vertical);
      tester.view.resetPhysicalSize();
    });

    testWidgets('NavigationRail is visible in landscape', (WidgetTester tester) async {
      await tester.pumpWidget(
        localizedWidget(
          child: MediaQuery(
            data: MediaQueryData(size: Size(400, 800)),
            child: Scaffold(body: RootView()),
          ),
        ),
      );

      final flexWidget = tester.widget<Flex>(find.byType(Flex).first);
      expect(flexWidget.direction, Axis.horizontal);
    });
  });
}
