// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:stacked/stacked.dart';

// Project imports:
import 'package:notredame/features/app/signets-api/models/course.dart';
import 'package:notredame/features/app/signets-api/models/course_evaluation.dart';
import 'package:notredame/features/app/widgets/base_scaffold.dart';
import 'package:notredame/features/student/grades/grade_details/grades_details_viewmodel.dart';
import 'package:notredame/features/student/grades/widgets/grade_circular_progress.dart';
import 'package:notredame/features/student/grades/widgets/grade_evaluation_tile.dart';
import 'package:notredame/features/student/grades/widgets/grade_not_available.dart';
import 'package:notredame/utils/app_theme.dart';
import 'package:notredame/utils/utils.dart';

class GradesDetailsView extends StatefulWidget {
  final Course course;

  const GradesDetailsView({super.key, required this.course});

  @override
  State<GradesDetailsView> createState() => _GradesDetailsViewState();
}

class _GradesDetailsViewState extends State<GradesDetailsView>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  bool _completed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _controller.forward();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _completed = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) =>
      ViewModelBuilder<GradesDetailsViewModel>.reactive(
        viewModelBuilder: () => GradesDetailsViewModel(
            course: widget.course, intl: AppIntl.of(context)!),
        builder: (context, model, child) => BaseScaffold(
          safeArea: false,
          showBottomBar: false,
          body: NestedScrollView(
            headerSliverBuilder: (context, innerBoxScrolled) => [
              SliverAppBar(
                backgroundColor:
                    Theme.of(context).brightness == Brightness.light
                        ? AppTheme.etsLightRed
                        : BottomAppBarTheme.of(context).color,
                pinned: true,
                onStretchTrigger: () {
                  return Future<void>.value();
                },
                titleSpacing: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                title: Hero(
                  tag:
                      'course_acronym_${model.course.acronym}_${model.course.session}',
                  child: Text(
                    model.course.acronym,
                    softWrap: false,
                    overflow: TextOverflow.visible,
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Center(
                  child: Container(
                    constraints: BoxConstraints(
                      minWidth: MediaQuery.of(context).size.width,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.light
                          ? AppTheme.etsLightRed
                          : AppTheme.darkTheme().cardColor,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: SafeArea(
                        top: false,
                        bottom: false,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            _buildClassInfo(model.course.title),
                            if (model.course.teacherName != null)
                              _buildClassInfo(AppIntl.of(context)!
                                  .grades_teacher(model.course.teacherName!)),
                            _buildClassInfo(AppIntl.of(context)!
                                .grades_group_number(model.course.group)),
                            _buildClassInfo(AppIntl.of(context)!
                                .credits_number(model.course.numberOfCredits)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
            body: SafeArea(
              top: false,
              bottom: false,
              child: _buildGradeEvaluations(model),
            ),
          ),
        ),
      );

  Widget _buildGradeEvaluations(GradesDetailsViewModel model) {
    if (model.isBusy) {
      return const Center(child: CircularProgressIndicator());
    } else if (model.course.inReviewPeriod &&
        !(model.course.allReviewsCompleted ?? true)) {
      return Center(
        child: GradeNotAvailable(
            key: const Key("EvaluationNotCompleted"),
            onPressed: model.refresh,
            isEvaluationPeriod: true),
      );
    } else if (model.course.summary != null) {
      return RefreshIndicator(
        onRefresh: () => model.refresh(),
        child: ListView(
          padding: const EdgeInsets.all(5.0),
          children: <Widget>[
            Column(
              children: <Widget>[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          flex: 50,
                          child: GradeCircularProgress(
                            1.0,
                            completed: _completed,
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
                              _buildGradesSummary(
                                model.course.summary?.currentMark,
                                model.course.summary?.markOutOf,
                                AppIntl.of(context)!.grades_current_rating,
                                Colors.green,
                                context,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 15.0),
                                child: _buildGradesSummary(
                                  model.course.summary?.passMark,
                                  model.course.summary?.markOutOf,
                                  AppIntl.of(context)!.grades_average,
                                  Colors.red,
                                  context,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                IntrinsicHeight(
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Expanded(
                          flex: 3,
                          child: _buildCourseGradeSummary(
                            AppIntl.of(context)!.grades_median,
                            validateGrade(
                              context,
                              model.course.summary?.median.toString(),
                              AppIntl.of(context)!.grades_grade_in_percentage(
                                  Utils.getGradeInPercentage(
                                      model.course.summary?.median,
                                      model.course.summary?.markOutOf)),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: _buildCourseGradeSummary(
                            AppIntl.of(context)!.grades_standard_deviation,
                            validateGrade(
                              context,
                              model.course.summary?.standardDeviation
                                  .toString(),
                              model.course.summary?.standardDeviation
                                  .toString(),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: _buildCourseGradeSummary(
                            AppIntl.of(context)!.grades_percentile_rank,
                            validateGrade(
                              context,
                              model.course.summary?.percentileRank.toString(),
                              model.course.summary?.percentileRank.toString(),
                            ),
                          ),
                        ),
                      ]),
                ),
                const SizedBox(
                  height: 8.0,
                ),
                Column(children: <Widget>[
                  for (final CourseEvaluation evaluation
                      in model.course.summary?.evaluations ?? [])
                    GradeEvaluationTile(
                      evaluation,
                      completed: _completed,
                      key: Key("GradeEvaluationTile_${evaluation.title}"),
                    ),
                  const SizedBox(height: 24)
                ]),
              ],
            ),
          ],
        ),
      );
    } else {
      return Center(
        child: GradeNotAvailable(
            key: const Key("GradeNotAvailable"), onPressed: model.refresh),
      );
    }
  }

  Align _buildClassInfo(String info) => Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.only(left: 15.0),
          child: Text(
            info,
            style: Theme.of(context)
                .textTheme
                .bodyLarge!
                .copyWith(color: Colors.white, fontSize: 16),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      );

  /// Build the student grade or the average grade with their title
  Column _buildGradesSummary(double? currentGrade, double? maxGrade,
      String recipient, Color color, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        FittedBox(
          fit: BoxFit.fitWidth,
          child: Text(
              AppIntl.of(context)!.grades_grade_with_percentage(
                currentGrade ?? 0.0,
                maxGrade ?? 0.0,
                Utils.getGradeInPercentage(
                  currentGrade,
                  maxGrade,
                ),
              ),
              style: Theme.of(context)
                  .textTheme
                  .titleLarge!
                  .copyWith(color: color)),
        ),
        Text(recipient,
            style:
                Theme.of(context).textTheme.bodyLarge!.copyWith(color: color)),
      ],
    );
  }

  String validateGrade(BuildContext context, String? grade, String? text) {
    if (grade == "null" || grade == null || text == "null" || text == null) {
      return AppIntl.of(context)!.grades_not_available;
    }

    return text;
  }

  /// Build the card of the Medidian, Standard deviation or Percentile Rank
  Widget _buildCourseGradeSummary(String? title, String number) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title ?? "",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              number,
              style: const TextStyle(fontSize: 19),
            ),
          ],
        ),
      ),
    );
  }
}
