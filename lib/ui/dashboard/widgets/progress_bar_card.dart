// Flutter imports:
import 'dart:math';

import 'package:flutter/material.dart';

// Project imports:
import 'package:notredame/l10n/app_localizations.dart';

class ProgressBarCard extends StatelessWidget {
  final String progressBarText;
  final double progress;
  final bool loading;
  final TextStyle smallTextStyle = TextStyle(fontSize: 18, height: 1);

  ProgressBarCard({super.key, required this.progressBarText, required this.progress, required this.loading});

  @override
  Widget build(BuildContext context) => AspectRatio(
    aspectRatio: 1,
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (loading || progress >= 0.0)
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  LayoutBuilder(
                    builder: (BuildContext context, BoxConstraints constraints) {
                      final textPainter = TextPainter(
                        text: TextSpan(text: "jours restants", style: smallTextStyle),
                        textDirection: TextDirection.ltr,
                      )..layout();
                      double size = constraints.maxWidth - textPainter.height - 12;
                      return Transform.translate(
                        offset: Offset(0, -12),
                        child: Transform.scale(scale: size / 100, alignment: Alignment.bottomRight, child: _progress()),
                      );
                    },
                  ),
                  Text("jours restants", style: smallTextStyle),
                ],
              )
            else
              Container(
                padding: const EdgeInsets.all(16),
                child: Center(child: Text(AppIntl.of(context)!.session_without)),
              ),
          ],
        ),
      ),
    ),
  );

  Widget _progress() {
    return Transform.rotate(
      angle: -pi / 5,
      child: CustomPaint(
        painter: _CircularProgressPainter(progress * 100),
        child: SizedBox(
          width: 100,
          height: 100,
          child: Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
              width: 40,
              height: 32,
              child: Transform.rotate(
                angle: pi / 5,
                child: Transform.translate(
                  offset: Offset(5, 60),
                  child: FittedBox(
                    alignment: Alignment.centerRight,
                    fit: BoxFit.scaleDown,
                    child: Text(
                      progressBarText,
                      style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, height: 1),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CircularProgressPainter extends CustomPainter {
  final double value;

  _CircularProgressPainter(this.value);

  @override
  void paint(Canvas canvas, Size size) {
    final double strokeWidth = 12;
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double radius = (size.width / 2) - strokeWidth / 2;
    final double startAngle = pi - pi / 4;
    final double sweepAngle = pi + 2 * pi / 4;
    final double progressSweep = sweepAngle * (value / 100);

    // Paint background (gray)
    final backgroundPaint = Paint()
      ..color = Colors.black54
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Paint foreground (green)
    final foregroundPaint = Paint()
      ..shader = RadialGradient(
        colors: [Colors.lightGreen.withAlpha(0), Colors.green],
      ).createShader(Rect.fromCircle(center: Offset(radius - 2, radius), radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), startAngle, sweepAngle, false, backgroundPaint);

    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), startAngle, progressSweep, false, foregroundPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
