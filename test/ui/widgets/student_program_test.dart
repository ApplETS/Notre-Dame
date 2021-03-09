// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// MODEL
import 'package:notredame/core/models/program.dart';

// VIEW
import 'package:notredame/ui/widgets/student_program.dart';

import '../../helpers.dart';

final _program = Program(
    name: 'Bac',
    average: '3.01/4.30',
    status: 'Actif',
    code: '7425',
    completedCourses: '34',
    registeredCredits: '31',
    accumulatedCredits: '75',
    equivalentCourses: '0',
    failedCourses: '0');

void main() {
  AppIntl intl;

  group('Student program - ', () {
    setUp(() async {
      intl = await setupAppIntl();
    });

    tearDown(() {});

    group('has all categories - ', () {
      testWidgets('contains one divider and one column',
          (WidgetTester tester) async {
        await tester
            .pumpWidget(localizedWidget(child: StudentProgram(_program)));
        await tester.pumpAndSettle();

        final divider = find.byType(Divider);
        expect(divider, findsNWidgets(1));

        final column = find.byType(Column);
        expect(column, findsNWidgets(1));
      });

      testWidgets('contains 9 listTile', (WidgetTester tester) async {
        await tester
            .pumpWidget(localizedWidget(child: StudentProgram(_program)));
        await tester.pumpAndSettle();

        final listTiles = find.byType(ListTile);
        expect(listTiles, findsNWidgets(9));

        expect(find.widgetWithText(ListTile, intl.profile_code_program),
            findsOneWidget);

        expect(find.widgetWithText(ListTile, intl.profile_average_program),
            findsOneWidget);

        expect(
            find.widgetWithText(
                ListTile, intl.profile_number_accumulated_credits_program),
            findsOneWidget);

        expect(
            find.widgetWithText(
                ListTile, intl.profile_number_registered_credits_program),
            findsOneWidget);

        expect(
            find.widgetWithText(
                ListTile, intl.profile_number_completed_courses_program),
            findsOneWidget);

        expect(
            find.widgetWithText(
                ListTile, intl.profile_number_failed_courses_program),
            findsOneWidget);

        expect(
            find.widgetWithText(
                ListTile, intl.profile_number_equivalent_courses_program),
            findsOneWidget);

        expect(find.widgetWithText(ListTile, intl.profile_status_program),
            findsOneWidget);
      });

      testWidgets('contains 17 Text fields', (WidgetTester tester) async {
        await tester
            .pumpWidget(localizedWidget(child: StudentProgram(_program)));
        await tester.pumpAndSettle();

        final text = find.byType(Text);
        expect(text, findsNWidgets(17));
      });
    });
  });
}
