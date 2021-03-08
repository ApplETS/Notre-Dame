// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// VIEW
import 'package:notredame/ui/views/not_found_view.dart';
import 'package:notredame/ui/widgets/base_scaffold.dart';

import '../../helpers.dart';

void main() {
  group('NotFoundView - ', () {
    setUp(() async {
      setupNavigationServiceMock();
    });

    tearDown(() {});

    group('UI - ', () {
      testWidgets('has a go back to dashboard button',
          (WidgetTester tester) async {
        await tester.pumpWidget(localizedWidget(child: NotFoundView()));
        await tester.pumpAndSettle();

        expect(find.byType(FlatButton), findsOneWidget);
      });

      group("golden - ", () {
        testWidgets("default view (no events)", (WidgetTester tester) async {
          tester.binding.window.physicalSizeTestValue = const Size(800, 1410);

          await tester.pumpWidget(localizedWidget(child: NotFoundView()));
          await tester.pumpAndSettle();

          await expectLater(find.byType(NotFoundView),
              matchesGoldenFile(goldenFilePath("notFoundView_1")));
        });
      });
    });
  });
}
