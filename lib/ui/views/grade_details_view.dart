// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:stacked/stacked.dart';

// VIEWMODELS
import 'package:notredame/core/viewmodels/grades_details_viewmodel.dart';

// MODELS
import 'package:notredame/core/models/course.dart';

// WIDGETS
import 'package:notredame/ui/widgets/grade_circular_progress.dart';
import 'package:notredame/ui/widgets/base_scaffold.dart';
import 'package:notredame/ui/widgets/grade_evaluation_tile.dart';
import 'package:notredame/ui/widgets/grade_not_available.dart';

// OTHERS
import 'package:notredame/ui/utils/app_theme.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:notredame/core/utils/utils.dart';

class GradesDetailsView extends StatefulWidget {
  final Course course;

  const GradesDetailsView({this.course});

  @override
  _GradesDetailsViewState createState() => _GradesDetailsViewState();
}

class _GradesDetailsViewState extends State<GradesDetailsView>
    with TickerProviderStateMixin {
  AnimationController _controller;
  bool _completed = false;
  double initialTopHeight = 0.0;

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

    SchedulerBinding.instance.addPostFrameCallback((Duration duration) {
      GradesDetailsViewModel.startDiscovery(context);
    });
  }

  @override
  Widget build(BuildContext context) =>
      ViewModelBuilder<GradesDetailsViewModel>.reactive(
        viewModelBuilder: () => GradesDetailsViewModel(
            course: widget.course, intl: AppIntl.of(context)),
        builder: (context, model, child) => BaseScaffold(
          showBottomBar: false,
          body: Hero(
            tag:
                'course_acronym_${model.course.acronym}_${model.course.session}',
            child: Material(
              child: NestedScrollView(
                headerSliverBuilder: (context, innerBoxScrolled) => [
                  SliverAppBar(
                    pinned: true,
                    stretch: true,
                    elevation: 0,
                    onStretchTrigger: () {
                      return Future<void>.value();
                    },
                    expandedHeight: 80.0,
                    flexibleSpace: LayoutBuilder(
                      builder:
                          (BuildContext context, BoxConstraints constraints) {
                        if (initialTopHeight == 0.0) {
                          initialTopHeight = constraints.biggest.height;
                        }
                        final double topHeight = constraints.biggest.height;

                        return FlexibleSpaceBar(
                          centerTitle: true,
                          titlePadding: EdgeInsetsDirectional.only(
                            start: topHeight < initialTopHeight ? 50.0 : 15.0,
                            bottom: topHeight < initialTopHeight ? 16.0 : 5.0,
                          ),
                          title: Align(
                            alignment: AlignmentDirectional.bottomStart,
                            child: Text(
                              model.course.acronym ?? "",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText1
                                  .copyWith(
                                      color: Colors.white,
                                      fontSize: 19,
                                      fontWeight: FontWeight.bold),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Center(
                      child: Container(
                        constraints: BoxConstraints(
                          minWidth: MediaQuery.of(context).size.width,
                          maxHeight: 45,
                        ),
                        decoration: BoxDecoration(
                          color:
                              Theme.of(context).brightness == Brightness.light
                                  ? AppTheme.etsLightRed
                                  : Theme.of(context).bottomAppBarColor,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            _buildClassInfo(model.course.title ?? ""),
                            _buildClassInfo(AppIntl.of(context)
                                .grades_group_number(model.course.group ?? "")),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
                body: RefreshIndicator(
                  onRefresh: () => model.refresh(),
                  child: _buildGradeEvaluations(model),
                ),
              ),
            ),
          ),
        ),
      );

  Widget _buildGradeEvaluations(GradesDetailsViewModel model) {
    if (model.course.summary != null) {
      return ListView(
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
                            model.course.summary.currentMark,
                            model.course.summary.markOutOf,
                          ),
                          averageGrade: Utils.getGradeInPercentage(
                            model.course.summary.passMark,
                            model.course.summary.markOutOf,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 40,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            _buildGradesSummary(
                              model.course.summary.currentMark,
                              model.course.summary.markOutOf,
                              AppIntl.of(context).grades_current_rating,
                              Colors.green,
                              context,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 15.0),
                              child: _buildGradesSummary(
                                model.course.summary.passMark ?? 0.0,
                                model.course.summary.markOutOf,
                                AppIntl.of(context).grades_average,
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
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Expanded(
                      flex: 3,
                      child: _buildCourseGradeSummary(
                        AppIntl.of(context).grades_median,
                        validateGrade(
                          context,
                          model.course.summary.median.toString(),
                          AppIntl.of(context).grades_grade_in_percentage(
                              Utils.getGradeInPercentage(
                                  model.course.summary.median,
                                  model.course.summary.markOutOf)),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: _buildCourseGradeSummary(
                        AppIntl.of(context).grades_standard_deviation,
                        validateGrade(
                          context,
                          model.course.summary.standardDeviation.toString(),
                          model.course.summary.standardDeviation.toString(),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: _buildCourseGradeSummary(
                        AppIntl.of(context).grades_percentile_rank,
                        validateGrade(
                          context,
                          model.course.summary.percentileRank.toString(),
                          model.course.summary.percentileRank.toString(),
                        ),
                      ),
                    ),
                  ]),
              Column(children: <Widget>[
                for (var evaluation in model.course.summary.evaluations)
                  GradeEvaluationTile(
                    evaluation,
                    completed: _completed,
                    key: Key("GradeEvaluationTile_${evaluation.title}"),
                    isFirstEvaluation:
                        evaluation == model.course.summary.evaluations.first,
                  ),
              ]),
            ],
          ),
        ],
      );
    } else if (model.isBusy) {
      return const Center(child: CircularProgressIndicator());
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
                .bodyText1
                .copyWith(color: Colors.white, fontSize: 16),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      );

  /// Build the student grade or the average grade with their title
  Column _buildGradesSummary(double currentGrade, double maxGrade,
      String recipient, Color color, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        FittedBox(
          fit: BoxFit.fitWidth,
          child: Text(
              AppIntl.of(context).grades_grade_with_percentage(
                currentGrade,
                maxGrade,
                Utils.getGradeInPercentage(
                  currentGrade,
                  maxGrade,
                ),
              ),
              style:
                  Theme.of(context).textTheme.headline6.copyWith(color: color)),
        ),
        Text(recipient,
            style:
                Theme.of(context).textTheme.bodyText1.copyWith(color: color)),
      ],
    );
  }

  String validateGrade(BuildContext context, String grade, String text) {
    if (grade == "null" || grade == null) {
      return AppIntl.of(context).grades_not_available;
    }

    return text;
  }

  /// Build the card of the Medidian, Standart deviation or Percentile Rank
  SizedBox _buildCourseGradeSummary(String title, String number) {
    return SizedBox(
      height: 110,
      width: MediaQuery.of(context).size.width / 3.1,
      child: Card(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.only(top: 14.0),
                child: Text(
                  title ?? "",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.only(top: 2.0),
                child: Text(
                  number,
                  style: const TextStyle(fontSize: 19),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
