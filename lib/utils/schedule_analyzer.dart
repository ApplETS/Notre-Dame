// Project imports:
import 'package:notredame/data/models/activity_code.dart';
import 'package:notredame/data/services/signets-api/models/course_activity.dart';
import 'package:notredame/utils/date_utils.dart';

/// Analyzes course activity schedules to determine patterns and gaps.
class ScheduleAnalyzer {
  static const int _defaultWeekendGapDays = 3;

  final List<CourseActivity> courseActivities;
  final DateTime now;

  ScheduleAnalyzer({required this.courseActivities, required this.now});

  late final _sortedActivities = List<CourseActivity>.from(courseActivities)
    ..sort((a, b) => a.startDateTime.compareTo(b.startDateTime));
  late final _currentWeekActivities = getActivitiesForCurrentWeek();
  late final _nextWeekActivities = getActivitiesForNextWeek();
  late final _upcomingBreakGapInfo = _getUpcomingBreakGapInfo();
  late final _currentGapInfo = _getCurrentGapInfo();

  /// Returns all course activities whose startDateTime falls within the given range [start, end).
  List<CourseActivity> getActivitiesInRange(DateTime start, DateTime end) {
    return courseActivities
        .where((activity) => !activity.startDateTime.isBefore(start) && activity.startDateTime.isBefore(end))
        .toList();
  }

  List<DateTime> getUniqueDays(List<CourseActivity> activities) {
    return activities.map((activity) => DateUtils.dateOnly(activity.startDateTime)).toSet().toList()..sort();
  }

  List<CourseActivity> getActivitiesForCurrentWeek() {
    final start = DateUtils.startOfWeek(now);
    final end = start.add(const Duration(days: 7));
    return getActivitiesInRange(start, end);
  }

  List<CourseActivity> getActivitiesForNextWeek() {
    final startOfNextWeek = DateUtils.startOfWeek(now).add(const Duration(days: 7));
    final endOfNextWeek = startOfNextWeek.add(const Duration(days: 7));
    return getActivitiesInRange(startOfNextWeek, endOfNextWeek);
  }

  int calculateUsualWeekendGapDays({required DateTime excludeStart, required DateTime excludeEnd}) {
    if (courseActivities.length < 2) return _defaultWeekendGapDays;

    final sortedActivities = _sortedActivities;
    final weekendGapDurationsInDays = <int>[];
    final excludeStartDate = DateUtils.dateOnly(excludeStart);
    final excludeEndDate = DateUtils.dateOnly(excludeEnd);

    for (int i = 0; i < sortedActivities.length - 1; i++) {
      final currentActivityDate = sortedActivities[i].startDateTime;
      final nextActivityDate = sortedActivities[i + 1].startDateTime;

      // Skip if both activities are in the same week (only interested in gaps between weeks)
      if (DateUtils.startOfWeek(currentActivityDate).isAtSameMomentAs(DateUtils.startOfWeek(nextActivityDate))) {
        continue;
      }

      // Exclude the specified gap. For example, this prevents the gap we are currently in from
      // influencing the usual historical average.
      if (DateUtils.dateOnly(currentActivityDate).isAtSameMomentAs(excludeStartDate) &&
          DateUtils.dateOnly(nextActivityDate).isAtSameMomentAs(excludeEndDate)) {
        continue;
      }

      final gapDays = DateUtils.daysBetween(currentActivityDate, nextActivityDate);
      if (gapDays > 0) {
        weekendGapDurationsInDays.add(gapDays);
      }
    }

    if (weekendGapDurationsInDays.isEmpty) return _defaultWeekendGapDays;

    weekendGapDurationsInDays.sort();

    // Return the median gap
    return weekendGapDurationsInDays[(weekendGapDurationsInDays.length - 1) ~/ 2];
  }

  DateTime? findNextActivityAfterCurrentWeek() {
    final endOfWeek = DateUtils.startOfWeek(now).add(const Duration(days: 7));

    final futureActivities = _sortedActivities.where((activity) => !activity.startDateTime.isBefore(endOfWeek));

    return futureActivities.isNotEmpty ? futureActivities.first.startDateTime : null;
  }

