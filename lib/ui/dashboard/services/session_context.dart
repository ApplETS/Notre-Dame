// Project imports:
import 'package:notredame/data/services/signets-api/models/course_activity.dart';
import 'package:notredame/data/services/signets-api/models/replaced_day.dart';
import 'package:notredame/data/services/signets-api/models/session.dart';

class SessionContext {
  static const int _defaultWeekendGapDays = 3;

  final DateTime now;
  final Session session;
  final List<CourseActivity> courseActivities;
  final List<ReplacedDay> replacedDays;

  final bool isSessionStarted;
  final int daysRemaining;
  final int monthsRemaining;
  final int weeksCompleted;
  final int weeksRemaining;
  final int courseDaysThisWeek;

  SessionContext({
    required this.now,
    required this.session,
    required this.courseActivities,
    required this.replacedDays,
    required this.isSessionStarted,
    required this.daysRemaining,
    required this.monthsRemaining,
    required this.weeksCompleted,
    required this.weeksRemaining,
    required this.courseDaysThisWeek,
  });

  factory SessionContext.fromSession({
    required Session session,
    required List<CourseActivity> activities,
    required List<ReplacedDay> replacedDays,
    required DateTime now,
  }) {
    return SessionContext(
      session: session,
      courseActivities: activities,
      replacedDays: replacedDays,
      now: now,
      isSessionStarted: now.compareTo(session.startDate) >= 0,
      daysRemaining: session.endDate.difference(now).inDays,
      monthsRemaining: _calculateMonthsRemaining(session.endDate, now),
      weeksCompleted: _calculateWeeksCompleted(session.startDate, now),
      weeksRemaining: _calculateWeeksRemaining(session.endDate, now),
      courseDaysThisWeek: _calculateCourseDaysThisWeek(activities, now),
    );
  }

  static DateTime _dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

  static DateTime _startOfWeek(DateTime date) => _dateOnly(date).subtract(Duration(days: date.weekday - 1));

  static int _daysBetweenCourseDays(DateTime start, DateTime end) {
    return _dateOnly(end).difference(_dateOnly(start)).inDays;
  }

  static List<CourseActivity> _getActivitiesInRange(List<CourseActivity> activities, DateTime start, DateTime end) {
    return activities.where((a) => !a.startDateTime.isBefore(start) && a.startDateTime.isBefore(end)).toList();
  }

  static List<DateTime> _getUniqueDays(List<CourseActivity> activities) {
    return activities.map((a) => _dateOnly(a.startDateTime)).toSet().toList()..sort();
  }

  bool get hasNextWeekSchedule => _getActivitiesForNextWeek().isNotEmpty;

  bool get isLongWeekendIncoming {
    final thisWeek = _getActivitiesForCurrentWeek();
    final nextWeek = _getActivitiesForNextWeek();

    if (thisWeek.isEmpty) return false;

    final lastActivityThisWeek = thisWeek.map((a) => a.startDateTime).reduce((a, b) => a.isAfter(b) ? a : b);
    final nextActivity = nextWeek.isNotEmpty
        ? nextWeek.map((a) => a.startDateTime).reduce((a, b) => a.isBefore(b) ? a : b)
        : _findNextActivity();

    if (nextActivity == null) return false;

    final upcomingGapDays = _daysBetweenCourseDays(lastActivityThisWeek, nextActivity);
    final usualGapDays = _calculateUsualWeekendGapDays(excludeStart: lastActivityThisWeek, excludeEnd: nextActivity);

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

    final upcomingGapDays = _daysBetweenCourseDays(lastActivity.endDateTime, nextActivity.startDateTime);
    final usualGapDays = _calculateUsualWeekendGapDays(
      excludeStart: lastActivity.startDateTime,
      excludeEnd: nextActivity.startDateTime,
    );

    return upcomingGapDays > usualGapDays;
  }

  bool get isAfterLastCourseOfWeek {
    final thisWeek = _getActivitiesForCurrentWeek();
    if (thisWeek.isEmpty) return false;

    final lastActivityThisWeek = thisWeek.map((a) => a.endDateTime).reduce((a, b) => a.isAfter(b) ? a : b);

    return now.isAfter(lastActivityThisWeek) || now.isAtSameMomentAs(lastActivityThisWeek);
  }

  bool get isNextWeekShorter {
    final nextWeek = _getActivitiesForNextWeek();
    if (nextWeek.isEmpty) return true;

    return _getUniqueDays(nextWeek).length < 5;
  }

