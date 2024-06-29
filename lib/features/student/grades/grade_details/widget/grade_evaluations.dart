import 'package:ets_api_clients/models.dart';
import 'package:flutter/material.dart';
import 'package:notredame/features/student/grades/grade_details/grades_details_viewmodel.dart';
import 'package:notredame/features/student/grades/grade_details/widget/course_grade_summary.dart';
import 'package:notredame/features/student/grades/grade_details/widget/grade_summary.dart';
import 'package:notredame/features/student/grades/widgets/grade_circular_progress.dart';
import 'package:notredame/features/student/grades/widgets/grade_evaluation_tile.dart';
import 'package:notredame/features/student/grades/widgets/grade_not_available.dart';
import 'package:notredame/utils/utils.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class GradeEvaluations extends StatelessWidget {
  final GradesDetailsViewModel model;
  final bool completed;

  const GradeEvaluations({required this.model, required this.completed});

  @override
  Widget build(BuildContext context) {
    if (model.isBusy) {
      return _buildLoadingIndicator();
    } else if (model.course.inReviewPeriod &&
        !(model.course.allReviewsCompleted ?? true)) {
      return _buildEvaluationNotCompleted();
    } else if (model.course.summary != null) {
      return _buildGradeDetails(context);
    } else {
      return _buildGradeNotAvailable();
    }
  }

  Widget _buildLoadingIndicator() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildEvaluationNotCompleted() {
    return Center(
      child: GradeNotAvailable(
        key: const Key("EvaluationNotCompleted"),
        onPressed: model.refresh,
        isEvaluationPeriod: true,
      ),
    );
  }

  Widget _buildGradeNotAvailable() {
    return Center(
      child: GradeNotAvailable(
        key: const Key("GradeNotAvailable"),
        onPressed: model.refresh,
      ),
    );
  }

  Widget _buildGradeDetails(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => model.refresh(),
      child: ListView(
        padding: const EdgeInsets.all(5.0),
        children: <Widget>[
          _buildSummaryCard(context),
          _buildAdditionalDetails(context),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              flex: 50,
              child: GradeCircularProgress(
                1.0,
                completed: completed,
                key: const Key("GradeCircularProgress_summary"),
                finalGrade: model.course.grade,
                studentGrade: Utils.getGradeInPercentage(
                  model.course.summary?.currentMark,
                  model.course.summary?.markOutOf,
                ),
                averageGrade: Utils.getGradeInPercentage(
                  model.course.summary?.passMark,
                  model.course.summary?.markOutOf,
                ),
              ),
            ),
            Expanded(
              flex: 40,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  GradesSummary(
                    currentGrade: model.course.summary?.currentMark,
                    maxGrade: model.course.summary?.markOutOf,
                    recipient: AppIntl.of(context)!.grades_current_rating,
                    color: Colors.green,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 15.0),
                    child: GradesSummary(
                      currentGrade: model.course.summary?.passMark,
                      maxGrade: model.course.summary?.markOutOf,
                      recipient: AppIntl.of(context)!.grades_average,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalDetails(BuildContext context) {
    return Column(
      children: <Widget>[
        _buildAdditionalSummary(context),
        _buildEvaluationTiles(),
      ],
    );
  }

  Widget _buildAdditionalSummary(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Expanded(
          flex: 3,
          child: CourseGradeSummary(
            title: AppIntl.of(context)!.grades_median,
            number: model.course.summary?.median.toString() ??
                AppIntl.of(context)!.grades_not_available,
          ),
        ),
        Expanded(
          flex: 3,
          child: CourseGradeSummary(
            title: AppIntl.of(context)!.grades_standard_deviation,
            number: model.course.summary?.standardDeviation.toString() ??
                AppIntl.of(context)!.grades_not_available,
          ),
        ),
        Expanded(
          flex: 3,
          child: CourseGradeSummary(
            title: AppIntl.of(context)!.grades_percentile_rank,
            number: model.course.summary?.percentileRank.toString() ??
                AppIntl.of(context)!.grades_not_available,
          ),
        ),
      ],
    );
  }

  Widget _buildEvaluationTiles() {
    return Column(
      children: <Widget>[
        for (final CourseEvaluation evaluation
            in model.course.summary?.evaluations ?? [])
          GradeEvaluationTile(
            evaluation,
            completed: completed,
            key: Key("GradeEvaluationTile_${evaluation.title}"),
            isFirstEvaluation:
                evaluation == model.course.summary?.evaluations.first,
          ),
      ],
    );
  }
}
