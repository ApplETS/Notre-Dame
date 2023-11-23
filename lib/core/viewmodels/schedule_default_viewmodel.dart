// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:calendar_view/calendar_view.dart';
import 'package:ets_api_clients/models.dart';
import 'package:stacked/stacked.dart';

// Project imports:
import 'package:notredame/core/managers/course_repository.dart';
import 'package:notredame/locator.dart';
import 'package:notredame/ui/utils/app_theme.dart';

class ScheduleDefaultViewModel
    extends FutureViewModel<List<CalendarEventData<Object>>> {
  /// Load the events
  final CourseRepository _courseRepository = locator<CourseRepository>();

  final String _sessionCode;

  /// List of currently loaded events
  List<CalendarEventData<Object>> calendarEvents = [];

  /// A map that contains a color from the AppTheme.SchedulePalette palette associated with each course.
  final Map<String, Color> courseColors = {};

  /// The color palette corresponding to the schedule courses.
  List<Color> schedulePaletteThemeLight =
      AppTheme.schedulePaletteLight.toList();

  ScheduleDefaultViewModel({String sessionCode}) : _sessionCode = sessionCode;

  @override
  Future<List<CalendarEventData<Object>>> futureToRun() async {
    setBusy(true);
    final defaultScheduleActivities = await _courseRepository.getDefaultScheduleActivities(session: _sessionCode);
    final filteredScheduleActivities = defaultScheduleActivities
        .where((activity) => activity.activityCode.toLowerCase() != "exam")
        .toList();

    for (final activity in filteredScheduleActivities) {
      final event = calendarEventData(activity);
      calendarEvents.add(event);
    }

    setBusy(false);
    return calendarEvents;
  }

  CalendarEventData<Object> calendarEventData(ScheduleActivity eventData) {
    final courseLocation = eventData.activityLocation == "Non assign"
        ? "N/A"
        : eventData.activityLocation;

    final DateTime now = DateTime.now();
    final int daysToAdd = eventData.dayOfTheWeek - now.weekday;

    final DateTime targetDate = now.add(Duration(days: daysToAdd));
    final DateTime newStartTime = DateTime(targetDate.year, targetDate.month,
        targetDate.day, eventData.startTime.hour, eventData.startTime.minute);
    final DateTime newEndTime = DateTime(targetDate.year, targetDate.month,
            targetDate.day, eventData.endTime.hour, eventData.endTime.minute)
        .subtract(const Duration(minutes: 1));

    return CalendarEventData(
        title: "${eventData.courseAcronym}\n$courseLocation",
        description:
            "${eventData.courseAcronym};$courseLocation;${eventData.courseTitle};Je suis un nom de prof",
        date: targetDate,
        startTime: newStartTime,
        endTime: newEndTime,
        color: getCourseColor(eventData.courseAcronym.split('-')[0]));
  }

  Color getCourseColor(String courseName) {
    if (!courseColors.containsKey(courseName)) {
      courseColors[courseName] = schedulePaletteThemeLight.removeLast();
    }
    return courseColors[courseName];
  }
}
