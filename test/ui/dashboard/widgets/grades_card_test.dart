// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:notredame/data/repositories/course_repository.dart';

// Project imports:
import 'package:notredame/data/services/navigation_service.dart';
import 'package:notredame/data/services/signets-api/models/course.dart';
import 'package:notredame/data/services/signets-api/models/session.dart';
import 'package:notredame/l10n/app_localizations.dart';
import 'package:notredame/locator.dart';
import 'package:notredame/ui/dashboard/widgets/cards/grades_card.dart';
import 'package:notredame/ui/student/grades/widgets/grade_button.dart';
import '../../../data/mocks/repositories/course_repository_mock.dart';
import '../../../helpers.dart';

void main() {
  final Course course1 = Course(
    acronym: 'GEN101',
    group: '02',
    session: 'É2020',
    programCode: '999',
    grade: 'C+',
    numberOfCredits: 3,
    title: 'Cours générique',
  );

  final Course course2 = Course(
    acronym: 'GEN102',
    group: '02',
    session: 'É2020',
    programCode: '999',
    grade: 'C+',
    numberOfCredits: 3,
    title: 'Cours générique',
  );

  // Session
  final Session session = Session(
    shortName: "É2020",
    name: "Ete 2020",
    startDate: DateTime(2020).subtract(const Duration(days: 1)),
    endDate: DateTime(2020).add(const Duration(days: 1)),
    endDateCourses: DateTime(2022, 1, 10, 1, 1),
    startDateRegistration: DateTime(2017, 1, 9, 1, 1),
    deadlineRegistration: DateTime(2017, 1, 10, 1, 1),
    startDateCancellationWithRefund: DateTime(2017, 1, 10, 1, 1),
    deadlineCancellationWithRefund: DateTime(2017, 1, 11, 1, 1),
    deadlineCancellationWithRefundNewStudent: DateTime(2017, 1, 11, 1, 1),
    startDateCancellationWithoutRefundNewStudent: DateTime(2017, 1, 12, 1, 1),
    deadlineCancellationWithoutRefundNewStudent: DateTime(2017, 1, 12, 1, 1),
    deadlineCancellationASEQ: DateTime(2017, 1, 11, 1, 1),
  );

  final courses = [course1, course2];

  late AppIntl intl;

  group("GradesCard - ", () {
    setUp(() async {
      intl = await setupAppIntl();
      setupNavigationServiceMock();
      final courseRepositoryMock = setupCourseRepositoryMock();

      CourseRepositoryMock.stubSessions(
        courseRepositoryMock,
        toReturn: [session],
      );

      CourseRepositoryMock.stubGetSessions(
        courseRepositoryMock,
        toReturn: [session],
      );

      CourseRepositoryMock.stubActiveSessions(
        courseRepositoryMock,
        toReturn: [session],
      );
    });

    tearDown(() {
      unregister<NavigationService>();
      unregister<CourseRepository>();
    });

    testWidgets('Has card grades displayed - with no courses', (WidgetTester tester) async {
      await tester.pumpWidget(localizedWidget(child: const GradesCard(loading: false)));
      await tester.pumpAndSettle();

      // Find grades card
      final gradesCard = find.widgetWithText(Card, intl.grades_title, skipOffstage: false);
      expect(gradesCard, findsOneWidget);

      // Find grades card Title
      final gradesTitle = find.text(intl.grades_title, skipOffstage: false);
      expect(gradesTitle, findsOneWidget);

      // Find empty grades card
      final gradesEmptyTitle = find.text(intl.grades_msg_no_grades.split("\n").first, skipOffstage: false);
      expect(gradesEmptyTitle, findsOneWidget);
    });

    testWidgets('Has card grades displayed - with courses', (WidgetTester tester) async {
      final courseRepositoryMock =
      locator<CourseRepository>() as CourseRepositoryMock;

      CourseRepositoryMock.stubGetCourses(
        courseRepositoryMock,
        toReturn: courses,
        fromCacheOnly: true,
      );

      CourseRepositoryMock.stubGetCourses(
        courseRepositoryMock,
        toReturn: courses,
      );

      await tester.pumpWidget(
        localizedWidget(
          child: const GradesCard(
            loading: false,
          ),
        ),
      );

      await tester.pumpWidget(localizedWidget(child: const GradesCard(loading: false)));
      await tester.pumpAndSettle();

      // Find grades card
      final gradesCard = find.widgetWithText(Card, intl.grades_title, skipOffstage: false);
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
