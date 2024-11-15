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
      setupLaunchUrlServiceMock();
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
  });
}
