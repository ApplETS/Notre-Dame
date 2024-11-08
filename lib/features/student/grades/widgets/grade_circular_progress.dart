// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// Project imports:
import 'package:notredame/utils/app_theme.dart';

class GradeCircularProgress extends StatefulWidget {
  final bool completed;
  final String? finalGrade;
  final double? studentGrade;
  final double? averageGrade;
  final double ratio;

  const GradeCircularProgress(this.ratio,
      {super.key,
      this.completed = false,
      this.finalGrade,
      this.studentGrade,
      this.averageGrade});

  @override
  _GradeCircularProgressState createState() => _GradeCircularProgressState();
}

class _GradeCircularProgressState extends State<GradeCircularProgress>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> animation;

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
    Widget buildProgressIndicator(
        double? grade, Color color, double size, int duration) {
      return SizedBox(
        width: size * widget.ratio,
        height: size * widget.ratio,
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(
            begin: 0.0,
            end: widget.completed ? getGradeInDecimals(grade ?? 0.0) : 0.0,
          ),
          duration: Duration(milliseconds: duration),
          builder: (_, value, __) => CircularProgressIndicator(
            value: value,
            strokeWidth: 8.0 * widget.ratio,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      );
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        buildProgressIndicator(
            widget.studentGrade, animation.value ?? Colors.blue, 100, 1100),
        buildProgressIndicator(widget.averageGrade, Colors.red, 80, 700),
        Text(
          getGrade(context),
          style: TextStyle(fontSize: 22 * widget.ratio),
        ),
      ],
    );
  }

  double getGradeInDecimals(double grade) =>
      (grade / 100) > 1.0 ? 1.0 : (grade / 100);

  String getGrade(BuildContext context) {
    if (widget.finalGrade != null) {
      return widget.finalGrade!;
    }

    if (widget.studentGrade != null) {
      return AppIntl.of(context)!
          .grades_grade_in_percentage(widget.studentGrade!.round());
    }

    return AppIntl.of(context)!.grades_not_available;
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

    return Color.lerp(startColor, endColor, colorProportion)!;
  }
}
