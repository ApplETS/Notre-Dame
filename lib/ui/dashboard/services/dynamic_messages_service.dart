// Project imports:
import 'package:notredame/data/repositories/course_repository.dart';
import 'package:notredame/data/services/signets-api/models/replaced_day.dart';
import 'package:notredame/data/services/signets-api/models/schedule_activity.dart';
import 'package:notredame/locator.dart';

class DynamicMessagesService {
  final CourseRepository _courseRepository = locator<CourseRepository>();

  Future<String> getDynamicMessage() async {
    await fetchData();

    if (!(sessionHasStarted())) {
      return "Repose-toi bien! La session recommence le ${upcomingSessionstartDate()}";
    }

    if (oneWeekRemainingUntilSessionEnd()) {
      return "Encore ${sessionEndDaysRemaining()} jours et c'est fini !";
    }

    // TODO : Add message if long weekend is currently happening
    if (longWeekendIncoming()) {
      return "Une longue fin de semaine s'en vient !";
    }

    // TODO : Regarder jour férier
    if (hasUpcomingHoliday()) {
      return "Jour férier $getUpcomingHolidayDate() !";
    }

    if (shouldDisplayLastCourseOfCurWeek()) {
      return "Fabuleux c'est ${getCurrentWeekDayName()} ! Dernière journée de cours de la semaine !";
    }

    // TODO : Check if this is after last course of the week.
    //  Check order vs last course day
    if (isEndOfWeek()) {
      return isEndOfFirstWeek()
          ? "Première semaine de la session complétée, continue !"
          : "${getCompletedWeeks()} semaine complétée !";
    }

    if (isFirstWeek()) {
      return "Bon début de session !";
    }

    if (isOneMonthOrLessRemaining()) {
      final remaining = getRemainingWeeks();
      final semaine = remaining == 1 ? 'semaine' : 'semaines';
      return "Tiens bon, il ne reste que $remaining $semaine !";
    }

    return "";
  }

  Future<void> fetchData() async {
    await Future.wait([
      _courseRepository.getSessions(),
      _courseRepository.getReplacedDays(),
      _courseRepository.getScheduleActivities(),
      _courseRepository.getCoursesActivities(),
    ]);
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

    // TODO : Maybe keep it all weekend
    final isFirstWeek = now.difference(startDate).inDays < 7 && now.weekday >= startDate.weekday;

    return isFirstWeek;
  }

  bool isFirstWeek() {
    final now = DateTime.now();
    final startDate = _courseRepository.activeSessions.first.startDate;

    final isFirstWeek = now.difference(startDate).inDays < 7;

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

  /// Check if a specific week has a weekend that is longer than usual
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
    int lastWeekdayCourse = -1;
    for (var i = fridayIndex; i >= mondayIndex; i--) {
      if (regularDays.contains(i)) {
        lastWeekdayCourse = i;
        break;
      }
    }

    // If last course day of the current week (starting from friday) is missed
    // then the weekend will be longer than usual
    if (missingDays.contains(lastWeekdayCourse)) {
      return true;
    }

    // TODO : Handle replaced days (ex: for holidays).
    //  Could verify that rest of the week (starting from "lastWeekdayCourse") doesn't have courses

    // TODO : Check if at least one course is in the current week
    // TODO : Handle weekend courses ?
    // TODO : Remove code duplication for both current and next week checks

    // Next week
    DateTime nextWeekStart = startOfCurrentWeek.add(Duration(days: 7));
    Set<int> actualDaysNextWeek = _getActualClassDaysForWeek(nextWeekStart);
    Set<int> missingDaysNextWeek = regularDays.difference(actualDaysNextWeek);

    // Find consecutive course days starting from monday all the way to friday
    int firstWeekdayCourse = -1;
    for (var i = mondayIndex; i >= fridayIndex; i++) {
      if (regularDays.contains(i)) {
        lastWeekdayCourse = i;
        break;
      }
    }

    // If first course of the next week (starting from monday) is missed
    // then the weekend will be longer than usual
    if (missingDaysNextWeek.contains(firstWeekdayCourse)) {
      return true;
    }

    return false;
  }

  Set<int> _getActualClassDaysForWeek(DateTime weekStart) {
    final weekEnd = weekStart.add(Duration(days: 6));
    final schedule = _courseRepository.coursesActivities ?? [];

    return schedule
        .where((activity) {
          final activityDate = DateTime(
            activity.startDateTime.year,
            activity.startDateTime.month,
            activity.startDateTime.day,
          );
          return activityDate.isAfter(weekStart.subtract(Duration(days: 1))) &&
              activityDate.isBefore(weekEnd.add(Duration(days: 1)));
        })
        .map((activity) => activity.startDateTime.weekday)
        .toSet();
  }

  /// Determines which days of the week the user regularly has classes
  Set<int> _getRegularCourseDays(List<ScheduleActivity> schedule) {
    return schedule.map((activity) => activity.dayOfTheWeek).toSet();
  }

  /// Helper method to get the start date of the week (Monday)
  DateTime _getStartOfWeek(DateTime date) {
    int daysToSubtract = date.weekday - 1;
    return DateTime(date.year, date.month, date.day).subtract(Duration(days: daysToSubtract));
  }

  //MARK: upcoming holiday
  DateTime? getUpcomingHolidayDate() {
    List<ReplacedDay>? replacedDays = _courseRepository.replacedDays;

    if (replacedDays == null || replacedDays.isEmpty) {
      return null;
    }

    final now = DateTime.now();
    final oneWeekFromNow = now.add(Duration(days: 7));

    final upcomingHolidays = replacedDays
        .where((event) => event.originalDate.isAfter(now) && event.originalDate.isBefore(oneWeekFromNow))
        .toList();

    if (upcomingHolidays.isEmpty) {
      return null;
    }

    upcomingHolidays.sort((a, b) => a.originalDate.compareTo(b.originalDate));

    return upcomingHolidays.first.originalDate;
  }

  bool hasUpcomingHoliday() {
    return getUpcomingHolidayDate() != null;
  }

  bool shouldDisplayLastCourseOfCurWeek() {
    DateTime now = DateTime.now();
    DateTime startOfCurrentWeek = _getStartOfWeek(now);

    Set<int> actualDays = _getActualClassDaysForWeek(startOfCurrentWeek);
    List<int> sortedDays = actualDays.toList()..sort();

    if (sortedDays.length < 3) {
      return false;
    }

    int todayWeekday = now.weekday;
    int lastClassDay = sortedDays.last;

    return todayWeekday == lastClassDay;
  }

  String getCurrentWeekDayName() {
    DateTime now = DateTime.now();
    List<String> weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return weekdays[now.weekday - 1];
  }

  DateTime? getLastCourseOfWeekDate() {
    DateTime now = DateTime.now();
    DateTime startOfCurrentWeek = _getStartOfWeek(now);

    Set<int> actualDays = _getActualClassDaysForWeek(startOfCurrentWeek);
    List<int> sortedDays = actualDays.toList()..sort();

    if (sortedDays.isEmpty) {
      return null;
    }

    int lastClassDay = sortedDays.last;

    return startOfCurrentWeek.add(Duration(days: lastClassDay - 1));
  }
}
