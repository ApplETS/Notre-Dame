// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:notredame/ui/ets/quick_links/security_info/widgets/emergency_view.dart';
import '../../../../../helpers.dart';

void main() {
  group('EmergencyView - ', () {
    setUp(() async {
      setupNetworkingServiceMock();
      setupLaunchUrlServiceMock();
    });

    tearDown(() {});

    group('UI - ', () {
      testWidgets('has call button and markdown view',
          (WidgetTester tester) async {
        await tester.pumpWidget(localizedWidget(
            child: const EmergencyView(
                'testEmergency', 'assets/markdown/armed_person_en.md')));
        await tester.pumpAndSettle();

        final markdown = find.byType(Markdown);
        expect(markdown, findsOneWidget);

        final Finder phoneButton = find.byType(FloatingActionButton);
        expect(phoneButton, findsOneWidget);
      });
    });
  });
}
