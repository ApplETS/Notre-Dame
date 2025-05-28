// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:calendar_view/calendar_view.dart';
import 'package:collection/collection.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:stacked/stacked.dart';

// Project imports:
import 'package:notredame/data/models/activity_code.dart';
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

  CalendarEventData<Object> calendarEventData(CourseActivity eventData) {
    final courseLocation = eventData.activityLocation == "Non assign" ? "N/A" : eventData.activityLocation.join(", ");
    final associatedCourses = _courses?.where((element) => element.acronym == eventData.courseGroup.split('-')[0]);
    final associatedCourse = associatedCourses?.isNotEmpty == true ? associatedCourses?.first : null;
    return CalendarEventData(
      title: "${eventData.courseGroup.split('-')[0]}\n$courseLocation\n${eventData.activityName}",
      description:
          "${eventData.courseGroup};$courseLocation;${eventData.activityName};${associatedCourse?.teacherName}",
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

  bool isLoadingEvents = false;

  @override
  Future<List<CourseActivity>> futureToRun() async {
    List<CourseActivity>? activities = await _courseRepository.getCoursesActivities(fromCacheOnly: true);
    try {
      setBusyForObject(isLoadingEvents, true);
      final fetchedCourseActivities = await _courseRepository.getCoursesActivities();

      if (fetchedCourseActivities != null) {
        activities = fetchedCourseActivities;
        // Reload the list of activities
        coursesActivities;

        _courses = await _courseRepository.getCourses(fromCacheOnly: true);
      }
    } catch (e) {
      onError(e);
    } finally {
      setBusyForObject(isLoadingEvents, false);
    }
    return activities ?? [];
  }

  @override
  void onError(error) {
    throw error;
    Fluttertoast.showToast(msg: appIntl.error);
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

          if (scheduleActivitiesContainsGroup) {
            if (_scheduleActivityIsSelected(course)) {
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

  bool _scheduleActivityIsSelected(CourseActivity course) {
    if (course.activityDescription != ActivityDescriptionName.labA &&
        course.activityDescription != ActivityDescriptionName.labB) {
      return true;
    }

    final activityNameSelected = settingsScheduleActivities[course.courseGroup.split("-").first];

    return activityNameSelected == course.activityDescription;
  }

  List<CalendarEventData> calendarEventsFromDate(DateTime date) {
    return _coursesActivities[date.withoutTime]?.map((eventData) => calendarEventData(eventData)).toList() ?? [];
  }

  bool returnToCurrentDate();

  handleDateSelectedChanged(DateTime newDate);
}
