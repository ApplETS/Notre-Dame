// Dart imports:
import 'dart:math';

// Package imports:
import 'package:material_ui/material_ui.dart';
import 'package:skeletonizer/skeletonizer.dart';

// Project imports:
import 'package:notredame/ui/core/themes/app_palette.dart';
import 'package:notredame/ui/core/ui/navigation_menu/navigation_menu.dart';
import 'package:notredame/ui/dashboard/clipper/swoosh_clipper.dart';
import 'package:notredame/ui/dashboard/view_model/dashboard_viewmodel.dart';
import 'package:notredame/ui/dashboard/widgets/broadcast_message_component.dart';
import 'package:notredame/ui/dashboard/widgets/cards/schedule_card.dart';
import 'package:notredame/ui/dashboard/widgets/cards/grades_card.dart';
import 'package:notredame/ui/dashboard/widgets/cards/progress_bar_card.dart';
import 'package:notredame/ui/dashboard/widgets/cards/session_reminder_card.dart';

class DashboardPhoneHorizontalLayout extends StatelessWidget {
  final DashboardViewModel model;
  final double viewportHeight;

  const DashboardPhoneHorizontalLayout({super.key, required this.model, required this.viewportHeight});

  static const double _fontSize = 16;
  static const double _lineHeight = 1.2;
  static const double _titleTopPadding = 16.0;
  static const double _titleBottomPadding = 16.0;
  static const double _spacing = 12.0;
  static const double _bannerWidthFactor = 0.78;
  static const double _minContentHeight = 220.0;

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(fontSize: _fontSize, height: _lineHeight, color: AppPalette.grey.white);

    // Used to get the dimensions of the dynamic message.
    final textPainter = TextPainter(
      text: TextSpan(text: "\n", style: textStyle),
      maxLines: 2,
      textDirection: TextDirection.ltr,
      textScaler: MediaQuery.of(context).textScaler,
    );

    textPainter.layout();

    final double bottomPadding = _spacing + NavigationMenu.overlapHeight(context);
    final double height = max(
      viewportHeight,
      _titleTopPadding + textPainter.height + _minContentHeight + bottomPadding,
    );

    return SizedBox(
      height: height,
      child: Stack(
        children: [
          _redBanner(textPainter.height + MediaQuery.of(context).padding.top + _titleTopPadding + _titleBottomPadding),
          SafeArea(
            left: false,
            child: Padding(
              padding: EdgeInsets.only(bottom: bottomPadding),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _title(textStyle, model.busy(model.dynamicMessageText) ? null : textPainter.height),
                        const SizedBox(height: _spacing),
                        Expanded(child: _content()),
                      ],
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(4.0, _spacing, _spacing, 0.0),
                    child: GradesCard(direction: Axis.vertical),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _title(TextStyle textStyle, double? twoLinesHeight) {
    return AnimatedBuilder(
      animation: model.titleAnimation,
      builder: (context, child) {
        return Padding(
          padding: const EdgeInsets.only(left: 24.0, right: 32.0, top: _titleTopPadding, bottom: _titleBottomPadding),
          child: Transform.translate(
            offset: model.titleSlideOffset,
            child: Opacity(
              opacity: model.titleFadeOpacity,
              child: Align(
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: 0.75,
                  child: model.remoteConfigService.dashboardMessageActive
                      ? BroadcastMessageComponent(broadcastMessage: model.broadcastMessage, style: textStyle)
                      : model.busy(model.dynamicMessageText)
                      ? Skeletonizer(
                          child: Bone.multiText(fontSize: _fontSize, style: textStyle, lines: 1),
                        )
                      : Text(
                          // model.dynamicMessageText ?? '',
                          "dsfskljdhfladsadklfdsjklfkdjlsafdjklasfdsfskljdhfladsadklfdsjklfkdjlsafdjklasfdsfskljdhfladsadklfdsjklfkdjlsafdjklasfdsfskljdhfladsadklfdsjklfkdjlsafdjklasfdsfskljdhfladsadklfdsjklfkdjlsafdjklasf",
                          style: textStyle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.start,
                        ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Session reminder and progress cards stacked on the left, schedule on the right.
  Widget _content() {
    return Padding(
      padding: const EdgeInsets.only(left: 24.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Both cards are square, so the column width follows the available height.
          final double sideCardSize = min((constraints.maxHeight - _spacing) / 2, 180);
          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: _spacing,
            children: [
              SizedBox(
                width: sideCardSize,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: _spacing,
                  children: [
                    const SessionReminderCard(),
                    ProgressBarCard(
                      progressBarText: model.progressBarModel.sessionProgress?.daysRemaining.toString() ?? "XX",
                      progressBarAltText: model.progressBarModel.sessionProgress != null
                          ? (model.progressBarModel.sessionProgress!.percentage * 100).toStringAsFixed(0)
                          : "XX%",
                      progress: model.progressBarModel.sessionProgress?.percentage ?? 0.0,
                      loading: model.progressBarModel.sessionProgress == null,
                      showingPercentage: model.progressBarModel.showingPercentage,
                      onToggle: model.progressBarModel.toggleProgressBarMode,
                    ),
                  ],
                ),
              ),
              const Expanded(child: ScheduleCard()),
            ],
          );
        },
      ),
    );
  }

  /// Animated red banner behind the dynamic message
  Widget _redBanner(double height) {
    return FractionallySizedBox(
      alignment: Alignment.topLeft,
      widthFactor: _bannerWidthFactor,
      child: AnimatedBuilder(
        animation: model.heightAnimation,
        builder: (context, child) {
          return Opacity(
            opacity: model.opacityAnimation.value,
            child: PhysicalShape(
              clipper: SwooshClipper(),
              elevation: 4.0,
              color: model.remoteConfigService.dashboardMessageActive
                  ? model.broadcastMessage!.color
                  : AppPalette.etsLightRed,
              child: SizedBox(height: height * model.heightAnimation.value),
            ),
          );
        },
      ),
    );
  }
}
