// FLUTTER / DART / THIRD-PARTIES
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// VIEW
import 'package:notredame/ui/views/feedback_view.dart';

// HELPERS
import '../../helpers.dart';

void main() {
  group('FeedbackView - ', () {
    setUp(() async {
      await setupAppIntl();
      setupNavigationServiceMock();
      setupGithubApiMock();
    });

    tearDown(() {});

    group('UI - ', () {
      testWidgets('has 2 cards, 2 ElevatedButton and SingleChildScrollView', (WidgetTester tester) async {
        await tester.pumpWidget(localizedWidget(child: FeedbackView()));
        await tester.pumpAndSettle();

        final singleChildScrollView = find.byType(SingleChildScrollView);
        expect(singleChildScrollView, findsOneWidget);

        final card = find.byType(Card);
        expect(card, findsNWidgets(2));

        final elevatedButton = find.byType(ElevatedButton);
        expect(elevatedButton, findsNWidgets(2));
      });
    });
    group("golden - ", () {
      testWidgets("default view", (WidgetTester tester) async {
        tester.binding.window.physicalSizeTestValue = const Size(800, 1410);

        await tester.pumpWidget(localizedWidget(child: FeedbackView()));
        await tester.pumpAndSettle();

        await expectLater(find.byType(FeedbackView),
            matchesGoldenFile(goldenFilePath("feedbackView_1")));
      });
    }, skip: !Platform.isLinux);
  });
}
