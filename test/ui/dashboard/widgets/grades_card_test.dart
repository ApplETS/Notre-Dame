// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:notredame/data/services/navigation_service.dart';
import 'package:notredame/data/services/signets-api/models/course.dart';
import 'package:notredame/ui/dashboard/widgets/grades_card.dart';
import 'package:notredame/ui/student/grades/widgets/grade_button.dart';
import '../../../helpers.dart';

main() {
  final Course course1 = Course(
      acronym: 'GEN101',
      group: '02',
      session: 'É2020',
      programCode: '999',
      grade: 'C+',
      numberOfCredits: 3,
      title: 'Cours générique');

  final Course course2 = Course(
      acronym: 'GEN102',
      group: '02',
      session: 'É2020',
      programCode: '999',
      grade: 'C+',
      numberOfCredits: 3,
      title: 'Cours générique');

  final courses = [course1, course2];

  late AppIntl intl;

  group("GradesCard - ", () {
    setUp(() async {
      intl = await setupAppIntl();
      setupNavigationServiceMock();
    });

    tearDown(() {
      unregister<NavigationService>();
    });

    testWidgets('Has card grades displayed - with no courses',
        (WidgetTester tester) async {
      await tester.pumpWidget(localizedWidget(
          child: GradesCard(courses: [], onDismissed: () {}, loading: false)));
      await tester.pumpAndSettle();

      // Find grades card
      final gradesCard =
          find.widgetWithText(Card, intl.grades_title, skipOffstage: false);
      expect(gradesCard, findsOneWidget);

      // Find grades card Title
      final gradesTitle = find.text(intl.grades_title, skipOffstage: false);
      expect(gradesTitle, findsOneWidget);

      // Find empty grades card
      final gradesEmptyTitle = find.text(
          intl.grades_msg_no_grades.split("\n").first,
          skipOffstage: false);
      expect(gradesEmptyTitle, findsOneWidget);
    });

    testWidgets('Has card grades displayed - with courses',
        (WidgetTester tester) async {
      await tester.pumpWidget(localizedWidget(
          child: GradesCard(
              courses: courses, onDismissed: () {}, loading: false)));
      await tester.pumpAndSettle();

      // Find grades card
      final gradesCard =
          find.widgetWithText(Card, intl.grades_title, skipOffstage: false);
      expect(gradesCard, findsOneWidget);

      // Find grades card Title
      final gradesTitle = find.text(intl.grades_title, skipOffstage: false);
      expect(gradesTitle, findsOneWidget);

      // Find grades buttons in the card
      final gradesButtons = find.byType(GradeButton, skipOffstage: false);
      expect(gradesButtons, findsNWidgets(2));
    });
  });
}
