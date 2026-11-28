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

class DashboardPhoneVerticalLayout extends StatelessWidget {
  final DashboardViewModel model;
  final double viewportHeight;

  const DashboardPhoneVerticalLayout({super.key, required this.model, required this.viewportHeight});

  static const double _cardsRowTopPadding = 16.0;
  static const double _cardsRowMaxHeight = 200.0;
  static const double _cardsRowHorizontalPadding = 40.0;
  static const double _cardsRowSpacing = 18.0;
  static const double _spacing = 6.0;
  static const double _circleHeight = 200.0;

  static const double _minContentHeight = 600.0;

  @override
  Widget build(BuildContext context) {
    final double messageHeight = DashboardMessage.height(context);
    final double bottomPadding = NavigationMenu.overlapHeight(context);
    final double topPadding = MediaQuery.paddingOf(context).top;

    // The side cards are square: the row is as tall as one card, capped by the row's max height.
    final double cardWidth = (MediaQuery.sizeOf(context).width - 2 * _cardsRowHorizontalPadding - _cardsRowSpacing) / 2;
    final double cardsRowHeight = min(cardWidth, _cardsRowMaxHeight - _cardsRowTopPadding);

    // 1/3 of the card row overlaps the red circle
    double titleTopPadding = max(
      0.0,
      _circleHeight - (messageHeight + topPadding + cardsRowHeight * (1 / 3) + _cardsRowTopPadding),
    );

    double height = max(
      viewportHeight,
      topPadding + titleTopPadding + messageHeight + _minContentHeight + bottomPadding,
    );

    // Viewport is too small to display without scrolling
    if (height > viewportHeight) {
      // We remove 1/3 of card row height in the top padding leave more space for the content
      titleTopPadding = max(0.0, titleTopPadding - cardsRowHeight * (1 / 3));
      height = max(viewportHeight, topPadding + titleTopPadding + messageHeight + _minContentHeight + bottomPadding);
    }

    return SizedBox(
      height: height,
      child: Stack(
        children: [
          DashboardBanner(model: model, clipper: CircleClipper(), height: _circleHeight),
          SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 32.0, right: 32.0, top: titleTopPadding),
                  child: DashboardMessage(model: model),
                ),
                Container(
                  constraints: const BoxConstraints(maxHeight: _cardsRowMaxHeight),
                  padding: const EdgeInsets.fromLTRB(
                    _cardsRowHorizontalPadding,
                    _cardsRowTopPadding,
                    _cardsRowHorizontalPadding,
                    0.0,
                  ),
                  child: Row(
                    spacing: _cardsRowSpacing,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Expanded(child: SessionReminderCard(model: model.sessionReminderModel)),
                      Expanded(child: ProgressBarCard(model: model.progressBarModel)),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(12.0, _spacing, 12.0, bottomPadding),
                    child: Column(
                      spacing: _spacing,
                      children: [
                        Expanded(child: ScheduleCard(model: model.scheduleModel)),
                        GradesCard(model: model.gradesModel),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
