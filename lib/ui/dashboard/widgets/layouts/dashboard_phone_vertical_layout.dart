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

class DashboardPhoneVerticalLayout extends StatefulWidget {
  final DashboardViewModel model;
  final double viewportHeight;

  const DashboardPhoneVerticalLayout({super.key, required this.model, required this.viewportHeight});

  @override
  State<DashboardPhoneVerticalLayout> createState() => _DashboardPhoneVerticalLayoutState();
}

class _DashboardPhoneVerticalLayoutState extends State<DashboardPhoneVerticalLayout> {
  final GlobalKey _titleKey = GlobalKey();
  final GlobalKey _rowKey = GlobalKey();
  final GlobalKey _gradesCardKey = GlobalKey();

  final double paddingAboveSchedule = 6.0;
  final double spacingBetweenGradesAndSchedule = 6.0;
  late double paddingUnderGrades;

  double? _scheduleCardHeight;

  @override
  void initState() {
    super.initState();
    _schedulePostFrameUpdate();
  }

  @override
  void didUpdateWidget(DashboardPhoneVerticalLayout oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.viewportHeight != widget.viewportHeight) {
      _schedulePostFrameUpdate();
    }
  }

  void _schedulePostFrameUpdate() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _updateScheduleCardHeight(widget.viewportHeight);
    });
  }

  void _updateScheduleCardHeight(double viewportHeight) {
    final titleHeight = _titleKey.currentContext?.size?.height ?? 0;
    final cardsRowHeight = _rowKey.currentContext?.size?.height ?? 0;
    final gradesCardHeight = _gradesCardKey.currentContext?.size?.height ?? 0;

    final totalFixed =
        titleHeight +
        cardsRowHeight +
        gradesCardHeight +
        paddingAboveSchedule +
        paddingUnderGrades +
        spacingBetweenGradesAndSchedule;

    final remaining = viewportHeight - totalFixed;
    final scheduleHeight = max(250.0, remaining);

    if (scheduleHeight != _scheduleCardHeight) {
      setState(() => _scheduleCardHeight = scheduleHeight);
    }
  }

  @override
  Widget build(BuildContext context) {
    _schedulePostFrameUpdate();

    paddingUnderGrades = NavigationMenu.overlapHeight(context);

    return Stack(
      children: [
        DashboardBanner(model: widget.model, clipper: CircleClipper(), height: 240),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              key: _titleKey,
              padding: const EdgeInsets.only(left: 32.0, right: 32.0, top: 80.0),
              child: DashboardMessage(model: widget.model),
            ),
            Container(
              key: _rowKey,
              constraints: const BoxConstraints(maxHeight: 200),
              padding: const EdgeInsets.fromLTRB(40.0, 16.0, 40.0, 0.0),
              child: Row(
                spacing: 18.0,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(child: SessionReminderCard(model: widget.model.sessionReminderModel)),
                  Expanded(child: ProgressBarCard(model: widget.model.progressBarModel)),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(12.0, paddingAboveSchedule, 12.0, paddingUnderGrades),
              child: Column(
                spacing: spacingBetweenGradesAndSchedule,
                children: [
                  if (_scheduleCardHeight != null)
                    SizedBox(
                      height: _scheduleCardHeight,
                      child: ScheduleCard(model: widget.model.scheduleModel),
                    ),
                  GradesCard(key: _gradesCardKey, model: widget.model.gradesModel),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
