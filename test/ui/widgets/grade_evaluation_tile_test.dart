// Flutter imports:

import 'package:flutter/material.dart';

// Package imports:
import 'package:ets_api_clients/models.dart';
import 'package:feature_discovery/feature_discovery.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:notredame/ui/widgets/grade_circular_progress.dart';
import 'package:notredame/ui/widgets/grade_evaluation_tile.dart';
import '../../helpers.dart';

void main() {
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
      CourseEvaluation(
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
      CourseEvaluation(
        courseGroup: "02",
        title: "Laboratoire 2",
        weight: 15,
        teacherMessage: null,
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
      testWidgets(
          "display a circular progress bar, the title, the weight and an icon",
          (WidgetTester tester) async {
        final evaluation = courseSummary.evaluations.first;

        await tester.pumpWidget(localizedWidget(
            child: FeatureDiscovery(
                child: GradeEvaluationTile(evaluation,
                    completed: true, isFirstEvaluation: false))));
        await tester.pumpAndSettle();

        final circularPercentIndicator = find.byType(GradeCircularProgress);
        expect(circularPercentIndicator, findsOneWidget);

        final label = find.text("Laboratoire 1");
        expect(label, findsOneWidget);

        final label2 = find.text("Weight: 10.0 %");
        expect(label2, findsOneWidget);
      });

      testWidgets("display N/A when the information is null",
          (WidgetTester tester) async {
        final evaluation = courseSummary.evaluations.last;

        final widget = localizedWidget(
            child: FeatureDiscovery(
                child: GradeEvaluationTile(evaluation,
                    completed: true, isFirstEvaluation: false)));

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
        //grades_standard_deviation, grades_percentile_rank
        expect(label3, findsNWidgets(2));

        final label4 = find.text("0.0/30 (0.0%)");
        expect(label4, findsNWidgets(3));

        final label5 = find.text("0.0/15.0 (0.0%)");
        expect(label5, findsOneWidget);
      });
    });
  });
}
