// Project imports:
import 'package:notredame/data/services/signets-api/models/course_activity.dart';
import 'package:notredame/data/services/signets-api/models/replaced_day.dart';
import 'package:notredame/data/services/signets-api/models/session.dart';
import 'package:notredame/utils/activity_schedule_analyzer.dart';
import 'package:notredame/utils/replaced_day_analyzer.dart';
import 'package:notredame/utils/utils.dart';

class SessionContext {
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

  ScheduleAnalyzer? _scheduleAnalyzerCache;
  ReplacedDayAnalyzer? _replacedDayAnalyzerCache;

  ScheduleAnalyzer get _scheduleAnalyzer =>
      _scheduleAnalyzerCache ??= ScheduleAnalyzer(courseActivities: courseActivities, now: now);

  ReplacedDayAnalyzer get _replacedDayAnalyzer =>
      _replacedDayAnalyzerCache ??= ReplacedDayAnalyzer(replacedDays: replacedDays, now: now);

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
    final analyzer = ScheduleAnalyzer(courseActivities: activities, now: now);

    return SessionContext(
      session: session,
      courseActivities: activities,
      replacedDays: replacedDays,
      now: now,
      isSessionStarted: now.compareTo(session.startDate) >= 0,
      daysRemaining: session.endDate.difference(now).inDays,
      monthsRemaining: Utils.monthsRemaining(session.endDate, now),
      weeksCompleted: Utils.weeksCompleted(session.startDate, now),
      weeksRemaining: Utils.weeksRemaining(session.endDate, now),
      courseDaysThisWeek: analyzer.courseDaysThisWeek,
    );
  }

  bool get hasNextWeekSchedule => _scheduleAnalyzer.hasNextWeekSchedule;

  bool get isLongWeekendIncoming => _scheduleAnalyzer.isLongWeekendIncoming;

  bool get isInsideLongWeekend => _scheduleAnalyzer.isInsideLongWeekend;

  bool get isAfterLastCourseOfWeek => _scheduleAnalyzer.isAfterLastCourseOfWeek;

  bool get isLastCourseDayOfWeek => _scheduleAnalyzer.isLastCourseDayOfWeek;

  bool get isNextWeekShorter => _scheduleAnalyzer.isNextWeekShorter;

  ReplacedDay? getUpcomingReplacedDay() => _replacedDayAnalyzer.getUpcoming();

  bool isReplacedDayCancellation(ReplacedDay replacedDay) => _replacedDayAnalyzer.isCancellation(replacedDay);
}
