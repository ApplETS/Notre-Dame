// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:calendar_view/calendar_view.dart';
import 'package:skeletonizer/skeletonizer.dart';

// Project imports:
import 'package:notredame/data/repositories/settings_repository.dart';
import 'package:notredame/data/services/signets-api/models/course_activity.dart';
import 'package:notredame/l10n/app_localizations.dart';
import 'package:notredame/locator.dart';
import 'package:notredame/ui/core/ui/dismissible_card.dart';
import 'package:notredame/ui/dashboard/widgets/course_activity_tile.dart';

class ScheduleCard extends StatelessWidget {
  final SettingsRepository _settingsRepository = locator<SettingsRepository>();

  final VoidCallback onDismissed;
  final List<CourseActivity> events;
  final bool loading;

  ScheduleCard({super.key, required this.onDismissed, required this.events, required this.loading});

  @override
  Widget build(BuildContext context) {
    var title = AppIntl.of(context)!.title_schedule;
    var tomorrowDate = _settingsRepository.dateTimeNow.add(Duration(days: 1)).withoutTime;
    if (events.isNotEmpty && events.first.startDateTime.withoutTime == tomorrowDate) {
      title += AppIntl.of(context)!.card_schedule_tomorrow;
    }

    late List<CourseActivity>? courseActivities;
    courseActivities = loading
        ? [
            // User will not see this.
            // It serves the purpose of creating text in the skeleton and make it look closer to the real schedule.
            CourseActivity(
              courseGroup: "APP375-99",
              courseName: "Développement mobile (ÉTSMobile)",
              activityName: '',
              activityDescription: '5 à 7',
              activityLocation: '100 Génies',
              startDateTime: DateTime.now(),
              endDateTime: DateTime.now(),
            ),
          ]
        : events;

    return DismissibleCard(
      onDismissed: (DismissDirection direction) => onDismissed(),
      key: UniqueKey(),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.fromLTRB(17, 15, 0, 0),
                child: Text(title, style: Theme.of(context).textTheme.titleLarge),
              ),
            ),
            if (courseActivities.isNotEmpty)
              Skeletonizer(enabled: loading, child: _buildEventList(courseActivities))
            else
              SizedBox(height: 100, child: Center(child: Text(AppIntl.of(context)!.schedule_no_event))),
          ],
        ),
      ),
    );
  }

  Widget _buildEventList(List<dynamic> events) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
      itemBuilder: (_, index) => CourseActivityTile(events[index] as CourseActivity),
      separatorBuilder: (_, index) =>
          (index < events.length) ? const Divider(thickness: 1, indent: 30, endIndent: 30) : const SizedBox(),
      itemCount: events.length,
    );
  }
}
