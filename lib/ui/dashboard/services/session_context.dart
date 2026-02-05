// Project imports:
import 'package:notredame/data/services/signets-api/models/course_activity.dart';
import 'package:notredame/data/services/signets-api/models/session.dart';

class SessionContext {
  final Session session;
  final List<CourseActivity> courseActivities;
  final DateTime now;

  final bool isSessionStarted;
  final int daysRemaining;
  final int daysSinceStart;
  final bool isLastDayOfWeek;
  final int monthsCompleted;
  final int monthsRemaining;
  final int weeksCompleted;
  final int weeksRemaining;
  final int courseDaysThisWeek;
  final bool isFirstWeek;

  SessionContext({
    required this.session,
    required this.courseActivities,
    required this.now,
    required this.isSessionStarted,
    required this.daysRemaining,
    required this.daysSinceStart,
    required this.isLastDayOfWeek,
    required this.monthsCompleted,
    required this.monthsRemaining,
    required this.weeksCompleted,
    required this.weeksRemaining,
    required this.courseDaysThisWeek,
    required this.isFirstWeek,
  });

  factory SessionContext.fromSession({
    required Session session,
    required List<CourseActivity> activities,
    required DateTime now,
  }) {
    return SessionContext(
      session: session,
      courseActivities: activities,
      now: now,
      isSessionStarted: now.isAfter(session.startDate),
      daysRemaining: session.startDate.difference(now).inDays,
      daysSinceStart: session.endDate.difference(now).inDays,
      isLastDayOfWeek: _isLastCourseDayOfWeek(activities, now),
      monthsCompleted: _calculateMonthsCompleted(session.startDate, now),
      monthsRemaining: _calculateMonthsRemaining(session.startDate, now),
      weeksCompleted: _calculateWeeksCompleted(session.startDate, now),
      weeksRemaining: _calculateWeeksRemaining(session.startDate, now),
      courseDaysThisWeek: _calculateCourseDaysThisWeek(activities, now),
      isFirstWeek: _isFirstWeek(session.startDate, now),
    );
  }

  static DateTime _dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

  static DateTime _startOfWeek(DateTime date) => _dateOnly(date).subtract(Duration(days: date.weekday - 1));

  static List<CourseActivity> _getActivitiesInRange(List<CourseActivity> activities, DateTime start, DateTime end) {
    return activities.where((a) => !a.startDateTime.isBefore(start) && a.startDateTime.isBefore(end)).toList();
  }

  static List<DateTime> _getUniqueDays(List<CourseActivity> activities) {
    return activities.map((a) => _dateOnly(a.startDateTime)).toSet().toList()..sort();
  }

  bool get hasNextWeekSchedule => _getActivitiesForNextWeek().isNotEmpty;

  bool get isLongWeekend {
    final thisWeek = _getActivitiesForCurrentWeek();
    final nextWeek = _getActivitiesForNextWeek();

    if (thisWeek.isEmpty) return false;

    final lastActivityThisWeek = thisWeek.map((a) => a.startDateTime).reduce((a, b) => a.isAfter(b) ? a : b);

    if (nextWeek.isEmpty) {
      final daysUntilNextActivity = _findNextActivity()?.difference(lastActivityThisWeek).inDays ?? 0;
      return daysUntilNextActivity > 2;
    }

    final firstActivityNextWeek = nextWeek.map((a) => a.startDateTime).reduce((a, b) => a.isBefore(b) ? a : b);

    return firstActivityNextWeek.difference(lastActivityThisWeek).inDays > 2;
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

  static bool _isLastCourseDayOfWeek(List<CourseActivity> activities, DateTime now) {
    final today = _dateOnly(now);
    final start = _startOfWeek(now);
    final end = start.add(const Duration(days: 7));
    final thisWeekActivities = _getActivitiesInRange(activities, start, end);

    if (thisWeekActivities.isEmpty) return false;

    final daysWithActivities = _getUniqueDays(thisWeekActivities);
    return daysWithActivities.last.isAtSameMomentAs(today);
  }

  static int _calculateMonthsCompleted(DateTime startDate, DateTime now) {
    return (now.year - startDate.year) * 12 + now.month - startDate.month;
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

  static bool _isFirstWeek(DateTime startDate, DateTime now) {
    return now.difference(startDate).inDays < 7;
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

  DateTime? _findNextActivity() {
    final endOfWeek = now.add(Duration(days: 7 - now.weekday));

    final futureActivities = courseActivities.where((a) => a.startDateTime.isAfter(endOfWeek)).toList()
      ..sort((a, b) => a.startDateTime.compareTo(b.startDateTime));

    return futureActivities.isNotEmpty ? futureActivities.first.startDateTime : null;
  }
}
