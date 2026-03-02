// Project imports:
import 'package:notredame/data/models/dynamic_message.dart';
import 'package:notredame/data/models/dynamic_message_context.dart';

class DynamicMessagesService {
  DynamicMessage determineMessage(DynamicMessageContext context) {
    if (context.isFinalsOver) {
      if (context.nextSessionStartDate != null) {
        return SessionStartsSoonMessage(context.nextSessionStartDate!, context.daysUntilNextSession!);
      }
      return SessionCompletedMessage();
    }

    if (context.isCoursesOver && context.hasFinals) {
      return ExamPeriodMessage(context.finalsDaysRemaining!);
    }

    if (context.courseDaysRemaining <= 7 && context.hasFinals) {
      return FinalsApproachingMessage(context.courseDaysRemaining);
    }

    if (context.courseDaysRemaining <= 7) {
      return DaysBeforeCoursesEndMessage(context.courseDaysRemaining);
    }

    if (context.isFirstDayBackFromBreak) {
      return FirstDayBackAfterBreakMessage();
    }

    if (context.isInsideLongWeekend) {
      final daysUntilResume = context.daysUntilNextCourse ?? 0;
      final totalBreakDuration = context.totalBreakDuration ?? 0;
      if (totalBreakDuration >= 6) {
        return ExtendedBreakMessage(daysUntilResume);
      }
      return LongWeekendCurrentlyMessage(context.weeksCompleted);
    }

    if (context.isLongWeekendIncoming) {
      final upcomingDuration = context.upcomingBreakDuration ?? 0;
      if (upcomingDuration >= 6) {
        final daysUntilBreak = context.daysUntilBreakStart ?? 0;
        return UpcomingExtendedBreakMessage(daysUntilBreak);
      }
      return LongWeekendIncomingMessage();
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

    final isWeekDone =
        context.isAfterLastCourseOfWeek &&
        (context.courseDaysThisWeek >= 3 || context.now.weekday >= DateTime.saturday);

    if (context.weeksCompleted == 1) {
      if (isWeekDone) {
        return FirstWeekCompletedMessage();
      }
      return FirstWeekOfSessionMessage();
    }

    if (isWeekDone) {
      return WeekCompletedMessage(context.weeksCompleted);
    }

    if (context.isLastCourseDayOfWeek && context.courseDaysThisWeek >= 3) {
      return LastCourseDayOfWeekMessage(context.now.weekday);
    }

    if (context.courseWeeksRemaining <= 4) {
      return LessOneMonthRemainingMessage(context.courseWeeksRemaining);
    }

    return GenericEncouragementMessage.forToday();
  }
}
