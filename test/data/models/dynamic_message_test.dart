// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

// Project imports:
import 'package:notredame/data/models/dynamic_message.dart';
import 'package:notredame/l10n/app_localizations.dart';

void main() {
  late AppIntl intlEn;
  late AppIntl intlFr;

  setUp(() async {
    await initializeDateFormatting('en');
    await initializeDateFormatting('fr');
    intlEn = await AppIntl.delegate.load(const Locale('en'));
    intlFr = await AppIntl.delegate.load(const Locale('fr'));
  });

  group('DynamicMessage.resolve -', () {
    group('SessionStartsSoonMessage -', () {
      test('formats date in English locale', () {
        final message = SessionStartsSoonMessage(DateTime(2025, 1, 15));
        final result = message.resolve(intlEn);
        expect(result, contains('January 15, 2025'));
      });

      test('formats date in French locale', () {
        final message = SessionStartsSoonMessage(DateTime(2025, 1, 15));
        final result = message.resolve(intlFr);
        expect(result, contains('15 janvier 2025'));
      });
    });

    group('DaysBeforeCoursesEndMessage -', () {
      test('resolves with days remaining', () {
        final result = const DaysBeforeCoursesEndMessage(5).resolve(intlEn);
        expect(result, contains('5'));
      });

      test('resolves with 1 day remaining', () {
        final result = const DaysBeforeCoursesEndMessage(1).resolve(intlEn);
        expect(result, contains('1'));
      });
    });

    group('LongWeekendIncomingMessage -', () {
      test('resolves to expected string', () {
        final result = const LongWeekendIncomingMessage().resolve(intlEn);
        expect(result, intlEn.dynamic_message_long_weekend_incoming);
      });
    });

    group('UpcomingExtendedBreakMessage -', () {
      test('uses tomorrow variant when daysUntilBreak is 1', () {
        final result = const UpcomingExtendedBreakMessage(1).resolve(intlEn);
        expect(result, intlEn.dynamic_message_upcoming_extended_break_tomorrow);
      });

      test('uses regular variant when daysUntilBreak > 1', () {
        final result = const UpcomingExtendedBreakMessage(3).resolve(intlEn);
        expect(result, intlEn.dynamic_message_upcoming_extended_break(3));
      });
    });

    group('LongWeekendCurrentlyMessage -', () {
      test('resolves with weeks completed', () {
        final result = const LongWeekendCurrentlyMessage(4).resolve(intlEn);
        expect(result, intlEn.dynamic_message_long_weekend_currently(4));
      });
    });

    group('ExtendedBreakMessage -', () {
      test('uses tomorrow variant when daysUntilResume is 1', () {
        final result = const ExtendedBreakMessage(1).resolve(intlEn);
        expect(result, intlEn.dynamic_message_extended_break_tomorrow);
      });

      test('uses regular variant when daysUntilResume > 1', () {
        final result = const ExtendedBreakMessage(5).resolve(intlEn);
        expect(result, intlEn.dynamic_message_extended_break(5));
      });
    });

    group('FirstDayBackAfterBreakMessage -', () {
      test('resolves to expected string', () {
        final result = const FirstDayBackAfterBreakMessage().resolve(intlEn);
        expect(result, intlEn.dynamic_message_first_day_back_after_break);
      });
    });

    group('LastCourseDayOfWeekMessage -', () {
      test('resolves with Monday', () {
        final result = const LastCourseDayOfWeekMessage(DateTime.monday).resolve(intlEn);
        expect(result, contains('Monday'));
      });

      test('resolves with Friday', () {
        final result = const LastCourseDayOfWeekMessage(DateTime.friday).resolve(intlEn);
        expect(result, contains('Friday'));
      });

      test('resolves with French weekday name', () {
        final result = const LastCourseDayOfWeekMessage(DateTime.wednesday).resolve(intlFr);
        expect(result, contains(intlFr.schedule_settings_starting_weekday_wednesday));
      });

      test('falls back to Monday for invalid weekday', () {
        final result = const LastCourseDayOfWeekMessage(0).resolve(intlEn);
        expect(result, contains('Monday'));
      });
    });

    group('FirstWeekOfSessionMessage -', () {
      test('resolves to expected string', () {
        final result = const FirstWeekOfSessionMessage().resolve(intlEn);
        expect(result, intlEn.dynamic_message_first_week_of_session);
      });
    });

    group('FirstWeekCompletedMessage -', () {
      test('resolves to expected string', () {
        final result = const FirstWeekCompletedMessage().resolve(intlEn);
        expect(result, intlEn.dynamic_message_first_week_of_session_completed);
      });
    });

    group('WeekCompletedMessage -', () {
      test('resolves with weeks completed', () {
        final result = const WeekCompletedMessage(3).resolve(intlEn);
        expect(result, intlEn.dynamic_message_end_of_week(3));
      });
    });

    group('LessOneMonthRemainingMessage -', () {
      test('uses last week variant when weeksRemaining is 1', () {
        final result = const LessOneMonthRemainingMessage(1).resolve(intlEn);
        expect(result, intlEn.dynamic_message_last_course_week_remaining);
      });

      test('uses regular variant when weeksRemaining > 1', () {
        final result = const LessOneMonthRemainingMessage(3).resolve(intlEn);
        expect(result, intlEn.dynamic_message_less_one_month_remaining(3));
      });
    });

    group('FinalsApproachingMessage -', () {
      test('uses tomorrow variant when courseDaysRemaining <= 0', () {
        final result = const FinalsApproachingMessage(0).resolve(intlEn);
        expect(result, intlEn.dynamic_message_finals_approaching_tomorrow);
      });

      test('uses regular variant when courseDaysRemaining > 0', () {
        final result = const FinalsApproachingMessage(3).resolve(intlEn);
        expect(result, intlEn.dynamic_message_finals_approaching);
      });
    });

    group('ExamPeriodMessage -', () {
      test('uses last day variant when daysRemaining <= 0', () {
        final result = const ExamPeriodMessage(0).resolve(intlEn);
        expect(result, intlEn.dynamic_message_exam_period_last_day);
      });

      test('uses tomorrow variant when daysRemaining == 1', () {
        final result = const ExamPeriodMessage(1).resolve(intlEn);
        expect(result, intlEn.dynamic_message_exam_period_tomorrow_last_day);
      });

      test('uses regular variant when daysRemaining > 1', () {
        final result = const ExamPeriodMessage(4).resolve(intlEn);
        expect(result, intlEn.dynamic_message_exam_period(4));
      });
    });

    group('SessionCompletedMessage -', () {
      test('resolves to expected string', () {
        final result = const SessionCompletedMessage().resolve(intlEn);
        expect(result, intlEn.dynamic_message_session_completed);
      });
    });

    group('GenericEncouragementMessage -', () {
      test('resolves each variant 0-6', () {
        final expectedMessages = [
          intlEn.dynamic_message_generic_encouragement_0,
          intlEn.dynamic_message_generic_encouragement_1,
          intlEn.dynamic_message_generic_encouragement_2,
          intlEn.dynamic_message_generic_encouragement_3,
          intlEn.dynamic_message_generic_encouragement_4,
          intlEn.dynamic_message_generic_encouragement_5,
          intlEn.dynamic_message_generic_encouragement_6,
        ];

        for (var i = 0; i < 7; i++) {
          final result = GenericEncouragementMessage(i).resolve(intlEn);
          expect(result, expectedMessages[i], reason: 'variant $i should match');
        }
      });

      test('forToday produces same variant on same day', () {
        final message1 = GenericEncouragementMessage.forToday();
        final message2 = GenericEncouragementMessage.forToday();
        expect(message1.variant, message2.variant);
        expect(message1.variant, inInclusiveRange(0, 6));
      });
    });

    group('NoCoursesOnDayMessage -', () {
      test('resolves with weekday and reason', () {
        final result = const NoCoursesOnDayMessage(DateTime.monday, 'Holiday').resolve(intlEn);
        expect(result, contains('Monday'));
        expect(result, contains('Holiday'));
      });
    });

    group('DayFollowsScheduleMessage -', () {
      test('resolves with both weekdays and reason', () {
        final result = const DayFollowsScheduleMessage(
          DateTime.tuesday,
          DateTime.thursday,
          'Schedule change',
        ).resolve(intlEn);
        expect(result, contains('Tuesday'));
        expect(result, contains('Thursday'));
        expect(result, contains('Schedule change'));
      });
    });

    group('weekdayName coverage -', () {
      test('all 7 weekdays resolve correctly in English', () {
        final expectedNames = {
          DateTime.monday: intlEn.schedule_settings_starting_weekday_monday,
          DateTime.tuesday: intlEn.schedule_settings_starting_weekday_tuesday,
          DateTime.wednesday: intlEn.schedule_settings_starting_weekday_wednesday,
          DateTime.thursday: intlEn.schedule_settings_starting_weekday_thursday,
          DateTime.friday: intlEn.schedule_settings_starting_weekday_friday,
          DateTime.saturday: intlEn.schedule_settings_starting_weekday_saturday,
          DateTime.sunday: intlEn.schedule_settings_starting_weekday_sunday,
        };

        for (final entry in expectedNames.entries) {
          final result = LastCourseDayOfWeekMessage(entry.key).resolve(intlEn);
          expect(result, contains(entry.value), reason: 'weekday ${entry.key} should contain ${entry.value}');
        }
      });
    });
  });
}
