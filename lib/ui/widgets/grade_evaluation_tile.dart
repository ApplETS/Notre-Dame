// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// MODELS
import 'package:notredame/core/models/evaluation.dart';

// WIDGETS
import 'package:notredame/ui/widgets/grade_circular_progress.dart';

// OTHER
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class GradeEvaluationTile extends StatefulWidget {
  final Evaluation evaluation;

  const GradeEvaluationTile(this.evaluation, {Key key}) : super(key: key);

  @override
  _GradeEvaluationTileState createState() => _GradeEvaluationTileState();
}

class _GradeEvaluationTileState extends State<GradeEvaluationTile> {
  bool showEvaluationDetails = false;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
            child: Theme(
              data: Theme.of(context).copyWith(
                dividerColor: Colors.transparent,
                accentColor: Colors.red,
                unselectedWidgetColor: Colors.red,
              ),
              child: ExpansionTile(
                onExpansionChanged: (value) {
                  showEvaluationDetails = !showEvaluationDetails;
                },
                leading: FractionallySizedBox(
                  heightFactor: 1.1,
                  alignment: Alignment.topCenter,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return GradeCircularProgress(constraints.maxHeight / 100,
                          key: Key(
                              "GradeCircularProgress_${widget.evaluation.title}"),
                          studentGrade: getGradeInPercentage(
                            widget.evaluation.mark,
                            widget.evaluation.correctedEvaluationOutOfFormatted,
                          ),
                          averageGrade: getGradeInPercentage(
                            widget.evaluation.passMark,
                            widget.evaluation.correctedEvaluationOutOfFormatted,
                          ));
                    },
                  ),
                ),
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Text(
                        widget.evaluation.title,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 15,
                            color:
                                Theme.of(context).brightness == Brightness.light
                                    ? Colors.black
                                    : Colors.white),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                      child: Text(
                        AppIntl.of(context)
                            .grades_weight(widget.evaluation.weight),
                        style: TextStyle(
                            fontSize: 12,
                            color:
                                Theme.of(context).brightness == Brightness.light
                                    ? Colors.black
                                    : Colors.white),
                      ),
                    ),
                  ],
                ),
                children: <Widget>[
                  evaluationsSummary(context, widget.evaluation),
                ],
              ),
            ),
          ),
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
      padding: const EdgeInsets.only(top: 10.0, right: 15.0),
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
