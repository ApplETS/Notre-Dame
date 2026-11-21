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
import 'package:notredame/ui/dashboard/widgets/grades_card.dart';
import 'package:notredame/ui/dashboard/widgets/progress_bar_card.dart';
import 'package:notredame/ui/dashboard/widgets/session_reminder_card.dart';

class DashboardPhoneHorizontalLayout extends StatelessWidget {
  final DashboardViewModel model;
  final double viewportHeight;

  const DashboardPhoneHorizontalLayout({super.key, required this.model, required this.viewportHeight});

  static const double _fontSize = 16;
  static const double _lineHeight = 1.2;
  static const double _titleTopPadding = 20.0;
  static const double _spacing = 12.0;
  static const double _bannerWidthFactor = 0.78;
  static const double _minContentHeight = 220.0;

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(fontSize: _fontSize, height: _lineHeight, color: AppPalette.grey.white);
    const double twoLinesHeight = _fontSize * _lineHeight * 2;

    final double bottomPadding = max(_spacing, NavigationMenu.overlapHeight(context));
    final double height = max(viewportHeight, _titleTopPadding + twoLinesHeight + _minContentHeight + bottomPadding);

    return SizedBox(
      height: height,
      child: Stack(
        children: [
          _redBanner(),
          SafeArea(
            left: false,
            top: false,
            bottom: false,
            child: Padding(
              padding: EdgeInsets.only(bottom: bottomPadding),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _title(textStyle, twoLinesHeight),
                        const SizedBox(height: _spacing),
                        Expanded(child: _content()),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(4.0, _spacing, _spacing, 0.0),
                    child: Expanded(
                      child: GradesCard(
                        courses: model.courses,
                        loading: model.busy(model.courses),
                        direction: Axis.vertical,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _title(TextStyle textStyle, double twoLinesHeight) {
    return AnimatedBuilder(
      animation: model.titleAnimation,
      builder: (context, child) {
        return Padding(
          padding: const EdgeInsets.only(left: 32.0, right: 32.0, top: _titleTopPadding),
          child: Transform.translate(
            offset: model.titleSlideOffset,
            child: Opacity(
              opacity: model.titleFadeOpacity,
              child: SizedBox(
                height: twoLinesHeight,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: model.remoteConfigService.dashboardMessageActive
                      ? BroadcastMessageComponent(broadcastMessage: model.broadcastMessage, style: textStyle)
                      : model.busy(model.dynamicMessageText)
                      ? Skeletonizer(
                          child: Bone.multiText(fontSize: _fontSize, style: textStyle, lines: 2),
                        )
                      : Text(
                          model.dynamicMessageText ?? '',
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
                      progressBarText: model.sessionProgress?.daysRemaining.toString() ?? "XX",
                      progressBarAltText: model.sessionProgress != null
                          ? (model.sessionProgress!.percentage * 100).toStringAsFixed(0)
                          : "XX%",
                      progress: model.sessionProgress?.percentage ?? 0.0,
                      loading: model.sessionProgress == null,
                      showingPercentage: model.showingPercentage,
                      onToggle: model.toggleProgressBarMode,
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
  Widget _redBanner() {
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
              // TODO ajust
              child: SizedBox(height: 80 * model.heightAnimation.value),
            ),
          );
        },
      ),
    );
  }
}
