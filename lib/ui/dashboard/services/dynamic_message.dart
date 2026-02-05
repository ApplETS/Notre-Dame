import 'package:notredame/l10n/app_localizations.dart';

sealed class DynamicMessage {
  const DynamicMessage();
}

class SessionStartsSoonMessage extends DynamicMessage {
  final String formattedDate;
  const SessionStartsSoonMessage(this.formattedDate);
}

class DaysBeforeSessionEndsMessage extends DynamicMessage {
  final int daysRemaining;
  const DaysBeforeSessionEndsMessage(this.daysRemaining);
}

class LongWeekendIncomingMessage extends DynamicMessage {
  const LongWeekendIncomingMessage();
}

class LastCourseDayOfWeekMessage extends DynamicMessage {
  final String weekday;
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

extension DynamicMessageResolver on DynamicMessage {
  String resolve(AppIntl intl) {
    return switch (this) {
      SessionStartsSoonMessage(:final formattedDate) => intl.dynamic_message_session_starts_soon(formattedDate),
      DaysBeforeSessionEndsMessage(:final daysRemaining) => intl.dynamic_message_days_before_session_ends(
        daysRemaining,
      ),
      LongWeekendIncomingMessage() => intl.dynamic_message_long_weekend_incoming,
      LastCourseDayOfWeekMessage(:final weekday) => intl.dynamic_message_last_course_day_of_session(weekday),
      FirstWeekOfSessionMessage() => intl.dynamic_message_first_week_of_session,
      FirstWeekCompletedMessage() => intl.dynamic_message_first_week_of_session_completed,
      WeekCompletedMessage(:final weeksCompleted) => intl.dynamic_message_end_of_week(weeksCompleted),
      LessOneMonthRemainingMessage(:final weeksRemaining) => intl.dynamic_message_less_one_month_remaining(
        weeksRemaining,
      ),
      GenericEncouragementMessage() => intl.dynamic_message_generic_encouragement,
    };
  }
}
