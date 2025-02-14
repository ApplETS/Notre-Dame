import 'package:stacked/stacked.dart';
// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:calendar_view/calendar_view.dart';
import 'package:collection/collection.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:fluttertoast/fluttertoast.dart';

// Project imports:
import 'package:notredame/data/models/activity_code.dart';
import 'package:notredame/data/repositories/course_repository.dart';
import 'package:notredame/data/repositories/settings_repository.dart';
import 'package:notredame/data/services/calendar_service.dart';
import 'package:notredame/data/services/signets-api/models/course.dart';
import 'package:notredame/data/services/signets-api/models/course_activity.dart';
import 'package:notredame/data/services/signets-api/models/schedule_activity.dart';
import 'package:notredame/domain/constants/preferences_flags.dart';
import 'package:notredame/locator.dart';
import 'package:notredame/ui/core/themes/app_palette.dart';

abstract class CalendarViewModel extends FutureViewModel<List<CourseActivity>> {
  /// Load the events
  final CourseRepository _courseRepository = locator<CourseRepository>();

  /// Manage de settings
  final SettingsRepository _settingsManager = locator<SettingsRepository>();

  /// Localization class of the application.
  @protected final AppIntl appIntl;

  /// Settings of the user for the schedule
  final Map<PreferencesFlag, dynamic> settings = {};

  /// Activities sorted by day
  Map<DateTime, List<CourseActivity>> _coursesActivities = {};

  /// Courses associated to the student
  List<Course>? _courses;

  /// The currently selected CalendarTimeFormat, A default value is set for test purposes.
  /// This value is then change to the cache value on load.
  CalendarTimeFormat calendarFormat = CalendarTimeFormat.week;

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

  CalendarEventData<Object> calendarEventData(CourseActivity eventData) {
    final courseLocation = eventData.activityLocation == "Non assign"
        ? "N/A"
        : eventData.activityLocation;
    final associatedCourses = _courses?.where(
            (element) => element.acronym == eventData.courseGroup.split('-')[0]);
    final associatedCourse =
    associatedCourses?.isNotEmpty == true ? associatedCourses?.first : null;
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
      courseColors[courseName] = schedulePaletteTheme.removeLast();
    }
    return courseColors[courseName] ?? AppPalette.etsLightRed;
  }

  bool isLoadingEvents = false;

  bool get calendarViewSetting {
    if (busy(settings)) {
      return false;
    }
    return settings[PreferencesFlag.scheduleListView] as bool;
  }

  @override
  Future<List<CourseActivity>> futureToRun() async {
    loadSettings();
    List<CourseActivity>? activities =
    await _courseRepository.getCoursesActivities(fromCacheOnly: true);
    try {
      setBusyForObject(isLoadingEvents, true);
      final fetchedCourseActivities = await _courseRepository.getCoursesActivities();

      if (fetchedCourseActivities != null) {
        activities = fetchedCourseActivities;
        // Reload the list of activities
        coursesActivities;

        _courses = await _courseRepository.getCourses(fromCacheOnly: true);
      }
      final scheduleActivities = await _courseRepository.getScheduleActivities();
      await assignScheduleActivities(scheduleActivities);
    } catch (e) {
      onError(e);
    } finally {
      setBusyForObject(isLoadingEvents, false);
    }
    return activities ?? [];
  }

  Future assignScheduleActivities(
      List<ScheduleActivity> listOfSchedules) async {
    if (listOfSchedules.isEmpty ||
        !listOfSchedules.any((element) =>
        element.activityCode == ActivityCode.labGroupA ||
            element.activityCode == ActivityCode.labGroupB)) {
      return;
    }

    setBusy(true);
    scheduleActivitiesByCourse.clear();
    for (final activity in listOfSchedules) {
      if (activity.activityCode == ActivityCode.labGroupA ||
          activity.activityCode == ActivityCode.labGroupB) {
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
  void onError(error) {
    Fluttertoast.showToast(msg: appIntl.error);
  }

  Future loadSettings() async {
    setBusyForObject(settings, true);
    settings.clear();
    settings.addAll(await _settingsManager.getScheduleSettings());
    calendarFormat =
    settings[PreferencesFlag.scheduleCalendarFormat] as CalendarTimeFormat;

    await loadSettingsScheduleActivities();

    setBusyForObject(settings, false);
  }

  Future loadSettingsScheduleActivities() async {
    for (final courseAcronym in scheduleActivitiesByCourse.keys) {
      final String? activityCodeToUse = await _settingsManager.getDynamicString(
          PreferencesFlag.scheduleLaboratoryGroup, courseAcronym);
      final scheduleActivityToSet = scheduleActivitiesByCourse[courseAcronym]
          ?.firstWhereOrNull(
              (element) => element.activityCode == activityCodeToUse);
      if (scheduleActivityToSet != null) {
        settingsScheduleActivities[courseAcronym] = scheduleActivityToSet.name;
      } else {
        // All group selected
        settingsScheduleActivities
            .removeWhere((key, value) => key == courseAcronym);
      }

      coursesActivities;
    }
  }

  /// Return the list of all the courses activities arranged by date.
  Map<DateTime, List<CourseActivity>> get coursesActivities {
    _coursesActivities = {};

    // Build the map
    if (_courseRepository.coursesActivities != null) {
      for (final CourseActivity course
      in _courseRepository.coursesActivities!) {
        final DateTime dateOnly = course.startDateTime.subtract(Duration(
            hours: course.startDateTime.hour,
            minutes: course.startDateTime.minute));

        if (!_coursesActivities.containsKey(dateOnly)) {
          _coursesActivities[dateOnly] = [];
        }

        _coursesActivities.update(dateOnly, (value) {
          final scheduleActivitiesContainsGroup = settingsScheduleActivities
              .containsKey(course.courseGroup.split("-").first);

          if (scheduleActivitiesContainsGroup) {
            if (scheduleActivityIsSelected(course)) {
              value.add(course);
            }
          } else {
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

  bool scheduleActivityIsSelected(CourseActivity course) {
    if (course.activityDescription != ActivityDescriptionName.labA &&
        course.activityDescription != ActivityDescriptionName.labB) {
      return true;
    }

    final activityNameSelected =
    settingsScheduleActivities[course.courseGroup.split("-").first];

    return activityNameSelected == course.activityDescription;
  }

  /// Get the activities for a specific [date], return empty if there is no activity for this [date]
  List<CourseActivity> coursesActivitiesFor(DateTime date) {
    // Populate the _coursesActivities
    if (_coursesActivities.isEmpty) {
      coursesActivities;
    }

    return _coursesActivities[date.withoutTime] ?? [];
  }

  List<CalendarEventData> calendarEventsFromDate(DateTime date) {
    return _coursesActivities[date.withoutTime]
        ?.map((eventData) => calendarEventData(eventData))
        .toList() ??
        [];
  }

  bool returnToCurrentDate();

  handleDateSelectedChanged(DateTime newDate);
}
