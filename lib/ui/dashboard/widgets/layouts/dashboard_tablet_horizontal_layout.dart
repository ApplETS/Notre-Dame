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
import 'package:notredame/ui/dashboard/widgets/cards/schedule_card.dart';
import 'package:notredame/ui/dashboard/widgets/cards/session_reminder_card.dart';
import 'package:notredame/ui/dashboard/widgets/dashboard_banner.dart';
import 'package:notredame/ui/dashboard/widgets/dashboard_message.dart';

class DashboardTabletHorizontalLayout extends StatelessWidget {
  final DashboardViewModel model;
  final double viewportHeight;

  const DashboardTabletHorizontalLayout({super.key, required this.model, required this.viewportHeight});

  static const double _titleTopPadding = 24.0;
  static const double _titleBottomPadding = 24.0;

  static const double _circleHeight = 64.0;

  static const double _horizontalPadding = 32.0;
  static const double _spacing = 16.0;
  static const double _minContentHeight = 420.0;

  @override
  Widget build(BuildContext context) {
    final double messageHeight = DashboardMessage.height(context);
    final double bottomPadding = _spacing + NavigationMenu.overlapHeight(context);
    final double height = max(
      viewportHeight,
      _titleTopPadding + messageHeight + _titleBottomPadding + _minContentHeight + bottomPadding,
    );
    final double topPadding = MediaQuery.paddingOf(context).top;

    return SizedBox(
      height: height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          DashboardBanner(
            model: model,
            clipper: CircleClipper(),
            height: topPadding + _titleTopPadding + messageHeight + _titleBottomPadding + _circleHeight,
          ),
          SafeArea(
            left: false,
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: _spacing,
        children: [
          Expanded(child: ScheduleCard(model: model.scheduleModel)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: _spacing,
              children: [
                Expanded(child: _sideCards()),
                GradesCard(model: model.gradesModel),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Progress and session reminder cards stacked on the left, upcoming feature on the right.
  Widget _sideCards() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxSideCardSize = MediaQuery.of(context).size.width > 1000.0 ? 200.0 : 160.0;
        // Both cards are square, so the column width follows the available height.
        final double sideCardSize = min((constraints.maxHeight - _spacing) / 2, maxSideCardSize);
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
                  ProgressBarCard(model: model.progressBarModel),
                  SessionReminderCard(model: model.sessionReminderModel),
                ],
              ),
            ),
            const Expanded(child: Card(color: Colors.yellow)),
          ],
        );
      },
    );
  }
}
