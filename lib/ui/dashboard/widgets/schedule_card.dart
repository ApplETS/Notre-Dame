// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:calendar_view/calendar_view.dart';
import 'package:notredame/ui/dashboard/widgets/widget_component.dart';
import 'package:notredame/ui/schedule/schedule_controller.dart';
import 'package:notredame/ui/schedule/widgets/calendars/day_calendar.dart';
import 'package:skeletonizer/skeletonizer.dart';

// Project imports:
import 'package:notredame/data/repositories/settings_repository.dart';
import 'package:notredame/data/services/signets-api/models/course_activity.dart';
import 'package:notredame/l10n/app_localizations.dart';
import 'package:notredame/locator.dart';
import 'package:notredame/ui/dashboard/widgets/course_activity_tile.dart';

class ScheduleCard extends StatelessWidget {
  final SettingsRepository _settingsRepository = locator<SettingsRepository>();

  final List<CourseActivity> events;

  ScheduleCard({super.key, required this.events});

  @override
  Widget build(BuildContext context) {
    var title = AppIntl.of(context)!.title_schedule;
    var date = _settingsRepository.dateTimeNow;

    var tomorrowDate = _settingsRepository.dateTimeNow.add(Duration(days: 1)).withoutTime;
    if (events.isNotEmpty && events.first.startDateTime.withoutTime == tomorrowDate) {
      title += AppIntl.of(context)!.card_schedule_tomorrow;
      date = tomorrowDate;
    }

    late List<CourseActivity>? courseActivities = events;


    return WidgetComponent(
      title: title,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

               SizedBox(
                   height:300,
                   child: DayCalendar(listView: false, controller: ScheduleController(), selectedDate: date))

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
