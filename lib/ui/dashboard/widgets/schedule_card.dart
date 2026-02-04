// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:calendar_view/calendar_view.dart';
import 'package:notredame/ui/core/themes/app_theme.dart';
import 'package:notredame/ui/dashboard/widgets/widget_component.dart';
import 'package:notredame/ui/schedule/schedule_controller.dart';
import 'package:notredame/ui/schedule/widgets/calendars/day_calendar.dart';

// Project imports:
import 'package:notredame/data/repositories/settings_repository.dart';
import 'package:notredame/data/services/signets-api/models/course_activity.dart';
import 'package:notredame/l10n/app_localizations.dart';
import 'package:notredame/locator.dart';

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

    int endHour = 18;

    if (events.isNotEmpty && events.last.endDateTime.hour > 18) {
      endHour = events.last.endDateTime.hour + 1;
    }
    // TODO set end hour according to last event

    return SizedBox(
      height: 400,
      child: WidgetComponent(
        title: title,
        child: Expanded(
          child: DayCalendar(
            listView: false,
            controller: ScheduleController(),
            selectedDate: date,
            heightPerMinute: 364 / ((endHour - 7) * 60),
            startHour: 8,
            endHour: endHour,
            backgroundColor: context.theme.appColors.dashboardCard,
            scrollOffset: 0,
            scrollPhysics: NeverScrollableScrollPhysics(),
          ),
        ),
      ),
    );
  }
}
