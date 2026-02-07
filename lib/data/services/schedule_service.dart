import 'dart:ui';

import 'package:calendar_view/calendar_view.dart';
import 'package:collection/collection.dart';
import 'package:notredame/data/services/signets-api/models/course.dart';
import 'package:notredame/data/services/signets-api/models/course_activity.dart';
import 'package:notredame/data/services/signets-api/models/schedule_activity.dart';

import '../../domain/constants/preferences_flags.dart';
import '../../locator.dart';
import '../../ui/core/themes/app_palette.dart';
import '../models/activity_code.dart';
import '../models/calendar_event_tile.dart';
import '../repositories/course_repository.dart';
import '../repositories/settings_repository.dart';

class ScheduleService {
  /// Load the events
  final CourseRepository _courseRepository = locator<CourseRepository>();

  /// Manage de settings
  final SettingsRepository _settingsManager = locator<SettingsRepository>();

  /// Activities sorted by day
  Map<DateTime, List<CourseActivity>> _coursesActivities = {};

  /// Courses associated to the student
  List<Course>? _courses;

  /// This map contains the courses that has the group A or group B mark
  final Map<String, List<ScheduleActivity>> _scheduleActivitiesByCourse = {};

  /// This map contains the direct settings as string for each course that are grouped
  /// (Example: (key, value) => ("ING150", "Laboratoire (Groupe A)"))
  final Map<String, String> _settingsScheduleActivities = {};

  /// A map that contains a color from the AppTheme.SchedulePalette palette associated with each course.
  final Map<String, Color> _courseColors = {};

  /// The color palette corresponding to the schedule courses.
  final List<Color> _schedulePaletteTheme = AppPalette.schedule.toList();

  Map<DateTime, List<EventData>> _events = {};

  Future<Map<DateTime, List<EventData>>> get events async {
    if (_events.isNotEmpty) {
      return _events;
    }

    List<CourseActivity>? activities = await _courseRepository.getCoursesActivities(fromCacheOnly: true);

    final fetchedCourseActivities = await _courseRepository.getCoursesActivities();

    if (fetchedCourseActivities != null) {
      activities = fetchedCourseActivities;
      // Reload the list of activities
      coursesActivities;

      _courses = await _courseRepository.getCourses(fromCacheOnly: true);
    }
    final scheduleActivities = await _courseRepository.getScheduleActivities();
    await _assignScheduleActivities(scheduleActivities);

    _events = coursesActivities.map((key, value) => MapEntry(key, _calendarEventTile(value)));

    // if (activities != null) {
    //   _events = _coursesActivities[date.withoutTime]?.map((eventData) => _calendarEventTile(eventData)).toList() ?? [];
    //   _events = activities!.map((eventData) => _calendarEventTile(eventData)).toList() ?? [];
    // }

    return _events;
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
          final scheduleActivitiesContainsGroup = _settingsScheduleActivities.containsKey(
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

  Future _assignScheduleActivities(List<ScheduleActivity> listOfSchedules) async {
    if (listOfSchedules.isEmpty ||
        !listOfSchedules.any(
          (element) => [ActivityCode.labGroupA, ActivityCode.labGroupB].contains(element.activityCode),
        )) {
      return;
    }

    _scheduleActivitiesByCourse.clear();
    for (final activity in listOfSchedules) {
      if (activity.activityCode == ActivityCode.labGroupA || activity.activityCode == ActivityCode.labGroupB) {
        // Create the list with the new activity inside or add the activity to an existing group
        if (!_scheduleActivitiesByCourse.containsKey(activity.courseAcronym)) {
          _scheduleActivitiesByCourse[activity.courseAcronym] = [activity];
        } else {
          _scheduleActivitiesByCourse[activity.courseAcronym]?.add(activity);
        }
      }
    }

    await _loadSettingsScheduleActivities();
  }

  Future _loadSettingsScheduleActivities() async {
    for (final courseAcronym in _scheduleActivitiesByCourse.keys) {
      final String? activityCodeToUse = await _settingsManager.getDynamicString(
        PreferencesFlag.scheduleLaboratoryGroup,
        courseAcronym,
      );
      final scheduleActivityToSet = _scheduleActivitiesByCourse[courseAcronym]?.firstWhereOrNull(
        (element) => element.activityCode == activityCodeToUse,
      );
      if (scheduleActivityToSet != null) {
        _settingsScheduleActivities[courseAcronym] = scheduleActivityToSet.activityCode;
      } else {
        // All group selected
        _settingsScheduleActivities.removeWhere((key, value) => key == courseAcronym);
      }

      coursesActivities;
    }
  }

  bool _scheduleActivityIsSelected(CourseActivity course) {
    if (course.activityName != ActivityName.labA && course.activityName != ActivityName.labB) {
      return true;
    }

    final activityNameSelected = _settingsScheduleActivities[course.courseGroup.split("-").first];
    return (activityNameSelected == ActivityCode.labGroupA && ActivityName.labA == course.activityName) ||
        (activityNameSelected == ActivityCode.labGroupB && ActivityName.labB == course.activityName);
  }

  Color _getCourseColor(String courseName) {
    if (!_courseColors.containsKey(courseName)) {
      _courseColors[courseName] = _schedulePaletteTheme.removeLast();
    }
    return _courseColors[courseName] ?? AppPalette.etsLightRed;
  }

  List<EventData> _calendarEventTile(List<CourseActivity> courses) {
    List<EventData> events = [];
    for (final course in courses) {
      final associatedCourses = _courses?.where((element) => element.acronym == course.courseGroup.split('-')[0]);
      final associatedCourse = associatedCourses?.isNotEmpty == true ? associatedCourses?.first : null;

      events.add(
        EventData(
          courseAcronym: course.courseGroup.split('-')[0],
          group: course.courseGroup,
          locations: course.activityLocation,
          activityName: course.activityName,
          courseName: course.courseName,
          teacherName: associatedCourse?.teacherName,
          date: course.startDateTime,
          startTime: course.startDateTime,
          endTime: course.endDateTime.subtract(const Duration(minutes: 1)),
          color: _getCourseColor(course.courseGroup.split('-')[0]),
        ),
      );
    }

    return events;
  }
}
