// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:notredame/data/services/navigation_service.dart';
import 'package:notredame/data/services/networking_service.dart';
import 'package:notredame/ui/core/ui/navigation_menu/navigation_menu.dart';
import '../../../../data/mocks/services/analytics_service_mock.dart';
import '../../../../helpers.dart';

late int selectedIndex;

Widget buildNavigationMenu({Size size = const Size(400, 800)}) {
  return localizedWidget(
    child: MediaQuery(
      data: MediaQueryData(size: size),
      child: Scaffold(
        body: NavigationMenu(selectedIndex: 0, indexChangedCallback: (callback) => selectedIndex = callback.index),
      ),
    ),
  );
}

void main() {
  late List<String> buttonLabels;

  group('buttons - ', () {
    setUp(() {
      selectedIndex = 0;
      buttonLabels = ['Dashboard', 'Schedule', 'Student', 'ÉTS', 'More'];
      setupNavigationServiceMock();
      setupNetworkingServiceMock();
      setupAnalyticsServiceMock();
    });

    tearDown(() {
      unregister<NavigationService>();
      unregister<NetworkingService>();
      unregister<AnalyticsServiceMock>();
    });

    testWidgets('Tapping buttons updates active index', (WidgetTester tester) async {
      await tester.pumpWidget(buildNavigationMenu());
      await tester.pumpAndSettle();

      // Tap third button
      await tester.tap(find.byType(Icon).last);
      await tester.pumpAndSettle();

      expect(selectedIndex, 4);
    });

    testWidgets('Shows correct number of navigation buttons', (WidgetTester tester) async {
      await tester.pumpWidget(buildNavigationMenu());

      for (final label in buttonLabels) {
        expect(find.text(label), findsOneWidget);
      }
    });

    testWidgets('Does nothing when tapping active button', (WidgetTester tester) async {
      await tester.pumpWidget(buildNavigationMenu());
      await tester.pumpAndSettle();

      // Initial active button is Dashboard (index 0)
      await tester.tap(find.byType(Icon).first);
      await tester.pumpAndSettle();

      // Verify index didn't change
      expect(selectedIndex, 0);
    });
  });

  group('orientation', () {
    testWidgets('Renders bottom bar in portrait orientation', (WidgetTester tester) async {
      await tester.pumpWidget(buildNavigationMenu());

      expect(find.byType(Flex), findsWidgets);

      final flexWidget = tester.widget<Flex>(find.byType(Flex).first);
      expect(flexWidget.direction, Axis.horizontal);
    });

    testWidgets('Renders sidebar in landscape orientation', (WidgetTester tester) async {
      await tester.pumpWidget(buildNavigationMenu(size: const Size(800, 400)));

      expect(find.byType(Flex), findsWidgets);

      final flexWidget = tester.widget<Flex>(find.byType(Flex).first);
      expect(flexWidget.direction, Axis.vertical);
    });

    testWidgets('Updates UI when orientation changes', (WidgetTester tester) async {
      await tester.pumpWidget(buildNavigationMenu());
      Flex flexWidget = tester.widget<Flex>(find.byType(Flex).first);
      expect(flexWidget.direction, Axis.horizontal);

      // Change to landscape
      await tester.pumpWidget(buildNavigationMenu(size: const Size(800, 400)));
      await tester.pumpAndSettle();

      flexWidget = tester.widget<Flex>(find.byType(Flex).first);
      expect(flexWidget.direction, Axis.vertical);

      expect(find.byType(Container), findsWidgets);
    });
  });
}
