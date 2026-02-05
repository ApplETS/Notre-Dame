// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:stacked/stacked.dart';

// Project imports:
import 'package:notredame/data/models/calendar_event_tile.dart';
import 'package:notredame/data/repositories/course_repository.dart';
import 'package:notredame/data/services/signets-api/models/schedule_activity.dart';
import 'package:notredame/locator.dart';
import 'package:notredame/ui/core/themes/app_palette.dart';

class SessionScheduleViewModel extends FutureViewModel<List<CalendarEventTile<Object>>> {
  /// Load the events
  final CourseRepository _courseRepository = locator<CourseRepository>();

  final String? _sessionCode;

  bool isLoadingEvents = false;

  bool displaySaturday = false;
  bool displaySunday = false;

  /// List of currently loaded events
  List<CalendarEventTile<Object>> calendarEvents = [];

  /// A map that contains a color from the AppTheme.SchedulePalette palette associated with each course.
  final Map<String, Color> courseColors = {};

  /// The color palette corresponding to the schedule courses.
  List<Color> schedulePalette = AppPalette.schedule.toList();

  SessionScheduleViewModel({String? sessionCode}) : _sessionCode = sessionCode;

  @override
  Future<List<CalendarEventTile<Object>>> futureToRun() async {
    refresh();
    return calendarEvents;
  }

  CalendarEventTile<Object> calendarEventTile(ScheduleActivity eventData) {
    final DateTime now = DateTime.now();
    final int daysToAdd = eventData.dayOfTheWeek - (now.weekday % 7);
    final DateTime targetDate = now.add(Duration(days: daysToAdd));
    final DateTime newStartTime = DateTime(
      targetDate.year,
      targetDate.month,
      targetDate.day,
      eventData.startTime.hour,
      eventData.startTime.minute,
    );
    final DateTime newEndTime = DateTime(
      targetDate.year,
      targetDate.month,
      targetDate.day,
      eventData.endTime.hour,
      eventData.endTime.minute,
    ).subtract(const Duration(minutes: 1));

    return CalendarEventTile(
      title: eventData.courseAcronym,
      description: "${eventData.courseAcronym};;${eventData.courseTitle};null",
      date: targetDate,
      startTime: newStartTime,
      endTime: newEndTime,
      color: getCourseColor(eventData.courseAcronym.split('-')[0]) ?? AppPalette.grey.darkGrey,
    );
  }

  Color? getCourseColor(String courseName) {
    if (!courseColors.containsKey(courseName)) {
      courseColors[courseName] = schedulePalette.removeLast();
    }
    return courseColors[courseName];
  }

  Future<void> refresh() async {
    try {
      setBusyForObject(isLoadingEvents, true);

      if (_sessionCode != null) {
        final defaultScheduleActivities = await _courseRepository.getDefaultScheduleActivities(session: _sessionCode);
        final filteredScheduleActivities = defaultScheduleActivities
            .where((activity) => activity.activityCode.toLowerCase() != "exam")
            .toList();

        for (final activity in filteredScheduleActivities) {
          final event = calendarEventTile(activity);
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
    } on Exception catch (e) {
      onError(e, null);
    }
  }
}