  bool get hasNextWeekSchedule => _nextWeekActivities.isNotEmpty;

  _GapInfo? _getUpcomingBreakGapInfo() {
    final thisWeek = _currentWeekActivities;
    final nextWeek = _nextWeekActivities;

    if (thisWeek.isEmpty) return null;

    final lastActivityThisWeek = thisWeek
        .map((activity) => activity.startDateTime)
        .reduce((a, b) => a.isAfter(b) ? a : b);
    final nextActivity = nextWeek.isNotEmpty
        ? nextWeek.map((activity) => activity.startDateTime).reduce((a, b) => a.isBefore(b) ? a : b)
        : findNextActivityAfterCurrentWeek();

    if (nextActivity == null) return null;

    final upcomingGapDays = DateUtils.daysBetween(lastActivityThisWeek, nextActivity);
    final usualGapDays = calculateUsualWeekendGapDays(excludeStart: lastActivityThisWeek, excludeEnd: nextActivity);

    return _GapInfo(
      upcomingGapDays: upcomingGapDays,
      usualGapDays: usualGapDays,
      nextActivityStart: nextActivity,
      lastActivityEnd: lastActivityThisWeek,
    );
  }

  bool get isLongWeekendIncoming {
    final breakInfo = _upcomingBreakGapInfo;
    if (breakInfo == null) return false;
    return breakInfo.isLongerThanUsual;
  }

  int? get upcomingBreakDuration {
    final breakInfo = _upcomingBreakGapInfo;
    if (breakInfo == null || !breakInfo.isLongerThanUsual) return null;
    return breakInfo.upcomingGapDays;
  }

  /// Returns days until the break starts (first day with no class), or null if no break.
  int? get daysUntilBreakStart {
    final breakInfo = _upcomingBreakGapInfo;
    if (breakInfo == null || !breakInfo.isLongerThanUsual) return null;
    return DateUtils.daysBetween(now, breakInfo.lastActivityEnd) + 1;
  }

  bool get isInsideLongWeekend {
    final gapInfo = _currentGapInfo;
    if (gapInfo == null) return false;

    return gapInfo.isLongerThanUsual && DateUtils.daysBetween(now, gapInfo.nextActivityStart) > 0;
  }

  bool get isFirstDayBackFromBreak {
    if (courseActivities.isEmpty) return false;

    final today = DateUtils.dateOnly(now);
    final sortedActivities = _sortedActivities;

    // Today must have activities for it to be the "first day back"
    final hasActivitiesToday = sortedActivities
        .any((a) => DateUtils.dateOnly(a.startDateTime).isAtSameMomentAs(today));
    if (!hasActivitiesToday) return false;

    final activitiesBeforeToday = sortedActivities
        .where((a) => DateUtils.dateOnly(a.startDateTime).isBefore(today));
    if (activitiesBeforeToday.isEmpty) return false;

    final lastActivityBeforeToday = activitiesBeforeToday.last;
    final firstActivityToday = sortedActivities
        .firstWhere((a) => DateUtils.dateOnly(a.startDateTime).isAtSameMomentAs(today));

    // Within-week gaps (e.g. Wed→Sun) are normal schedule, not breaks
    if (DateUtils.startOfWeek(lastActivityBeforeToday.startDateTime)
        .isAtSameMomentAs(DateUtils.startOfWeek(firstActivityToday.startDateTime))) {
      return false;
    }

    final gapDays = DateUtils.daysBetween(
      lastActivityBeforeToday.endDateTime,
      firstActivityToday.startDateTime,
    );
    final usualGapDays = calculateUsualWeekendGapDays(
      excludeStart: lastActivityBeforeToday.startDateTime,
      excludeEnd: firstActivityToday.startDateTime,
    );

    return gapDays > usualGapDays;
  }

  int? get daysUntilNextCourse {
    final gapInfo = _currentGapInfo;
    if (gapInfo == null || !gapInfo.isLongerThanUsual) return null;

    return DateUtils.daysBetween(now, gapInfo.nextActivityStart);
  }

