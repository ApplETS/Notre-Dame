// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// MODELS
import 'package:notredame/core/models/evaluation.dart';
import 'package:notredame/ui/utils/app_theme.dart';

// WIDGETS
import 'package:notredame/ui/widgets/grade_circular_progress.dart';

// OTHER
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class GradeEvaluationTile extends StatefulWidget {
  final Evaluation evaluation;

  const GradeEvaluationTile(this.evaluation);

  @override
  _GradeEvaluationTileState createState() => _GradeEvaluationTileState();
}

class _GradeEvaluationTileState extends State<GradeEvaluationTile> {
  bool showEvaluationDetails = false;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                showEvaluationDetails = !showEvaluationDetails;
              });
            },
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: SizedBox(
                height: 90.0,
                child: ListTile(
                  leading: Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: FractionallySizedBox(
                      alignment: Alignment.topCenter,
                      heightFactor: 1.2,
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return GradeCircularProgress(
                            studentGrade: getGradeInPercentage(
                              widget.evaluation.mark,
                              widget
                                  .evaluation.correctedEvaluationOutOfFormatted,
                            ),
                            averageGrade: getGradeInPercentage(
                              widget.evaluation.passMark,
                              widget
                                  .evaluation.correctedEvaluationOutOfFormatted,
                            ),
                            ratio: constraints.maxHeight / 100,
                          );
                        },
                      ),
                    ),
                  ),
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        widget.evaluation.title,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          height: 3,
                          fontSize: 15,
                          color:
                              Theme.of(context).brightness == Brightness.light
                                  ? Colors.black
                                  : Colors.white,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0, bottom: 9.0),
                        child: Text(
                            AppIntl.of(context)
                                .grades_weight(widget.evaluation.weight),
                            style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).brightness ==
                                        Brightness.light
                                    ? Colors.black
                                    : Colors.white)),
                      ),
                    ],
                  ),
                  trailing: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: IconButton(
                      icon: Icon(
                        showEvaluationDetails
                            ? Icons.keyboard_arrow_up_sharp
                            : Icons.keyboard_arrow_down_sharp,
                        color: AppTheme.etsLightRed,
                      ),
                      onPressed: () {
                        setState(() {
                          showEvaluationDetails = !showEvaluationDetails;
                        });
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (showEvaluationDetails)
            Column(
              children: <Widget>[
                evaluationsSummary(context, widget.evaluation)
              ],
            )
          else
            Container()
        ],
      );

  Widget evaluationsSummary(BuildContext context, Evaluation evaluation) {
    return Padding(
      padding: const EdgeInsets.only(left: 25.0, right: 15.0),
      child: SizedBox(
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
