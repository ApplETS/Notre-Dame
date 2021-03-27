// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// MANAGER
import 'package:notredame/core/managers/course_repository.dart';

// MODELS
import 'package:notredame/core/models/course.dart';

// VIEW
import 'package:notredame/ui/views/grades_view.dart';

// OTHERS
import '../../helpers.dart';
import '../../mock/managers/course_repository_mock.dart';

void main() {
  CourseRepository courseRepository;

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
      setupNavigationServiceMock();
      courseRepository = setupCourseRepositoryMock();
    });

    group("Goldens -", () {
      testWidgets("No grades available", (WidgetTester tester) async {
        // Mock the repository to have 0 courses available
        CourseRepositoryMock.stubCourses(
            courseRepository as CourseRepositoryMock);
        CourseRepositoryMock.stubGetCourses(
            courseRepository as CourseRepositoryMock,
            fromCacheOnly: false);
        CourseRepositoryMock.stubGetCourses(
            courseRepository as CourseRepositoryMock,
            fromCacheOnly: true);

        tester.binding.window.physicalSizeTestValue = const Size(800, 1410);

        await tester.pumpWidget(localizedWidget(child: GradesView()));
        await tester.pumpAndSettle();

        await expectLater(find.byType(GradesView),
            matchesGoldenFile(goldenFilePath("gradesView_1")));
      });

      testWidgets("Multiples sessions and grades loaded",
          (WidgetTester tester) async {
        // Mock the repository to have 0 courses available
        CourseRepositoryMock.stubCourses(
            courseRepository as CourseRepositoryMock,
            toReturn: courses);
        CourseRepositoryMock.stubGetCourses(
            courseRepository as CourseRepositoryMock,
            fromCacheOnly: false);
        CourseRepositoryMock.stubGetCourses(
            courseRepository as CourseRepositoryMock,
            toReturn: courses,
            fromCacheOnly: true);

        tester.binding.window.physicalSizeTestValue = const Size(800, 1410);

        await tester.pumpWidget(localizedWidget(child: GradesView()));
        await tester.pumpAndSettle();

        await expectLater(find.byType(GradesView),
            matchesGoldenFile(goldenFilePath("gradesView_2")));
      });
    });

    group("UI -", () {});

    group("Interaction -", () {});
  });
}
