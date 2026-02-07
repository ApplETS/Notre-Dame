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

class DaysBeforeSessionEndsMessage extends DynamicMessage {
  final int daysRemaining;
  const DaysBeforeSessionEndsMessage(this.daysRemaining);
}

class LongWeekendIncomingMessage extends DynamicMessage {
  const LongWeekendIncomingMessage();
}

class LongWeekendCurrentlyMessage extends DynamicMessage {
  final int weeksCompleted;
  const LongWeekendCurrentlyMessage(this.weeksCompleted);
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

class GenericEncouragementMessage extends DynamicMessage {
  const GenericEncouragementMessage();
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
    String formatDate(DateTime date) => DateFormat('d MMMM yyyy', intl.localeName).format(date);

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
      DaysBeforeSessionEndsMessage(:final daysRemaining) => intl.dynamic_message_days_before_session_ends(
        daysRemaining,
      ),
      LongWeekendIncomingMessage() => intl.dynamic_message_long_weekend_incoming,
      LastCourseDayOfWeekMessage(:final weekday) => intl.dynamic_message_last_course_day_of_session(
        weekdayName(weekday),
      ),
      FirstWeekOfSessionMessage() => intl.dynamic_message_first_week_of_session,
      FirstWeekCompletedMessage() => intl.dynamic_message_first_week_of_session_completed,
      WeekCompletedMessage(:final weeksCompleted) => intl.dynamic_message_end_of_week(weeksCompleted),
      LessOneMonthRemainingMessage(:final weeksRemaining) => intl.dynamic_message_less_one_month_remaining(
        weeksRemaining,
      ),
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
      GenericEncouragementMessage() => intl.dynamic_message_generic_encouragement,
      LongWeekendCurrentlyMessage(:final weeksCompleted) => intl.dynamic_message_long_weekend_currently(weeksCompleted),
    };
  }
}
