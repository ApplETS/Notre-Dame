// Package imports:
import 'package:collection/collection.dart';

// Project imports:
import 'package:notredame/data/repositories/course_repository.dart';
import 'package:notredame/data/repositories/settings_repository.dart';
import 'package:notredame/data/services/signets-api/models/session.dart';
import 'package:notredame/data/services/signets-api/models/course_activity.dart';
import 'package:notredame/data/services/signets-api/models/replaced_day.dart';
import 'package:notredame/data/services/signets-api/models/schedule_activity.dart';
import 'package:notredame/l10n/app_localizations.dart';
import 'package:notredame/ui/dashboard/services/long_weekend_status.dart';
import 'package:notredame/locator.dart';

class DynamicMessagesService {
  final CourseRepository _courseRepository = locator<CourseRepository>();
  final SettingsRepository settingsManager = locator<SettingsRepository>();

  final int daysInAWeek = 7;

  AppIntl intl;

  DateTime get now => DateTime(2025, 04, 28);
  Session get firstActiveSession => _courseRepository.activeSessions.first;

  DynamicMessagesService(this.intl);

  Future<String> getDynamicMessage() async {
    await fetchData();

    if (!(sessionHasStarted())) {
      return intl.dynamic_message_session_starts_soon(firstActiveSession.startDate.toString());
    }

    if (oneWeekRemainingUntilSessionEnd()) {
      return intl.dynamic_message_days_before_session_ends(daysRemainingBeforeSessionEnds());
    }

    LongWeekendStatus incomingLongWeekendStatus = getIncomingLongWeekendStatus();
    if (incomingLongWeekendStatus == LongWeekendStatus.incoming) {
      return intl.dynamic_message_long_weekend_incoming;
    } else if (incomingLongWeekendStatus == LongWeekendStatus.inside) {
      return intl.dynamic_message_long_weekend_currently(getCompletedWeeksInCurSession());
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
          : intl.dynamic_message_end_of_week(getCompletedWeeksInCurSession());
    }

    // TODO : Maybe move higher up
    if (isFirstWeek()) {
      return intl.dynamic_message_first_week_of_session;
    }

    if (isOneMonthOrLessRemainingToSession()) {
      return intl.dynamic_message_less_one_month_remaining(
        getRemainingWeeksUntilSessionEnd(),
      ); // TODO : Différencier entre fin des cours et période d'examens
    }

    // TODO : Ajouter messages génériques
    return "Message générique";
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
    final nowDate = DateTime(now.year, now.month, now.day);
    final startDate = DateTime(
      firstActiveSession.startDate.year,
      firstActiveSession.startDate.month,
      firstActiveSession.startDate.day,
    );
    return !startDate.isAfter(nowDate);
  }

  bool oneWeekRemainingUntilSessionEnd() {
    final endDate = firstActiveSession.endDate;

    final daysFromNow = endDate.difference(now).inDays;
    return daysFromNow <= daysInAWeek && daysFromNow >= 0;
  }

  int daysRemainingBeforeSessionEnds() {
    final endDate = firstActiveSession.endDate;
    return endDate.difference(now).inDays;
  }

  bool isEndOfWeek() {
    List<CourseActivity>? courses = _courseRepository.coursesActivities;

    DateTime mondayDateOfCurrentWeek = _getStartOfWeek(now);
    Set<int> curWeekCourseDays = _getClassDaysForWeek(mondayDateOfCurrentWeek);

    if (courses == null || courses.isEmpty) {
      return false;
    }

    int curWeekday = now.weekday;

    // Check that current day is not friday, saturday or sunday
    if (curWeekday != DateTime.friday && curWeekday != DateTime.saturday && curWeekday != DateTime.sunday) {
      return false;
    }

    int fridayWeekdayIndex = 5;
    int saturdayWeekdayIndex = 6;
    int sundayWeekdayIndex = 7;

    bool hasFridayCourses = curWeekCourseDays.contains(fridayWeekdayIndex);
    bool hasSaturdayCourses = curWeekCourseDays.contains(saturdayWeekdayIndex);
    bool hasSundayCourses = curWeekCourseDays.contains(sundayWeekdayIndex);

    // Check that there are no courses on friday, saturday and sunday
    if (!curWeekCourseDays.contains(fridayWeekdayIndex) &&
        !curWeekCourseDays.contains(saturdayWeekdayIndex) &&
        !curWeekCourseDays.contains(sundayWeekdayIndex)) {
      return true;
    }

    DateTime? lastCourseOfWeekEndTime = getLatestCourseEndTime(now);

    // check if there are courses on sunday
    if (hasSundayCourses) {
      // user doesn't have a weekend this week
      return false;
    } else if (hasSaturdayCourses) {
      if (lastCourseOfWeekEndTime != null &&
          now.hour > lastCourseOfWeekEndTime.hour &&
          now.weekday == DateTime.saturday) {
        return true;
      }
    } else if (hasFridayCourses) {
      if (lastCourseOfWeekEndTime != null && now.isAfter(lastCourseOfWeekEndTime) && now.weekday == DateTime.friday) {
        return true;
      }
    }

    return false;
  }

