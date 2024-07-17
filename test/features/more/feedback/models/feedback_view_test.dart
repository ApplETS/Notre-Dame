// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:notredame/features/more/feedback/feedback_view.dart';
import '../../../../common/helpers.dart';

void main() {
  group('FeedbackView - ', () {
    setUp(() async {
      await setupAppIntl();
      setupNavigationServiceMock();
      setupPreferencesServiceMock();
      setupGithubApiMock();
    });

    tearDown(() {});

    group('UI - ', () {
      testWidgets('has 2 ElevatedButton', (WidgetTester tester) async {
        await tester.pumpWidget(localizedWidget(child: FeedbackView()));
        await tester.pumpAndSettle();

        final elevatedButton = find.byType(ElevatedButton);
        expect(elevatedButton, findsNWidgets(2));
      });
    });
    group("golden - ", () {
      testWidgets("default view", (WidgetTester tester) async {
        tester.view.physicalSize = const Size(800, 1410);

        await tester.pumpWidget(localizedWidget(child: FeedbackView()));
        await tester.pumpAndSettle();

        await expectLater(find.byType(FeedbackView),
            matchesGoldenFile(goldenFilePath("feedbackView_1")));
      });
    }, skip: !Platform.isLinux);
  });
}
