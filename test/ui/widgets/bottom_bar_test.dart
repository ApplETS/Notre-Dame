// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:feature_discovery/feature_discovery.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

// Project imports:
import 'package:notredame/features/app/integration/networking_service.dart';
import 'package:notredame/features/app/navigation/navigation_service.dart';
import 'package:notredame/features/app/navigation/router_paths.dart';
import 'package:notredame/features/app/widgets/bottom_bar.dart';
import '../../helpers.dart';
import '../../mock/services/analytics_service_mock.dart';
import '../../mock/services/navigation_service_mock.dart';

late NavigationServiceMock navigationServiceMock;

void main() {
  group('BottomBar - ', () {
    setUp(() {
      navigationServiceMock = setupNavigationServiceMock();
      setupNetworkingServiceMock();
      setupAnalyticsServiceMock();
    });

    tearDown(() {
      unregister<NavigationService>();
      unregister<NetworkingService>();
      unregister<AnalyticsServiceMock>();
    });

    testWidgets(
        'has five sections with icons and titles (dashboard, schedule, student, ets and more)',
        (WidgetTester tester) async {
      await tester.pumpWidget(
          localizedWidget(child: FeatureDiscovery(child: BottomBar())));
      await tester.pumpAndSettle();

      final texts = find.byType(Text);
      final icons = find.byType(Icon);

      expect(texts, findsNWidgets(5));
      expect(icons, findsNWidgets(5));
    });

    testWidgets('not navigate when tapped multiple times',
        (WidgetTester tester) async {
      await tester.pumpWidget(
          localizedWidget(child: FeatureDiscovery(child: BottomBar())));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.school));
      await tester.tap(find.byIcon(Icons.school));
      await tester.tap(find.byIcon(Icons.school));
      await tester.tap(find.byIcon(Icons.school));
      await tester.tap(find.byIcon(Icons.school));
      await tester.tap(find.byIcon(Icons.school));

      verify(navigationServiceMock.pushNamedAndRemoveUntil(RouterPaths.student))
          .called(1);
    });

    group('navigate when tapped to - ', () {
      testWidgets('dashboard', (WidgetTester tester) async {
        await tester.pumpWidget(
            localizedWidget(child: FeatureDiscovery(child: BottomBar())));
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.schedule));
        await tester.tap(find.byIcon(Icons.dashboard));

        verify(navigationServiceMock
            .pushNamedAndRemoveUntil(RouterPaths.dashboard));
      });

      testWidgets('schedule', (WidgetTester tester) async {
        await tester.pumpWidget(
            localizedWidget(child: FeatureDiscovery(child: BottomBar())));
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.schedule));

        verify(navigationServiceMock
            .pushNamedAndRemoveUntil(RouterPaths.schedule));
      });

      testWidgets('student', (WidgetTester tester) async {
        await tester.pumpWidget(
            localizedWidget(child: FeatureDiscovery(child: BottomBar())));
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.school));

        verify(
            navigationServiceMock.pushNamedAndRemoveUntil(RouterPaths.student));
      });

      testWidgets('ets', (WidgetTester tester) async {
        await tester.pumpWidget(
            localizedWidget(child: FeatureDiscovery(child: BottomBar())));
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.account_balance));

        verify(navigationServiceMock.pushNamedAndRemoveUntil(RouterPaths.ets));
      });

      testWidgets('more', (WidgetTester tester) async {
        await tester.pumpWidget(
            localizedWidget(child: FeatureDiscovery(child: BottomBar())));
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.dehaze));

        verify(navigationServiceMock.pushNamedAndRemoveUntil(RouterPaths.more));
      });
    });
  });
}