  bool isEndOfFirstWeek() {
    DateTime curSessionStartDate = _courseRepository.activeSessions.first.startDate;
    int curSessionStartDateWeekday = curSessionStartDate.weekday;

    Set<int> daysTooLateForFullFirstWeek = {DateTime.thursday, DateTime.friday, DateTime.saturday, DateTime.sunday};

    // If session started late in the week, consider next Monday as the real start
    if (daysTooLateForFullFirstWeek.contains(curSessionStartDateWeekday)) {
      int daysUntilNextMonday = (DateTime.monday - curSessionStartDateWeekday + 7) % 7;
      DateTime adjustedStartDate = curSessionStartDate.add(Duration(days: daysUntilNextMonday));

      // Include weekend as end of first week
      DateTime endOfWeek = adjustedStartDate.add(Duration(days: 6));
      return now.isAfter(adjustedStartDate.subtract(Duration(days: 1))) &&
          now.isBefore(endOfWeek.add(Duration(days: 1)));
    } else {
      bool isFirstWeek = now.difference(curSessionStartDate).inDays < 7 && now.weekday >= curSessionStartDateWeekday;
      return isFirstWeek;
    }
  }

  bool isFirstWeek() {
    final startDate = _courseRepository.activeSessions.first.startDate;
    final isFirstWeek = now.difference(startDate).inDays < 7;
    return isFirstWeek;
  }

  int getCompletedWeeksInCurSession() {
    DateTime sessionStartDate = _courseRepository.activeSessions.first.startDate;
    int daysPassed = now.difference(sessionStartDate).inDays;
    int fullWeeksPassed = daysPassed ~/ 7;

    return fullWeeksPassed > 0 ? fullWeeksPassed : 0;
  }

  bool isOneMonthOrLessRemainingToSession() {
    DateTime sessionEndDate = firstActiveSession.endDate;
    int sessionDaysRemaining = sessionEndDate.difference(now).inDays;
    return sessionDaysRemaining <= 30 && sessionDaysRemaining >= 0;
  }

  int getRemainingWeeksUntilSessionEnd() {
    DateTime endDate = _courseRepository.activeSessions.first.endDate;

    // If session has ended
    if (endDate.isBefore(now)) return 0;

    int daysRemaining = endDate.difference(now).inDays;
    int remainingWeeks = (daysRemaining / 7).ceil();

    return remainingWeeks;
  }

  int getLastCourseDayOfCurWeek() {
    DateTime startOfCurrentWeek = _getStartOfWeek(now);
    Set<int> courseDays = _getClassDaysForWeek(startOfCurrentWeek);
    int fridayWeekday = 5;
    return courseDays.where((courseWeekday) => courseWeekday <= fridayWeekday).reduce((a, b) => a > b ? a : b);
  }

  int getFirstCourseDayOfNextWeek() {
    DateTime startOfCurrentWeek = _getStartOfWeek(now).add(Duration(days: 7));
    Set<int> courseDays = _getClassDaysForWeek(startOfCurrentWeek);
    int mondayWeekday = 1;
    return courseDays.where((courseWeekday) => courseWeekday >= mondayWeekday).reduce((a, b) => a < b ? a : b);
  }

  int getFirstCourseDayOfCurWeek() {
    DateTime startOfCurrentWeek = _getStartOfWeek(now);
    Set<int> courseDays = _getClassDaysForWeek(startOfCurrentWeek);
    int fridayWeekday = 5;
    return courseDays.where((courseWeekday) => courseWeekday <= fridayWeekday).reduce((a, b) => a < b ? a : b);
  }

  bool _hasCoursesInWeek(DateTime curTime) {
    DateTime startOfCurrentWeek = _getStartOfWeek(curTime);
    Set<int> classDays = _getClassDaysForWeek(startOfCurrentWeek);
    return classDays.isNotEmpty;
  }

