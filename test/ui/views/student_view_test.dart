// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// VIEW
import 'package:notredame/ui/views/student_view.dart';

import '../../helpers.dart';

void main() {
  group('StudentView - ', () {
    setUp(() async {
      setupNavigationServiceMock();
    });

    tearDown(() {});

    group('UI - ', () {
      testWidgets('has Tab bar and sliverAppBar', (WidgetTester tester) async {
        await tester.pumpWidget(localizedWidget(child: StudentView()));
        await tester.pumpAndSettle();

        final tabBar = find.byType(TabBar);
        expect(tabBar, findsOneWidget);

        final sliverAppBar = find.byType(SliverAppBar);
        expect(sliverAppBar, findsOneWidget);
      });
    });
  });
}
