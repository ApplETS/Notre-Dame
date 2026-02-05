// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:notredame/ui/dashboard/services/dynamic_messages_service.dart';

// Package imports:
import 'package:skeletonizer/skeletonizer.dart';

// Project imports:
import 'package:notredame/l10n/app_localizations.dart';

class ProgressBarCard extends StatefulWidget {
  final String progressBarText;
  final double progress;
  final bool loading;

  const ProgressBarCard({super.key, required this.progressBarText, required this.progress, required this.loading});

  @override
  State<ProgressBarCard> createState() => _ProgressBarCardState();
}

class _ProgressBarCardState extends State<ProgressBarCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  final TextStyle smallTextStyle = TextStyle(fontSize: 18, height: 1);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 500), vsync: this);

    _animation = Tween<double>(
      begin: 0,
      end: widget.progress,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant ProgressBarCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _animation = Tween<double>(
        begin: _animation.value,
        end: widget.progress,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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
            if (widget.loading || widget.progress >= 0.0)
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  LayoutBuilder(
                    builder: (BuildContext context, BoxConstraints constraints) {
                      final textPainter = TextPainter(
                        text: TextSpan(text: AppIntl.of(context)!.progress_bar, style: smallTextStyle),
                        textDirection: TextDirection.ltr,
                      )..layout();
                      double size = constraints.maxWidth - textPainter.height - 12;
                      return Transform.translate(
                        offset: const Offset(0, -12),
                        child: Transform.scale(
                          scale: size / 100,
                          alignment: Alignment.bottomRight,
                          child: AnimatedBuilder(
                            animation: _animation,
                            builder: (context, child) => _progress(_animation.value),
                          ),
                        ),
                      );
                    },
                  ),
                  Text(AppIntl.of(context)!.progress_bar, style: smallTextStyle),
                ],
              )
            else
              Expanded(child: Center(child: Text(AppIntl.of(context)!.session_without))),
          ],
        ),
      ),
    ),
  );

  Widget _progress(double animatedProgress) => Transform.rotate(
    angle: -pi / 5,
    child: CustomPaint(
      painter: _CircularProgressPainter(animatedProgress),
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
                offset: const Offset(5, 60),
                child: FittedBox(
                  alignment: Alignment.centerRight,
                  fit: BoxFit.scaleDown,
                  child: widget.loading
                      ? Skeletonizer(
                          enabled: true,
                          child: Bone(height: 32, width: 40, borderRadius: BorderRadius.circular(10)),
                        )
                      : Text(
                          widget.progressBarText,
                          style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, height: 1),
                        ),
                ),
              ),
            ),
          ),
        ),
<<<<<<< HEAD

        FutureBuilder<String>(
          future: DynamicMessagesService(AppIntl.of(context)!).getDynamicMessage(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(padding: EdgeInsets.fromLTRB(17, 10, 17, 0), child: LinearProgressIndicator());
            }
            if (snapshot.hasError || (snapshot.data?.isEmpty ?? true)) {
              return const SizedBox.shrink();
            }

            return Padding(
              padding: const EdgeInsets.fromLTRB(17, 10, 17, 0),
              child: Text(snapshot.data!, style: Theme.of(context).textTheme.bodyMedium),
            );
          },
        ),

        if (loading || progress >= 0.0)
          Skeletonizer(
            enabled: loading,
            ignoreContainers: true,
            child: Stack(
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(17, 10, 15, 20),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                    child: GestureDetector(
                      onTap: () => changeProgressBarText(),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 30,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppPalette.gradeGoodMax),
                        backgroundColor: AppPalette.grey.darkGrey,
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => changeProgressBarText(),
                  child: Container(
                    padding: const EdgeInsets.only(top: 16),
                    child: Center(
                      child: Text(progressBarText, style: const TextStyle(color: Colors.white)),
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          Container(
            padding: const EdgeInsets.all(16),
            child: Center(child: Text(AppIntl.of(context)!.session_without)),
          ),
      ],
=======
      ),
>>>>>>> v5
    ),
  );
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
    final double sweepAngle = pi + 2 * pi / 4 + pi / 20;
    final double progressSweep = sweepAngle * value;

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
      ).createShader(Rect.fromCircle(center: Offset(radius, radius), radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), startAngle, sweepAngle, false, backgroundPaint);

    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), startAngle, progressSweep, false, foregroundPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
