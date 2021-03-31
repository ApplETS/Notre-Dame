// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:stacked/stacked.dart';

// MODELS
import 'package:notredame/core/viewmodels/grades_details_viewmodel.dart';
import 'package:notredame/core/models/course.dart';

// WIDGETS
import 'package:notredame/ui/widgets/grade_circular_progress.dart';
import 'package:notredame/ui/widgets/base_scaffold.dart';
import 'package:notredame/ui/widgets/grade_evaluation_tile.dart';

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
  double topHeight = 0.0;

  @override
  Widget build(BuildContext context) =>
      ViewModelBuilder<GradesDetailsViewModel>.reactive(
        viewModelBuilder: () =>
            GradesDetailsViewModel(intl: AppIntl.of(context)),
        builder: (context, model, child) => RefreshIndicator(
          onRefresh: () async {
            if (await model.refresh()) {
              Fluttertoast.showToast(msg: AppIntl.of(context).error);
            }
          },
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
                            widget.course.acronym,
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
                          maxHeight: 40),
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.light
                            ? AppTheme.etsLightRed
                            : const Color(0xff222222),
                      ),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            getClassInformation(widget.course.title),
                            getClassInformation(AppIntl.of(context)
                                .grades_group_number(widget.course.group)),
                          ]),
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildListDelegate([
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const GradeCircularProgress(0.85, 0.72, 1.0),
                              Padding(
                                padding: const EdgeInsets.only(left: 55.0),
                                child: Column(
                                  children: [
                                    getTotalGrade(
                                        "85,3/100 (85 %)",
                                        AppIntl.of(context)
                                            .grades_current_rating,
                                        Colors.green),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 15.0),
                                      child: getTotalGrade(
                                          "75,2/100 (75 %)",
                                          AppIntl.of(context).grades_average,
                                          AppTheme.etsLightRed),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        getHeadersSummary(
                            AppIntl.of(context).grades_median,
                            AppIntl.of(context).grades_grade_in_percentage(
                                gradeString(
                                    AppIntl.of(context), widget.course))),
                        getHeadersSummary(
                            AppIntl.of(context).grades_standard_deviation, ' '),
                        getHeadersSummary(
                            AppIntl.of(context).grades_percentile_rank, ' '),
                      ],
                    ),
                    Column(
                      children: <Widget>[getEvaluations()],
                    ),
                  ]),
                ),
              ],
            ),
          ),
        ),
      );

  Align getClassInformation(String info) {
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

  GradeEvaluationTile getEvaluations() {
    /*widget.course.summary.evaluations.forEach((element) {
      GradeEvaluationTile('Devoir 1', "10", 0.95, 0.75);
    });*/

    return const GradeEvaluationTile('Devoir 1', "10", 0.95, 0.75);
  }

  Column getTotalGrade(String grade, String recipient, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          grade,
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
        Text(recipient, style: TextStyle(color: color)),
      ],
    );
  }

  Container getHeadersSummary(String title, String number) {
    return Container(
      height: 110,
      width: MediaQuery.of(context).size.width / 3.2,
      child: Card(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: Text(title, textAlign: TextAlign.center),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 25.0),
              child: Text(
                number,
                style:
                    const TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build the grade string based on the available information. By default
  /// will return [grades_not_available].
  String gradeString(AppIntl intl, Course grade) {
    if (grade == null && widget.course.summary != null) {
      return intl.grades_grade_in_percentage(
          widget.course.summary.currentMarkInPercent.round());
    } else if (widget.course.grade != null) {
      return widget.course.grade.toString();
    }

    return intl.grades_not_available;
  }
}
