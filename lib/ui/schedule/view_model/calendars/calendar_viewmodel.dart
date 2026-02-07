// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:calendar_view/calendar_view.dart';
import 'package:collection/collection.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:stacked/stacked.dart';

// Project imports:
import 'package:notredame/data/models/activity_code.dart';
import 'package:notredame/data/models/calendar_event_tile.dart';
import 'package:notredame/data/repositories/course_repository.dart';
import 'package:notredame/data/repositories/settings_repository.dart';
import 'package:notredame/data/services/signets-api/models/course.dart';
import 'package:notredame/data/services/signets-api/models/course_activity.dart';
import 'package:notredame/data/services/signets-api/models/schedule_activity.dart';
import 'package:notredame/domain/constants/preferences_flags.dart';
import 'package:notredame/l10n/app_localizations.dart';
import 'package:notredame/locator.dart';
import 'package:notredame/ui/core/themes/app_palette.dart';

abstract class CalendarViewModel extends FutureViewModel<List<CourseActivity>> {
  /// Load the events
  final CourseRepository _courseRepository = locator<CourseRepository>();

  /// Manage de settings
  final SettingsRepository _settingsManager = locator<SettingsRepository>();

  /// Localization class of the application.
  @protected
  final AppIntl appIntl;

  /// Activities sorted by day
  Map<DateTime, List<CourseActivity>> _coursesActivities = {};

  /// Courses associated to the student
  List<Course>? _courses;

  /// This map contains the courses that has the group A or group B mark
  final Map<String, List<ScheduleActivity>> scheduleActivitiesByCourse = {};

  /// This map contains the direct settings as string for each course that are grouped
  /// (Example: (key, value) => ("ING150", "Laboratoire (Groupe A)"))
  final Map<String, String> settingsScheduleActivities = {};

  /// A map that contains a color from the AppTheme.SchedulePalette palette associated with each course.
  final Map<String, Color> courseColors = {};

  /// The color palette corresponding to the schedule courses.
  List<Color> schedulePaletteTheme = AppPalette.schedule.toList();

  CalendarViewModel({required AppIntl intl}) : appIntl = intl;

  EventData calendarEventTile(CourseActivity eventData) {
    final associatedCourses = _courses?.where((element) => element.acronym == eventData.courseGroup.split('-')[0]);
    final associatedCourse = associatedCourses?.isNotEmpty == true ? associatedCourses?.first : null;

    return EventData(
      courseAcronym: eventData.courseGroup.split('-')[0],
      group: eventData.courseGroup,
      locations: eventData.activityLocation,
      activityName: eventData.activityName,
      courseName: eventData.courseName,
      teacherName: associatedCourse?.teacherName,
      date: eventData.startDateTime,
      startTime: eventData.startDateTime,
      endTime: eventData.endDateTime.subtract(const Duration(minutes: 1)),
      color: getCourseColor(eventData.courseGroup.split('-')[0]),
    );
  }

  Color getCourseColor(String courseName) {
    if (!courseColors.containsKey(courseName)) {
      courseColors[courseName] = schedulePaletteTheme.removeLast();
    }
    return courseColors[courseName] ?? AppPalette.etsLightRed;
  }

  @override
  Future<List<CourseActivity>> futureToRun() async {
    List<CourseActivity>? activities = await _courseRepository.getCoursesActivities(fromCacheOnly: true);
    try {
      final fetchedCourseActivities = await _courseRepository.getCoursesActivities();

      if (fetchedCourseActivities != null) {
        activities = fetchedCourseActivities;
        // Reload the list of activities
        coursesActivities;

        _courses = await _courseRepository.getCourses(fromCacheOnly: true);
      }
      final scheduleActivities = await _courseRepository.getScheduleActivities();
      await _assignScheduleActivities(scheduleActivities);
    } catch (e) {
      onError(e, null);
    }
    return activities ?? [];
  }

  Future _assignScheduleActivities(List<ScheduleActivity> listOfSchedules) async {
    if (listOfSchedules.isEmpty ||
        !listOfSchedules.any(
          (element) => [ActivityCode.labGroupA, ActivityCode.labGroupB].contains(element.activityCode),
        )) {
      return;
    }

    scheduleActivitiesByCourse.clear();
    for (final activity in listOfSchedules) {
      if (activity.activityCode == ActivityCode.labGroupA || activity.activityCode == ActivityCode.labGroupB) {
        // Create the list with the new activity inside or add the activity to an existing group
        if (!scheduleActivitiesByCourse.containsKey(activity.courseAcronym)) {
          scheduleActivitiesByCourse[activity.courseAcronym] = [activity];
        } else {
          scheduleActivitiesByCourse[activity.courseAcronym]?.add(activity);
        }
      }
    }

    await loadSettingsScheduleActivities();
  }

  @override
  void onError(error, StackTrace? stackTrace) {
    Fluttertoast.showToast(msg: appIntl.error);
  }

  Future loadSettingsScheduleActivities() async {
    for (final courseAcronym in scheduleActivitiesByCourse.keys) {
      final String? activityCodeToUse = await _settingsManager.getDynamicString(
        PreferencesFlag.scheduleLaboratoryGroup,
        courseAcronym,
      );
      final scheduleActivityToSet = scheduleActivitiesByCourse[courseAcronym]?.firstWhereOrNull(
        (element) => element.activityCode == activityCodeToUse,
      );
      if (scheduleActivityToSet != null) {
        settingsScheduleActivities[courseAcronym] = scheduleActivityToSet.activityCode;
      } else {
        // All group selected
        settingsScheduleActivities.removeWhere((key, value) => key == courseAcronym);
      }

      coursesActivities;
    }
  }

  /// Return the list of all the courses activities arranged by date.
  Map<DateTime, List<CourseActivity>> get coursesActivities {
    _coursesActivities = {};

    // Build the map
    if (_courseRepository.coursesActivities != null) {
      for (final CourseActivity course in _courseRepository.coursesActivities!) {
        final DateTime dateOnly = course.startDateTime.withoutTime;

        if (!_coursesActivities.containsKey(dateOnly)) {
          _coursesActivities[dateOnly] = [];
        }

        _coursesActivities.update(dateOnly, (value) {
          final scheduleActivitiesContainsGroup = settingsScheduleActivities.containsKey(
            course.courseGroup.split("-").first,
          );

          if (scheduleActivitiesContainsGroup && _scheduleActivityIsSelected(course) ||
              !scheduleActivitiesContainsGroup) {
            value.add(course);
          }

          return value;
        }, ifAbsent: () => [course]);
      }
    }

    _coursesActivities.updateAll((key, value) {
      value.sort((a, b) => a.startDateTime.compareTo(b.startDateTime));

      return value;
    });

    return _coursesActivities;
  }

  bool _scheduleActivityIsSelected(CourseActivity course) {
    if (course.activityName != ActivityName.labA && course.activityName != ActivityName.labB) {
      return true;
    }

    final activityNameSelected = settingsScheduleActivities[course.courseGroup.split("-").first];
    return (activityNameSelected == ActivityCode.labGroupA && ActivityName.labA == course.activityName) ||
        (activityNameSelected == ActivityCode.labGroupB && ActivityName.labB == course.activityName);
  }

  List<EventData> calendarEventsFromDate(DateTime date) {
    return _coursesActivities[date.withoutTime]?.map((eventData) => calendarEventTile(eventData)).toList() ?? [];
  }

  bool returnToCurrentDate();

  void handleDateSelectedChanged(DateTime newDate);
}
