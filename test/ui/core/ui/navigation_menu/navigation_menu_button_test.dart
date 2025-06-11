// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:notredame/data/services/navigation_service.dart';
import 'package:notredame/data/services/networking_service.dart';
import 'package:notredame/ui/core/themes/app_palette.dart';
import 'package:notredame/ui/core/ui/navigation_menu/navigation_menu_button.dart';
import '../../../../data/mocks/services/analytics_service_mock.dart';
import '../../../../helpers.dart';

void main() {
  group('NavigationMenuButton - ', () {
    setUp(() {
      setupNavigationServiceMock();
      setupNetworkingServiceMock();
      setupAnalyticsServiceMock();
    });

    tearDown(() {
      unregister<NavigationService>();
      unregister<NetworkingService>();
      unregister<AnalyticsServiceMock>();
    });

    testWidgets('Initial state displays inactive icon and hidden text', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NavigationMenuButton(
              label: 'Test',
              activeIcon: Icons.home,
              inactiveIcon: Icons.home_outlined,
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.home_outlined), findsOneWidget);
      expect(find.byIcon(Icons.home), findsNothing);

      // Verify text is initially hidden (opacity 0)
      final fadeTransition = tester.widget<FadeTransition>(find.byType(FadeTransition));
      expect(fadeTransition.opacity.value, 0.0);
    });

    testWidgets('Tapping button triggers onPressed callback', (WidgetTester tester) async {
      bool isPressed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NavigationMenuButton(
              label: 'Test',
              activeIcon: Icons.home,
              inactiveIcon: Icons.home_outlined,
              onPressed: () => isPressed = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(ElevatedButton));
      expect(isPressed, true);
    });

    testWidgets('restartAnimation activates button state with animations', (WidgetTester tester) async {
      final key = GlobalKey<NavigationMenuButtonState>();
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(400, 800)), // Portrait
            child: Scaffold(
              body: NavigationMenuButton(
                key: key,
                label: 'Test',
                activeIcon: Icons.home,
                inactiveIcon: Icons.home_outlined,
                onPressed: () {},
              ),
            ),
          ),
        ),
      );

      // Trigger active state
      key.currentState!.restartAnimation();
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // Verify active icon and background color
      expect(find.byIcon(Icons.home), findsOneWidget);
      final elevatedButton = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      final backgroundColor = elevatedButton.style?.backgroundColor?.resolve({});
      expect(backgroundColor, AppPalette.etsLightRed);

      // Verify text is visible
      final fadeTransition = tester.widget<FadeTransition>(find.byType(FadeTransition));
      expect(fadeTransition.opacity.value, 1.0);

      // Verify shadow in portrait
      expect(find.byType(ClipRect), findsOneWidget);
    });

    testWidgets('reverseAnimation reverts to inactive state', (WidgetTester tester) async {
      final key = GlobalKey<NavigationMenuButtonState>();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NavigationMenuButton(
              key: key,
              label: 'Test',
              activeIcon: Icons.home,
              inactiveIcon: Icons.home_outlined,
              onPressed: () {},
            ),
          ),
        ),
      );

      key.currentState!.restartAnimation();
      await tester.pumpAndSettle();

      key.currentState!.reverseAnimation();
      await tester.pumpAndSettle();

      // Verify inactive icon and transparent background
      expect(find.byIcon(Icons.home_outlined), findsOneWidget);
      final elevatedButton = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(elevatedButton.style?.backgroundColor?.resolve({}), Colors.transparent);

      // Verify text is hidden
      final fadeTransition = tester.widget<FadeTransition>(find.byType(FadeTransition));
      expect(fadeTransition.opacity.value, 0.0);
    });

    testWidgets('In landscape orientation, no shadow is present', (WidgetTester tester) async {
      final key = GlobalKey<NavigationMenuButtonState>();
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(800, 400)), // Landscape
            child: Scaffold(
              body: NavigationMenuButton(
                key: key,
                label: 'Test',
                activeIcon: Icons.home,
                inactiveIcon: Icons.home_outlined,
                onPressed: () {},
              ),
            ),
          ),
        ),
      );

      key.currentState!.restartAnimation();
      await tester.pumpAndSettle();

      // Verify no shadow in landscape
      expect(find.byType(ClipRect), findsNothing);
    });
  });
}
