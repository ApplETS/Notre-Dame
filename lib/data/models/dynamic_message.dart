// Dart imports:
import 'dart:math';

// Package imports:
import 'package:intl/intl.dart';

// Project imports:
import 'package:notredame/l10n/app_localizations.dart';

sealed class DynamicMessage {
  const DynamicMessage();
}

class SessionStartsSoonMessage extends DynamicMessage {
  final DateTime startDate;
  const SessionStartsSoonMessage(this.startDate);
}

class DaysBeforeCoursesEndMessage extends DynamicMessage {
  final int daysRemaining;
  const DaysBeforeCoursesEndMessage(this.daysRemaining);
}

class LongWeekendIncomingMessage extends DynamicMessage {
  const LongWeekendIncomingMessage();
}

class UpcomingExtendedBreakMessage extends DynamicMessage {
  final int daysUntilBreak;
  const UpcomingExtendedBreakMessage(this.daysUntilBreak);
}

class LongWeekendCurrentlyMessage extends DynamicMessage {
  final int weeksCompleted;
  const LongWeekendCurrentlyMessage(this.weeksCompleted);
}

class ExtendedBreakMessage extends DynamicMessage {
  final int daysUntilResume;
  const ExtendedBreakMessage(this.daysUntilResume);
}

class FirstDayBackAfterBreakMessage extends DynamicMessage {
  const FirstDayBackAfterBreakMessage();
}

class LastCourseDayOfWeekMessage extends DynamicMessage {
  final int weekday;
  const LastCourseDayOfWeekMessage(this.weekday);
}

class FirstWeekOfSessionMessage extends DynamicMessage {
  const FirstWeekOfSessionMessage();
}

class FirstWeekCompletedMessage extends DynamicMessage {
  const FirstWeekCompletedMessage();
}

class WeekCompletedMessage extends DynamicMessage {
  final int weeksCompleted;
  const WeekCompletedMessage(this.weeksCompleted);
}

class LessOneMonthRemainingMessage extends DynamicMessage {
  final int weeksRemaining;
  const LessOneMonthRemainingMessage(this.weeksRemaining);
}

class FinalsApproachingMessage extends DynamicMessage {
  final int courseDaysRemaining;
  const FinalsApproachingMessage(this.courseDaysRemaining);
}

class ExamPeriodMessage extends DynamicMessage {
  final int daysRemaining;
  const ExamPeriodMessage(this.daysRemaining);
}

class SessionCompletedMessage extends DynamicMessage {
  const SessionCompletedMessage();
}

class GenericEncouragementMessage extends DynamicMessage {
  final int variant;
  const GenericEncouragementMessage(this.variant);

  factory GenericEncouragementMessage.forToday([Random? random]) {
    final now = DateTime.now();
    // Seed the RNG with the current date so the same variant is returned
    // for all calls on a given day, but rotates automatically the next day.
    final rng = random ?? Random(now.year * 10000 + now.month * 100 + now.day);
    return GenericEncouragementMessage(rng.nextInt(7));
  }
}

class NoCoursesOnDayMessage extends DynamicMessage {
  final int weekday;
  final String reason;
  const NoCoursesOnDayMessage(this.weekday, this.reason);
}

class DayFollowsScheduleMessage extends DynamicMessage {
  final int originalWeekday;
  final int replacementWeekday;
  final String reason;
  const DayFollowsScheduleMessage(this.originalWeekday, this.replacementWeekday, this.reason);
}

