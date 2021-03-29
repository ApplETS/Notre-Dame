// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';

// OTHERS
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:notredame/ui/utils/app_theme.dart';

class GradeCircularProgress extends StatelessWidget {
  final double grade;
  final double average;
  final double ratio;

  const GradeCircularProgress(this.grade, this.average, this.ratio);

  @override
  Widget build(BuildContext context) {
    return CircularPercentIndicator(
      animation: true,
      animationDuration: 700,
      radius: 100 * ratio,
      lineWidth: 8.0 * ratio,
      percent: grade,
      center: CircularPercentIndicator(
        animation: true,
        animationDuration: 700,
        radius: 80 * ratio,
        lineWidth: 8.0 * ratio,
        percent: average,
        center: Text(AppIntl.of(context).grades_grade_in_percentage(83.2),
            style: TextStyle(
                color: Theme.of(context).brightness == Brightness.light ? Colors.black : Colors.white,
                fontSize: 16 * ratio)),
        progressColor: Colors.red,
      ),
      progressColor: Colors.green,
    );
  }
}
