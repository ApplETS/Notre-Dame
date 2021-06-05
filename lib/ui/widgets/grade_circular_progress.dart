// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';

// OTHERS
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class GradeCircularProgress extends StatelessWidget {
  final bool completed;
  final String finalGrade;
  final double studentGrade;
  final double averageGrade;
  final double ratio;

  const GradeCircularProgress(this.ratio,
      {Key key,
      this.completed,
      this.finalGrade,
      this.studentGrade,
      this.averageGrade})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CircularPercentIndicator(
      animation: true,
      animationDuration: 1100,
      radius: 100 * ratio,
      lineWidth: 8.0 * ratio,
      percent: completed ? getGradeInDecimals(studentGrade ?? 0.0) : 0,
      circularStrokeCap: CircularStrokeCap.round,
      center: CircularPercentIndicator(
        animation: true,
        animationDuration: 700,
        radius: 80 * ratio,
        lineWidth: 8.0 * ratio,
        percent: completed ? getGradeInDecimals(averageGrade ?? 0.0) : 0,
        circularStrokeCap: CircularStrokeCap.round,
        center: Text(
          getGrade(context),
          style: TextStyle(
              color: Theme.of(context).brightness == Brightness.light
                  ? Colors.black
                  : Colors.white,
              fontSize: 22 * ratio),
        ),
        progressColor: Colors.red,
      ),
      progressColor: Colors.green,
    );
  }

  double getGradeInDecimals(double grade) => grade / 100;

  String getGrade(BuildContext context) {
    if (finalGrade != null) {
      return finalGrade;
    }

    if (studentGrade != null) {
      return AppIntl.of(context)
          .grades_grade_in_percentage(studentGrade.round());
    }

    return AppIntl.of(context).grades_not_available;
  }
}
