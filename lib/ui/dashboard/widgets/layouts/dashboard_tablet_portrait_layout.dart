// Dart imports:
import 'dart:math';

// Package imports:
import 'package:material_ui/material_ui.dart';

// Project imports:
import 'package:notredame/ui/core/ui/navigation_menu/navigation_menu.dart';
import 'package:notredame/ui/dashboard/clipper/circle_clipper.dart';
import 'package:notredame/ui/dashboard/view_model/dashboard_viewmodel.dart';
import 'package:notredame/ui/dashboard/widgets/cards/grades_card.dart';
import 'package:notredame/ui/dashboard/widgets/cards/progress_bar_card.dart';
import 'package:notredame/ui/dashboard/widgets/cards/quick_links_card.dart';
import 'package:notredame/ui/dashboard/widgets/cards/schedule_card.dart';
import 'package:notredame/ui/dashboard/widgets/cards/session_reminder_card.dart';
import 'package:notredame/ui/dashboard/widgets/dashboard_banner.dart';
import 'package:notredame/ui/dashboard/widgets/dashboard_message.dart';

class DashboardTabletPortraitLayout extends StatelessWidget {
  final DashboardViewModel model;
  final double viewportHeight;

  const DashboardTabletPortraitLayout({super.key, required this.model, required this.viewportHeight});

  static const double _titleTopPadding = 24.0;
  static const double _titleBottomPadding = 24.0;

  static const double _circleHeight = 64.0;

  static const double _horizontalPadding = 32.0;
  static const double _spacing = 16.0;
  static const double _minContentHeight = 500.0;

  @override
  Widget build(BuildContext context) {
    final double messageHeight = DashboardMessage.height(context);
    final double bottomPadding = _spacing + NavigationMenu.overlapHeight(context);
    final double height = max(
      viewportHeight,
      _titleTopPadding + messageHeight + _titleBottomPadding + _circleHeight + _minContentHeight + bottomPadding,
    );
    final double topPadding = MediaQuery.paddingOf(context).top;

    return SizedBox(
      height: height,
      child: Stack(
        children: [
          DashboardBanner(
            model: model,
            clipper: CircleClipper(),
            height: topPadding + _titleTopPadding + messageHeight + _titleBottomPadding + _circleHeight,
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.only(bottom: bottomPadding),
              child: Column(
                spacing: _spacing,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      _horizontalPadding,
                      _titleTopPadding,
                      _horizontalPadding,
                      _titleBottomPadding,
                    ),
                    child: DashboardMessage(model: model),
                  ),
                  Expanded(child: _content()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _content() {
    return Padding(
      padding: const EdgeInsets.only(left: _horizontalPadding, right: _horizontalPadding, top: _circleHeight),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double sideCardSize = min(constraints.maxWidth * 0.25, 180.0);
          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: _spacing,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: _spacing,
                  children: [
                    Expanded(child: ScheduleCard(model: model.scheduleModel)),
                    GradesCard(model: model.gradesModel),
                  ],
                ),
              ),
              SizedBox(width: sideCardSize, child: _sideCards()),
            ],
          );
        },
      ),
    );
  }

  /// Progress and session reminder cards stacked above the upcoming feature.
  Widget _sideCards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: _spacing,
      children: [
        ProgressBarCard(model: model.progressBarModel),
        SessionReminderCard(model: model.sessionReminderModel),
        const Expanded(child: QuickLinksCard()),
      ],
    );
  }
}
