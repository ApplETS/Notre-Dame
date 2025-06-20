// Project imports:
import 'package:notredame/data/repositories/course_repository.dart';
import 'package:notredame/data/services/signets-api/models/schedule_activity.dart';
import 'package:notredame/locator.dart';

class DynamicMessagesService {
  final CourseRepository _courseRepository = locator<CourseRepository>();

  Future<String> getDynamicMessage() async {
    if (!(sessionHasStarted())) {
      return "Repose-toi bien! La session recommence le ${upcomingSessionstartDate()}";
    }

    if (oneWeekRemainingUntilSessionEnd()) {
      return "Encore ${sessionEndDaysRemaining()} jours et c'est fini !";
    }

    if (sessionRecentlyStarted()) {
      return "Bon début de session !";
    }

    if (isEndOfWeek()) {
      return isEndOfFirstWeek()
          ? "Première semaine de la session complétée, continue !"
          : "${getCompletedWeeks()} semaine complétée !";
    }

    if (isOneMonthOrLessRemaining()) {
      final remaining = getRemainingWeeks();
      final semaine = remaining == 1 ? 'semaine' : 'semaines';
      return "Tiens bon, il ne reste que $remaining $semaine !";
    }

    return "";
  }

  bool sessionHasStarted() {
    final now = DateTime.now();
    final firstActiveSession = _courseRepository.activeSessions.first;
    return firstActiveSession.startDate.isAfter(now);
  }

  String upcomingSessionstartDate() {
    final firstActiveSession = _courseRepository.activeSessions.first;
    return firstActiveSession.startDate.toString();
  }

  bool oneWeekRemainingUntilSessionEnd() {
    final now = DateTime.now();
    final firstActiveSession = _courseRepository.activeSessions.first;
    final endDate = firstActiveSession.endDate;

    final difference = endDate.difference(now).inDays;
    return difference <= 7 && difference >= 0;
  }

  String sessionEndDaysRemaining() {
    final now = DateTime.now();
    final firstActiveSession = _courseRepository.activeSessions.first;
    final endDate = firstActiveSession.endDate;

    return endDate.difference(now).inDays.toString();
  }

  bool sessionRecentlyStarted() {
    final now = DateTime.now();
    final oneWeekAgo = now.subtract(Duration(days: 7));
    final firstActiveSession = _courseRepository.activeSessions.first;

    return firstActiveSession.startDate.isAfter(oneWeekAgo) && firstActiveSession.startDate.isBefore(now);
  }

  bool isEndOfWeek() {
    // TODO: Add checks
    //  - if there are weekend courses
    //  - if friday time is after courses
    final now = DateTime.now();
    return now.weekday == DateTime.friday || now.weekday == DateTime.saturday || now.weekday == DateTime.sunday;
  }

  bool isEndOfFirstWeek() {
    final now = DateTime.now();
    final startDate = _courseRepository.activeSessions.first.startDate;

    final isFirstWeek = now.difference(startDate).inDays < 7 && now.weekday >= startDate.weekday;

    return isFirstWeek;
  }

  int getCompletedWeeks() {
    final now = DateTime.now();
    final startDate = _courseRepository.activeSessions.first.startDate;

    final daysPassed = now.difference(startDate).inDays;
    final fullWeeks = daysPassed ~/ 7;

    return fullWeeks > 0 ? fullWeeks : 0;
  }

  bool isOneMonthOrLessRemaining() {
    final now = DateTime.now();
    final firstActiveSession = _courseRepository.activeSessions.first;
    final endDate = firstActiveSession.endDate;

    final daysRemaining = endDate.difference(now).inDays;

    return daysRemaining <= 30 && daysRemaining >= 0;
  }

  int getRemainingWeeks() {
    final now = DateTime.now();
    final endDate = _courseRepository.activeSessions.first.endDate;

    if (endDate.isBefore(now)) return 0;

    final daysRemaining = endDate.difference(now).inDays;
    final remainingWeeks = (daysRemaining / 7).ceil();

    return remainingWeeks;
  }

  /// Checks if a specific week has a weekend that is longer than usual
  bool longWeekendIncoming() {
    List<ScheduleActivity>? schedule = _courseRepository.scheduleActivities;
    if (schedule == null || schedule.isEmpty) return false;

    Set<int> regularDays = _getRegularCourseDays(schedule);
    DateTime now = DateTime.now();
    DateTime startOfCurrentWeek = _getStartOfWeek(now);

    int mondayIndex = 1;
    int fridayIndex = 5;

    // Current week
    DateTime weekStart = startOfCurrentWeek;
    Set<int> actualDays = _getActualClassDaysForWeek(weekStart);
    Set<int> missingDays = regularDays.difference(actualDays);

    // Find consecutive course days starting from friday all the way to monday
    int lastWeekdayCourse = fridayIndex;
    for (var i = fridayIndex; i >= 1; i--) {
      if (!regularDays.contains(i) && i == lastWeekdayCourse) {
        lastWeekdayCourse--;
      }
    }

    // If last course of the current week (starting from friday) is missed
    // then the weekend will be longer than usual
    if (missingDays.contains(lastWeekdayCourse)) {
      return true;
    }

    // TODO : Check if at least one course in current week
    // TODO : Handle weekend courses
    // TODO : Remove code duplication for both current and next week checks

    // Next week
    DateTime nextWeekStart = startOfCurrentWeek.add(Duration(days: 7));
    Set<int> actualDaysNextWeek = _getActualClassDaysForWeek(nextWeekStart);
    Set<int> missingDaysNextWeek = regularDays.difference(actualDaysNextWeek);

    // Find consecutive course days starting from monday all to day to friday
    int firstWeekdayCourse = mondayIndex;
    for (var i = mondayIndex; i <= 5; i++) {
      if (!regularDays.contains(i) && i == firstWeekdayCourse) {
        firstWeekdayCourse++;
      }
    }

    // If first course of the next week (starting from monday) is missed
    // then the weekend will be longer than usual
    if (missingDaysNextWeek.contains(lastWeekdayCourse)) {
      return true;
    }

    return false;
  }

  Set<int> _getActualClassDaysForWeek(DateTime weekStart) {
    final weekEnd = weekStart.add(Duration(days: 6));
    final schedule = _courseRepository.scheduleActivities ?? [];

    return schedule
        .where((activity) {
          final activityDate = DateTime(activity.startTime.year, activity.startTime.month, activity.startTime.day);
          return activityDate.isAfter(weekStart.subtract(Duration(days: 1))) &&
              activityDate.isBefore(weekEnd.add(Duration(days: 1)));
        })
        .map((activity) => activity.dayOfTheWeek)
        .toSet();
  }

  /// Determines which days of the week the user regularly has classes
  Set<int> _getRegularCourseDays(List<ScheduleActivity> schedule) {
    return schedule.map((activity) => activity.dayOfTheWeek).toSet();
  }

  // Helper method to get the start of the week (Monday)
  DateTime _getStartOfWeek(DateTime date) {
    int daysToSubtract = date.weekday - 1;
    return DateTime(date.year, date.month, date.day).subtract(Duration(days: daysToSubtract));
  }
}
