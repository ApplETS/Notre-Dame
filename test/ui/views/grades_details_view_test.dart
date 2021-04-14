// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

// MODELS
import 'package:notredame/core/models/course.dart';
import 'package:notredame/core/models/course_summary.dart';
import 'package:notredame/core/models/evaluation.dart' as model;

// VIEWS
import 'package:notredame/ui/views/grade_details_view.dart';

// WIDGETS
import 'package:notredame/ui/widgets/grade_not_available.dart';

// OTHERS
import '../../helpers.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
      model.Evaluation(
        courseGroup: "02",
        title: "Laboratoire 2",
        weight: 10,
        teacherMessage: null,
        ignore: false,
        mark: 24,
        correctedEvaluationOutOf: "30",
        passMark: 25,
        standardDeviation: 2,
        median: 80,
        percentileRank: 5,
        published: true,
        targetDate: DateTime(2021, 02, 02),
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

  group("GradesDetailsView -", () {
    setUp(() async {
      intl = await setupAppIntl();
    });

    group("UI -", () {
      testWidgets(
          'has 1 RefreshIndicator, 1 SliverAppBar, 1 SliverToBoxAdapter and 1 SliverList when a course is valid',
          (WidgetTester tester) async {
        await tester.pumpWidget(localizedWidget(child: GradesDetailsView(course: course)));
        await tester.pumpAndSettle();

        expect(find.byType(RefreshIndicator), findsOneWidget);
        expect(find.byType(SliverAppBar), findsOneWidget);
        expect(find.byType(SliverToBoxAdapter), findsOneWidget);
        expect(find.byType(SliverList), findsOneWidget);
      });

      testWidgets('display the course title, group and acronym when a course is valid', (WidgetTester tester) async {
        await tester.pumpWidget(localizedWidget(child: GradesDetailsView(course: course)));
        await tester.pumpAndSettle();

        expect(find.text(course.title), findsOneWidget);
        expect(find.text(course.group), findsOneWidget);
        expect(find.text(course.acronym), findsOneWidget);
      });

      testWidgets("GradesDetailsView widget is displayed when a course summary is null", (WidgetTester tester) async {
        await tester.pumpWidget(localizedWidget(child: GradesDetailsView(course: courseWithoutSummary)));

        expect(find.byType(RefreshIndicator), findsOneWidget);
        expect(find.byWidget(const GradeNotAvailable()), findsOneWidget);
      });
    });
  });
}
