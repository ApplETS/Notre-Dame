// Flutter imports:
import 'dart:math';

import 'package:flutter/material.dart';

// Package imports:
import 'package:stacked/stacked.dart';

// Project imports:
import 'package:notredame/l10n/app_localizations.dart';
import 'package:notredame/ui/core/themes/app_palette.dart';
import 'package:notredame/ui/core/ui/base_scaffold.dart';
import 'package:notredame/ui/dashboard/clipper/circle_clipper.dart';
import 'package:notredame/ui/dashboard/view_model/dashboard_viewmodel.dart';
import 'package:notredame/ui/dashboard/widgets/grades_card.dart';
import 'package:notredame/ui/dashboard/widgets/progress_bar_card.dart';
import 'package:notredame/ui/dashboard/widgets/cards/schedule_card.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> with SingleTickerProviderStateMixin {
  // Keys to measure dynamic widgets
  final GlobalKey _titleKey = GlobalKey();
  final GlobalKey _rowKey = GlobalKey();
  final GlobalKey _gradesCardKey = GlobalKey();

  double? _scheduleCardHeight;

  @override
  void initState() {
    super.initState();
    DashboardViewModel.launchInAppReview();
  }

  void _updateScheduleCardHeight(double viewportHeight) {
    final titleHeight = _titleKey.currentContext!.size!.height;
    final cardsRowHeight = _rowKey.currentContext!.size!.height;
    final gradesCardHeight = _gradesCardKey.currentContext!.size!.height;
    final totalFixed = titleHeight + cardsRowHeight + gradesCardHeight + 44.0; // TODO fix magic number. Spacing + top + bottom

    final remaining = viewportHeight - totalFixed;
    final scheduleHeight = max(250.0, remaining);

    if (scheduleHeight != _scheduleCardHeight) {
      setState(() => _scheduleCardHeight = scheduleHeight);
    }
  }
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<DashboardViewModel>.reactive(
      viewModelBuilder: () {
        final model = DashboardViewModel(intl: AppIntl.of(context)!);
        model.init(this);
        return model;
      },
      builder: (context, model, child) {
        return BaseScaffold(
          body: RefreshIndicator(
            onRefresh: model.loadDataAndUpdateWidget,
            child: LayoutBuilder(
              builder: (context, constraints) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _updateScheduleCardHeight(constraints.maxHeight);
                });

                return SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Stack(
                    children: [
                      _redCircle(model),
                      _phoneVertical(context, model),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  /// Animated circle widget
  Widget _redCircle(DashboardViewModel model) {
    return AnimatedBuilder(
      animation: model.heightAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: model.opacityAnimation.value,
          child: PhysicalShape(
            clipper: CircleClipper(),
            elevation: 4.0,
            color: AppPalette.etsLightRed,
            child: SizedBox(height: model.heightAnimation.value, width: double.infinity),
          ),
        );
      },
    );
  }

  Widget _phoneVertical(BuildContext context, DashboardViewModel model) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedBuilder(
          key: _titleKey,
          animation: model.titleAnimation,
          builder: (context, child) {
            return Padding(
              padding: const EdgeInsets.only(left: 32.0, right: 32.0, top: 80.0),
              child: Transform.translate(
                offset: model.titleSlideOffset,
                child: Opacity(
                  opacity: model.titleFadeOpacity,
                  child: SkeletonLoader(
                    loading: model.isLoading,
                    child: Text(
                      'TODO: créer un message dynamique, pour plus de détails, consulter la issue #863',
                      style: TextStyle(fontSize: 16, color: AppPalette.grey.white),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        Container(
          key: _rowKey,
          padding: EdgeInsets.fromLTRB(40.0, 16.0, 40.0, 0.0),
          child: Row(
            spacing: 18,
            children: [
              Expanded(child: AspectRatio(aspectRatio: 1, child: Card(child: null))),
              Expanded(
                child: ProgressBarCard(
                  progressBarText: model.getProgressBarText(context),
                  progress: model.progress,
                  loading: model.busy(model.progress),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12.0, 6.0, 12.0, 32.0),
          child: Column(
            spacing: 6.0,
            children: [
              if (_scheduleCardHeight != null)
                SizedBox(
                  height: _scheduleCardHeight,
                  child: ScheduleCard(),
                ),
              GradesCard(
                key: _gradesCardKey,
                courses: model.courses,
                loading: model.busy(model.courses),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