  bool get isLastCourseDayOfWeek {
    final thisWeek = _getActivitiesForCurrentWeek();
    if (thisWeek.isEmpty) return false;

    final today = _dateOnly(now);
    final daysWithActivities = _getUniqueDays(thisWeek);

    return daysWithActivities.isNotEmpty && daysWithActivities.last.isAtSameMomentAs(today);
  }

  static int _calculateCourseDaysThisWeek(List<CourseActivity> activities, DateTime now) {
    final start = _startOfWeek(now);
    final end = start.add(const Duration(days: 7));
    final thisWeekActivities = _getActivitiesInRange(activities, start, end);
    return _getUniqueDays(thisWeekActivities).length;
  }

  static int _calculateMonthsRemaining(DateTime endDate, DateTime now) {
    final months = (endDate.year - now.year) * 12 + (endDate.month - now.month);
    return months < 0 ? 0 : months;
  }

  static int _calculateWeeksCompleted(DateTime startDate, DateTime now) {
    return now.difference(startDate).inDays ~/ 7;
  }

  static int _calculateWeeksRemaining(DateTime endDate, DateTime now) {
    final weeks = endDate.difference(now).inDays ~/ 7;
    return weeks < 0 ? 0 : weeks;
  }

  List<CourseActivity> _getActivitiesForCurrentWeek() {
    final start = _startOfWeek(now);
    final end = start.add(const Duration(days: 7));
    return _getActivitiesInRange(courseActivities, start, end);
  }

  List<CourseActivity> _getActivitiesForNextWeek() {
    final startOfNextWeek = _startOfWeek(now).add(const Duration(days: 7));
    final endOfNextWeek = startOfNextWeek.add(const Duration(days: 7));
    return _getActivitiesInRange(courseActivities, startOfNextWeek, endOfNextWeek);
  }

  int _calculateUsualWeekendGapDays({required DateTime excludeStart, required DateTime excludeEnd}) {
    if (courseActivities.length < 2) return _defaultWeekendGapDays;

    final sortedActivities = List<CourseActivity>.from(courseActivities)
      ..sort((a, b) => a.startDateTime.compareTo(b.startDateTime));

    final gaps = <int>[];
    final excludeStartDate = _dateOnly(excludeStart);
    final excludeEndDate = _dateOnly(excludeEnd);

    for (int i = 0; i < sortedActivities.length - 1; i++) {
      final current = sortedActivities[i].startDateTime;
      final next = sortedActivities[i + 1].startDateTime;

      if (_startOfWeek(current).isAtSameMomentAs(_startOfWeek(next))) {
        continue;
      }

      if (_dateOnly(current).isAtSameMomentAs(excludeStartDate) && _dateOnly(next).isAtSameMomentAs(excludeEndDate)) {
        continue;
      }

      final gapDays = _daysBetweenCourseDays(current, next);
      if (gapDays > 0) {
        gaps.add(gapDays);
      }
    }

    if (gaps.isEmpty) return _defaultWeekendGapDays;

    gaps.sort();
    return gaps[(gaps.length - 1) ~/ 2];
  }

  DateTime? _findNextActivity() {
    final endOfWeek = _startOfWeek(now).add(const Duration(days: 7));

    final futureActivities = courseActivities.where((a) => !a.startDateTime.isBefore(endOfWeek)).toList()
      ..sort((a, b) => a.startDateTime.compareTo(b.startDateTime));

    return futureActivities.isNotEmpty ? futureActivities.first.startDateTime : null;
  }

  ReplacedDay? getUpcomingReplacedDay() {
    if (replacedDays.isEmpty) return null;

    final today = _dateOnly(now);
    final sevenDaysFromNow = today.add(const Duration(days: 7));

    final upcoming = replacedDays.where((replacedDay) {
      final originalDate = _dateOnly(replacedDay.originalDate);
      return !originalDate.isBefore(today) && originalDate.isBefore(sevenDaysFromNow);
    }).toList();

    if (upcoming.isEmpty) return null;

    upcoming.sort((a, b) => _dateOnly(a.originalDate).compareTo(_dateOnly(b.originalDate)));

    return upcoming.first;
  }

  bool isReplacedDayCancellation(ReplacedDay replacedDay) {
    return replacedDay.replacementDate.isBefore(replacedDay.originalDate);
  }
}
