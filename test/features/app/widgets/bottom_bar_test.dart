// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

// Project imports:
import 'package:notredame/data/services/networking_service.dart';
import 'package:notredame/data/services/navigation_service.dart';
import 'package:notredame/domain/constants/router_paths.dart';
import 'package:notredame/ui/core/ui/bottom_bar.dart';
import '../../../helpers.dart';
import '../../../../testing/mocks/services/analytics_service_mock.dart';
import '../../../../testing/mocks/services/navigation_service_mock.dart';

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
          localizedWidget(child: BottomBar()));
      await tester.pumpAndSettle();

      final texts = find.byType(Text);
      final icons = find.byType(Icon);

      expect(texts, findsNWidgets(5));
      expect(icons, findsNWidgets(5));
    });

    testWidgets('not navigate when tapped multiple times',
        (WidgetTester tester) async {
      await tester.pumpWidget(
          localizedWidget(child: BottomBar()));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.school_outlined));
      await tester.tap(find.byIcon(Icons.school_outlined));
      await tester.tap(find.byIcon(Icons.school_outlined));
      await tester.tap(find.byIcon(Icons.school_outlined));
      await tester.tap(find.byIcon(Icons.school_outlined));
      await tester.tap(find.byIcon(Icons.school_outlined));

      verify(navigationServiceMock.pushNamedAndRemoveDuplicates(RouterPaths.student))
          .called(1);
    });

    group('navigate when tapped to - ', () {
      testWidgets('dashboard', (WidgetTester tester) async {
        await tester.pumpWidget(
            localizedWidget(child: BottomBar()));
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.schedule_outlined));
        await tester.tap(find.byIcon(Icons.dashboard));

        verify(navigationServiceMock.pushNamedAndRemoveDuplicates(RouterPaths.dashboard));
      });

      testWidgets('schedule', (WidgetTester tester) async {
        await tester.pumpWidget(
            localizedWidget(child: BottomBar()));
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.schedule_outlined));

        verify(navigationServiceMock.pushNamedAndRemoveDuplicates(RouterPaths.schedule));
      });

      testWidgets('student', (WidgetTester tester) async {
        await tester.pumpWidget(
            localizedWidget(child: BottomBar()));
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.school_outlined));

        verify(navigationServiceMock.pushNamedAndRemoveDuplicates(RouterPaths.student));
      });

      testWidgets('ets', (WidgetTester tester) async {
        await tester.pumpWidget(
            localizedWidget(child: BottomBar()));
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.account_balance_outlined));

        verify(navigationServiceMock.pushNamedAndRemoveDuplicates(RouterPaths.ets));
      });

      testWidgets('more', (WidgetTester tester) async {
        await tester.pumpWidget(
            localizedWidget(child: BottomBar()));
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.menu_outlined));

        verify(navigationServiceMock.pushNamedAndRemoveDuplicates(RouterPaths.more));
      });
    });
  });
}
