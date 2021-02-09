// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// VIEW
import 'package:notredame/ui/views/settings_view.dart';

import '../../helpers.dart';

void main() {
  group('SettingsView - ', () {
    setUp(() async {
      setupNavigationServiceMock();
      setupCacheManagerMock();
      setupSettingsManagerMock();
    });

    tearDown(() {});

    group('UI - ', () {
      testWidgets('has 1 listView and 4 listTiles and 1 divider', (WidgetTester tester) async {
        await tester.pumpWidget(localizedWidget(
            child: SettingsView()));
        await tester.pumpAndSettle();

        final listview = find.byType(ListView);
        expect(listview, findsOneWidget);

        final listTile = find.byType(ListTile);
        expect(listTile, findsNWidgets(4));

        final divider = find.byType(Divider);
        expect(divider, findsOneWidget);
      });

      group("golden - ", () {
        testWidgets("default view (no events)", (WidgetTester tester) async {
          tester.binding.window.physicalSizeTestValue = const Size(800, 1410);

          await tester.pumpWidget(localizedWidget(child: SettingsView()));
          await tester.pumpAndSettle();

          await expectLater(find.byType(SettingsView),
              matchesGoldenFile(goldenFilePath("settingsView_1")));
        });
      });
    });
  });
}
