// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// MODELS
import 'package:notredame/core/models/evaluation.dart';

// WIDGETS
import 'package:notredame/ui/widgets/grade_circular_progress.dart';

// OTHER
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class GradeEvaluationTile extends StatelessWidget {
  final Evaluation evaluation;

  const GradeEvaluationTile(this.evaluation);

  @override
  Widget build(BuildContext context) => Theme(
        data: ThemeData().copyWith(
          dividerColor: Colors.transparent,
          accentColor: Colors.red,
          unselectedWidgetColor: Colors.red,
        ),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: ExpansionTile(
            leading: FractionallySizedBox(
              alignment: Alignment.topCenter,
              heightFactor: 1.2,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return GradeCircularProgress(
                    studentGrade: getGradeInPercentage(evaluation.mark,
                        evaluation.correctedEvaluationOutOfFormatted),
                    averageGrade: getGradeInPercentage(evaluation.passMark,
                        evaluation.correctedEvaluationOutOfFormatted),
                    ratio: constraints.maxHeight / 100,
                  );
                },
              ),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(evaluation.title,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        height: 3,
                        fontSize: 15,
                        color: Theme.of(context).brightness == Brightness.light
                            ? Colors.black
                            : Colors.white)),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, bottom: 9.0),
                  child: Text(
                      AppIntl.of(context).grades_weight(evaluation.weight),
                      style: TextStyle(
                          fontSize: 12,
                          color:
                              Theme.of(context).brightness == Brightness.light
                                  ? Colors.black
                                  : Colors.white)),
                ),
              ],
            ),
            children: <Widget>[evaluationsSummary(context, evaluation)],
          ),
        ),
      );

  Widget evaluationsSummary(BuildContext context, Evaluation evaluation) {
    return Padding(
      padding: const EdgeInsets.only(top: 5.0, bottom: 8),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.91,
        child: Column(
          children: [
            getSummary(
              AppIntl.of(context).grades_grade,
              AppIntl.of(context).grades_grade_with_percentage(
                evaluation.mark ?? 0.0,
                evaluation.correctedEvaluationOutOf ?? 0.0,
                getGradeInPercentage(evaluation.mark,
                    evaluation.correctedEvaluationOutOfFormatted),
              ),
            ),
            getSummary(
              AppIntl.of(context).grades_average,
              AppIntl.of(context).grades_grade_with_percentage(
                evaluation.passMark ?? 0.0,
                evaluation.correctedEvaluationOutOf ?? 0.0,
                getGradeInPercentage(evaluation.passMark,
                    evaluation.correctedEvaluationOutOfFormatted),
              ),
            ),
            getSummary(AppIntl.of(context).grades_median,
                validateResult(context, evaluation.median.toString())),
            getSummary(
                AppIntl.of(context).grades_standard_deviation,
                validateResult(
                    context, evaluation.standardDeviation.toString())),
            getSummary(AppIntl.of(context).grades_percentile_rank,
                validateResult(context, evaluation.percentileRank.toString())),
            getSummary(AppIntl.of(context).grades_target_date,
                getDate(evaluation.targetDate, context)),
          ],
        ),
      ),
    );
  }

  String getDate(DateTime targetDate, BuildContext context) {
    if (targetDate != null) {
      return DateFormat('d MMMM yyyy', AppIntl.of(context).localeName)
          .format(targetDate);
    }

    return AppIntl.of(context).grades_not_available;
  }

  Padding getSummary(String title, String grade) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, right: 15.0, bottom: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(title),
          Text(grade ?? ''),
        ],
      ),
    );
  }

  double getGradeInDecimal(double grade, double maxGrade) => grade / maxGrade;

  double getGradeInPercentage(double grade, double maxGrade) {
    if (grade == null || maxGrade == null) {
      return 0.0;
    }

    return ((grade / maxGrade) * 100).roundToDouble();
  }

  String validateResult(BuildContext context, String result) {
    if (result != "null") {
      return result;
    }

    return AppIntl.of(context).grades_not_available;
  }
}