  // TODO : Handle when two consecutive weeks have long weekends
  /// Check if a specific week has a weekend that is longer than usual
  LongWeekendStatus getIncomingLongWeekendStatus() {
    List<ScheduleActivity>? schedule = _courseRepository.scheduleActivities;
    if (schedule == null || schedule.isEmpty) return LongWeekendStatus.none;

    Set<int> regularDays = _getRegularCourseDays(schedule);
    DateTime startOfCurrentWeek = _getStartOfWeek(now);

    int mondayIndex = 1;
    int fridayIndex = 5;

    // Current week
    Set<int> classDays = _getClassDaysForWeek(startOfCurrentWeek);
    Set<int> missingDays = regularDays.difference(classDays);

    // If current week doesn't have at least one course
    // then don't consider it a long weekend
    if (!_hasCoursesInWeek(now)) {
      return LongWeekendStatus.none;
    }

    // Find consecutive course days starting from friday all the way to monday
    int lastWeekdayCourseDay = getLastCourseDayOfCurWeek();

    // Handle replaced days (ex: for holidays)
    if (classDays.any((day) => day > lastWeekdayCourseDay && day <= fridayIndex)) {
      return LongWeekendStatus.none;
    }

    // If user is already in long weekend
    if (now.weekday > classDays.max &&
        missingDays.any((weekday) => weekday > lastWeekdayCourseDay && weekday <= fridayIndex)) {
      return LongWeekendStatus.inside;
    }

    // If last course day of the current week (starting from friday) is missed
    // then the weekend will be longer than usual
    if (missingDays.any((weekday) => weekday > lastWeekdayCourseDay && weekday <= fridayIndex)) {
      return LongWeekendStatus.incoming;
    }

    // Next week
    DateTime nextWeekStart = startOfCurrentWeek.add(Duration(days: 7));
    Set<int> classDaysNextWeek = _getClassDaysForWeek(nextWeekStart);
    Set<int> missingDaysNextWeek = regularDays.difference(classDaysNextWeek); // check if days are connected

    // If next week doesn't have at least one course
    // then don't consider it a long weekend
    if (!_hasCoursesInWeek(nextWeekStart)) {
      return LongWeekendStatus.none;
    }

    // Find consecutive course days starting from monday all the way to friday
    int firstWeekdayCourseDay = getFirstCourseDayOfNextWeek();

    // Handle replaced days (ex: for holidays)
    if (classDaysNextWeek.any((day) => day >= mondayIndex && day < firstWeekdayCourseDay)) {
      return LongWeekendStatus.none;
    }

    // If user is already in long weekend
    if (now.weekday < getFirstCourseDayOfCurWeek() && missingDays.contains(now.weekday)) {
      return LongWeekendStatus.inside;
    }

    if (now.weekday > classDays.max &&
        missingDaysNextWeek.any((weekday) => weekday >= mondayIndex && weekday < firstWeekdayCourseDay)) {
      return LongWeekendStatus.inside;
    }

    // If first course day of the next week (starting from monday) is missed
    // then the weekend will be longer than usual
    if (missingDaysNextWeek.any((weekday) => weekday >= mondayIndex && weekday < firstWeekdayCourseDay)) {
      return LongWeekendStatus.incoming;
    }

    return LongWeekendStatus.none;
  }

  // TODO : Don't take weekStart as parameter. Take any day of the week
  //  and calculate week boundaries inside function
  /// Returns the weekdays where there are classes in the specified week
  Set<int> _getClassDaysForWeek(DateTime weekStart) {
    DateTime weekEnd = weekStart.add(Duration(days: 6));
    List<CourseActivity>? schedule = _courseRepository.coursesActivities ?? [];

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

  DateTime? getLatestCourseEndTime(DateTime targetDate) {
    final schedule = _courseRepository.coursesActivities ?? [];

    final matchingDateTimes = schedule
        .where((activity) => _isSameDay(activity.endDateTime, targetDate))
        .map((activity) => activity.endDateTime)
        .toList();

    if (matchingDateTimes.isEmpty) return null;

    matchingDateTimes.sort();
    return matchingDateTimes.last;
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && date1.month == date2.month && date1.day == date2.day;
  }

  /// Determines which days of the week the user regularly has classes
  Set<int> _getRegularCourseDays(List<ScheduleActivity> schedule) {
    List<CourseActivity>? allCourses = _courseRepository.coursesActivities;

    if (allCourses == null) return {};

    // Counts how many times each course activity happens in a session
    Map<String, int> courseCounts = {};

    for (CourseActivity course in allCourses) {
      courseCounts[course.courseName] = (courseCounts[course.courseName] ?? 0) + 1;
    }

    int minOccurrence = 12;

    // Filter schedule to only include activities with at least [minOccurrence] occurrences
    Iterable<ScheduleActivity> filteredActivities = schedule.where((activity) {
      int? count = courseCounts[activity.courseTitle];
      return (count != null && count >= minOccurrence);
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

    final oneWeekFromNow = now.add(Duration(days: 7));

    final upcomingHolidays = replacedDays
        .where((event) => event.originalDate.isAfter(now) && event.originalDate.isBefore(oneWeekFromNow))
        .toList();

    upcomingHolidays.sort((a, b) => a.originalDate.compareTo(b.originalDate));

    if (upcomingHolidays.isEmpty) return null;

    return upcomingHolidays.first.originalDate.toString();
  }

  bool hasUpcomingHoliday() {
    return getUpcomingHolidayDate() != null;
  }

  bool shouldDisplayLastCourseDayOfCurWeek() {
    DateTime now = DateTime.now();
    DateTime startOfCurrentWeek = _getStartOfWeek(now);

    Set<int> actualDays = _getClassDaysForWeek(startOfCurrentWeek);
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

    Set<int> actualDays = _getClassDaysForWeek(startOfCurrentWeek);
    List<int> sortedDays = actualDays.toList()..sort();

    if (sortedDays.isEmpty) {
      return null;
    }

    int lastClassDay = sortedDays.last;

    return startOfCurrentWeek.add(Duration(days: lastClassDay - 1));
  }
}
