// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:skeletonizer/skeletonizer.dart';

// Project imports:
import 'package:notredame/data/services/navigation_service.dart';
import 'package:notredame/data/services/signets-api/models/course_activity.dart';
import 'package:notredame/domain/constants/router_paths.dart';
import 'package:notredame/locator.dart';
import 'package:notredame/ui/core/ui/dismissible_card.dart';
import 'package:notredame/ui/dashboard/widgets/course_activity_tile.dart';

class ScheduleCard extends StatelessWidget {
  final NavigationService _navigationService = locator<NavigationService>();

  final VoidCallback onDismissed;
  final List<CourseActivity> todayDateEvents;
  final List<CourseActivity> tomorrowDateEvents;
  final bool loading;

  ScheduleCard(
      {super.key,
      required this.onDismissed,
      required this.todayDateEvents,
      required this.tomorrowDateEvents,
      required this.loading});

  @override
  Widget build(BuildContext context) {
    var title = AppIntl.of(context)!.title_schedule;
    if (todayDateEvents.isEmpty && tomorrowDateEvents.isNotEmpty) {
      title += AppIntl.of(context)!.card_schedule_tomorrow;
    }

    late List<CourseActivity>? courseActivities;
    if (loading) {
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
    } else if (todayDateEvents.isEmpty) {
      if (tomorrowDateEvents.isEmpty) {
        courseActivities = null;
      } else {
        courseActivities = tomorrowDateEvents;
      }
    } else {
      courseActivities = todayDateEvents;
    }

    return DismissibleCard(
      onDismissed: (DismissDirection direction) => onDismissed(),
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
                enabled: loading, child: _buildEventList(courseActivities))
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
