// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:notredame/features/student/grades/widgets/grade_circular_indicator.dart';

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
  State<GradeCircularProgress> createState() => _GradeCircularProgressState();
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
    return Stack(
      alignment: Alignment.center,
      children: [
        GradeCircularIndicator(
          grade: widget.averageGrade,
          color: Colors.red,
          size: 75,
          duration: 800,
          ratio: widget.ratio,
          completed: widget.completed,
        ),
        GradeCircularIndicator(
          grade: widget.studentGrade,
          color: animation.value ?? AppTheme.gradePassing,
          size: 95,
          duration: 1200,
          ratio: widget.ratio,
          completed: widget.completed,
        ),
        Text(
          getGrade(context),
          style: TextStyle(fontSize: 22 * widget.ratio),
        ),
      ],
    );
  }

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
