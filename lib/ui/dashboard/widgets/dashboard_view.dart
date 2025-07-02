// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:stacked/stacked.dart';

// Project imports:
import 'package:notredame/domain/constants/preferences_flags.dart';
import 'package:notredame/l10n/app_localizations.dart';
import 'package:notredame/ui/core/themes/app_palette.dart';
import 'package:notredame/ui/core/ui/base_scaffold.dart';
import 'package:notredame/ui/dashboard/clipper/circle_clipper.dart';
import 'package:notredame/ui/dashboard/view_model/dashboard_viewmodel.dart';
import 'package:notredame/ui/dashboard/widgets/grades_card.dart';
import 'package:notredame/ui/dashboard/widgets/progress_bar_card.dart';
import 'package:notredame/ui/dashboard/widgets/schedule_card.dart';
import 'package:notredame/ui/dashboard/widgets/widget_component.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<DashboardViewModel>.reactive(
      viewModelBuilder: () {
        /// Single viewModelBuilder reference for the whole dashboard view
        final model = DashboardViewModel(intl: AppIntl.of(context)!);
        model.init(this);
        return model;
      },
      builder: (context, model, child) {
        return BaseScaffold(
          body: RefreshIndicator(
            onRefresh: () async {
              await model.loadDataAndUpdateWidget();
            },
            child: Theme(
              data: Theme.of(context).copyWith(canvasColor: Colors.transparent),
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(0, 0, 0, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Content positioned on top of the circle
                    Stack(
                      children: [
                        /// Animated circle in the background
                        _redCircle(model),

                        /// Set content of the dashboard depending on the device orientation and size
                        setLayoutRelativeToDeviceSizeAndOrientation(context, model),
                      ],
                    ),
                  ],
                ),
              ),
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
            elevation: 4,
            shadowColor: const Color.fromRGBO(0, 0, 0, 1.0),
            color: AppPalette.etsLightRed,
            child: SizedBox(height: model.heightAnimation.value, width: double.infinity),
          ),
        );
      },
    );
  }

  /// Set layout depending on the device orientation and size
  Widget setLayoutRelativeToDeviceSizeAndOrientation(BuildContext context, DashboardViewModel model) {
    // TODO create layouts for all sizes and orientation

    bool isTablet = MediaQuery.of(context).size.shortestSide >= 600;
    bool isHorizontal = MediaQuery.of(context).orientation == Orientation.landscape;

    return _phoneVertical(context, model);
  }

  Widget _phoneVertical(BuildContext context, DashboardViewModel model) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 100),
        AnimatedBuilder(
          animation: model.titleAnimation,
          builder: (context, child) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Transform.translate(
                    offset: model.titleSlideOffset,
                    child: Opacity(
                      opacity: model.titleFadeOpacity,
                      child: Text(
                        'Accueil',
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.normal, color: AppPalette.grey.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Transform.translate(
                    offset: model.titleSlideOffset,
                    child: Opacity(
                      opacity: model.titleFadeOpacity,
                      child: SkeletonLoader(
                        loading: model.isLoading,
                        child: SizedBox(
                          width: double.infinity,
                          height: 70,
                          child: Text(
                            'TODO: créer un message dynamique, pour plus de détails, consulter la issue #863',
                            style: TextStyle(fontSize: 16, color: AppPalette.grey.white),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 0),
        Container(
          padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
          width: double.infinity,
          child: Row(
            spacing: 12,
            children: [
              Expanded(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Card(
                    child: null,
                  ),
                ),
              ),
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
        const SizedBox(height: 16),
        WidgetComponent(
          title: "Horaire - Aujourd'hui",
          childWidget: ScheduleCard(
            onDismissed: () => {},
            events: model.scheduleEvents,
            loading: model.busy(model.scheduleEvents),
          ),
        ),
        WidgetComponent(
          title: "Notes",
          childWidget: GradesCard(
            courses: model.courses,
            onDismissed: () => {},
            loading: model.busy(model.courses),
          ),
        ),
      ],
    );
  }
}
