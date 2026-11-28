// Dart imports:
import 'dart:math';

// Package imports:
import 'package:material_ui/material_ui.dart';

// Project imports:
import 'package:notredame/ui/core/ui/navigation_menu/navigation_menu.dart';
import 'package:notredame/ui/dashboard/clipper/swoosh_clipper.dart';
import 'package:notredame/ui/dashboard/view_model/dashboard_viewmodel.dart';
import 'package:notredame/ui/dashboard/widgets/banner/dashboard_banner.dart';
import 'package:notredame/ui/dashboard/widgets/banner/dashboard_message.dart';
import 'package:notredame/ui/dashboard/widgets/cards/grades_card.dart';
import 'package:notredame/ui/dashboard/widgets/cards/progress_bar_card.dart';
import 'package:notredame/ui/dashboard/widgets/cards/schedule_card.dart';
import 'package:notredame/ui/dashboard/widgets/cards/session_reminder_card.dart';

class DashboardPhoneLandscapeLayout extends StatelessWidget {
  final DashboardViewModel model;
  final double viewportHeight;

  const DashboardPhoneLandscapeLayout({super.key, required this.model, required this.viewportHeight});

  static const double _titleTopPadding = 16.0;
  static const double _titleBottomPadding = 16.0;
  static const double _spacing = 12.0;
  static const double _minContentHeight = 220.0;

  @override
  Widget build(BuildContext context) {
    final double messageHeight = DashboardMessage.height(context);
    final double bottomPadding = _spacing + NavigationMenu.overlapHeight(context);
    final double height = max(viewportHeight, _titleTopPadding + messageHeight + _minContentHeight + bottomPadding);
    final double topPadding = MediaQuery.paddingOf(context).top;

    return SizedBox(
      height: height,
      child: SafeArea(
        left: false,
        bottom: false,
        child: Padding(
          padding: EdgeInsets.only(bottom: bottomPadding),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      top: -topPadding,
                      left: 0,
                      right: 0,
                      child: DashboardBanner(
                        model: model,
                        clipper: SwooshClipper(),
                        height: messageHeight + topPadding + _titleTopPadding + _titleBottomPadding,
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 24.0,
                            right: 32.0,
                            top: _titleTopPadding,
                            bottom: _titleBottomPadding,
                          ),
                          child: DashboardMessage(model: model, alignment: Alignment.centerLeft, widthFactor: 0.75),
                        ),
                        const SizedBox(height: _spacing),
                        Expanded(child: _content()),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(4.0, _spacing, _spacing, 0.0),
                child: IntrinsicWidth(
                  child: GradesCard(model: model.gradesModel, direction: Axis.vertical),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Session reminder and progress cards stacked on the left, schedule on the right.
  Widget _content() {
    return Padding(
      padding: const EdgeInsets.only(left: 24.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // At most 40% of the width available
          final double sideCardSize = min(
            (constraints.maxHeight - _spacing) / 2,
            (constraints.maxWidth - _spacing) / 2.5,
          );
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
                    SessionReminderCard(model: model.sessionReminderModel),
                    ProgressBarCard(model: model.progressBarModel),
                  ],
                ),
              ),
              Expanded(child: ScheduleCard(model: model.scheduleModel)),
            ],
          );
        },
      ),
    );
  }
}