  int? get totalBreakDuration {
    final gapInfo = _currentGapInfo;
    if (gapInfo == null || !gapInfo.isLongerThanUsual) return null;

    return gapInfo.upcomingGapDays;
  }

  _GapInfo? _getCurrentGapInfo() {
    if (courseActivities.isEmpty) return null;

    final sortedActivities = _sortedActivities;
    final pastActivities = sortedActivities.where((activity) => activity.startDateTime.isBefore(now));
    if (pastActivities.isEmpty) return null;

    final lastActivity = pastActivities.last;

    if (now.isBefore(lastActivity.endDateTime)) return null;

    final futureActivities = sortedActivities.where((activity) => activity.startDateTime.isAfter(now));
    if (futureActivities.isEmpty) return null;

    final nextActivity = futureActivities.first;

    final upcomingGapDays = DateUtils.daysBetween(lastActivity.endDateTime, nextActivity.startDateTime);
    final usualGapDays = calculateUsualWeekendGapDays(
      excludeStart: lastActivity.startDateTime,
      excludeEnd: nextActivity.startDateTime,
    );

    return _GapInfo(
      upcomingGapDays: upcomingGapDays,
      usualGapDays: usualGapDays,
      nextActivityStart: nextActivity.startDateTime,
      lastActivityEnd: lastActivity.endDateTime,
    );
  }

  bool get isAfterLastCourseOfWeek {
    final thisWeek = _currentWeekActivities;
    if (thisWeek.isEmpty) return false;

    final lastActivityThisWeek = thisWeek
        .map((activity) => activity.endDateTime)
        .reduce((a, b) => a.isAfter(b) ? a : b);

    return now.isAfter(lastActivityThisWeek) || now.isAtSameMomentAs(lastActivityThisWeek);
  }

  bool get isLastCourseDayOfWeek {
    final thisWeek = _currentWeekActivities;
    if (thisWeek.isEmpty) return false;

    final today = DateUtils.dateOnly(now);
    final daysWithActivities = getUniqueDays(thisWeek);

    return daysWithActivities.isNotEmpty && daysWithActivities.last.isAtSameMomentAs(today);
  }

  int get courseDaysThisWeek {
    return getUniqueDays(_currentWeekActivities).length;
  }

  /// Returns the end date of the last regular course activity (excluding finals).
  /// Returns null if no regular course activities exist
  DateTime? getLastRegularCourseDate() {
    final regularActivities = courseActivities
        .where((activity) => activity.activityName.toLowerCase() != ActivityName.finalExam.toLowerCase())
        .toList();

    if (regularActivities.isEmpty) return null;

    return regularActivities.map((activity) => activity.endDateTime).reduce((a, b) => a.isAfter(b) ? a : b);
  }

  /// Returns the start date of the first final exam, or null if no finals exist
  DateTime? getFirstFinalExamDate() {
    final finals = _getFinalExamActivities();
    if (finals.isEmpty) return null;
    return finals.map((a) => a.startDateTime).reduce((a, b) => a.isBefore(b) ? a : b);
  }

  /// Returns the end date of the last final exam, or null if no finals exist
  DateTime? getLastFinalExamDate() {
    final finals = _getFinalExamActivities();
    if (finals.isEmpty) return null;
    return finals.map((a) => a.endDateTime).reduce((a, b) => a.isAfter(b) ? a : b);
  }

  List<CourseActivity> _getFinalExamActivities() {
    return courseActivities
        .where((a) => a.activityName.toLowerCase() == ActivityName.finalExam.toLowerCase())
        .toList();
  }
}

class _GapInfo {
  final int upcomingGapDays;
  final int usualGapDays;
  final DateTime nextActivityStart;
  final DateTime lastActivityEnd;

  _GapInfo({
    required this.upcomingGapDays,
    required this.usualGapDays,
    required this.nextActivityStart,
    required this.lastActivityEnd,
  });

  bool get isLongerThanUsual => upcomingGapDays > usualGapDays;
}
