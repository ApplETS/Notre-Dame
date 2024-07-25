// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:feature_discovery/feature_discovery.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';

// Project imports:
import 'package:notredame/features/app/signets-api/models/course_evaluation.dart';
import 'package:notredame/features/student/grades/widgets/grade_circular_progress.dart';
import 'package:notredame/features/welcome/discovery/discovery_components.dart';
import 'package:notredame/features/welcome/discovery/models/discovery_ids.dart';
import 'package:notredame/utils/app_theme.dart';
import 'package:notredame/utils/utils.dart';

class GradeEvaluationTile extends StatefulWidget {
  final bool completed;
  final CourseEvaluation evaluation;
  final bool isFirstEvaluation;

  const GradeEvaluationTile(this.evaluation,
      {super.key, this.completed = false, this.isFirstEvaluation = false});

  @override
  _GradeEvaluationTileState createState() => _GradeEvaluationTileState();
}

class _GradeEvaluationTileState extends State<GradeEvaluationTile>
    with TickerProviderStateMixin<GradeEvaluationTile> {
  bool showEvaluationDetails = false;
  late AnimationController controller;
  late Animation<double> rotateAnimation;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
        vsync: this,
        duration: const Duration(
          milliseconds: 200,
        ),
        value: 1.0);

    rotateAnimation = Tween(begin: pi, end: 0.0)
        .animate(CurvedAnimation(parent: controller, curve: Curves.easeIn));
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Theme(
            data: Theme.of(context).copyWith(
              dividerColor: Colors.transparent,
              unselectedWidgetColor: Colors.red,
            ),
            child: Card(
              color: Theme.of(context).brightness == Brightness.light
                  ? AppTheme.lightTheme().cardColor
                  : AppTheme.darkTheme().cardColor,
              clipBehavior: Clip.antiAlias,
              child: ExpansionTile(
                onExpansionChanged: (value) {
                  setState(() {
                    showEvaluationDetails = !showEvaluationDetails;

                    if (showEvaluationDetails) {
                      controller.reverse(from: pi);
                    } else {
                      controller.forward(from: 0.0);
                    }
                  });
                },
                leading: FractionallySizedBox(
                  heightFactor: 1.3,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final GradeCircularProgress circularProgress =
                          GradeCircularProgress(
                        constraints.maxHeight / 100,
                        completed: widget.completed,
                        key: Key(
                            "GradeCircularProgress_${widget.evaluation.title}"),
                        studentGrade: Utils.getGradeInPercentage(
                          widget.evaluation.mark,
                          widget.evaluation.correctedEvaluationOutOfFormatted,
                        ),
                        averageGrade: Utils.getGradeInPercentage(
                          widget.evaluation.passMark,
                          widget.evaluation.correctedEvaluationOutOfFormatted,
                        ),
                      );

                      if (widget.isFirstEvaluation) {
                        return _buildDiscoveryFeatureDescriptionWidget(
                            context,
                            circularProgress,
                            DiscoveryIds.detailsGradeDetailsEvaluations);
                      }

                      return circularProgress;
                    },
                  ),
                ),
                title: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        widget.evaluation.title,
                        style: TextStyle(
                          fontSize: 16,
                          color: Utils.getColorByBrightness(
                              context, Colors.black, Colors.white),
                        ),
                      ),
                      Text(
                        AppIntl.of(context)!
                            .grades_weight(widget.evaluation.weight),
                        style: TextStyle(
                          fontSize: 14,
                          color: Utils.getColorByBrightness(
                              context, Colors.black, Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
                trailing: AnimatedBuilder(
                  animation: rotateAnimation,
                  builder: (BuildContext context, Widget? child) {
                    return Transform.rotate(
                      angle: rotateAnimation.value,
                      child: const Icon(
                        Icons.keyboard_arrow_down_sharp,
                        color: AppTheme.etsLightRed,
                      ),
                    );
                  },
                  child: const Icon(
                    Icons.keyboard_arrow_down_sharp,
                    color: AppTheme.etsLightRed,
                  ),
                ),
                children: <Widget>[
                  _buildEvaluationSummary(context, widget.evaluation),
                ],
              ),
            ),
          ),
        ],
      );

  Widget _buildEvaluationSummary(
      BuildContext context, CourseEvaluation evaluation) {
    return Padding(
      padding: const EdgeInsets.only(left: 20.0, right: 15.0, bottom: 20.0),
      child: Column(
        children: [
          _buildSummary(
            AppIntl.of(context)!.grades_grade,
            AppIntl.of(context)!.grades_grade_with_percentage(
              evaluation.mark ?? 0.0,
              evaluation.correctedEvaluationOutOf,
              Utils.getGradeInPercentage(evaluation.mark,
                  evaluation.correctedEvaluationOutOfFormatted),
            ),
          ),
          _buildSummary(
            AppIntl.of(context)!.grades_average,
            AppIntl.of(context)!.grades_grade_with_percentage(
              evaluation.passMark ?? 0.0,
              evaluation.correctedEvaluationOutOf,
              Utils.getGradeInPercentage(evaluation.passMark,
                  evaluation.correctedEvaluationOutOfFormatted),
            ),
          ),
          _buildSummary(
            AppIntl.of(context)!.grades_median,
            AppIntl.of(context)!.grades_grade_with_percentage(
              evaluation.median ?? 0.0,
              evaluation.correctedEvaluationOutOf,
              Utils.getGradeInPercentage(evaluation.median,
                  evaluation.correctedEvaluationOutOfFormatted),
            ),
          ),
          _buildSummary(
              AppIntl.of(context)!.grades_weighted,
              validateResultWithPercentage(
                  context,
                  evaluation.weightedGrade,
                  evaluation.weight,
                  Utils.getGradeInPercentage(evaluation.mark,
                      evaluation.correctedEvaluationOutOfFormatted))),
          _buildSummary(AppIntl.of(context)!.grades_standard_deviation,
              validateResult(context, evaluation.standardDeviation.toString())),
          _buildSummary(AppIntl.of(context)!.grades_percentile_rank,
              validateResult(context, evaluation.percentileRank.toString())),
          _buildSummary(AppIntl.of(context)!.grades_target_date,
              getDate(evaluation.targetDate, context)),
        ],
      ),
    );
  }

  String getDate(DateTime? targetDate, BuildContext context) {
    if (targetDate != null) {
      return DateFormat('d MMMM yyyy', AppIntl.of(context)!.localeName)
          .format(targetDate);
    }

    return AppIntl.of(context)!.grades_not_available;
  }

  Padding _buildSummary(String title, String grade) {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0, right: 15.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(title, style: const TextStyle(fontSize: 14)),
          Text(grade, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  double getGradeInDecimal(double grade, double maxGrade) => grade / maxGrade;

  String validateResult(BuildContext context, String? result) {
    if (result != "null" && result != null) {
      return result;
    }

    return AppIntl.of(context)!.grades_not_available;
  }

  String validateResultWithPercentage(BuildContext context, double? result,
      double maxGrade, double percentage) {
    if (result == null) {
      return AppIntl.of(context)!.grades_not_available;
    }

    final String formattedResult = result.toStringAsFixed(2);
    return AppIntl.of(context)!.grades_grade_with_percentage(
        double.parse(formattedResult), maxGrade, percentage);
  }

  DescribedFeatureOverlay _buildDiscoveryFeatureDescriptionWidget(
      BuildContext context, Widget circularProgressBar, String featuredId) {
    final discovery = getDiscoveryByFeatureId(
        context, DiscoveryGroupIds.pageGradeDetails, featuredId);

    return DescribedFeatureOverlay(
        overflowMode: OverflowMode.wrapBackground,
        contentLocation: ContentLocation.below,
        featureId: discovery.featureId,
        title: Text(discovery.title, textAlign: TextAlign.justify),
        description: discovery.details,
        backgroundColor: AppTheme.appletsDarkPurple,
        tapTarget: circularProgressBar,
        pulseDuration: const Duration(seconds: 5),
        child: circularProgressBar);
  }
}
