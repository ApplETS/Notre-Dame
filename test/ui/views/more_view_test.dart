// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// VIEW
import 'package:notredame/ui/views/more_view.dart';

import '../../helpers.dart';

void main() {
  group('MoreView - ', () {
    setUp(() async {
      setupNavigationServiceMock();
      setupCacheManagerMock();
    });

    tearDown(() {});

    group('UI - ', () {
      testWidgets('has 1 listView and 6 listTiles', (WidgetTester tester) async {
        await tester.pumpWidget(localizedWidget(
            child: MoreView()));
        await tester.pumpAndSettle();

        final listview = find.byType(ListView);
        expect(listview, findsOneWidget);

        final listTile = find.byType(ListTile);
        expect(listTile, findsNWidgets(6));
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
