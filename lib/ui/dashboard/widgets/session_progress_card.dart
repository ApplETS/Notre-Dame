// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:auto_size_text/auto_size_text.dart';
import 'package:notredame/ui/dashboard/view_model/cards/session_progress_viewmodel.dart';
import 'package:skeletonizer/skeletonizer.dart';

// Project imports:
import 'package:notredame/l10n/app_localizations.dart';
import 'package:stacked/stacked.dart';
import '../../core/themes/app_theme.dart';

class SessionProgressCard extends StatefulWidget {
  const SessionProgressCard({super.key});

  @override
  State<SessionProgressCard> createState() => _SessionProgressCardState();
}

class _SessionProgressCardState extends State<SessionProgressCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ViewModelBuilder<SessionProgressViewmodel>.reactive(
    viewModelBuilder: () => SessionProgressViewmodel(intl: AppIntl.of(context)!),
    onViewModelReady: (model) {
      _controller = AnimationController(duration: const Duration(milliseconds: 500), vsync: this);

      _animation = Tween<double>(
        begin: 0,
        end: model.sessionProgress ?? 0.0,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

      _controller.forward();
    },
    builder: (context, model, child) {
      if (!model.isBusy && model.sessionProgress != null) {
        _updateAnimation(model.sessionProgress!);
      }
      return AspectRatio(
        aspectRatio: 1,
        child: Card(
          color: context.theme.appColors.dashboardCard,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
          child: model.isBusy || !model.hasSession || model.sessionProgress == 0.0
              ? Center(child: Text(AppIntl.of(context)!.session_without, textAlign: TextAlign.center))
              : Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  spacing: 12.0,
                  children: [
                    Expanded(
                      child: LayoutBuilder(
                        builder: (BuildContext context, BoxConstraints constraints) {
                          double size = constraints.maxHeight;
                          return Transform.scale(
                            scale: size / 100,
                            alignment: Alignment.centerRight,
                            child: AnimatedBuilder(
                              animation: _animation,
                              builder: (context, child) => _progress(_animation.value, model.daysRemaining, loading: model.isBusy),
                            ),
                          );
                        },
                      ),
                    ),
                    AutoSizeText(
                      AppIntl.of(context)!.progress_bar,
                      style: TextStyle(fontSize: 18, height: 1),
                      maxLines: 1,
                    ),
                  ],
                ),
        ),
      ),
    );
  });

  void _updateAnimation(double progress) {
    if (_animation.value == progress) return;

    _animation = Tween<double>(
      begin: _animation.value,
      end: progress,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller
      ..reset()
      ..forward();
  }

  Widget _progress(double animatedProgress, int? daysRemaining, {bool loading = false}) => Transform.rotate(
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
                  child: Skeletonizer(
                    enabled: loading,
                    child: Text(
                      daysRemaining?.toString() ?? "XX",
                      style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, height: 1),
                    ),
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
