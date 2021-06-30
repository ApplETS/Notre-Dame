// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:feature_discovery/feature_discovery.dart';

// SERVICE
import 'package:notredame/core/services/navigation_service.dart';

// WIDGET
import 'package:notredame/ui/widgets/bottom_bar.dart';

// OTHERS
import 'package:notredame/core/constants/router_paths.dart';

// HELPERS
import '../../helpers.dart';

// MOCKS
import '../../mock/services/networking_service_mock.dart';

NavigationService _navigationService;
NetworkingServiceMock networkingService;

void main() {
  group('BottomBar - ', () {
    setUp(() {
      _navigationService = setupNavigationServiceMock();
      networkingService = setupNetworkingServiceMock() as NetworkingServiceMock;
    });

    tearDown(() {
      unregister<NavigationService>();
      unregister<NetworkingServiceMock>();
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

    group('navigate when tapped to - ', () {
      testWidgets('dashboard', (WidgetTester tester) async {
        await tester.pumpWidget(
            localizedWidget(child: FeatureDiscovery(child: BottomBar())));
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.dashboard));

        verify(
            _navigationService.pushNamedAndRemoveUntil(RouterPaths.dashboard));
      });

      testWidgets('schedule', (WidgetTester tester) async {
        await tester.pumpWidget(
            localizedWidget(child: FeatureDiscovery(child: BottomBar())));
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.schedule));

        verify(
            _navigationService.pushNamedAndRemoveUntil(RouterPaths.schedule));
      });

      testWidgets('student', (WidgetTester tester) async {
        await tester.pumpWidget(
            localizedWidget(child: FeatureDiscovery(child: BottomBar())));
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.school));

        verify(_navigationService.pushNamedAndRemoveUntil(RouterPaths.student));
      });

      testWidgets('ets', (WidgetTester tester) async {
        await tester.pumpWidget(
            localizedWidget(child: FeatureDiscovery(child: BottomBar())));
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.account_balance));

        verify(_navigationService.pushNamedAndRemoveUntil(RouterPaths.ets));
      });

      testWidgets('more', (WidgetTester tester) async {
        await tester.pumpWidget(
            localizedWidget(child: FeatureDiscovery(child: BottomBar())));
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.dehaze));

        verify(_navigationService.pushNamedAndRemoveUntil(RouterPaths.more));
      });
    });
  });
}
