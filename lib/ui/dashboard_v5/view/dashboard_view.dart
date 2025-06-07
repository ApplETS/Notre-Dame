import 'package:flutter/material.dart';
import 'package:notredame/ui/core/themes/app_palette.dart';
import 'package:notredame/ui/dashboard/widgets/progress_bar_card.dart';
import 'package:notredame/ui/dashboard_v5/widgets/days_left_card.dart';
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
  late final DashboardViewModelV5 viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = DashboardViewModelV5();
    viewModel.fetchUserInfo();
    viewModel.init(this);
  }

  @override
  void dispose() {
    viewModel.controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<DashboardViewModel>.reactive(
        viewModelBuilder: () => DashboardViewModel(intl: AppIntl.of(context)!),
        builder: (context, model, child) {
          return Scaffold(
            body: RefreshIndicator(
              onRefresh: () => model.loadDataAndUpdateWidget(),
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
                              Padding(
                                padding: const EdgeInsets.only(left: 30),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Accueil',
                                      style: TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.normal,
                                        color: AppPalette.grey.white,
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      'Bonjour, ${viewModel.getFullName()} !',
                                      style: TextStyle(fontSize: 16, color: AppPalette.grey.white),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                              Container(
                                padding: const EdgeInsets.fromLTRB(16, 13, 16, 13),
                                width: double.infinity,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(child: DaysLeftCard()),
                                    const SizedBox(width: 15),
                                    Expanded(
                                      child: ProgressionCard(
                                        childWidget: ProgressBarCard(
                                            key: UniqueKey(),
                                            onDismissed: () => model.hideCard(PreferencesFlag.progressBarCard),
                                            changeProgressBarText: model.changeProgressBarText,
                                            progressBarText: model.getProgressBarText(context),
                                            progress: model.progress,
                                            loading: model.busy(model.progress)),
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
                            key: UniqueKey(),
                            onDismissed: () => model.hideCard(PreferencesFlag.scheduleCard),
                            events: model.scheduleEvents,
                            loading: model.busy(model.scheduleEvents)),
                      ),
                      WidgetComponent(
                        title: "Notes",
                        childWidget: GradesCard(
                            courses: model.courses,
                            onDismissed: () => model.hideCard(PreferencesFlag.gradesCard),
                            loading: model.busy(model.courses)),
                      ),
                      WidgetComponent(
                        title: "Évenements",
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }
}
