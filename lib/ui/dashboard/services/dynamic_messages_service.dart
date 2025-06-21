// Project imports:
import 'package:notredame/data/repositories/course_repository.dart';
import 'package:notredame/data/services/signets-api/models/course_activity.dart';
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
    //  Example : enjoy long weekend !
    if (longWeekendIncoming()) {
      return "Une longue fin de semaine s'en vient !";
    }

    if (hasUpcomingHoliday()) {
      return "Jour férier le ${getUpcomingHolidayDate()} !";
    }

    if (shouldDisplayLastCourseDayOfCurWeek()) {
      return "Fabuleux c'est ${getCurrentWeekDayName()} ! Dernière journée de cours de la semaine !";
    }

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
    return firstActiveSession.startDate.isBefore(now);
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
    final now = DateTime.now();
    List<CourseActivity>? courses = _courseRepository.coursesActivities;

    DateTime startOfCurrentWeek = _getStartOfWeek(now);
    Set<int> actualDays = _getActualClassDaysForWeek(startOfCurrentWeek);

    if (courses == null || courses.isEmpty) {
      return false;
    }

    // check if current day if either fri, sat, sun
    if (now.weekday != DateTime.friday || now.weekday != DateTime.saturday || now.weekday != DateTime.sunday) {
      return false;
    }

    bool hasFridayCourses = actualDays.contains(5);
    bool hasSaturdayCourses = actualDays.contains(6);
    bool hasSundayCourses = actualDays.contains(7);

    // check if no courses on fri, sat, sun
    if (!actualDays.contains(5) && !actualDays.contains(6) && !actualDays.contains(7)) {
      return true;
    }

    // check if there are courses on sunday
    if (hasSundayCourses) {
      // user doesn't have a weekend this week
      return false;
    } else if (hasSaturdayCourses) {
      DateTime? lastCourseEndTime = getLastCourseEndDateTimeOnSameDay(now);
      if (lastCourseEndTime != null && now.hour > lastCourseEndTime.hour && now.weekday == DateTime.saturday) {
        return true;
      }
    } else if (hasFridayCourses) {
      DateTime? lastCourseEndTime = getLastCourseEndDateTimeOnSameDay(now);
      if (lastCourseEndTime != null && now.isAfter(lastCourseEndTime) && now.weekday == DateTime.friday) {
        return true;
      }
    }

    return true;
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

    // If current week doesn't have at least one course
    // then don't consider it a long weekend
    if (actualDays.isEmpty) {
      return false;
    }

    // Find consecutive course days starting from friday all the way to monday
    int lastWeekdayCourse = -1;
    for (var i = fridayIndex; i >= mondayIndex; i--) {
      if (regularDays.contains(i)) {
        lastWeekdayCourse = i;
        break;
      }
    }

    // Handle replaced days (ex: for holidays)
    for (var i = fridayIndex; i > lastWeekdayCourse; i--) {
      if (actualDays.contains(i)) {
        return false;
      }
    }

    // If last course day of the current week (starting from friday) is missed
    // then the weekend will be longer than usual
    if (missingDays.contains(lastWeekdayCourse)) {
      return true;
    }

    // Next week
    DateTime nextWeekStart = startOfCurrentWeek.add(Duration(days: 7));
    Set<int> actualDaysNextWeek = _getActualClassDaysForWeek(nextWeekStart);
    Set<int> missingDaysNextWeek = regularDays.difference(actualDaysNextWeek);

    // If next week doesn't have at least one course
    // then don't consider it a long weekend
    if (actualDaysNextWeek.isEmpty) {
      return false;
    }

    // Find consecutive course days starting from monday all the way to friday
    int firstWeekdayCourse = -1;
    for (var i = mondayIndex; i <= fridayIndex; i++) {
      if (regularDays.contains(i)) {
        firstWeekdayCourse = i;
        break;
      }
    }

    // Handle replaced days (ex: for holidays)
    for (var i = mondayIndex; i < firstWeekdayCourse; i++) {
      if (actualDays.contains(i)) {
        return false;
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

  DateTime? getLastCourseEndDateTimeOnSameDay(DateTime targetDate) {
    final schedule = _courseRepository.coursesActivities ?? [];

    final matchingDateTimes = schedule
        .where((activity) => _isSameCalendarDay(activity.endDateTime, targetDate))
        .map((activity) => activity.endDateTime)
        .toList();

    if (matchingDateTimes.isEmpty) return null;

    matchingDateTimes.sort();
    return matchingDateTimes.last;
  }

  bool _isSameCalendarDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && date1.month == date2.month && date1.day == date2.day;
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

  String? getUpcomingHolidayDate() {
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

    return upcomingHolidays.first.originalDate.toString();
  }

  bool hasUpcomingHoliday() {
    return getUpcomingHolidayDate() != null;
  }

  bool shouldDisplayLastCourseDayOfCurWeek() {
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
