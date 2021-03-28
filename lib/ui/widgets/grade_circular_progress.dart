// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';

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
        center: Text('${grade * 100}  %',
            style: TextStyle(color: Colors.white, fontSize: 16 * ratio)),
        progressColor: Colors.red,
      ),
      progressColor: Colors.green,
    );
  }
}
