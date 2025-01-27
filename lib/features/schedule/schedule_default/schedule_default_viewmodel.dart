// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:calendar_view/calendar_view.dart';
import 'package:stacked/stacked.dart';

// Project imports:
import 'package:notredame/features/app/repository/course_repository.dart';
import 'package:notredame/features/app/signets-api/models/schedule_activity.dart';
import 'package:notredame/utils/app_theme.dart';
import 'package:notredame/utils/locator.dart';

class ScheduleDefaultViewModel
    extends FutureViewModel<List<CalendarEventData<Object>>> {
  /// Load the events
  final CourseRepository _courseRepository = locator<CourseRepository>();

  final String? _sessionCode;

  bool isLoadingEvents = false;

  bool displaySaturday = false;
  bool displaySunday = false;

  /// List of currently loaded events
  List<CalendarEventData<Object>> calendarEvents = [];

  /// A map that contains a color from the AppTheme.SchedulePalette palette associated with each course.
  final Map<String, Color> courseColors = {};

  /// The color palette corresponding to the schedule courses.
  List<Color> schedulePaletteThemeLight =
      AppTheme.schedulePaletteLight.toList();

  ScheduleDefaultViewModel({String? sessionCode}) : _sessionCode = sessionCode;

  @override
  Future<List<CalendarEventData<Object>>> futureToRun() async {
    refresh();
    return calendarEvents;
  }

  CalendarEventData<Object> calendarEventData(ScheduleActivity eventData) {
    final courseLocation = eventData.activityLocation == "Non assign"
        ? "N/A"
        : eventData.activityLocation;

    final DateTime now = DateTime.now();
    final int daysToAdd = eventData.dayOfTheWeek - getWeekDayIndex(now);
    final DateTime targetDate = now.add(Duration(days: daysToAdd));
    final DateTime newStartTime = DateTime(targetDate.year, targetDate.month,
        targetDate.day, eventData.startTime.hour, eventData.startTime.minute);
    final DateTime newEndTime = DateTime(targetDate.year, targetDate.month,
            targetDate.day, eventData.endTime.hour, eventData.endTime.minute)
        .subtract(const Duration(minutes: 1));

    final durationInHours = newEndTime.difference(newStartTime).inHours;

    final String title = durationInHours == 0
        ? eventData.courseAcronym
        : "${eventData.courseAcronym}\n$courseLocation";

    return CalendarEventData(
        title: title,
        description:
            "${eventData.courseAcronym};$courseLocation;${eventData.courseTitle};null",
        date: targetDate,
        startTime: newStartTime,
        endTime: newEndTime,
        color: getCourseColor(eventData.courseAcronym.split('-')[0]) ??
            Colors.grey);
  }

  Color? getCourseColor(String courseName) {
    if (!courseColors.containsKey(courseName)) {
      courseColors[courseName] = schedulePaletteThemeLight.removeLast();
    }
    return courseColors[courseName];
  }

  int getWeekDayIndex(DateTime dateTime) {
    int weekday = dateTime.weekday;
    return weekday == 7 ? 0 : weekday;
  }

  Future<void> refresh() async {
    try {
      setBusyForObject(isLoadingEvents, true);

      if (_sessionCode != null) {
        final defaultScheduleActivities = await _courseRepository
            .getDefaultScheduleActivities(session: _sessionCode);
        final filteredScheduleActivities = defaultScheduleActivities
            .where((activity) => activity.activityCode.toLowerCase() != "exam")
            .toList();

        for (final activity in filteredScheduleActivities) {
          final event = calendarEventData(activity);
          if (event.date.weekday == 6) {
            displaySaturday = true;
          }
          if (event.date.weekday == 7) {
            displaySunday = true;
          }
          calendarEvents.add(event);
        }

        setBusyForObject(isLoadingEvents, false);
        notifyListeners();
      }
    } on Exception catch (error) {
      onError(error);
    }
  }
}
