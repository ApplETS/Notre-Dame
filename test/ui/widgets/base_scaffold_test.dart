// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:feature_discovery/feature_discovery.dart';

// SERVICE
import 'package:notredame/core/services/navigation_service.dart';
import 'package:notredame/core/services/networking_service.dart';

// WIDGET
import 'package:notredame/ui/widgets/base_scaffold.dart';
import 'package:notredame/ui/widgets/bottom_bar.dart';

// HELPERS
import '../../helpers.dart';

void main() {
  group('BaseScaffold - ', () {
    setUp(() {
      setupNavigationServiceMock();
      setupNetworkingServiceMock();
    });

    tearDown(() {
      unregister<NavigationService>();
      unregister<NetworkingService>();
    });

    testWidgets(
        'has a loading overlay (without the loading visible) widget and a bottom bar',
        (WidgetTester tester) async {
      await tester.pumpWidget(localizedWidget(
          child: FeatureDiscovery(child: const BaseScaffold(body: SizedBox())),
          useScaffold: false));
      await tester.pumpAndSettle();

      expect(find.byType(BottomBar), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    group('loading - ', () {
      testWidgets('the loading is displayed if isLoading is true',
          (WidgetTester tester) async {
        await tester.pumpWidget(FeatureDiscovery(
            child: const MaterialApp(
                home: BaseScaffold(
                    body: SizedBox(), isLoading: true, showBottomBar: false))));

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });

      testWidgets("the loading isn't displayed if isLoading is false",
          (WidgetTester tester) async {
        await tester.pumpWidget(localizedWidget(
            child:
                FeatureDiscovery(child: const BaseScaffold(body: SizedBox())),
            useScaffold: false));
        await tester.pumpAndSettle();

        expect(find.byType(CircularProgressIndicator), findsNothing);
      });
    });

    group('appBar - ', () {
      testWidgets("by default doesn't have an appBar if appBar is set",
          (WidgetTester tester) async {
        await tester.pumpWidget(localizedWidget(
            child:
                FeatureDiscovery(child: const BaseScaffold(body: SizedBox())),
            useScaffold: false));
        await tester.pumpAndSettle();

        final appBar = find.byType(AppBar);

        expect(appBar, findsNothing);
      });

      testWidgets('has an appBar if appBar is set',
          (WidgetTester tester) async {
        await tester.pumpWidget(localizedWidget(
            child: FeatureDiscovery(
                child: BaseScaffold(appBar: AppBar(), body: const SizedBox())),
            useScaffold: false));
        await tester.pumpAndSettle();

        final appBar = find.byType(AppBar);

        expect(appBar, findsOneWidget);
      });
    });
  });
}
