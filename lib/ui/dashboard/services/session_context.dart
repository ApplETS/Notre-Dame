import 'package:notredame/data/services/signets-api/models/course_activity.dart';
import 'package:notredame/data/services/signets-api/models/session.dart';

class SessionContext {
  final Session session;
  final List<CourseActivity> courseActivities;

  final bool isSessionStarted;
  final int daysRemaining;
  final bool isLastDayOfWeek;
  final int sessionStartedMonthsAgo;
  final bool isFirstWeek;

  SessionContext({
    required this.session,
    required this.courseActivities,
    required this.isSessionStarted,
    required this.daysRemaining,
    required this.isLastDayOfWeek,
    required this.sessionStartedMonthsAgo,
    required this.isFirstWeek,
  });

  factory SessionContext.fromSession({required Session session, required List<CourseActivity> activities}) {
    final now = DateTime.now();

    return SessionContext(
      session: session,
      courseActivities: activities,
      isSessionStarted: now.isAfter(session.startDate),
      daysRemaining: session.endDate.difference(now).inDays,
      isLastDayOfWeek: now.weekday == DateTime.friday,
      sessionStartedMonthsAgo: _calculateMonthsSince(session.startDate, now),
      isFirstWeek: _isFirstWeek(session.startDate, now),
    );
  }

  bool get hasNextWeekSchedule {
    final nextWeekActivities = getActivitiesForNextWeek();
    return nextWeekActivities.isNotEmpty;
  }

  bool get isLongWeekend {
    final thisWeek = getActivitiesForCurrentWeek();
    final nextWeek = getActivitiesForNextWeek();

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
    final nextWeek = getActivitiesForNextWeek();
    if (nextWeek.isEmpty) return true;

    final uniqueDays = nextWeek
        .map((a) => DateTime(a.startDateTime.year, a.startDateTime.month, a.startDateTime.day))
        .toSet()
        .length;

    return uniqueDays < 5;
  }

  List<CourseActivity> getActivitiesForCurrentWeek() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(Duration(days: 7));

    return courseActivities.where((activity) {
      return activity.startDateTime.isAfter(startOfWeek) && activity.startDateTime.isBefore(endOfWeek);
    }).toList();
  }

  List<CourseActivity> getActivitiesForNextWeek() {
    final now = DateTime.now();
    final startOfNextWeek = now.add(Duration(days: 7 - now.weekday + 1));
    final endOfNextWeek = startOfNextWeek.add(Duration(days: 7));

    return courseActivities.where((activity) {
      return activity.startDateTime.isAfter(startOfNextWeek) && activity.startDateTime.isBefore(endOfNextWeek);
    }).toList();
  }

  DateTime? _findNextActivity() {
    final now = DateTime.now();
    final endOfWeek = now.add(Duration(days: 7 - now.weekday));

    final futureActivities = courseActivities.where((a) => a.startDateTime.isAfter(endOfWeek)).toList()
      ..sort((a, b) => a.startDateTime.compareTo(b.startDateTime));

    return futureActivities.isNotEmpty ? futureActivities.first.startDateTime : null;
  }

  static int _calculateMonthsSince(DateTime startDate, DateTime now) {
    return ((now.year - startDate.year) * 12 + now.month - startDate.month);
  }

  static bool _isFirstWeek(DateTime startDate, DateTime now) {
    return now.difference(startDate).inDays < 7;
  }
}
