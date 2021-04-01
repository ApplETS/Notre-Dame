// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';

// OTHERS
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class GradeCircularProgress extends StatelessWidget {
  final String finalGrade;
  final double studentGrade;
  final double averageGrade;
  final double ratio;

  const GradeCircularProgress(
      this.finalGrade, this.studentGrade, this.averageGrade, this.ratio);

  @override
  Widget build(BuildContext context) {
    return CircularPercentIndicator(
      animation: true,
      animationDuration: 700,
      radius: 100 * ratio,
      lineWidth: 8.0 * ratio,
      percent: getGradeInDecimals(studentGrade ?? 0.0),
      center: CircularPercentIndicator(
        animation: true,
        animationDuration: 700,
        radius: 80 * ratio,
        lineWidth: 8.0 * ratio,
        percent: getGradeInDecimals(averageGrade ?? 0.0),
        center: Text(getGrade(context),
            style: TextStyle(
                color: Theme.of(context).brightness == Brightness.light
                    ? Colors.black
                    : Colors.white,
                fontSize: 22 * ratio)),
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

    return AppIntl.of(context).grades_grade_in_percentage(studentGrade.round());
  }
}
