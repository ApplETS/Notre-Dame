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
      testWidgets('has button and listview', (WidgetTester tester) async {
        await tester.pumpWidget(localizedWidget(child: FeedbackView()));
        await tester.pumpAndSettle();

        final listView = find.byType(ListView);
        expect(listView, findsOneWidget);

        final button = find.byType(FloatingActionButton);
        expect(button, findsOneWidget);
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
