import 'package:stacked/stacked.dart';

import 'package:notredame/features/app/signets-api/models/course_activity.dart';
import 'package:notredame/features/app/repository/course_repository.dart';
import 'package:notredame/features/more/settings/settings_manager.dart';
import 'package:notredame/utils/locator.dart';
import 'package:notredame/constants/preferences_flags.dart';
import 'package:notredame/utils/activity_code.dart';

class ScheduleCardViewmodel extends FutureViewModel {
  final SettingsManager _settingsManager = locator<SettingsManager>();
  final CourseRepository _courseRepository = locator<CourseRepository>();

  /// Activities for today
  List<CourseActivity> _todayDateEvents = [];

  /// Get the list of activities for today
  List<CourseActivity> get todayDateEvents {
    return _todayDateEvents;
  }

  // Activities for tomorrow
  List<CourseActivity> _tomorrowDateEvents = [];

  /// Get the list of activities for tomorrow
  List<CourseActivity> get tomorrowDateEvents {
    return _tomorrowDateEvents;
  }

  @override
  Future futureToRun() async {
    await futureToRunSchedule();
  }

  Future<List<CourseActivity>> futureToRunSchedule() async {
    setBusyForObject(_todayDateEvents, true);
    setBusyForObject(_tomorrowDateEvents, true);
    try {
      var courseActivities =
      await _courseRepository.getCoursesActivities(fromCacheOnly: true);
      _todayDateEvents.clear();
      _tomorrowDateEvents.clear();
      final todayDate = _settingsManager.dateTimeNow;
      courseActivities = await _courseRepository.getCoursesActivities();

      if (_todayDateEvents.isEmpty &&
          _courseRepository.coursesActivities != null) {
        final DateTime tomorrowDate = todayDate.add(const Duration(days: 1));
        // Build the list
        for (final CourseActivity course in _courseRepository.coursesActivities!) {
          final DateTime dateOnly = course.startDateTime;
          if (isSameDay(todayDate, dateOnly) &&
              todayDate.compareTo(course.endDateTime) < 0) {
            _todayDateEvents.add(course);
          } else if (isSameDay(tomorrowDate, dateOnly)) {
            _tomorrowDateEvents.add(course);
          }
        }
      }

      _todayDateEvents
          .sort((a, b) => a.startDateTime.compareTo(b.startDateTime));
      _tomorrowDateEvents
          .sort((a, b) => a.startDateTime.compareTo(b.startDateTime));

      _todayDateEvents = await removeLaboratoryGroup(_todayDateEvents);
      _tomorrowDateEvents = await removeLaboratoryGroup(_tomorrowDateEvents);
      return courseActivities ?? [];
    } catch (error) {
      onError(error);
    } finally {
      setBusyForObject(_todayDateEvents, false);
      setBusyForObject(_tomorrowDateEvents, false);
    }
    return [];
  }

  Future<List<CourseActivity>> removeLaboratoryGroup(
      List<CourseActivity> todayDateEvents) async {
    final List<CourseActivity> todayDateEventsCopy = List.from(todayDateEvents);

    for (final courseAcronym in todayDateEvents) {
      final courseKey = courseAcronym.courseGroup.split('-')[0];

      final String? activityCodeToUse = await _settingsManager.getDynamicString(
          PreferencesFlag.scheduleLaboratoryGroup, courseKey);

      if (activityCodeToUse == ActivityCode.labGroupA) {
        todayDateEventsCopy.removeWhere((element) =>
        element.activityDescription == ActivityDescriptionName.labB &&
            element.courseGroup == courseAcronym.courseGroup);
      } else if (activityCodeToUse == ActivityCode.labGroupB) {
        todayDateEventsCopy.removeWhere((element) =>
        element.activityDescription == ActivityDescriptionName.labA &&
            element.courseGroup == courseAcronym.courseGroup);
      }
    }

    return todayDateEventsCopy;
  }

  /// Returns true if dates [a] and [b] are on the same day
  bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
