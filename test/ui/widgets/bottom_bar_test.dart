// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:notredame/core/constants/router_paths.dart';

// SERVICE
import 'package:notredame/core/services/navigation_service.dart';

// WIDGET
import 'package:notredame/ui/widgets/bottom_bar.dart';

import '../../helpers.dart';


NavigationService _navigationService;

void main() {
  group('BottomBar - ', () {
    setUp(() {
      _navigationService = setupNavigationServiceMock();
    });

    tearDown(() {
      unregister<NavigationService>();
    });

    testWidgets('has five sections with icons and titles (dashboard, schedule, student, ets and more)', (WidgetTester tester) async {
      await tester.pumpWidget(localizedWidget(child: BottomBar(BottomBar.dashboardView)));
      await tester.pumpAndSettle();

      final texts = find.byType(Text);
      final icons = find.byType(Icon);

      expect(texts, findsNWidgets(5));
      expect(icons, findsNWidgets(5));
    });

    group('navigate when tapped to - ', () {
      testWidgets('dashbord', (WidgetTester tester) async {
        await tester.pumpWidget(localizedWidget(child: BottomBar(BottomBar.dashboardView)));
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.dashboard));

        verify(_navigationService.pushNamed(RouterPaths.dashboard));
      });

      testWidgets('schedule', (WidgetTester tester) async {
        await tester.pumpWidget(localizedWidget(child: BottomBar(BottomBar.dashboardView)));
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.schedule));

        verify(_navigationService.pushNamed(RouterPaths.schedule));
      });

      testWidgets('student', (WidgetTester tester) async {
        await tester.pumpWidget(localizedWidget(child: BottomBar(BottomBar.dashboardView)));
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.school));

        verify(_navigationService.pushNamed(RouterPaths.student));
      });

      testWidgets('ets', (WidgetTester tester) async {
        await tester.pumpWidget(localizedWidget(child: BottomBar(BottomBar.dashboardView)));
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.account_balance));

        verify(_navigationService.pushNamed(RouterPaths.ets));
      });

      testWidgets('more', (WidgetTester tester) async {
        await tester.pumpWidget(localizedWidget(child: BottomBar(BottomBar.dashboardView)));
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.dehaze));

        verify(_navigationService.pushNamed(RouterPaths.more));
      });
    });
  });
}