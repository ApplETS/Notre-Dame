// Package imports:
import 'package:collection/collection.dart';

// Project imports:
import 'package:notredame/data/repositories/course_repository.dart';
import 'package:notredame/data/repositories/settings_repository.dart';
import 'package:notredame/l10n/app_localizations.dart';
import 'package:notredame/ui/dashboard/services/long_weekend_status.dart';
import 'package:notredame/data/services/signets-api/models/course_activity.dart';
import 'package:notredame/data/services/signets-api/models/replaced_day.dart';
import 'package:notredame/data/services/signets-api/models/schedule_activity.dart';
import 'package:notredame/locator.dart';

class DynamicMessagesService {
  final CourseRepository _courseRepository = locator<CourseRepository>();
  final SettingsRepository settingsManager = locator<SettingsRepository>();
  AppIntl intl;

  DynamicMessagesService(this.intl);

  Future<String> getDynamicMessage() async {
    await fetchData();

    if (!(sessionHasStarted())) {
      return intl.dynamic_message_session_starts_soon(upcomingSessionstartDate());
    }

    if (oneWeekRemainingUntilSessionEnd()) {
      return intl.dynamic_message_days_before_session_ends(sessionEndDaysRemaining());
    }

    LongWeekendStatus incomingLongWeekendStatus = longWeekendIncoming();
    if (incomingLongWeekendStatus == LongWeekendStatus.incoming) {
      return intl.dynamic_message_long_weekend_incoming;
    } else if (incomingLongWeekendStatus == LongWeekendStatus.inside) {
      return intl.dynamic_message_long_weekend_currently(getCompletedWeeks());
    }

    if (shouldDisplayLastCourseDayOfCurWeek()) {
      return intl.dynamic_message_last_course_day_of_session(getCurrentWeekDayName());
    }

    if (hasUpcomingHoliday()) {
      String? date = getUpcomingHolidayDate();
      if (date != null) {
        return intl.dynamic_message_public_holiday_incoming(date);
      }
    }

    if (isEndOfWeek()) {
      return isEndOfFirstWeek()
          ? intl.dynamic_message_first_week_of_session_completed
          : intl.dynamic_message_end_of_week(getCompletedWeeks());
    }

    // TODO : Maybe move higher up
    if (isFirstWeek()) {
      return intl.dynamic_message_first_week_of_session;
    }

    if (isOneMonthOrLessRemaining()) {
      return intl.dynamic_message_less_one_month_remaining(
        getRemainingWeeks(),
      ); // TODO : Différencier entre fin des cours et période d'examens
    }

    // TODO : Ajouter messages génériques
    return "Message générique";
  }

  Future<void> fetchData() async {
    await Future.wait([
      /*_courseRepository.getSessions(),
      _courseRepository.getReplacedDays(),
      _courseRepository.getScheduleActivities(),
      _courseRepository.getCoursesActivities(),*/
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

  int sessionEndDaysRemaining() {
    final now = DateTime.now();
    final firstActiveSession = _courseRepository.activeSessions.first;
    final endDate = firstActiveSession.endDate;

    return endDate.difference(now).inDays;
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
    if (now.weekday != DateTime.friday && now.weekday != DateTime.saturday && now.weekday != DateTime.sunday) {
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

    return false;
  }

  bool isEndOfFirstWeek() {
    DateTime now = DateTime.now();
    DateTime startDate = _courseRepository.activeSessions.first.startDate;

    Set<int> daysTooLateFirstWeek = {DateTime.thursday, DateTime.friday, DateTime.saturday, DateTime.sunday};

    // If session started late in the week, consider next Monday as the real start
    if (daysTooLateFirstWeek.contains(startDate.weekday)) {
      int daysUntilNextMonday = (DateTime.monday - startDate.weekday + 7) % 7;
      DateTime adjustedStartDate = startDate.add(Duration(days: daysUntilNextMonday));

      // Keep message active through the weekend
      DateTime endOfWeek = adjustedStartDate.add(Duration(days: 6));
      return now.isAfter(adjustedStartDate.subtract(Duration(days: 1))) &&
          now.isBefore(endOfWeek.add(Duration(days: 1)));
    } else {
      bool isFirstWeek = now.difference(startDate).inDays < 7 && now.weekday >= startDate.weekday;
      return isFirstWeek;
    }
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

  // TODO : Handle when two consecutive weeks have long weekends
  /// Check if a specific week has a weekend that is longer than usual
  LongWeekendStatus longWeekendIncoming() {
    List<ScheduleActivity>? schedule = _courseRepository.scheduleActivities;
    if (schedule == null || schedule.isEmpty) return LongWeekendStatus.none;

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
      return LongWeekendStatus.none;
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
        return LongWeekendStatus.none;
      }
    }

    // If user is already in long weekend
    if (now.weekday > actualDays.max && missingDays.contains(lastWeekdayCourse)) {
      return LongWeekendStatus.inside;
    }

    // If last course day of the current week (starting from friday) is missed
    // then the weekend will be longer than usual
    if (missingDays.contains(lastWeekdayCourse)) {
      return LongWeekendStatus.incoming;
    }

    // Next week
    DateTime nextWeekStart = startOfCurrentWeek.add(Duration(days: 7));
    Set<int> actualDaysNextWeek = _getActualClassDaysForWeek(nextWeekStart);
    Set<int> missingDaysNextWeek = regularDays.difference(actualDaysNextWeek);

    // If next week doesn't have at least one course
    // then don't consider it a long weekend
    if (actualDaysNextWeek.isEmpty) {
      return LongWeekendStatus.none;
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
      if (actualDaysNextWeek.contains(i)) {
        return LongWeekendStatus.none;
      }
    }

    // If user is already in long weekend
    if (now.weekday > actualDaysNextWeek.min &&
        missingDaysNextWeek.contains(firstWeekdayCourse) &&
        now.weekday > actualDays.max) {
      return LongWeekendStatus.inside;
    }

    // If first course day of the next week (starting from monday) is missed
    // then the weekend will be longer than usual
    if (missingDaysNextWeek.contains(firstWeekdayCourse)) {
      return LongWeekendStatus.incoming;
    }

    return LongWeekendStatus.none;
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
    List<CourseActivity>? allCourses = _courseRepository.coursesActivities;

    // Counts how many times each course activity happens in a session
    Map<String, int> courseCounts = {};

    if (allCourses != null) {
      for (var course in allCourses) {
        courseCounts[course.courseName] = (courseCounts[course.courseName] ?? 0) + 1;
      }
    }

    int minOccurence = 12;

    // Filter schedule to only include activities with at least [minOccurence] occurrences
    Iterable<ScheduleActivity> filteredActivities = schedule.where((activity) {
      int? count = courseCounts[activity.courseTitle];
      return (count != null && count >= minOccurence);
    });

    return filteredActivities.map((activity) => activity.dayOfTheWeek).toSet();
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

    // TODO : Maybe change to two days
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
