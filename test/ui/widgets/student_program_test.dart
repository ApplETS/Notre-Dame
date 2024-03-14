// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:ets_api_clients/models.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

// Project imports:
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
  late AppIntl intl;

  group('Student program - ', () {
    setUp(() async {
      intl = await setupAppIntl();
    });

    tearDown(() {});

    group('has all categories - ', () {
      testWidgets('contains one expansion tile', (WidgetTester tester) async {
        await tester
            .pumpWidget(localizedWidget(child: StudentProgram(_program)));
        await tester.pumpAndSettle();

        expect(find.byType(ExpansionTile), findsOneWidget);

        expect(find.text(_program.name), findsOneWidget);
      });

      testWidgets('contains infos', (WidgetTester tester) async {
        await tester
            .pumpWidget(localizedWidget(child: StudentProgram(_program)));
        await tester.pumpAndSettle();

        // Find the ExpansionTile and tap it to expand
        final expansionTile = find.byType(ExpansionTile);
        expect(expansionTile, findsOneWidget);
        await tester.tap(expansionTile);
        await tester.pumpAndSettle();

        expect(find.text(intl.profile_code_program), findsOneWidget);
        expect(find.text(intl.profile_average_program), findsOneWidget);
        expect(find.text(intl.profile_number_accumulated_credits_program),
            findsOneWidget);
        expect(find.text(intl.profile_number_registered_credits_program),
            findsOneWidget);
        expect(find.text(intl.profile_number_completed_courses_program),
            findsOneWidget);
        expect(find.text(intl.profile_number_failed_courses_program),
            findsOneWidget);
        expect(find.text(intl.profile_number_equivalent_courses_program),
            findsOneWidget);
        expect(find.text(intl.profile_status_program), findsOneWidget);
      });

      testWidgets('contains 17 Text fields', (WidgetTester tester) async {
        await tester
            .pumpWidget(localizedWidget(child: StudentProgram(_program)));
        await tester.pumpAndSettle();

        // Find the ExpansionTile and tap it to expand
        final expansionTile = find.byType(ExpansionTile);
        expect(expansionTile, findsOneWidget);
        await tester.tap(expansionTile);
        await tester.pumpAndSettle();

        final text = find.byType(Text);
        expect(text, findsNWidgets(17));
      });
    });
  });
}
