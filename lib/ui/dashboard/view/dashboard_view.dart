// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:stacked/stacked.dart';

// Project imports:
import 'package:notredame/ui/core/themes/app_palette.dart';
import 'package:notredame/ui/core/ui/base_scaffold.dart';
import 'package:notredame/ui/dashboard/widgets/progress_bar_card.dart';
import '../../../domain/constants/preferences_flags.dart';
import '../../../l10n/app_localizations.dart';
import '../../dashboard/view_model/dashboard_viewmodel.dart';
import '../../dashboard/widgets/grades_card.dart';
import '../../dashboard/widgets/schedule_card.dart';
import '../clipper/circle_clipper.dart';
import '../widgets/progression_card.dart';
import '../widgets/widget_component.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> with SingleTickerProviderStateMixin {
  static const EdgeInsets paddingCards = EdgeInsets.fromLTRB(16, 13, 16, 13);

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
                    Stack(
                      children: [
                        /// Animated circle in the background
                        _redCircle(model),

                        /// Content positioned on top of the circle
                        Column(
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
                                            style: TextStyle(
                                              fontSize: 28,
                                              fontWeight: FontWeight.normal,
                                              color: AppPalette.grey.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 10),

                                      /// TODO : La duration de l'animation du texte pourrais être plus courte..
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

                            /// TODO : Remettre old height of 20 instead de 0
                            const SizedBox(height: 0),
                            Container(
                              padding: paddingCards,
                              width: double.infinity,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                spacing: 16,
                                children: [
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.all(20),
                                      height: 145,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: AppPalette.grey.darkGrey,
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                      child: Placeholder(color: Colors.white),
                                    ),
                                  ),
                                  Expanded(
                                    child: ProgressionCard(
                                      childWidget: ProgressBarCard(
                                        onDismissed: () => model.hideCard(PreferencesFlag.progressBarCard),
                                        changeProgressBarText: model.changeProgressBarText,
                                        progressBarText: model.getProgressBarText(context),
                                        progress: model.progress,
                                        loading: model.busy(model.progress),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    WidgetComponent(
                      title: "Horaire - Aujourd'hui",
                      childWidget: ScheduleCard(
                        onDismissed: () => model.hideCard(PreferencesFlag.scheduleCard),
                        events: model.scheduleEvents,
                        loading: model.busy(model.scheduleEvents),
                      ),
                    ),
                    WidgetComponent(
                      title: "Notes",
                      childWidget: GradesCard(
                        courses: model.courses,
                        onDismissed: () => model.hideCard(PreferencesFlag.gradesCard),
                        loading: model.busy(model.courses),
                      ),
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
}
