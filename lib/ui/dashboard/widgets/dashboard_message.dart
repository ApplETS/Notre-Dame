// Package imports:
import 'package:material_ui/material_ui.dart';
import 'package:skeletonizer/skeletonizer.dart';

// Project imports:
import 'package:notredame/ui/core/themes/app_palette.dart';
import 'package:notredame/ui/dashboard/view_model/dashboard_viewmodel.dart';
import 'package:notredame/ui/dashboard/widgets/broadcast_message_component.dart';

/// Animated message shown at the top of the dashboard: the broadcast message when one is active,
/// otherwise the dynamic message. Once loaded, it always takes the height of [maxLines] lines,
/// so the layout does not jump when the message changes.
class DashboardMessage extends StatelessWidget {
  static const double _fontSize = 16;
  static const double _lineHeight = 1.2;
  static const int maxLines = 2;

  final DashboardViewModel model;

  /// Alignment of the message in the available space.
  final AlignmentGeometry alignment;

  /// Fraction of the available width taken by the message. Takes all of it when null.
  final double? widthFactor;

  const DashboardMessage({super.key, required this.model, this.alignment = Alignment.center, this.widthFactor});

  static TextStyle get textStyle => TextStyle(fontSize: _fontSize, height: _lineHeight, color: AppPalette.grey.white);

  /// Height taken by [maxLines] lines of the message, taking the text scaling into account.
  static double height(BuildContext context) {
    final textPainter = TextPainter(
      text: TextSpan(text: "\n" * (maxLines - 1), style: textStyle),
      maxLines: maxLines,
      textDirection: TextDirection.ltr,
      textScaler: MediaQuery.textScalerOf(context),
    )..layout();
    final height = textPainter.height;
    textPainter.dispose();
    return height;
  }

  bool get _loading => model.busy(model.dynamicMessageText);

  @override
  Widget build(BuildContext context) {
    final Widget message = SizedBox(
      height: _loading ? null : height(context),
      child: Align(
        alignment: alignment,
        child: widthFactor == null
            ? _message(context)
            : FractionallySizedBox(widthFactor: widthFactor, child: _message(context)),
      ),
    );

    return AnimatedBuilder(
      animation: model.titleAnimation,
      builder: (context, child) => Transform.translate(
        offset: model.titleSlideOffset,
        child: Opacity(opacity: model.titleFadeOpacity, child: child),
      ),
      child: message,
    );
  }

  Widget _message(BuildContext context) {
    if (model.remoteConfigService.dashboardMessageActive) {
      return BroadcastMessageComponent(broadcastMessage: model.broadcastMessage, style: textStyle);
    }

    if (_loading) {
      return Skeletonizer(
        child: Bone.multiText(
          fontSize: MediaQuery.textScalerOf(context).scale(_fontSize),
          style: textStyle,
          lines: maxLines,
        ),
      );
    }

    return Text(
      model.dynamicMessageText ?? '',
      style: textStyle,
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.start,
    );
  }
}
