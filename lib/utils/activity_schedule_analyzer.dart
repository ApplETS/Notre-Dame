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

  _UpcomingBreakInfo? _getUpcomingBreakInfo() {
    final thisWeek = getActivitiesForCurrentWeek();
    final nextWeek = getActivitiesForNextWeek();

    if (thisWeek.isEmpty) return null;

    final lastActivityThisWeek = thisWeek.map((a) => a.startDateTime).reduce((a, b) => a.isAfter(b) ? a : b);
    final nextActivity = nextWeek.isNotEmpty
        ? nextWeek.map((a) => a.startDateTime).reduce((a, b) => a.isBefore(b) ? a : b)
        : findNextActivityAfterCurrentWeek();

    if (nextActivity == null) return null;

    final upcomingGapDays = Utils.daysBetween(lastActivityThisWeek, nextActivity);
    final usualGapDays = calculateUsualWeekendGapDays(excludeStart: lastActivityThisWeek, excludeEnd: nextActivity);

    return _UpcomingBreakInfo(
      upcomingGapDays: upcomingGapDays,
      usualGapDays: usualGapDays,
      lastActivityThisWeek: lastActivityThisWeek,
      nextActivityStart: nextActivity,
    );
  }

  bool get isLongWeekendIncoming {
    final info = _getUpcomingBreakInfo();
    if (info == null) return false;
    return info.upcomingGapDays > info.usualGapDays;
  }

  /// Returns the duration of the upcoming break in days, or null if no break
  int? get upcomingBreakDuration {
    final info = _getUpcomingBreakInfo();
    if (info == null || info.upcomingGapDays <= info.usualGapDays) return null;
    return info.upcomingGapDays;
  }

  /// Returns days until the break starts (first day with no class), or null if no break
  int? get daysUntilBreakStart {
    final info = _getUpcomingBreakInfo();
    if (info == null || info.upcomingGapDays <= info.usualGapDays) return null;
    return Utils.daysBetween(now, info.lastActivityThisWeek) + 1;
  }

  bool get isInsideLongWeekend {
    final gapInfo = _getCurrentGapInfo();
    if (gapInfo == null) return false;

    return gapInfo.isLongerThanUsual;
  }

  /// Returns the number of days until the next course, or null if not in a break
  int? get daysUntilNextCourse {
    final gapInfo = _getCurrentGapInfo();
    if (gapInfo == null || !gapInfo.isLongerThanUsual) return null;

    return Utils.daysBetween(now, gapInfo.nextActivityStart);
  }

  /// Returns the total gap duration in days, or null if not in a break
  int? get totalBreakDuration {
    final gapInfo = _getCurrentGapInfo();
    if (gapInfo == null || !gapInfo.isLongerThanUsual) return null;

    return gapInfo.upcomingGapDays;
  }

  _GapInfo? _getCurrentGapInfo() {
    if (courseActivities.isEmpty) return null;

    final sortedActivities = List<CourseActivity>.from(courseActivities)
      ..sort((a, b) => a.startDateTime.compareTo(b.startDateTime));

    final pastActivities = sortedActivities.where((a) => a.startDateTime.isBefore(now));
    if (pastActivities.isEmpty) return null;

    final lastActivity = pastActivities.last;

    if (now.isBefore(lastActivity.endDateTime)) return null;

    final futureActivities = sortedActivities.where((a) => a.startDateTime.isAfter(now));
    if (futureActivities.isEmpty) return null;

    final nextActivity = futureActivities.first;

    final upcomingGapDays = Utils.daysBetween(lastActivity.endDateTime, nextActivity.startDateTime);
    final usualGapDays = calculateUsualWeekendGapDays(
      excludeStart: lastActivity.startDateTime,
      excludeEnd: nextActivity.startDateTime,
    );

    return _GapInfo(
      upcomingGapDays: upcomingGapDays,
      usualGapDays: usualGapDays,
      nextActivityStart: nextActivity.startDateTime,
    );
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

  int get courseDaysThisWeek {
    final thisWeekActivities = getActivitiesForCurrentWeek();
    return getUniqueDays(thisWeekActivities).length;
  }

  /// Returns the end date of the last regular course activity (excluding finals).
  /// Returns null if no regular course activities exist
  DateTime? getLastRegularCourseDate() {
    final regularActivities = courseActivities
        .where((a) => a.activityName.toLowerCase() != 'final')
        .toList();

    if (regularActivities.isEmpty) return null;

    return regularActivities
        .map((a) => a.endDateTime)
        .reduce((a, b) => a.isAfter(b) ? a : b);
  }
}

class _GapInfo {
  final int upcomingGapDays;
  final int usualGapDays;
  final DateTime nextActivityStart;

  _GapInfo({
    required this.upcomingGapDays,
    required this.usualGapDays,
    required this.nextActivityStart,
  });

  bool get isLongerThanUsual => upcomingGapDays > usualGapDays;
}

class _UpcomingBreakInfo {
  final int upcomingGapDays;
  final int usualGapDays;
  final DateTime lastActivityThisWeek;
  final DateTime nextActivityStart;

  _UpcomingBreakInfo({
    required this.upcomingGapDays,
    required this.usualGapDays,
    required this.lastActivityThisWeek,
    required this.nextActivityStart,
  });
}
