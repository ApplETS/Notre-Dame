// Flutter imports:
import 'package:flutter/material.dart';

class GradeCircularIndicator extends StatelessWidget {
  final double? grade;
  final Color color;
  final double size;
  final int duration;
  final double ratio;
  final bool completed;

  const GradeCircularIndicator({
    super.key,
    required this.grade,
    required this.color,
    required this.size,
    required this.duration,
    required this.ratio,
    required this.completed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size * ratio,
      height: size * ratio,
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(
          begin: 0.0,
          end: completed ? _getGradeInDecimals(grade ?? 0.0) : 0.0,
        ),
        duration: Duration(milliseconds: duration),
        curve: Curves.easeOut,
        builder: (_, value, __) => CircularProgressIndicator(
          value: value,
          strokeWidth: 8.0 * ratio,
          strokeCap: StrokeCap.round,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      ),
    );
  }

  double _getGradeInDecimals(double grade) =>
      (grade / 100) > 1.0 ? 1.0 : (grade / 100);
}
