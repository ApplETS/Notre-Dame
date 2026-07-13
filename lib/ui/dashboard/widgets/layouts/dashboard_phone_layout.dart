// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:skeletonizer/skeletonizer.dart';

// Project imports:
import 'package:notredame/ui/core/themes/app_palette.dart';
import 'package:notredame/ui/core/ui/navigation_menu/navigation_menu.dart';
import 'package:notredame/ui/dashboard/view_model/dashboard_viewmodel.dart';
import 'package:notredame/ui/dashboard/widgets/broadcast_message_component.dart';
import 'package:notredame/ui/dashboard/widgets/cards/grades_card.dart';
import 'package:notredame/ui/dashboard/widgets/cards/progress_bar_card.dart';
import 'package:notredame/ui/dashboard/widgets/cards/schedule_card.dart';
import 'package:notredame/ui/dashboard/widgets/cards/session_reminder_card.dart';

class DashboardPhoneLayout extends StatefulWidget {
  final DashboardViewModel model;
  final double viewportHeight;

  const DashboardPhoneLayout({super.key, required this.model, required this.viewportHeight});

  @override
  State<DashboardPhoneLayout> createState() => _DashboardPhoneLayoutState();
}

class _DashboardPhoneLayoutState extends State<DashboardPhoneLayout> {
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
  void didUpdateWidget(DashboardPhoneLayout oldWidget) {
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

    const double fontSize = 16;
    const double lineHeight = 1.2;

    final textStyle = TextStyle(fontSize: fontSize, height: lineHeight, color: AppPalette.grey.white);

    const double twoLinesHeight = fontSize * lineHeight * 2;
    paddingUnderGrades = NavigationMenu.overlapHeight(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedBuilder(
          key: _titleKey,
          animation: widget.model.progressBarModel.titleAnimation,
          builder: (context, child) {
            return Padding(
              padding: const EdgeInsets.only(left: 32.0, right: 32.0, top: 80.0),
              child: Transform.translate(
                offset: widget.model.titleSlideOffset,
                child: Opacity(
                  opacity: widget.model.titleFadeOpacity,
                  child: SizedBox(
                    height: twoLinesHeight,
                    child: Center(
                      child: widget.model.remoteConfigService.dashboardMessageActive
                          ? BroadcastMessageComponent(broadcastMessage: widget.model.broadcastMessage, style: textStyle)
                          : widget.model.busy(widget.model.dynamicMessageText)
                          ? Skeletonizer(
                              child: Bone.multiText(fontSize: fontSize, style: textStyle, lines: 2),
                            )
                          : Text(
                              widget.model.dynamicMessageText ?? '',
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
        ),
        Container(
          key: _rowKey,
          padding: const EdgeInsets.fromLTRB(40.0, 16.0, 40.0, 0.0),
          child: Row(
            spacing: 18.0,
            children: [
              const Expanded(child: SessionReminderCard()),
              Expanded(
                child: ProgressBarCard(
                  // progressBarText: widget.model.sessionProgress?.daysRemaining.toString() ?? "XX",
                  // progressBarAltText: widget.model.sessionProgress != null
                  //     ? (widget.model.sessionProgress!.percentage * 100).toStringAsFixed(0)
                  //     : "XX%",
                  // progress: widget.model.sessionProgress?.percentage ?? 0.0,
                  // loading: widget.model.sessionProgress == null,
                  // showingPercentage: widget.model.showingPercentage,
                  // onToggle: widget.model.progressBarModel.toggleProgressBarMode,
                  progressBarText: widget.model.progressBarModel.sessionProgress?.daysRemaining.toString() ?? "XX",
                  progressBarAltText: widget.model.progressBarModel.sessionProgress != null
                      ? (widget.model.progressBarModel.sessionProgress!.percentage * 100).toStringAsFixed(0)
                      : "XX%",
                  progress: widget.model.progressBarModel.sessionProgress?.percentage ?? 0.0,
                  loading: widget.model.progressBarModel.sessionProgress == null,
                  showingPercentage: widget.model.progressBarModel.showingPercentage,
                  onToggle: widget.model.progressBarModel.toggleProgressBarMode,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(12.0, paddingAboveSchedule, 12.0, paddingUnderGrades),
          child: Column(
            spacing: spacingBetweenGradesAndSchedule,
            children: [
              if (_scheduleCardHeight != null) SizedBox(height: _scheduleCardHeight, child: const ScheduleCard()),
              GradesCard(
                key: _gradesCardKey,
                courses: widget.model.courses,
                loading: widget.model.busy(widget.model.courses),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
