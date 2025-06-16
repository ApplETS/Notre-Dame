import 'package:flutter/material.dart';
import 'package:notredame/ui/core/themes/app_palette.dart';
import 'package:notredame/ui/dashboard/widgets/progress_bar_card.dart';
import 'package:stacked/stacked.dart';

import '../../../domain/constants/preferences_flags.dart';
import '../../../l10n/app_localizations.dart';
import '../../dashboard/view_model/dashboard_viewmodel.dart';
import '../../dashboard/widgets/grades_card.dart';
import '../../dashboard/widgets/schedule_card.dart';
import '../clipper/circle_clipper.dart';
import '../view_model/dashboard_viewmodel.dart';
import '../widgets/progression_card.dart';
import '../widgets/widget_component.dart';

class DashboardViewV5 extends StatefulWidget {
  const DashboardViewV5({super.key});

  @override
  State<DashboardViewV5> createState() => _DashboardViewStateV5();
}

class _DashboardViewStateV5 extends State<DashboardViewV5> with SingleTickerProviderStateMixin {
  static const EdgeInsets paddingCards = EdgeInsets.fromLTRB(16, 13, 16, 13);
  late DashboardViewModelV5 viewModel;
  bool _isViewModelInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_isViewModelInitialized) {
      final intl = AppIntl.of(context)!;
      viewModel = DashboardViewModelV5(intl: intl);
      viewModel.init(this);
      _isViewModelInitialized = true;
    }
  }

  @override
  void dispose() {
    viewModel.controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    /// TODO : Move all the logic needed from DashboardViewModel
    /// To the new DashboardViewModelV5
    /// DashboardViewModel => DashboardViewModelV5
    return ViewModelBuilder<DashboardViewModel>.reactive(
        viewModelBuilder: () => DashboardViewModel(intl: AppIntl.of(context)!),
        builder: (context, model, child) {
          return Scaffold(
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
                          AnimatedBuilder(
                            animation: viewModel.heightAnimation,
                            builder: (context, child) {
                              return Opacity(
                                opacity: viewModel.opacityAnimation.value,
                                child: PhysicalShape(
                                  clipper: CircleClipper(),
                                  elevation: 4,
                                  shadowColor: Color.fromRGBO(0, 0, 0, 1.0),
                                  color: AppPalette.etsLightRed,
                                  child: SizedBox(
                                    height: viewModel.heightAnimation.value,
                                    width: double.infinity,
                                  ),
                                ),
                              );
                            },
                          ),

                          /// Content positioned on top of the circle
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 100),
                              AnimatedBuilder(
                                  animation: viewModel.titleAnimation,
                                  builder: (context, child) {
                                    return Padding(
                                      padding: const EdgeInsets.only(left: 32),
                                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                        Transform.translate(
                                          offset: viewModel.titleSlideOffset,
                                          child: Opacity(
                                            opacity: viewModel.titleFadeOpacity,
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
                                          offset: viewModel.titleSlideOffset,
                                          child: Opacity(
                                            opacity: viewModel.titleFadeOpacity,
                                            child: SkeletonLoader(
                                              loading: viewModel.isLoading,
                                              child: SizedBox(
                                                /// TODO : Mettre la bonne width
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
                                      ]),
                                    );
                                  }),

                              /// TODO : Remettre old height of 20 instead de 0
                              const SizedBox(height: 0),
                              Container(
                                padding: paddingCards,
                                width: double.infinity,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
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
                                        child: Placeholder(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 15),
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
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }
}
