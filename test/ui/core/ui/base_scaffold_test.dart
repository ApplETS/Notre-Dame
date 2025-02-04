// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:notredame/data/services/navigation_service.dart';
import 'package:notredame/data/services/networking_service.dart';
import 'package:notredame/ui/core/ui/base_scaffold.dart';
import '../../../data/mocks/services/analytics_service_mock.dart';
import '../../../helpers.dart';

void main() {
  group('BaseScaffold - ', () {
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

    testWidgets(
        'has a loading overlay (without the loading visible) widget and a bottom bar',
        (WidgetTester tester) async {
      await tester.pumpWidget(
          localizedWidget(child: const BaseScaffold(body: SizedBox())));
      await tester.pumpAndSettle();

      expect(find.byType(NavigationRail), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    group('loading - ', () {
      testWidgets('the loading is displayed if isLoading is true',
          (WidgetTester tester) async {
        await tester.pumpWidget(const MaterialApp(
            home: BaseScaffold(
                body: SizedBox(), isLoading: true, showBottomBar: false)));

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });

      testWidgets("the loading isn't displayed if isLoading is false",
          (WidgetTester tester) async {
        await tester.pumpWidget(localizedWidget(
            child: const BaseScaffold(body: SizedBox()), useScaffold: false));
        await tester.pumpAndSettle();

        expect(find.byType(CircularProgressIndicator), findsNothing);
      });
    });

    group('appBar - ', () {
      testWidgets("by default doesn't have an appBar if appBar is set",
          (WidgetTester tester) async {
        await tester.pumpWidget(localizedWidget(
            child: const BaseScaffold(body: SizedBox()), useScaffold: false));
        await tester.pumpAndSettle();

        final appBar = find.byType(AppBar);

        expect(appBar, findsNothing);
      });

      testWidgets('has an appBar if appBar is set',
          (WidgetTester tester) async {
        await tester.pumpWidget(localizedWidget(
            child: BaseScaffold(appBar: AppBar(), body: const SizedBox()),
            useScaffold: false));
        await tester.pumpAndSettle();

        final appBar = find.byType(AppBar);

        expect(appBar, findsOneWidget);
      });
    });
  });
}
