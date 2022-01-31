// FLUTTER / DART / THIRD-PARTIES
import 'dart:math';
import 'package:feature_discovery/feature_discovery.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// CONSTANTS
import 'package:notredame/core/constants/discovery_ids.dart';

// MODELS
import 'package:signets_api_client/models.dart';

// UTILS
import 'package:notredame/ui/utils/discovery_components.dart';

// WIDGETS
import 'package:notredame/ui/widgets/grade_circular_progress.dart';

// OTHER
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:notredame/ui/utils/app_theme.dart';
import 'package:notredame/core/utils/utils.dart';

class GradeEvaluationTile extends StatefulWidget {
  final bool completed;
  final Evaluation evaluation;
  final bool isFirstEvaluation;

  const GradeEvaluationTile(this.evaluation,
      {Key key, this.completed, this.isFirstEvaluation})
      : super(key: key);

  @override
  _GradeEvaluationTileState createState() => _GradeEvaluationTileState();
}

class _GradeEvaluationTileState extends State<GradeEvaluationTile>
    with TickerProviderStateMixin<GradeEvaluationTile> {
  bool showEvaluationDetails = false;
  AnimationController controller;
  Animation<double> rotateAnimation;

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
              colorScheme:
                  ColorScheme.fromSwatch().copyWith(secondary: Colors.red),
            ),
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
                alignment: Alignment.topCenter,
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
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 30.0),
                    child: Text(
                      widget.evaluation.title,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        color: Utils.getColorByBrightness(
                            context, Colors.black, Colors.white),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0, bottom: 20.0),
                    child: Text(
                      AppIntl.of(context)
                          .grades_weight(widget.evaluation.weight),
                      style: TextStyle(
                        fontSize: 14,
                        color: Utils.getColorByBrightness(
                            context, Colors.black, Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
              trailing: Padding(
                padding: const EdgeInsets.only(top: 25.0, right: 10.0),
                child: AnimatedBuilder(
                  animation: rotateAnimation,
                  builder: (BuildContext context, Widget child) {
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
              ),
              children: <Widget>[
                _buildEvaluationSummary(context, widget.evaluation),
              ],
            ),
          ),
        ],
      );

  Widget _buildEvaluationSummary(BuildContext context, Evaluation evaluation) {
    return Padding(
      padding: const EdgeInsets.only(left: 25.0, right: 15.0),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.91,
        child: Column(
          children: [
            _buildSummary(
              AppIntl.of(context).grades_grade,
              AppIntl.of(context).grades_grade_with_percentage(
                evaluation.mark ?? 0.0,
                evaluation.correctedEvaluationOutOf ?? 0.0,
                Utils.getGradeInPercentage(evaluation.mark,
                    evaluation.correctedEvaluationOutOfFormatted),
              ),
            ),
            _buildSummary(
              AppIntl.of(context).grades_average,
              AppIntl.of(context).grades_grade_with_percentage(
                evaluation.passMark ?? 0.0,
                evaluation.correctedEvaluationOutOf ?? 0.0,
                Utils.getGradeInPercentage(evaluation.passMark,
                    evaluation.correctedEvaluationOutOfFormatted),
              ),
            ),
            _buildSummary(
              AppIntl.of(context).grades_median,
              AppIntl.of(context).grades_grade_with_percentage(
                evaluation.median ?? 0.0,
                evaluation.correctedEvaluationOutOf ?? 0.0,
                Utils.getGradeInPercentage(evaluation.median,
                    evaluation.correctedEvaluationOutOfFormatted),
              ),
            ),
            _buildSummary(
                AppIntl.of(context).grades_standard_deviation,
                validateResult(
                    context, evaluation.standardDeviation.toString())),
            _buildSummary(AppIntl.of(context).grades_percentile_rank,
                validateResult(context, evaluation.percentileRank.toString())),
            _buildSummary(AppIntl.of(context).grades_target_date,
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

  Padding _buildSummary(String title, String grade) {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0, right: 15.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(title, style: const TextStyle(fontSize: 14)),
          Text(grade ?? '', style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  double getGradeInDecimal(double grade, double maxGrade) => grade / maxGrade;

  String validateResult(BuildContext context, String result) {
    if (result != "null") {
      return result;
    }

    return AppIntl.of(context).grades_not_available;
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
