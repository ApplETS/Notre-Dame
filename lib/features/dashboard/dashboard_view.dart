import 'package:flutter/material.dart';
import 'package:notredame/constants/preferences_flags.dart';
import 'package:notredame/features/app/analytics/analytics_service.dart';
import 'package:notredame/features/app/navigation/navigation_service.dart';
import 'package:notredame/features/dashboard/dashboard_viewmodel.dart';
import 'package:notredame/features/dashboard/widgets-dashboard/about_us_card.dart';
import 'package:notredame/features/dashboard/widgets-dashboard/grades_card.dart';
import 'package:notredame/features/dashboard/widgets-dashboard/progress_bar_card.dart';
import 'package:notredame/features/dashboard/widgets-dashboard/schedule_card.dart';
import 'package:provider/provider.dart';

class DashboardView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final model = Provider.of<DashboardViewModel>(context);
    final navigationService = Provider.of<NavigationService>(context);
    final analyticsService = Provider.of<AnalyticsService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              ProgressBarCard(
                model: model,
                flag: PreferencesFlag.progressBarCard,
                progressBarText: Text('Some progress text'), // Example text, you can replace it with your logic
                dismissCard: () => model.hideCard(PreferencesFlag.progressBarCard),
                changeProgressBarText: () {
                  // Implement your logic here
                },
                setText: () {
                  // Implement your logic here
                },
              ),
              AboutUsCard(
                model: model,
                flag: PreferencesFlag.aboutUsCard,
                analyticsService: analyticsService,
              ),
              GradesCard(
                model: model,
                flag: PreferencesFlag.gradesCard,
                dismissCard: () => model.hideCard(PreferencesFlag.gradesCard),
              ),
              ScheduleCard(
                model: model,
                flag: PreferencesFlag.scheduleCard,
                dismissCard: () => model.hideCard(PreferencesFlag.scheduleCard),
                navigationService: navigationService,
              ),
              // Add other cards here as needed
            ],
          ),
        ),
      ),
    );
  }
}
