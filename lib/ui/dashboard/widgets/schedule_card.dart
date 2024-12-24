import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:notredame/data/services/navigation_service.dart';
import 'package:notredame/data/services/signets-api/models/course_activity.dart';
import 'package:notredame/domain/constants/router_paths.dart';
import 'package:notredame/locator.dart';
import 'package:notredame/ui/core/ui/dismissible_card.dart';
import 'package:notredame/ui/dashboard/view_model/dashboard_viewmodel.dart';
import 'package:notredame/ui/dashboard/widgets/course_activity_tile.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ScheduleCard extends StatelessWidget {
  final NavigationService _navigationService = locator<NavigationService>();
  
  final DashboardViewModel _model;
  final VoidCallback _onDismissed;

  ScheduleCard({super.key, required DashboardViewModel model, required VoidCallback onDismissed}) : _model = model, _onDismissed = onDismissed;

  @override
  Widget build(BuildContext context) {
    var title = AppIntl.of(context)!.title_schedule;
    if (_model.todayDateEvents.isEmpty && _model.tomorrowDateEvents.isNotEmpty) {
      title += AppIntl.of(context)!.card_schedule_tomorrow;
    }
    final bool isLoading = _model.busy(_model.todayDateEvents) ||
        _model.busy(_model.tomorrowDateEvents);

    late List<CourseActivity>? courseActivities;
    if (isLoading) {
      // User will not see this.
      // It serves the purpuse of creating text in the skeleton and make it look closer to the real schedule.
      courseActivities = [
        CourseActivity(
            courseGroup: "APP375-99",
            courseName: "Développement mobile (ÉTSMobile)",
            activityName: '',
            activityDescription: '5 à 7',
            activityLocation: '100 Génies',
            startDateTime: DateTime.now(),
            endDateTime: DateTime.now())
      ];
    } else if (_model.todayDateEvents.isEmpty) {
      if (_model.tomorrowDateEvents.isEmpty) {
        courseActivities = null;
      } else {
        courseActivities = _model.tomorrowDateEvents;
      }
    } else {
      courseActivities = _model.todayDateEvents;
    }

    return DismissibleCard(
      onDismissed: (DismissDirection direction) => _onDismissed(),
      key: UniqueKey(),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 5),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.fromLTRB(17, 15, 0, 0),
                child: GestureDetector(
                  onTap: () => _navigationService
                      .pushNamedAndRemoveUntil(RouterPaths.schedule),
                  child: Text(title,
                      style: Theme.of(context).textTheme.titleLarge),
                ),
              )),
          if (courseActivities != null)
            Skeletonizer(
                enabled: isLoading, child: _buildEventList(courseActivities))
          else
            SizedBox(
                height: 100,
                child:
                    Center(child: Text(AppIntl.of(context)!.schedule_no_event)))
        ]),
      ),
    );
  }
  
  Widget _buildEventList(List<dynamic> events) {
    return ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
        itemBuilder: (_, index) =>
            CourseActivityTile(events[index] as CourseActivity),
        separatorBuilder: (_, index) => (index < events.length)
            ? const Divider(thickness: 1, indent: 30, endIndent: 30)
            : const SizedBox(),
        itemCount: events.length);
  }
}