import 'dart:ui';

import 'package:calendar_view/calendar_view.dart';
import 'package:notredame/data/services/signets-api/models/course.dart';
import 'package:notredame/data/services/signets-api/models/course_activity.dart';
import 'package:notredame/domain/constants/preferences_flags.dart';
import 'package:notredame/locator.dart';
import 'package:notredame/ui/core/themes/app_palette.dart';
import 'package:notredame/data/models/activity_code.dart';
import 'package:notredame/data/models/calendar_event_tile.dart';
import 'package:notredame/data/repositories/course_repository.dart';
import 'package:notredame/data/repositories/settings_repository.dart';

class ScheduleService {
  /// If true, will fetch course activies again instead of using in-memory data
  bool _invalidateCache = false;

  /// Load the events
  final CourseRepository _courseRepository = locator<CourseRepository>();

  /// Manage de settings
  final SettingsRepository _settingsManager = locator<SettingsRepository>();

  /// Activities sorted by day
  Map<DateTime, List<CourseActivity>> _coursesActivities = {};

  /// Courses associated to the student
  List<Course>? _courses;

  /// A map that contains a color from the AppTheme.SchedulePalette palette associated with each course.
  final Map<String, Color> _courseColors = {};

  /// The color palette corresponding to the schedule courses.
  final List<Color> _schedulePaletteTheme = AppPalette.schedule.toList();

  Map<DateTime, List<EventData>> _events = {};

  Future<Map<DateTime, List<EventData>>> get events async {
    if (_events.isNotEmpty && !_invalidateCache) {
      return _events;
    }

    _invalidateCache = false;
    _courses = await _courseRepository.getCourses(fromCacheOnly: true);
    _events = (await coursesActivities).map((key, value) => MapEntry(key, _calendarEventTile(value)));
    return _events;
  }

  /// Return the list of all the courses activities arranged by date.
  Future<Map<DateTime, List<CourseActivity>>> get coursesActivities async {
    List<CourseActivity> courseActivities = await _courseRepository.getCoursesActivities() ?? [];
    _coursesActivities = {};
    for (final course in courseActivities) {
      final DateTime date = course.startDateTime.withoutTime;
      final String courseAcronym = course.courseGroup.split("-").first;
      final isLabAorB = course.activityName == ActivityName.labA || course.activityName == ActivityName.labB;

      // If user wants to display lab A or B only for the current course
      final activitySelected = await _settingsManager.getDynamicString(
        PreferencesFlag.scheduleLaboratoryGroup,
        courseAcronym,
      );

      if (isLabAorB &&
          (activitySelected == ActivityCode.labGroupA && ActivityName.labA != course.activityName ||
              activitySelected == ActivityCode.labGroupB && ActivityName.labB != course.activityName)) {
        continue;
      }

      // Populate the map
      _coursesActivities.update(date, (v) {
        v.add(course);
        return v;
      }, ifAbsent: () => [course]);
    }

    _coursesActivities.updateAll((key, value) {
      value.sort((a, b) => a.startDateTime.compareTo(b.startDateTime));
      return value;
    });

    return _coursesActivities;
  }

  void invalidateCache() {
    _invalidateCache = true;
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
