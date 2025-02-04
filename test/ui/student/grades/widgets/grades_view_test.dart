// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import 'package:notredame/data/repositories/course_repository.dart';
import 'package:notredame/data/repositories/settings_repository.dart';
import 'package:notredame/data/services/navigation_service.dart';
import 'package:notredame/data/services/networking_service.dart';
import 'package:notredame/data/services/signets-api/models/course.dart';
import 'package:notredame/ui/student/grades/widgets/grade_button.dart';
import 'package:notredame/ui/student/grades/widgets/grades_view.dart';
import '../../../../data/mocks/repositories/course_repository_mock.dart';
import '../../../../helpers.dart';

void main() {
  SharedPreferences.setMockInitialValues({});
  late CourseRepositoryMock courseRepositoryMock;
  late AppIntl intl;

  final Course courseSummer = Course(
      acronym: 'GEN101',
      group: '02',
      session: 'É2020',
      programCode: '999',
      grade: 'C+',
      numberOfCredits: 3,
      title: 'Cours générique');

  final Course courseSummer2 = Course(
      acronym: 'GEN102',
      group: '02',
      session: 'É2020',
      programCode: '999',
      grade: 'C+',
      numberOfCredits: 3,
      title: 'Cours générique');

  final Course courseWinter = Course(
      acronym: 'GEN101',
      group: '02',
      session: 'H2020',
      programCode: '999',
      grade: 'C+',
      numberOfCredits: 3,
      title: 'Cours générique');

  final Course courseFall = Course(
      acronym: 'GEN101',
      group: '02',
      session: 'A2020',
      programCode: '999',
      grade: 'C+',
      numberOfCredits: 3,
      title: 'Cours générique');

  final courses = [courseSummer, courseSummer2, courseWinter, courseFall];

  group("GradesView -", () {
    setUp(() async {
      intl = await setupAppIntl();
      setupNavigationServiceMock();
      courseRepositoryMock = setupCourseRepositoryMock();
      setupSettingsManagerMock();
      setupAnalyticsServiceMock();
      setupFlutterToastMock();
      setupNavigationServiceMock();
    });

    tearDown(() {
      unregister<CourseRepository>();
      unregister<NetworkingService>();
      unregister<SettingsRepository>();
      unregister<NavigationService>();
    });

    group("UI -", () {
      testWidgets(
          "Right message is displayed when there is no grades available",
          (WidgetTester tester) async {
        // Mock the repository to have 0 courses available
        CourseRepositoryMock.stubCourses(courseRepositoryMock);
        CourseRepositoryMock.stubGetCourses(courseRepositoryMock);
        CourseRepositoryMock.stubGetCourses(courseRepositoryMock,
            fromCacheOnly: true);

        tester.view.physicalSize = const Size(800, 1410);

        await tester.pumpWidget(localizedWidget(child: GradesView()));
        await tester.pumpAndSettle(const Duration(seconds: 1));

        expect(find.text(intl.grades_msg_no_grades), findsOneWidget);
      });

      testWidgets(
          "Correct number of grade button and right session name are displayed",
          (WidgetTester tester) async {
        // Mock the repository to have 4 courses available
        CourseRepositoryMock.stubCourses(courseRepositoryMock,
            toReturn: courses);
        CourseRepositoryMock.stubGetCourses(courseRepositoryMock);
        CourseRepositoryMock.stubGetCourses(courseRepositoryMock,
            toReturn: courses, fromCacheOnly: true);

        tester.view.physicalSize = const Size(800, 1410);
        await tester.runAsync(() async {
          await tester.pumpWidget(localizedWidget(
            child: GradesView(),
          ));
          await tester.pumpAndSettle(const Duration(seconds: 10));
        }).then((value) {
          // Check the summer session list of grades.
          final summerSessionText = find.text("${intl.session_summer} 2020");
          expect(summerSessionText, findsOneWidget);
          final summerList = find
              .ancestor(of: summerSessionText, matching: find.byType(Column))
              .first;
          expect(
              find.descendant(
                  of: summerList, matching: find.byType(GradeButton)),
              findsNWidgets(2),
              reason: "The summer session should have two grade buttons.");

          // Check the fall session list of grades.
          final fallSessionText = find.text("${intl.session_fall} 2020");
          expect(fallSessionText, findsOneWidget);
          final fallList = find
              .ancestor(of: fallSessionText, matching: find.byType(Column))
              .first;
          expect(
              find.descendant(of: fallList, matching: find.byType(GradeButton)),
              findsOneWidget,
              reason:
                  "The summer session should have 1 grade button because the session have one course.");

          // Check the winter session list of grades.
          final winterSessionText = find.text("${intl.session_winter} 2020");
          expect(winterSessionText, findsOneWidget);
          final winterList = find
              .ancestor(of: winterSessionText, matching: find.byType(Column))
              .first;
          expect(
              find.descendant(
                  of: winterList, matching: find.byType(GradeButton)),
              findsOneWidget,
              reason: "The summer session should have two grade buttons.");
        });
      });
    });
  });
}
