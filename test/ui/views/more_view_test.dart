// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

// CONSTANTS
import 'package:notredame/core/constants/router_paths.dart';

// GENERATED
import 'package:notredame/generated/l10n.dart';

// SERVICES
import 'package:notredame/core/services/navigation_service.dart';

// VIEW
import 'package:notredame/ui/views/more_view.dart';

import '../../helpers.dart';

void main() {
  AppIntl intl;
  NavigationService navigation;
  group('MoreView - ', () {
    setUp(() async {
      intl = await setupAppIntl();
      navigation = setupNavigationServiceMock();
      setupCacheManagerMock();
    });

    tearDown(() {});

    group('UI - ', () {
      testWidgets('has 1 listView and 6 listTiles',
          (WidgetTester tester) async {
        await tester.pumpWidget(localizedWidget(child: MoreView()));
        await tester.pumpAndSettle();

        final listview = find.byType(ListView);
        expect(listview, findsOneWidget);

        final listTile = find.byType(ListTile);
        expect(listTile, findsNWidgets(6));
      });

      group('navigation - ', () {
        testWidgets('about', (WidgetTester tester) async {
          await tester.pumpWidget(localizedWidget(child: MoreView()));
          await tester.pumpAndSettle();

          // Tap the button.
          await tester.tap(
              find.widgetWithText(ListTile, intl.more_about_applets_title));

          // Rebuild the widget after the state has changed.
          await tester.pump();

          verify(navigation.pushNamed(RouterPaths.about)).called(1);
        });

        testWidgets('contributors', (WidgetTester tester) async {
          await tester.pumpWidget(localizedWidget(child: MoreView()));
          await tester.pumpAndSettle();

          // Tap the button.
          await tester
              .tap(find.widgetWithText(ListTile, intl.more_contributors));

          // Rebuild the widget after the state has changed.
          await tester.pump();

          verify(navigation.pushNamed(RouterPaths.contributors)).called(1);
        });

        testWidgets('parameters', (WidgetTester tester) async {
          await tester.pumpWidget(localizedWidget(child: MoreView()));
          await tester.pumpAndSettle();

          // Tap the button.
          await tester.tap(find.widgetWithText(ListTile, intl.settings_title));

          // Rebuild the widget after the state has changed.
          await tester.pump();

          verify(navigation.pushNamed(RouterPaths.settings)).called(1);
        });
      });

      group("golden - ", () {
        testWidgets("default view (no events)", (WidgetTester tester) async {
          tester.binding.window.physicalSizeTestValue = const Size(800, 1410);

          await tester.pumpWidget(localizedWidget(child: MoreView()));
          await tester.pumpAndSettle();

          await expectLater(find.byType(MoreView),
              matchesGoldenFile(goldenFilePath("moreView_1")));
        });
      });
    });
  });
}
