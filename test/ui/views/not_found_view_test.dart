// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// VIEW
import 'package:notredame/ui/views/not_found_view.dart';

// OTHER
import '../../helpers.dart';

void main() {
  group('NotFoundView - ', () {
    const String _pageNotFoundPassed = "/test";
    setUp(() async {
      setupNavigationServiceMock();
      setupAnalyticsServiceMock();
      setupRiveAnimationServiceMock();
    });

    tearDown(() {});

    group('UI - ', () {
      testWidgets('has a go back to dashboard button',
          (WidgetTester tester) async {
        await tester.pumpWidget(localizedWidget(
            child: const NotFoundView(pageName: _pageNotFoundPassed)));
        await tester.pumpAndSettle();

        expect(find.byType(ElevatedButton), findsOneWidget);
        // Make sure to find one text for the title,one for the description and
        // one for the button text
        expect(find.byType(Text), findsNWidgets(3));
        // Make sure to find the page name somewhere
        expect(find.textContaining(_pageNotFoundPassed), findsOneWidget);
      });
      group("golden - ", () {
        testWidgets("default view (no events)", (WidgetTester tester) async {
          tester.binding.window.physicalSizeTestValue = const Size(800, 1410);

          await tester.pumpWidget(localizedWidget(
              child: const NotFoundView(pageName: _pageNotFoundPassed)));
          await tester.pumpAndSettle();

          await expectLater(find.byType(NotFoundView),
              matchesGoldenFile(goldenFilePath("notFoundView_1")));
        });
      });
    });
  });
}
