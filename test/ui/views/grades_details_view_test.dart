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
import '../../../lib/ui/widgets/grade_circular_progress.dart';

// OTHERS
import '../../helpers.dart';

void main() {
  CourseRepository courseRepository;
  AppIntl intl;

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
      intl = await setupAppIntl();
      courseRepository = setupCourseRepositoryMock();
    });

    tearDown(() {
      unregister<CourseRepository>();
    });

    group('UI - ', () {
      testWidgets('has a RefreshIndicator, GradeCircularProgress and three cards when a course is valid',
          (WidgetTester tester) async {
        await tester.pumpWidget(localizedWidget(child: GradesDetailsView(course: course)));
        await tester.pumpAndSettle();

        expect(find.byType(RefreshIndicator), findsOneWidget);
        expect(find.byType(GradeCircularProgress), findsOneWidget);
        expect(find.byType(Card), findsNWidgets(3));
      });

      testWidgets('display the course title, group and acronym when a course is valid', (WidgetTester tester) async {
        await tester.pumpWidget(localizedWidget(child: GradesDetailsView(course: course)));
        await tester.pumpAndSettle();

        expect(find.text('Cours générique'), findsOneWidget);
        expect(find.text("Group 02"), findsOneWidget);
        expect(find.text("GEN101"), findsOneWidget);
      });

      testWidgets("display GradeNotAvailable when a course summary is null", (WidgetTester tester) async {
        await tester.pumpWidget(localizedWidget(child: GradesDetailsView(course: courseWithoutSummary)));

        expect(find.byType(RefreshIndicator), findsOneWidget);
        expect(find.byWidget(const GradeNotAvailable()), findsOneWidget);
      });
    });

    group("golden - ", () {
      testWidgets("default view", (WidgetTester tester) async {
        tester.binding.window.physicalSizeTestValue = const Size(800, 1410);

        await tester.pumpWidget(localizedWidget(child: GradesDetailsView(course: course)));
        await tester.pumpAndSettle();

        await expectLater(find.byType(GradesDetailsView), matchesGoldenFile(goldenFilePath("gradesDetailsView_1")));
      });
    });
  });
}
