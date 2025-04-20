// Flutter imports:

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:notredame/data/services/signets-api/models/course_evaluation.dart';
import 'package:notredame/data/services/signets-api/models/course_summary.dart';
import 'package:notredame/ui/student/grades/widgets/grade_circular_progress.dart';
import 'package:notredame/ui/student/grades/widgets/grade_evaluation_tile.dart';
import 'package:notredame/utils/utils.dart';
import '../../../../helpers.dart';

void main() {
  late AppIntl intl;

  final CourseSummary courseSummary = CourseSummary(
    currentMark: 5,
    currentMarkInPercent: 50,
    markOutOf: 10,
    passMark: 6,
    standardDeviation: 2.3,
    median: 4.5,
    percentileRank: 99,
    evaluations: [
      CourseEvaluation(
        courseGroup: "02",
        title: "Laboratoire 1",
        weight: 10,
        teacherMessage: '',
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
      CourseEvaluation(
        courseGroup: "02",
        title: "Laboratoire 2",
        weight: 15,
        teacherMessage: '',
        ignore: false,
        correctedEvaluationOutOf: "30",
        published: true,
        targetDate: DateTime(2021, 02, 02),
      ),
    ],
  );

  group("GradeEvaluationTile -", () {
    setUp(() async {
      intl = await setupAppIntl();
    });

    group("UI -", () {
      testWidgets("display a circular progress bar, the title, the weight and an icon", (WidgetTester tester) async {
        final evaluation = courseSummary.evaluations.first;

        await tester.pumpWidget(localizedWidget(child: GradeEvaluationTile(evaluation, completed: true)));
        await tester.pumpAndSettle();

        final circularPercentIndicator = find.byType(GradeCircularProgress);
        expect(circularPercentIndicator, findsOneWidget);

        final label = find.text("Laboratoire 1");
        expect(label, findsOneWidget);

        final label2 = find.text("Weight: 10.0 %");
        expect(label2, findsOneWidget);
      });

      testWidgets("display values when the information is not null", (WidgetTester tester) async {
        final evaluation = courseSummary.evaluations.first;

        final widget = localizedWidget(child: GradeEvaluationTile(evaluation, completed: true));

        await tester.pumpWidget(widget);

        await tester.pumpAndSettle();

        final circularPercentIndicator = find.byType(GradeCircularProgress);
        expect(circularPercentIndicator, findsOneWidget);

        // Tap the button.
        await tester.tap(find.byType(ExpansionTile));

        await tester.pumpFrames(widget, const Duration(seconds: 5));

        final label = find.text(evaluation.title);
        expect(label, findsOneWidget);

        final label2 = find.text("Weight: 10.0 %");
        expect(label2, findsOneWidget);

        final String formattedMark = evaluation.mark!.toStringAsFixed(2);
        final label3 = find.text(intl.grades_grade_with_percentage(
            evaluation.mark!,
            evaluation.correctedEvaluationOutOfFormatted,
            Utils.getGradeInPercentage(double.parse(formattedMark), evaluation.correctedEvaluationOutOfFormatted) ?? 0.0));
        expect(label3, findsOneWidget);

        final String formattedPassMark = evaluation.passMark!.toStringAsFixed(2);
        final label4 = find.text(intl.grades_grade_with_percentage(
            double.parse(formattedPassMark),
            evaluation.correctedEvaluationOutOfFormatted,
            Utils.getGradeInPercentage(evaluation.passMark!, evaluation.correctedEvaluationOutOfFormatted) ?? 0.0));
        expect(label4, findsOneWidget);

        final String formattedAverage = evaluation.passMark!.toStringAsFixed(2);
        final label5 = find.text(intl.grades_grade_with_percentage(
            double.parse(formattedAverage),
            evaluation.correctedEvaluationOutOfFormatted,
            Utils.getGradeInPercentage(evaluation.passMark!, evaluation.correctedEvaluationOutOfFormatted) ?? 0.0));
        expect(label5, findsOneWidget);

        final String formattedMedian = evaluation.median!.toStringAsFixed(2);
        final label6 = find.text(intl.grades_grade_with_percentage(
            double.parse(formattedMedian),
            evaluation.correctedEvaluationOutOfFormatted,
            Utils.getGradeInPercentage(evaluation.median!, evaluation.correctedEvaluationOutOfFormatted) ?? 0.0));
        expect(label6, findsOneWidget);

        final label7 = find.text(evaluation.standardDeviation.toString());
        expect(label7, findsOneWidget);

        final label8 = find.text(evaluation.percentileRank.toString());
        expect(label8, findsOneWidget);
      });

      testWidgets("display N/A when the information is null", (WidgetTester tester) async {
        final evaluation = courseSummary.evaluations.last;

        final widget = localizedWidget(child: GradeEvaluationTile(evaluation, completed: true));

        await tester.pumpWidget(widget);

        await tester.pumpAndSettle();

        final circularPercentIndicator = find.byType(GradeCircularProgress);
        expect(circularPercentIndicator, findsOneWidget);

        // Tap the button.
        await tester.tap(find.byType(ExpansionTile));

        await tester.pumpFrames(widget, const Duration(seconds: 5));

        final label = find.text("Laboratoire 2");
        expect(label, findsOneWidget);

        final label2 = find.text("Weight: 15.0 %");
        expect(label2, findsOneWidget);

        final label3 = find.text(intl.grades_not_available);
        /*
          grade_grade (circular progress), grade_grade, grades_average,
          grades_median, grades_weighted_grade,grades_standard_deviation,
          grades_percentile_rank
        */
        expect(label3, findsNWidgets(7));
      });
    });
  });
}
