// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:notredame/ui/not_found/widgets/not_found_view.dart';
import '../../../../helpers.dart';

void main() {
  group('NotFoundView - ', () {
    const String pageNotFoundPassed = "/test";
    setUp(() async {
      setupNavigationServiceMock();
      setupAnalyticsServiceMock();
    });

    tearDown(() {});

    group('UI - ', () {
      testWidgets('has a go back to dashboard button',
          (WidgetTester tester) async {
        await tester.pumpWidget(localizedWidget(
            child: const NotFoundView(pageName: pageNotFoundPassed)));
        await tester.pumpAndSettle();

        expect(find.byType(ElevatedButton), findsOneWidget);
        // Make sure to find one text for the title,one for the description and
        // one for the button text
        expect(find.byType(Text), findsNWidgets(3));
        // Make sure to find the page name somewhere
        expect(find.textContaining(pageNotFoundPassed), findsOneWidget);
      });
    });
  });
}
