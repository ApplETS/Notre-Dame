// Project imports:
import 'package:notredame/data/models/dynamic_message.dart';
import 'package:notredame/data/models/session_context.dart';

class DynamicMessagesService {
  DynamicMessage? determineMessage(SessionContext context) {
    if (!context.isSessionStarted) {
      return SessionStartsSoonMessage(context.session.startDate);
    }

    if (context.daysRemaining <= 7 && context.daysRemaining >= 0) {
      return DaysBeforeSessionEndsMessage(context.daysRemaining);
    }

    final replacedDay = context.getUpcomingReplacedDay();
    if (replacedDay != null) {
      final originalWeekday = replacedDay.originalDate.weekday;

      if (context.isReplacedDayCancellation(replacedDay)) {
        return NoCoursesOnDayMessage(originalWeekday, replacedDay.description);
      }

      final replacementWeekday = replacedDay.replacementDate.weekday;
      return DayFollowsScheduleMessage(originalWeekday, replacementWeekday, replacedDay.description);
    }

    if (context.isInsideLongWeekend) {
      return LongWeekendCurrentlyMessage(context.weeksCompleted);
    }

    if (context.isLongWeekendIncoming) {
      return LongWeekendIncomingMessage();
    }

    if (context.weeksCompleted == 1) {
      if (context.isAfterLastCourseOfWeek) {
        return FirstWeekCompletedMessage();
      }
      return FirstWeekOfSessionMessage();
    }

    if (context.isAfterLastCourseOfWeek) {
      return WeekCompletedMessage(context.weeksCompleted);
    }

    if (context.isLastCourseDayOfWeek && context.courseDaysThisWeek >= 3) {
      return LastCourseDayOfWeekMessage(context.now.weekday);
    }

    if (context.monthsRemaining <= 1) {
      return LessOneMonthRemainingMessage(context.weeksRemaining);
    }

    return GenericEncouragementMessage();
  }
}
