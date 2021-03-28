// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';
import 'package:notredame/ui/utils/app_theme.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// WIDGETS
import 'package:notredame/ui/widgets/grade_circular_progress.dart';

// CONSTANT
import 'package:notredame/ui/utils/app_theme.dart';

class GradeEvaluationTile extends StatelessWidget {
  final String title;
  final String weight;
  bool rotate = false;
  final double tempGrade1;
  final double tempAverage2;

  GradeEvaluationTile(
      this.title, this.weight, this.tempGrade1, this.tempAverage2);

  @override
  Widget build(BuildContext context) => Theme(
        data: ThemeData().copyWith(dividerColor: Colors.transparent),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: ExpansionTile(
            leading: FractionallySizedBox(
              alignment: Alignment.topCenter,
              heightFactor: 1.2,
              child: Container(
                  child: LayoutBuilder(builder: (context, constraints) {
                return GradeCircularProgress(
                    tempGrade1, tempAverage2, constraints.maxHeight / 100);
              })),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(title,
                    style: TextStyle(
                        height: 3,
                        fontSize: 15,
                        color: Theme.of(context).brightness == Brightness.light
                            ? Colors.black
                            : Colors.white)),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, bottom: 9.0),
                  child: Text('Pondération: $weight',
                      style: TextStyle(
                          fontSize: 12,
                          color:
                              Theme.of(context).brightness == Brightness.light
                                  ? Colors.black
                                  : Colors.white)),
                ),
              ],
            ),
            trailing: Transform.rotate(
              angle: rotate == true ? 180 * 3.14 / 360 : 0,
              child: IconButton(
                icon: const Padding(
                  padding: EdgeInsets.only(left: 20.0),
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    color: AppTheme.etsLightRed,
                    size: 30,
                  ),
                ),
                onPressed: () => {
                  rotate = true,
                },
              ),
            ),
            children: <Widget>[evaluationsSummary(context)],
            onExpansionChanged: (isOpen) {
              rotate = !rotate;
            },
          ),
        ),
      );

  Widget evaluationsSummary(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 5.0, bottom: 8),
      child: Container(
          width: MediaQuery.of(context).size.width * 0.91,
          child: Column(
            children: [
              getSummary(AppIntl.of(context).grades_grade, "4,7/5,0 (82,9 %)"),
              getSummary(AppIntl.of(context).grades_average, "2,7/5,0 (54 %)"),
              getSummary(AppIntl.of(context).grades_median, "4,2"),
              getSummary(AppIntl.of(context).grades_standard_deviation, "0,6"),
              getSummary(AppIntl.of(context).grades_percentile_rank, "79"),
              getSummary(
                  AppIntl.of(context).grades_target_date, "18 septembre 2020"),
            ],
          )),
    );
  }

  Padding getSummary(String title, String grade) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, right: 15.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(title),
          Text(grade),
        ],
      ),
    );
  }
}
