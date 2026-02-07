// Project imports:
import 'package:notredame/data/services/signets-api/models/course_activity.dart';
import 'package:notredame/utils/utils.dart';

/// Analyzes course activity schedules to determine patterns and gaps.
class ScheduleAnalyzer {
  static const int _defaultWeekendGapDays = 3;

  final List<CourseActivity> courseActivities;
  final DateTime now;

  ScheduleAnalyzer({required this.courseActivities, required this.now});

  List<CourseActivity> getActivitiesInRange(DateTime start, DateTime end) {
    return courseActivities.where((a) => !a.startDateTime.isBefore(start) && a.startDateTime.isBefore(end)).toList();
  }

  List<DateTime> getUniqueDays(List<CourseActivity> activities) {
    return activities.map((a) => Utils.dateOnly(a.startDateTime)).toSet().toList()..sort();
  }

  List<CourseActivity> getActivitiesForCurrentWeek() {
    final start = Utils.startOfWeek(now);
    final end = start.add(const Duration(days: 7));
    return getActivitiesInRange(start, end);
  }

  List<CourseActivity> getActivitiesForNextWeek() {
    final startOfNextWeek = Utils.startOfWeek(now).add(const Duration(days: 7));
    final endOfNextWeek = startOfNextWeek.add(const Duration(days: 7));
    return getActivitiesInRange(startOfNextWeek, endOfNextWeek);
  }

  int calculateUsualWeekendGapDays({required DateTime excludeStart, required DateTime excludeEnd}) {
    if (courseActivities.length < 2) return _defaultWeekendGapDays;

    final sortedActivities = List<CourseActivity>.from(courseActivities)
      ..sort((a, b) => a.startDateTime.compareTo(b.startDateTime));

    final gaps = <int>[];
    final excludeStartDate = Utils.dateOnly(excludeStart);
    final excludeEndDate = Utils.dateOnly(excludeEnd);

    for (int i = 0; i < sortedActivities.length - 1; i++) {
      final current = sortedActivities[i].startDateTime;
      final next = sortedActivities[i + 1].startDateTime;

      if (Utils.startOfWeek(current).isAtSameMomentAs(Utils.startOfWeek(next))) {
        continue;
      }

      if (Utils.dateOnly(current).isAtSameMomentAs(excludeStartDate) &&
          Utils.dateOnly(next).isAtSameMomentAs(excludeEndDate)) {
        continue;
      }

      final gapDays = Utils.daysBetween(current, next);
      if (gapDays > 0) {
        gaps.add(gapDays);
      }
    }

    if (gaps.isEmpty) return _defaultWeekendGapDays;

    gaps.sort();
    return gaps[(gaps.length - 1) ~/ 2];
  }

  DateTime? findNextActivityAfterCurrentWeek() {
    final endOfWeek = Utils.startOfWeek(now).add(const Duration(days: 7));

    final futureActivities = courseActivities.where((a) => !a.startDateTime.isBefore(endOfWeek)).toList()
      ..sort((a, b) => a.startDateTime.compareTo(b.startDateTime));

    return futureActivities.isNotEmpty ? futureActivities.first.startDateTime : null;
  }

  bool get hasNextWeekSchedule => getActivitiesForNextWeek().isNotEmpty;

  bool get isLongWeekendIncoming {
    final thisWeek = getActivitiesForCurrentWeek();
    final nextWeek = getActivitiesForNextWeek();

    if (thisWeek.isEmpty) return false;

    final lastActivityThisWeek = thisWeek.map((a) => a.startDateTime).reduce((a, b) => a.isAfter(b) ? a : b);
    final nextActivity = nextWeek.isNotEmpty
        ? nextWeek.map((a) => a.startDateTime).reduce((a, b) => a.isBefore(b) ? a : b)
        : findNextActivityAfterCurrentWeek();

    if (nextActivity == null) return false;

    final upcomingGapDays = Utils.daysBetween(lastActivityThisWeek, nextActivity);
    final usualGapDays = calculateUsualWeekendGapDays(excludeStart: lastActivityThisWeek, excludeEnd: nextActivity);

    return upcomingGapDays > usualGapDays;
  }

  bool get isInsideLongWeekend {
    if (courseActivities.isEmpty) return false;

    final sortedActivities = List<CourseActivity>.from(courseActivities)
      ..sort((a, b) => a.startDateTime.compareTo(b.startDateTime));

    final pastActivities = sortedActivities.where((a) => a.startDateTime.isBefore(now));
    if (pastActivities.isEmpty) return false;

    final lastActivity = pastActivities.last;

    if (now.isBefore(lastActivity.endDateTime)) return false;

    final futureActivities = sortedActivities.where((a) => a.startDateTime.isAfter(now));
    if (futureActivities.isEmpty) return false;

    final nextActivity = futureActivities.first;

    final upcomingGapDays = Utils.daysBetween(lastActivity.endDateTime, nextActivity.startDateTime);
    final usualGapDays = calculateUsualWeekendGapDays(
      excludeStart: lastActivity.startDateTime,
      excludeEnd: nextActivity.startDateTime,
    );

    return upcomingGapDays > usualGapDays;
  }

  bool get isAfterLastCourseOfWeek {
    final thisWeek = getActivitiesForCurrentWeek();
    if (thisWeek.isEmpty) return false;

    final lastActivityThisWeek = thisWeek.map((a) => a.endDateTime).reduce((a, b) => a.isAfter(b) ? a : b);

    return now.isAfter(lastActivityThisWeek) || now.isAtSameMomentAs(lastActivityThisWeek);
  }

  bool get isLastCourseDayOfWeek {
    final thisWeek = getActivitiesForCurrentWeek();
    if (thisWeek.isEmpty) return false;

    final today = Utils.dateOnly(now);
    final daysWithActivities = getUniqueDays(thisWeek);

    return daysWithActivities.isNotEmpty && daysWithActivities.last.isAtSameMomentAs(today);
  }

  bool get isNextWeekShorter {
    final nextWeek = getActivitiesForNextWeek();
    if (nextWeek.isEmpty) return true;

    return getUniqueDays(nextWeek).length < 5;
  }

  int get courseDaysThisWeek {
    final thisWeekActivities = getActivitiesForCurrentWeek();
    return getUniqueDays(thisWeekActivities).length;
  }
}
