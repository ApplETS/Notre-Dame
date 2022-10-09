// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';

// UTILS
import 'package:notredame/ui/utils/app_theme.dart';

// OTHERS
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class GradeCircularProgress extends StatefulWidget {
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
  _GradeCircularProgressState createState() => _GradeCircularProgressState();
}

class _GradeCircularProgressState extends State<GradeCircularProgress>
    with TickerProviderStateMixin {
  AnimationController _controller;
  Animation<Color> animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1100),
      vsync: this,
    );

    _controller.forward();

    animation = ColorTween(
      begin: AppTheme.gradeFailureMin,
      end: gradePercentageColor(widget.studentGrade ?? 0.0),
    ).animate(_controller)
      ..addListener(() {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CircularPercentIndicator(
      animation: true,
      animationDuration: 1100,
      radius: 100 * widget.ratio,
      lineWidth: 8.0 * widget.ratio,
      percent:
          widget.completed ? getGradeInDecimals(widget.studentGrade ?? 0.0) : 0,
      circularStrokeCap: CircularStrokeCap.round,
      center: CircularPercentIndicator(
        animation: true,
        animationDuration: 700,
        radius: 80 * widget.ratio,
        lineWidth: 8.0 * widget.ratio,
        percent: widget.completed
            ? getGradeInDecimals(widget.averageGrade ?? 0.0)
            : 0,
        circularStrokeCap: CircularStrokeCap.round,
        center: Text(
          getGrade(context),
          style: TextStyle(fontSize: 22 * widget.ratio),
        ),
        progressColor: Colors.red,
      ),
      progressColor: animation.value,
    );
  }

  double getGradeInDecimals(double grade) =>
      (grade / 100) > 1.0 ? 1.0 : (grade / 100);

  String getGrade(BuildContext context) {
    if (widget.finalGrade != null) {
      return widget.finalGrade;
    }

    if (widget.studentGrade != null) {
      return AppIntl.of(context)
          .grades_grade_in_percentage(widget.studentGrade.round());
    }

    return AppIntl.of(context).grades_not_available;
  }

  Color gradePercentageColor(double gradePercentage) {
    const double passingGrade = 50.0;
    const double minGoodGrade = 80.0;
    const double maxGrade = 100.0;

    Color startColor;
    Color endColor;
    double colorProportion = gradePercentage;

    if (gradePercentage >= 0 && gradePercentage <= passingGrade) {
      startColor = AppTheme.gradeFailureMin;
      endColor = AppTheme.gradeFailureMax;
      colorProportion /= passingGrade;
    } else if (gradePercentage > passingGrade &&
        gradePercentage <= minGoodGrade) {
      startColor = AppTheme.gradePassing;
      endColor = AppTheme.gradeGoodMin;
      colorProportion -= passingGrade;
      colorProportion /= minGoodGrade - passingGrade;
    } else {
      startColor = AppTheme.gradeGoodMin;
      endColor = AppTheme.gradeGoodMax;

      if (colorProportion >= maxGrade) {
        colorProportion = 1;
      } else {
        colorProportion -= minGoodGrade;
        colorProportion /= maxGrade - minGoodGrade;
      }
    }

    return Color.lerp(startColor, endColor, colorProportion);
  }
}
