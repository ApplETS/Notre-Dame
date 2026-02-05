// Project imports:
import 'package:notredame/data/services/signets-api/models/course_activity.dart';
import 'package:notredame/data/services/signets-api/models/session.dart';

class SessionContext {
  final Session session;
  final List<CourseActivity> courseActivities;

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

  bool get hasNextWeekSchedule {
    final nextWeekActivities = _getActivitiesForNextWeek();
    return nextWeekActivities.isNotEmpty;
  }

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

    final gapDays = firstActivityNextWeek.difference(lastActivityThisWeek).inDays;

    return gapDays > 2;
  }

  bool get isNextWeekShorter {
    final nextWeek = _getActivitiesForNextWeek();
    if (nextWeek.isEmpty) return true;

    final uniqueDays = nextWeek
        .map((a) => DateTime(a.startDateTime.year, a.startDateTime.month, a.startDateTime.day))
        .toSet()
        .length;

    return uniqueDays < 5;
  }

  bool get isLastCourseDayOfWeek {
    final thisWeek = _getActivitiesForCurrentWeek();
    if (thisWeek.isEmpty) return false;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final daysWithActivities =
        thisWeek.map((a) => DateTime(a.startDateTime.year, a.startDateTime.month, a.startDateTime.day)).toSet().toList()
          ..sort();

    return daysWithActivities.isNotEmpty && daysWithActivities.last.isAtSameMomentAs(today);
  }

  static int _calculateCourseDaysThisWeek(List<CourseActivity> activities, DateTime now) {
    final startOfWeek = DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 7));

    final thisWeekActivities = activities.where((activity) {
      return activity.startDateTime.isAfter(startOfWeek) && activity.startDateTime.isBefore(endOfWeek);
    }).toList();

    return thisWeekActivities
        .map((a) => DateTime(a.startDateTime.year, a.startDateTime.month, a.startDateTime.day))
        .toSet()
        .length;
  }

  static bool _isLastCourseDayOfWeek(List<CourseActivity> activities, DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    final startOfWeek = today.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 7));

    final thisWeekActivities = activities.where((activity) {
      return activity.startDateTime.isAfter(startOfWeek) && activity.startDateTime.isBefore(endOfWeek);
    }).toList();

    if (thisWeekActivities.isEmpty) return false;

    final daysWithActivities =
        thisWeekActivities
            .map((a) => DateTime(a.startDateTime.year, a.startDateTime.month, a.startDateTime.day))
            .toSet()
            .toList()
          ..sort();

    return daysWithActivities.last.isAtSameMomentAs(today);
  }

  List<CourseActivity> _getActivitiesForCurrentWeek() {
    final now = DateTime.now();
    final startOfWeek = DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 7));

    return courseActivities.where((activity) {
      return activity.startDateTime.isAfter(startOfWeek) && activity.startDateTime.isBefore(endOfWeek);
    }).toList();
  }

  List<CourseActivity> _getActivitiesForNextWeek() {
    final now = DateTime.now();

    final startOfThisWeek = DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));

    final startOfNextWeek = startOfThisWeek.add(const Duration(days: 7));
    final endOfNextWeek = startOfNextWeek.add(const Duration(days: 7));

    return courseActivities.where((activity) {
      return !activity.startDateTime.isBefore(startOfNextWeek) && activity.startDateTime.isBefore(endOfNextWeek);
    }).toList();
  }

  DateTime? _findNextActivity() {
    final now = DateTime.now();
    final endOfWeek = now.add(Duration(days: 7 - now.weekday));

    final futureActivities = courseActivities.where((a) => a.startDateTime.isAfter(endOfWeek)).toList()
      ..sort((a, b) => a.startDateTime.compareTo(b.startDateTime));

    return futureActivities.isNotEmpty ? futureActivities.first.startDateTime : null;
  }

  static int _calculateMonthsCompleted(DateTime startDate, DateTime now) {
    return ((now.year - startDate.year) * 12 + now.month - startDate.month);
  }

  static int _calculateMonthsRemaining(DateTime endDate, DateTime now) {
    final months = (endDate.year - now.year) * 12 + (endDate.month - now.month);

    return months < 0 ? 0 : months;
  }

  static int _calculateWeeksCompleted(DateTime startDate, DateTime now) {
    final differenceInDays = now.difference(startDate).inDays;
    return differenceInDays ~/ 7;
  }

  static int _calculateWeeksRemaining(DateTime endDate, DateTime now) {
    final differenceInDays = endDate.difference(now).inDays;
    final weeks = differenceInDays ~/ 7;

    return weeks < 0 ? 0 : weeks;
  }

  static bool _isFirstWeek(DateTime startDate, DateTime now) {
    return now.difference(startDate).inDays < 7;
  }
}
