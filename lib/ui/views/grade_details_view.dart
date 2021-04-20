// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

// MODELS
import 'package:notredame/core/viewmodels/grades_details_viewmodel.dart';
import 'package:notredame/core/models/course.dart';

// WIDGETS
import 'package:notredame/ui/widgets/grade_circular_progress.dart';
import 'package:notredame/ui/widgets/base_scaffold.dart';
import 'package:notredame/ui/widgets/grade_evaluation_tile.dart';
import 'package:notredame/ui/widgets/grade_not_available.dart';

// OTHERS
import 'package:notredame/ui/utils/app_theme.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class GradesDetailsView extends StatefulWidget {
  final Course course;

  const GradesDetailsView({this.course});

  @override
  _GradesDetailsViewState createState() => _GradesDetailsViewState();
}

class _GradesDetailsViewState extends State<GradesDetailsView> {
  Widget getGradeEvaluations(GradesDetailsViewModel model) {
    if (model.course.summary != null) {
      return SliverList(
        delegate: SliverChildListDelegate(
          <Widget>[
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: Column(
                children: <Widget>[
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          GradeCircularProgress(
                            1.0,
                            key: const Key("GradeCircularProgress_summary"),
                            finalGrade: model.course.grade,
                            studentGrade: getGradeInPercentage(
                              model.course.summary.currentMark,
                              model.course.summary.markOutOf,
                            ),
                            averageGrade: getGradeInPercentage(
                              model.course.summary.passMark,
                              model.course.summary.markOutOf,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 55.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                getGradeSummary(
                                  getGradeInPercentage(
                                    model.course.summary.currentMark,
                                    model.course.summary.markOutOf,
                                  ),
                                  AppIntl.of(context).grades_current_rating,
                                  Colors.green,
                                  context,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 15.0),
                                  child: getGradeSummary(
                                    getGradeInPercentage(
                                        model.course.summary.passMark,
                                        model.course.summary.markOutOf),
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
                        getHeadersSummary(
                          AppIntl.of(context).grades_median,
                          validateGrade(
                            context,
                            model.course.summary.median.toString(),
                            AppIntl.of(context).grades_grade_in_percentage(
                                model.course.summary.median),
                          ),
                        ),
                        getHeadersSummary(
                          AppIntl.of(context).grades_standard_deviation,
                          validateGrade(
                            context,
                            model.course.summary.standardDeviation.toString(),
                            model.course.summary.standardDeviation.toString(),
                          ),
                        ),
                        getHeadersSummary(
                          AppIntl.of(context).grades_percentile_rank,
                          validateGrade(
                            context,
                            model.course.summary.percentileRank.toString(),
                            model.course.summary.percentileRank.toString(),
                          ),
                        ),
                      ]),
                  Column(children: <Widget>[
                    for (var evaluation in model.course.summary.evaluations)
                      GradeEvaluationTile(evaluation,
                          key: Key("GradeEvaluationTile_${evaluation.title}")),
                  ]),
                ],
              ),
            ),
          ],
        ),
      );
    } else {
      return SliverList(
          delegate: SliverChildListDelegate(<Widget>[
        const GradeNotAvailable(key: Key("GradeNotAvailable"))
      ]));
    }
  }

  double topHeight = 0.0;

  @override
  Widget build(BuildContext context) =>
      ViewModelBuilder<GradesDetailsViewModel>.reactive(
        viewModelBuilder: () => GradesDetailsViewModel(
            intl: AppIntl.of(context), course: widget.course),
        builder: (context, model, child) => RefreshIndicator(
          onRefresh: () => model.refresh(),
          child: BaseScaffold(
            body: CustomScrollView(
              slivers: <Widget>[
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
                      topHeight = constraints.biggest.height;
                      return FlexibleSpaceBar(
                        centerTitle: true,
                        titlePadding: EdgeInsetsDirectional.only(
                          start: topHeight < 120.0 ? 60.0 : 15.0,
                          top: topHeight < 120.0 ? 5.0 : 15.0,
                          bottom: topHeight < 120.0 ? 15.0 : 1.0,
                        ),
                        title: Align(
                          alignment: AlignmentDirectional.bottomStart,
                          child: Text(
                            model.course.acronym ?? "",
                            style:
                                TextStyle(fontSize: topHeight < 120 ? 20 : 15),
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
                        maxHeight: 40,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.light
                            ? AppTheme.etsLightRed
                            : const Color(0xff222222),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          getClassInfo(model.course.title ?? ""),
                          getClassInfo(AppIntl.of(context)
                              .grades_group_number(model.course.group ?? "")),
                        ],
                      ),
                    ),
                  ),
                ),
                getGradeEvaluations(model)
              ],
            ),
          ),
        ),
      );

  Align getClassInfo(String info) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 15.0),
        child: Text(
          info,
          style: const TextStyle(color: Colors.white),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  double getGradeInPercentage(double grade, double maxGrade) {
    if (grade == null || grade == 0.0) {
      return 0.0;
    }

    return ((grade / maxGrade) * 100).roundToDouble();
  }

  Column getGradeSummary(
      double grade, String recipient, Color color, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          AppIntl.of(context).grades_grade_with_percentage(grade, 100, grade),
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
        Text(
          recipient,
          style: TextStyle(color: color),
        ),
      ],
    );
  }

  String validateGrade(BuildContext context, String grade, String text) {
    if (grade == "null" || grade == null) {
      return AppIntl.of(context).grades_not_available;
    }

    return text;
  }

  SizedBox getHeadersSummary(String title, String number) {
    return SizedBox(
      height: 110,
      width: MediaQuery.of(context).size.width / 3.1,
      child: Card(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: Text(title ?? "", textAlign: TextAlign.center),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 25.0),
              child: Text(
                number,
                style: const TextStyle(fontSize: 19),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
