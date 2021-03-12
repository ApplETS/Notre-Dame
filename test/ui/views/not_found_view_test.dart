// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// VIEW
import 'package:notredame/ui/views/not_found_view.dart';

// OTHER
import '../../helpers.dart';

void main() {
  group('NotFoundView - ', () {
    setUp(() async {
      setupNavigationServiceMock();
      setupAnalyticsServiceMock();
      setupRiveAnimationServiceMock();
    });

    tearDown(() {});

    group('UI - ', () {
      testWidgets(
          'has a go back to dashboard button and at least one text element',
          (WidgetTester tester) async {
        await tester.pumpWidget(
            localizedWidget(child: const NotFoundView(pageName: "/test")));
        await tester.pumpAndSettle();

        expect(find.byType(ElevatedButton), findsOneWidget);

        expect(find.byType(Text), findsWidgets);
      });

      group("golden - ", () {
        testWidgets("default view (no events)", (WidgetTester tester) async {
          tester.binding.window.physicalSizeTestValue = const Size(800, 1410);

          await tester.pumpWidget(
              localizedWidget(child: const NotFoundView(pageName: "/test")));
          await tester.pumpAndSettle();

          await expectLater(find.byType(NotFoundView),
              matchesGoldenFile(goldenFilePath("notFoundView_1")));
        });
      });
    });
  });
}
