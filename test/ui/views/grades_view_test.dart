// FLUTTER / DART / THIRD-PARTIES
import 'package:feature_discovery/feature_discovery.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

// MANAGER
import 'package:notredame/core/managers/course_repository.dart';
import 'package:notredame/core/managers/settings_manager.dart';
import '../../mock/managers/course_repository_mock.dart';

// MODELS
import 'package:ets_api_clients/models.dart';

// SERVICES
import 'package:notredame/core/services/networking_service.dart';

// VIEW / WIDGETS
import 'package:notredame/ui/views/grades_view.dart';
import 'package:notredame/ui/widgets/grade_button.dart';

// OTHERS
import '../../helpers.dart';

void main() {
  CourseRepository courseRepository;
  AppIntl intl;

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
      courseRepository = setupCourseRepositoryMock();
      setupSettingsManagerMock();
      setupAnalyticsServiceMock();
    });

    tearDown(() {
      unregister<CourseRepository>();
      unregister<NetworkingService>();
      unregister<SettingsManager>();
    });

    group("golden -", () {
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

        await tester.pumpWidget(
            localizedWidget(child: FeatureDiscovery(child: GradesView())));
        await tester.pumpAndSettle(const Duration(seconds: 1));

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

        await tester.pumpWidget(
            localizedWidget(child: FeatureDiscovery(child: GradesView())));
        await tester.pumpAndSettle(const Duration(seconds: 1));

        await expectLater(find.byType(GradesView),
            matchesGoldenFile(goldenFilePath("gradesView_2")));
      });
    });

    group("UI -", () {
      testWidgets(
          "Right message is displayed when there is no grades available",
          (WidgetTester tester) async {
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

        await tester.pumpWidget(
            localizedWidget(child: FeatureDiscovery(child: GradesView())));
        await tester.pumpAndSettle(const Duration(seconds: 1));

        expect(find.text(intl.grades_msg_no_grades), findsOneWidget);
      });

      testWidgets(
          "Correct number of grade button and right session name are displayed",
          (WidgetTester tester) async {
        // Mock the repository to have 4 courses available
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

        await tester.pumpWidget(
            localizedWidget(child: FeatureDiscovery(child: GradesView())));
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // Check the summer session list of grades.
        final summerSessionText = find.text("${intl.session_summer} 2020");
        expect(summerSessionText, findsOneWidget);
        final summerList = find
            .ancestor(of: summerSessionText, matching: find.byType(Column))
            .first;
        expect(
            find.descendant(of: summerList, matching: find.byType(GradeButton)),
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
            find.descendant(of: winterList, matching: find.byType(GradeButton)),
            findsOneWidget,
            reason: "The summer session should have two grade buttons.");
      });
    });
  });
}
