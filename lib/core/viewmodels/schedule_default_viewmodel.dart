// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:calendar_view/calendar_view.dart';
import 'package:ets_api_clients/models.dart';
import 'package:notredame/core/managers/course_repository.dart';
import 'package:stacked/stacked.dart';
import 'package:table_calendar/table_calendar.dart';

// Project imports:
import 'package:notredame/core/constants/preferences_flags.dart';
import 'package:notredame/core/managers/settings_manager.dart';
import 'package:notredame/locator.dart';
import 'package:notredame/ui/utils/app_theme.dart';

class ScheduleDefaultViewModel extends FutureViewModel<List<CourseActivity>> {
  /// Load the events
  final CourseRepository _courseRepository = locator<CourseRepository>();
  
  /// Manage de settings
  final SettingsManager _settingsManager = locator<SettingsManager>();

  /// Settings of the user for the schedule
  final Map<PreferencesFlag, dynamic> settings = {};

  /// Courses associated to the student
  List<Course> courses;

  final String _sessionCode;

  bool isLoadingEvents = false;

  /// List of currently loaded events
  List<CalendarEventData> calendarEvents = [];

  /// The currently selected CalendarFormat, A default value is set for test purposes.
  /// This value is then change to the cache value on load.
  CalendarFormat calendarFormat = CalendarFormat.week;

  /// This map contains the courses that has the group A or group B mark
  final Map<String, List<ScheduleActivity>> scheduleActivitiesByCourse = {};

  /// This map contains the direct settings as string for each course that are grouped
  /// (Example: (key, value) => ("ING150", "Laboratoire (Groupe A)"))
  final Map<String, String> settingsScheduleActivities = {};

  /// A map that contains a color from the AppTheme.SchedulePalette palette associated with each course.
  final Map<String, Color> courseColors = {};

  /// The color palette corresponding to the schedule courses.
  List<Color> schedulePaletteThemeLight =
      AppTheme.schedulePaletteLight.toList();

  /// Get current locale
  Locale get locale => _settingsManager.locale;

  ScheduleDefaultViewModel({String sessionCode})
      : _sessionCode = sessionCode;

  @override
  Future<List<CourseActivity>> futureToRun() {
    final filteredActivities = _courseRepository.courses.where((activity) => activity.session == _sessionCode).toList();
    return null;
  }
  
  CalendarEventData<Object> calendarEventData(CourseActivity eventData) {
    final courseLocation = eventData.activityLocation == "Non assign"
        ? "N/A"
        : eventData.activityLocation;
    final associatedCourses = courses?.where(
        (element) => element.acronym == eventData.courseGroup.split('-')[0]);
    final associatedCourse =
        associatedCourses?.isNotEmpty == true ? associatedCourses.first : null;
    return CalendarEventData(
        title:
            "${eventData.courseGroup.split('-')[0]}\n$courseLocation\n${eventData.activityName}",
        description:
            "${eventData.courseGroup};$courseLocation;${eventData.activityName};${associatedCourse?.teacherName}",
        date: eventData.startDateTime,
        startTime: eventData.startDateTime,
        endTime: eventData.endDateTime.subtract(const Duration(minutes: 1)),
        color: getCourseColor(eventData.courseGroup.split('-')[0]));
  }

  Color getCourseColor(String courseName) {
    if (!courseColors.containsKey(courseName)) {
      courseColors[courseName] = schedulePaletteThemeLight.removeLast();
    }
    return courseColors[courseName];
  }
}
