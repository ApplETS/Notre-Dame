// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notredame/core/managers/course_repository.dart';

// MODELS
import 'package:notredame/core/models/course.dart';
import 'package:notredame/core/models/course_summary.dart';
import 'package:notredame/core/models/evaluation.dart' as model;

// VIEWS
import 'package:notredame/ui/views/grade_details_view.dart';

// WIDGETS
import 'package:notredame/ui/widgets/grade_not_available.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../../../lib/ui/widgets/grade_circular_progress.dart';
import '../../../lib/ui/widgets/grade_evaluation_tile.dart';

// OTHERS
import '../../helpers.dart';
import '../../mock/managers/course_repository_mock.dart';

void main() {
  AppIntl intl;
  CourseRepository courseRepository;

  final CourseSummary courseSummary = CourseSummary(
    currentMark: 5,
    currentMarkInPercent: 50,
    markOutOf: 10,
    passMark: 6,
    standardDeviation: 2.3,
    median: 4.5,
    percentileRank: 99,
    evaluations: [
      model.Evaluation(
        courseGroup: "02",
        title: "Laboratoire 1",
        weight: 10,
        teacherMessage: null,
        ignore: false,
        mark: 24,
        correctedEvaluationOutOf: "35",
        passMark: 25,
        standardDeviation: 2,
        median: 80,
        percentileRank: 5,
        published: true,
        targetDate: DateTime(2021, 01, 05),
      ),
    ],
  );

  final Course course = Course(
    acronym: 'GEN101',
    group: '02',
    session: 'H2020',
    programCode: '999',
    numberOfCredits: 3,
    title: 'Cours générique',
    summary: courseSummary,
  );

  final Course courseWithoutSummary = Course(
    acronym: 'GEN101',
    group: '02',
    session: 'H2020',
    programCode: '999',
    numberOfCredits: 3,
    title: 'Cours générique',
  );

  group('GradesDetailsView - ', () {
    setUp(() async {
      setupNavigationServiceMock();
      courseRepository = setupCourseRepositoryMock();
      intl = await setupAppIntl();
    });

    tearDown(() {
      unregister<CourseRepository>();
    });

    group('UI - ', () {
      ScrollController primaryScrollController(WidgetTester tester) {
        return PrimaryScrollController.of(
            tester.element(find.byType(CustomScrollView)));
      }

      testWidgets(
          'has a RefreshIndicator, GradeCircularProgress, three cards and evaluation tiles when a course is valid',
          (WidgetTester tester) async {
        //CourseRepositoryMock.stubGetCourseSummary(courseRepository as CourseRepositoryMock, courseWithoutSummary,
        //toReturn: course);

        await tester.pumpWidget(
            localizedWidget(child: GradesDetailsView(course: course)));
        await tester.pumpAndSettle();

        expect(find.byType(RefreshIndicator), findsOneWidget);

        // Find all the grade circular progress
        expect(find.byKey(const Key("GradeCircularProgress_summary")),
            findsOneWidget);
        for (final eval in courseSummary.evaluations) {
          expect(find.byKey(Key("GradeCircularProgress_${eval.title}")),
              findsOneWidget);
        }

        expect(find.byType(Card), findsNWidgets(4));

        for (final eval in courseSummary.evaluations) {
          expect(find.byKey(Key("GradeEvaluationTile_${eval.title}")),
              findsOneWidget);
        }
      });

      testWidgets(
          'when the page is at the top, it displays the course title, acronym and group',
          (WidgetTester tester) async {
        CourseRepositoryMock.stubGetCourseSummary(
            courseRepository as CourseRepositoryMock, courseWithoutSummary,
            toReturn: course);

        await tester.pumpWidget(
            localizedWidget(child: GradesDetailsView(course: course)));
        await tester.pumpAndSettle();

        final ScrollController controller = primaryScrollController(tester);

        expect(controller.offset, 0.0);
        expect(find.byType(SliverAppBar), findsOneWidget);

        expect(find.text('Cours générique'), findsOneWidget);
        expect(find.text('GEN101'), findsOneWidget);
        expect(find.text('Group 02'), findsOneWidget);
      });

      testWidgets(
          'when the page is scrolled at the bottom, it displays only the course title on top of the page',
          (WidgetTester tester) async {
        CourseRepositoryMock.stubGetCourseSummary(
            courseRepository as CourseRepositoryMock, courseWithoutSummary,
            toReturn: course);

        await tester.pumpWidget(
            localizedWidget(child: GradesDetailsView(course: course)));
        await tester.pumpAndSettle();

        final ScrollController controller = primaryScrollController(tester);

        controller.jumpTo(130.0);
        await tester.pump();

        expect(find.byType(SliverToBoxAdapter), findsNothing);

        /*expect(find.text('Cours générique'), findsOneWidget);
        expect(find.text('GEN101'), findsNothing);
        expect(find.text('Group 02'), findsNothing);*/
      });

      testWidgets("display GradeNotAvailable when a course summary is null",
          (WidgetTester tester) async {
        CourseRepositoryMock.stubGetCourseSummary(
            courseRepository as CourseRepositoryMock, courseWithoutSummary,
            toReturn: courseWithoutSummary);

        await tester.pumpWidget(localizedWidget(
            child: GradesDetailsView(course: courseWithoutSummary)));
        await tester.pumpAndSettle();

        expect(find.byKey(const Key("GradeNotAvailable")), findsOneWidget);
      });
    });

    group("golden - ", () {
      testWidgets("default view", (WidgetTester tester) async {
        CourseRepositoryMock.stubGetCourseSummary(
            courseRepository as CourseRepositoryMock, courseWithoutSummary,
            toReturn: course);

        tester.binding.window.physicalSizeTestValue = const Size(800, 1410);

        await tester.pumpWidget(
            localizedWidget(child: GradesDetailsView(course: course)));
        await tester.pumpAndSettle();

        await expectLater(find.byType(GradesDetailsView),
            matchesGoldenFile(goldenFilePath("gradesDetailsView_1")));
      });
    });
  });
}
