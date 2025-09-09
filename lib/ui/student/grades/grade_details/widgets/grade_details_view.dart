// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:stacked/stacked.dart';

// Project imports:
import 'package:notredame/data/services/signets-api/models/course.dart';
import 'package:notredame/data/services/signets-api/models/course_evaluation.dart';
import 'package:notredame/l10n/app_localizations.dart';
import 'package:notredame/ui/core/themes/app_palette.dart';
import 'package:notredame/ui/core/themes/app_theme.dart';
import 'package:notredame/ui/core/ui/base_scaffold.dart';
import 'package:notredame/ui/student/grades/grade_details/view_model/grades_details_viewmodel.dart';
import 'package:notredame/ui/student/grades/widgets/grade_circular_progress.dart';
import 'package:notredame/ui/student/grades/widgets/grade_evaluation_tile.dart';
import 'package:notredame/ui/student/grades/widgets/grade_not_available.dart';
import 'package:notredame/utils/utils.dart';

class GradesDetailsView extends StatefulWidget {
  final Course course;

  const GradesDetailsView({super.key, required this.course});

  @override
  State<GradesDetailsView> createState() => _GradesDetailsViewState();
}

class _GradesDetailsViewState extends State<GradesDetailsView> with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _ignoredEvaluationsAnimationController;
  bool _completed = false;
  final GlobalKey _expansionTileKey = GlobalKey();
  late Animation<double> _rotateAnimation;
  bool _isIgnoredEvaluationsExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _controller.forward();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _completed = true;
        });
      }
    });

    _ignoredEvaluationsAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      value: 1.0,
    );
    _ignoredEvaluationsAnimationController.forward();

    _rotateAnimation = Tween(
      begin: pi,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _ignoredEvaluationsAnimationController, curve: Curves.easeIn));
  }

  @override
  void dispose() {
    _controller.dispose();
    _ignoredEvaluationsAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ViewModelBuilder<GradesDetailsViewModel>.reactive(
    viewModelBuilder: () => GradesDetailsViewModel(course: widget.course, intl: AppIntl.of(context)!),
    builder: (context, model, child) => BaseScaffold(
      safeArea: false,
      showBottomBar: false,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxScrolled) => [
          SliverAppBar(
            backgroundColor: context.theme.appColors.vibrantAppBar,
            pinned: true,
            onStretchTrigger: () {
              return Future<void>.value();
            },
            titleSpacing: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: AppPalette.grey.white),
              tooltip: AppIntl.of(context)!.go_back,
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Hero(
              tag: 'course_acronym_${model.course.acronym}_${model.course.session}',
              child: Text(
                model.course.acronym,
                softWrap: false,
                overflow: TextOverflow.visible,
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  color: AppPalette.grey.white,
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Center(
              child: Container(
                constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width),
                decoration: BoxDecoration(color: context.theme.appColors.vibrantAppBar),
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
                          _buildClassInfo(AppIntl.of(context)!.grades_teacher(model.course.teacherName!)),
                        _buildClassInfo(AppIntl.of(context)!.grades_group_number(model.course.group)),
                        _buildClassInfo(AppIntl.of(context)!.credits_number(model.course.numberOfCredits)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
        body: SafeArea(top: false, bottom: false, child: _buildGradeEvaluations(model)),
      ),
    ),
  );

  Widget _buildGradeEvaluations(GradesDetailsViewModel model) {
    if (model.isBusy) {
      return const Center(child: CircularProgressIndicator());
    } else if (model.course.inReviewPeriod && !(model.course.allReviewsCompleted ?? true)) {
      return Center(
        child: GradeNotAvailable(
          key: const Key("EvaluationNotCompleted"),
          onPressed: model.refresh,
          isEvaluationPeriod: true,
        ),
      );
    } else if (model.course.summary != null) {
      final allEvaluations = model.course.summary?.evaluations ?? [];
      final ignoredEvaluations = allEvaluations.where((e) => e.ignore).toList();
      final nonIgnoredEvaluations = allEvaluations.where((e) => !e.ignore).toList();

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
                                context.theme.appColors.positiveText,
                                context,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 15.0),
                                child: _buildGradesSummary(
                                  model.course.summary?.passMark,
                                  model.course.summary?.markOutOf,
                                  AppIntl.of(context)!.grades_average,
                                  context.theme.appColors.negativeText,
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
                                    model.course.summary?.markOutOf,
                                  ) ??
                                  0.0,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: _buildCourseGradeSummary(
                          AppIntl.of(context)!.grades_standard_deviation,
                          validateGrade(
                            context,
                            model.course.summary?.standardDeviation.toString(),
                            model.course.summary?.standardDeviation.toString(),
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
                    ],
                  ),
                ),
                const SizedBox(height: 8.0),
                Column(
                  children: <Widget>[
                    for (final CourseEvaluation evaluation in nonIgnoredEvaluations)
                      GradeEvaluationTile(
                        evaluation,
                        completed: _completed,
                        key: Key("GradeEvaluationTile_${evaluation.title}"),
                      ),
                    if (ignoredEvaluations.isNotEmpty) ...[_buildIgnoredEvaluationsExpansionTile(ignoredEvaluations)],
                    const SizedBox(height: 24),
                  ],
                ),
              ],
            ),
          ],
        ),
      );
    } else {
      return Center(
        child: GradeNotAvailable(key: const Key("GradeNotAvailable"), onPressed: model.refresh),
      );
    }
  }

  Align _buildClassInfo(String info) => Align(
    alignment: Alignment.centerLeft,
    child: Padding(
      padding: const EdgeInsets.only(left: 15.0),
      child: Text(
        info,
        style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: AppPalette.grey.white, fontSize: 16),
        overflow: TextOverflow.ellipsis,
      ),
    ),
  );

  /// Build the student grade or the average grade with their title
  Column _buildGradesSummary(
    double? currentGrade,
    double? maxGrade,
    String recipient,
    Color color,
    BuildContext context,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        FittedBox(
          fit: BoxFit.fitWidth,
          child: Text(
            Utils.validateResultWithPercentage(
              context,
              currentGrade,
              maxGrade ?? 0.0,
              Utils.getGradeInPercentage(currentGrade, maxGrade) ?? 0.0,
            ),
            style: Theme.of(context).textTheme.titleLarge!.copyWith(color: color),
          ),
        ),
        Text(recipient, style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: color)),
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
            Text(title ?? "", textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 4),
            Text(number, style: const TextStyle(fontSize: 19)),
          ],
        ),
      ),
    );
  }

  Widget _buildIgnoredEvaluationsExpansionTile(List<CourseEvaluation> ignoredEvaluations) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        key: _expansionTileKey,
        onExpansionChanged: (value) {
          _isIgnoredEvaluationsExpanded = !_isIgnoredEvaluationsExpanded;
          if (value) {
            _ignoredEvaluationsAnimationController.reverse(from: pi);
            _scrollToSelectedContent(expansionTileKey: _expansionTileKey);
          } else {
            _ignoredEvaluationsAnimationController.forward(from: 0.0);
          }
        },
        trailing: AnimatedBuilder(
          animation: _rotateAnimation,
          builder: (BuildContext context, Widget? child) {
            return Transform.rotate(
              angle: _rotateAnimation.value,
              child: const Icon(Icons.keyboard_arrow_down_sharp, color: AppPalette.etsLightRed),
            );
          },
          child: const Icon(Icons.keyboard_arrow_down_sharp, color: AppPalette.etsLightRed),
        ),
        tilePadding: EdgeInsets.only(left: 8.0, right: 28),
        title: Row(
          children: [
            Text(
              AppIntl.of(context)!.ignored_evaluations_section_title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(width: 8),
            Container(
              constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
              decoration: BoxDecoration(color: Colors.grey[800], shape: BoxShape.circle),
              child: IntrinsicWidth(
                child: IntrinsicHeight(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      child: Text(ignoredEvaluations.length.toString()),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 8.0),
            child: Text(AppIntl.of(context)!.ignored_evaluations_section_tooltip_text),
          ),
          for (final CourseEvaluation evaluation in ignoredEvaluations)
            GradeEvaluationTile(evaluation, completed: _completed, key: Key("GradeEvaluationTile_${evaluation.title}")),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _scrollToSelectedContent({required GlobalKey expansionTileKey}) {
    final keyContext = expansionTileKey.currentContext;
    if (keyContext != null) {
      Future.delayed(Duration(milliseconds: 200)).then((value) {
        Scrollable.ensureVisible(keyContext, duration: Duration(milliseconds: 200));
      });
    }
  }
}
