// Project imports:
import 'package:notredame/ui/dashboard/services/dynamic_message.dart';
import 'package:notredame/ui/dashboard/services/session_context.dart';

class DynamicMessagesService {
  DynamicMessage? determineMessage(SessionContext context) {
    if (!context.isSessionStarted) {
      return SessionStartsSoonMessage(_formatDate(context.session.startDate));
    }

    if (context.daysRemaining <= 7 && context.daysRemaining >= 0) {
      return DaysBeforeSessionEndsMessage(context.daysRemaining);
    }

    final replacedDay = context.getUpcomingReplacedDay();
    if (replacedDay != null) {
      final originalWeekday = _getWeekdayName(replacedDay.originalDate);

      if (context.isReplacedDayCancellation(replacedDay)) {
        return NoCoursesOnDayMessage(originalWeekday, replacedDay.description);
      } else {
        final replacementWeekday = _getWeekdayName(replacedDay.replacementDate);
        return DayFollowsScheduleMessage(originalWeekday, replacementWeekday, replacedDay.description);
      }
    }

    if (context.isInsideLongWeekend) {
      return LongWeekendCurrentlyMessage(context.weeksCompleted);
    }

    if (context.isLongWeekendIncoming) {
      return LongWeekendIncomingMessage();
    }

    if (context.weeksCompleted < 1) {
      return FirstWeekOfSessionMessage();
    }

    if (context.isAfterLastCourseOfWeek) {
      if (context.weeksCompleted == 1) {
        return FirstWeekCompletedMessage();
      }
      return WeekCompletedMessage(context.weeksCompleted);
    }

    if (context.isLastCourseDayOfWeek && context.courseDaysThisWeek >= 3) {
      return LastCourseDayOfWeekMessage(_getWeekdayName(context.now));
    }

    if (context.monthsRemaining <= 1) {
      return LessOneMonthRemainingMessage(context.weeksRemaining);
    }

    return GenericEncouragementMessage();
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _getWeekdayName(DateTime date) {
    const weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return weekdays[date.weekday - 1];
  }
}