extension DynamicMessageResolver on DynamicMessage {
  String resolve(AppIntl intl) {
    String formatDate(DateTime date) {
      final pattern = intl.localeName == 'en' ? 'MMMM d, yyyy' : 'd MMMM yyyy';
      return DateFormat(pattern, intl.localeName).format(date);
    }

    String weekdayName(int weekday) {
      return switch (weekday) {
        DateTime.monday => intl.schedule_settings_starting_weekday_monday,
        DateTime.tuesday => intl.schedule_settings_starting_weekday_tuesday,
        DateTime.wednesday => intl.schedule_settings_starting_weekday_wednesday,
        DateTime.thursday => intl.schedule_settings_starting_weekday_thursday,
        DateTime.friday => intl.schedule_settings_starting_weekday_friday,
        DateTime.saturday => intl.schedule_settings_starting_weekday_saturday,
        DateTime.sunday => intl.schedule_settings_starting_weekday_sunday,
        _ => intl.schedule_settings_starting_weekday_monday,
      };
    }

    return switch (this) {
      SessionStartsSoonMessage(:final startDate) => intl.dynamic_message_session_starts_soon(formatDate(startDate)),
      DaysBeforeCoursesEndMessage(:final daysRemaining) => intl.dynamic_message_days_before_session_ends(daysRemaining),
      LongWeekendIncomingMessage() => intl.dynamic_message_long_weekend_incoming,
      UpcomingExtendedBreakMessage(:final daysUntilBreak) =>
        daysUntilBreak == 1
            ? intl.dynamic_message_upcoming_extended_break_tomorrow
            : intl.dynamic_message_upcoming_extended_break(daysUntilBreak),
      LastCourseDayOfWeekMessage(:final weekday) => intl.dynamic_message_last_course_day_of_session(
        weekdayName(weekday),
      ),
      FirstWeekOfSessionMessage() => intl.dynamic_message_first_week_of_session,
      FirstWeekCompletedMessage() => intl.dynamic_message_first_week_of_session_completed,
      WeekCompletedMessage(:final weeksCompleted) => intl.dynamic_message_end_of_week(weeksCompleted),
      LessOneMonthRemainingMessage(:final weeksRemaining) =>
        weeksRemaining == 1
            ? intl.dynamic_message_last_course_week_remaining
            : intl.dynamic_message_less_one_month_remaining(weeksRemaining),
      NoCoursesOnDayMessage(:final weekday, :final reason) => intl.dynamic_message_no_courses_on_day(
        weekdayName(weekday),
        reason,
      ),
      DayFollowsScheduleMessage(:final originalWeekday, :final replacementWeekday, :final reason) =>
        intl.dynamic_message_day_follows_schedule(
          weekdayName(originalWeekday),
          weekdayName(replacementWeekday),
          reason,
        ),
      FinalsApproachingMessage(:final courseDaysRemaining) =>
        courseDaysRemaining <= 0
            ? intl.dynamic_message_finals_approaching_tomorrow
            : intl.dynamic_message_finals_approaching,
      ExamPeriodMessage(:final daysRemaining) =>
        daysRemaining <= 0
            ? intl.dynamic_message_exam_period_last_day
            : daysRemaining == 1
                ? intl.dynamic_message_exam_period_tomorrow_last_day
                : intl.dynamic_message_exam_period(daysRemaining),
      SessionCompletedMessage() => intl.dynamic_message_session_completed,
      GenericEncouragementMessage(:final variant) => [
        intl.dynamic_message_generic_encouragement_0,
        intl.dynamic_message_generic_encouragement_1,
        intl.dynamic_message_generic_encouragement_2,
        intl.dynamic_message_generic_encouragement_3,
        intl.dynamic_message_generic_encouragement_4,
        intl.dynamic_message_generic_encouragement_5,
        intl.dynamic_message_generic_encouragement_6,
      ][variant],
      LongWeekendCurrentlyMessage(:final weeksCompleted) => intl.dynamic_message_long_weekend_currently(weeksCompleted),
      ExtendedBreakMessage(:final daysUntilResume) =>
        daysUntilResume == 1
            ? intl.dynamic_message_extended_break_tomorrow
            : intl.dynamic_message_extended_break(daysUntilResume),
      FirstDayBackAfterBreakMessage() => intl.dynamic_message_first_day_back_after_break,
    };
  }
}
