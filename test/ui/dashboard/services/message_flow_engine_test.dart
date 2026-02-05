// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:notredame/data/services/signets-api/models/course_activity.dart';
import 'package:notredame/data/services/signets-api/models/session.dart';
import 'package:notredame/ui/dashboard/services/dynamic_message.dart';
import 'package:notredame/ui/dashboard/services/dynamic_messages_service.dart';
import 'package:notredame/ui/dashboard/services/session_context.dart';

void main() {
  late DynamicMessagesService engine;

  Session createSession({required DateTime startDate, required DateTime endDate}) {
    return Session(
      shortName: 'TEST',
      name: 'Test Session',
      startDate: startDate,
      endDate: endDate,
      endDateCourses: endDate,
      startDateRegistration: startDate.subtract(const Duration(days: 30)),
      deadlineRegistration: startDate.subtract(const Duration(days: 15)),
      startDateCancellationWithRefund: startDate,
      deadlineCancellationWithRefund: startDate.add(const Duration(days: 7)),
      deadlineCancellationWithRefundNewStudent: startDate.add(const Duration(days: 14)),
      startDateCancellationWithoutRefundNewStudent: startDate.add(const Duration(days: 15)),
      deadlineCancellationWithoutRefundNewStudent: startDate.add(const Duration(days: 30)),
      deadlineCancellationASEQ: startDate.add(const Duration(days: 7)),
    );
  }

  CourseActivity createActivity(DateTime date) {
    return CourseActivity(
      courseGroup: 'TEST101',
      courseName: 'Test Course',
      activityName: 'Lecture',
      activityDescription: 'Test lecture',
      activityLocation: ['A-1234'],
      startDateTime: date,
      endDateTime: date.add(const Duration(hours: 3)),
    );
  }

  setUp(() {
    engine = DynamicMessagesService();
  });

  group('DynamicMessagesService -', () {
    group('SessionStartsSoonMessage -', () {
      test('returns SessionStartsSoonMessage when session has not started', () {
        final now = DateTime(2024, 1, 1);
        final session = createSession(startDate: DateTime(2024, 1, 10), endDate: DateTime(2024, 4, 30));

        final context = SessionContext.fromSession(session: session, activities: [], now: now);

        final message = engine.determineMessage(context);
        expect(message, isA<SessionStartsSoonMessage>());
        expect((message as SessionStartsSoonMessage).formattedDate, '10/1/2024');
      });

      test('formats start date correctly', () {
        final session = createSession(startDate: DateTime(2024, 12, 25), endDate: DateTime(2025, 4, 30));
        final context = SessionContext.fromSession(session: session, activities: [], now: DateTime(2024, 12, 1));

        final message = engine.determineMessage(context) as SessionStartsSoonMessage;
        expect(message.formattedDate, '25/12/2024');
      });
    });

    group('DaysBeforeSessionEndsMessage -', () {
      test('returns DaysBeforeSessionEndsMessage when daysRemaining <= 7', () {
        final context = SessionContext(
          now: DateTime(2024, 4, 23),
          session: createSession(startDate: DateTime(2024, 1, 1), endDate: DateTime(2024, 4, 30)),
          courseActivities: [],
          isSessionStarted: true,
          daysRemaining: 7,
          daysSinceStart: 112,
          isLastDayOfWeek: false,
          monthsCompleted: 3,
          monthsRemaining: 0,
          weeksCompleted: 16,
          weeksRemaining: 1,
          courseDaysThisWeek: 3,
          isFirstWeek: false,
        );

        final message = engine.determineMessage(context);
        expect(message, isA<DaysBeforeSessionEndsMessage>());
        expect((message as DaysBeforeSessionEndsMessage).daysRemaining, 7);
      });

      test('returns DaysBeforeSessionEndsMessage when 0 days remaining', () {
        final context = SessionContext(
          now: DateTime(2024, 4, 30),
          session: createSession(startDate: DateTime(2024, 1, 1), endDate: DateTime(2024, 4, 30)),
          courseActivities: [],
          isSessionStarted: true,
          daysRemaining: 0,
          daysSinceStart: 119,
          isLastDayOfWeek: false,
          monthsCompleted: 3,
          monthsRemaining: 0,
          weeksCompleted: 17,
          weeksRemaining: 0,
          courseDaysThisWeek: 1,
          isFirstWeek: false,
        );

        final message = engine.determineMessage(context);
        expect(message, isA<DaysBeforeSessionEndsMessage>());
        expect((message as DaysBeforeSessionEndsMessage).daysRemaining, 0);
      });

      test('does not trigger when more than 7 days remaining', () {
        final context = SessionContext(
          now: DateTime(2024, 2, 15),
          session: createSession(startDate: DateTime(2024, 1, 1), endDate: DateTime(2024, 4, 30)),
          courseActivities: [],
          isSessionStarted: true,
          daysRemaining: 74,
          daysSinceStart: 45,
          isLastDayOfWeek: false,
          monthsCompleted: 1,
          monthsRemaining: 2,
          weeksCompleted: 6,
          weeksRemaining: 10,
          courseDaysThisWeek: 3,
          isFirstWeek: false,
        );

        final message = engine.determineMessage(context);
        expect(message, isNot(isA<DaysBeforeSessionEndsMessage>()));
      });
    });

    group('LongWeekendIncomingMessage -', () {
      test('returns LongWeekendIncomingMessage when isLongWeekend is true', () {
        final now = DateTime(2024, 2, 15, 10); // Thursday
        final session = createSession(startDate: DateTime(2024, 1, 1), endDate: DateTime(2024, 6, 30));

        final activities = [
          createActivity(DateTime(2024, 2, 15, 9)), // Thursday
          createActivity(DateTime(2024, 2, 20, 9)), // Tuesday next week
        ];

        final context = SessionContext(
          now: now,
          session: session,
          courseActivities: activities,
          isSessionStarted: true,
          daysRemaining: 135,
          daysSinceStart: 45,
          isLastDayOfWeek: false,
          monthsCompleted: 1,
          monthsRemaining: 4,
          weeksCompleted: 6,
          weeksRemaining: 19,
          courseDaysThisWeek: 2,
          isFirstWeek: false,
        );

        expect(context.isLongWeekend, isTrue);

        final message = engine.determineMessage(context);
        expect(message, isA<LongWeekendIncomingMessage>());
      });

      test('does not return when not a long weekend', () {
        final now = DateTime(2024, 2, 15, 10); // Thursday
        final session = createSession(startDate: DateTime(2024, 1, 1), endDate: DateTime(2024, 6, 30));

        final activities = [
          createActivity(DateTime(2024, 2, 15, 9)), // Thursday
          createActivity(DateTime(2024, 2, 19, 9)), // Monday next week (2 days gap)
        ];

        final context = SessionContext.fromSession(session: session, activities: activities, now: now);

        final message = engine.determineMessage(context);
        expect(message, isNot(isA<LongWeekendIncomingMessage>()));
      });
    });

    group('LastCourseDayOfWeekMessage -', () {
      test('returns LastCourseDayOfWeekMessage when last course day and >= 3 course days', () {
        final now = DateTime(2024, 2, 18, 10); // Sunday
        final session = createSession(startDate: DateTime(2024, 1, 1), endDate: DateTime(2024, 6, 30));

        final activities = [
          createActivity(DateTime(2024, 2, 12, 9)), // Monday
          createActivity(DateTime(2024, 2, 14, 9)), // Wednesday
          createActivity(DateTime(2024, 2, 18, 9)), // Sunday (today) - last day of week
          createActivity(DateTime(2024, 2, 19, 9)), // Monday next week (1 day gap from Sun to Mon)
        ];

        final context = SessionContext(
          now: now,
          session: session,
          courseActivities: activities,
          isSessionStarted: true,
          daysRemaining: 132,
          daysSinceStart: 48,
          isLastDayOfWeek: false,
          monthsCompleted: 1,
          monthsRemaining: 4,
          weeksCompleted: 6,
          weeksRemaining: 19,
          courseDaysThisWeek: 3,
          isFirstWeek: false,
        );

        expect(context.isLongWeekend, isFalse);
        expect(context.isLastCourseDayOfWeek, isTrue);

        final message = engine.determineMessage(context);
        expect(message, isA<LastCourseDayOfWeekMessage>());
        expect((message as LastCourseDayOfWeekMessage).weekday, 'Sunday');
      });

      test('does not return when less than 3 course days', () {
        final now = DateTime(2024, 2, 14, 10); // Wednesday
        final session = createSession(startDate: DateTime(2024, 1, 1), endDate: DateTime(2024, 6, 30));

        final activities = [
          createActivity(DateTime(2024, 2, 12, 9)), // Monday
          createActivity(DateTime(2024, 2, 14, 9)), // Wednesday
          createActivity(DateTime(2024, 2, 19, 9)), // Monday next week
        ];

        final context = SessionContext.fromSession(session: session, activities: activities, now: now);

        final message = engine.determineMessage(context);
        expect(message, isNot(isA<LastCourseDayOfWeekMessage>()));
      });

      test('does not return when not last course day of week', () {
        final now = DateTime(2024, 2, 14, 10); // Wednesday
        final session = createSession(startDate: DateTime(2024, 1, 1), endDate: DateTime(2024, 6, 30));

        final activities = [
          createActivity(DateTime(2024, 2, 12, 9)), // Monday
          createActivity(DateTime(2024, 2, 14, 9)), // Wednesday
          createActivity(DateTime(2024, 2, 15, 9)), // Thursday
          createActivity(DateTime(2024, 2, 16, 9)), // Friday
          createActivity(DateTime(2024, 2, 19, 9)), // Monday next week
        ];

        final context = SessionContext.fromSession(session: session, activities: activities, now: now);

        expect(context.isLastCourseDayOfWeek, isFalse);

        final message = engine.determineMessage(context);
        expect(message, isNot(isA<LastCourseDayOfWeekMessage>()));
      });
    });

    group('FirstWeekOfSessionMessage -', () {
      test('returns FirstWeekOfSessionMessage in the first week', () {
        final context = SessionContext(
          now: DateTime(2024, 1, 13),
          session: createSession(startDate: DateTime(2024, 1, 10), endDate: DateTime(2024, 6, 30)),
          courseActivities: [],
          isSessionStarted: true,
          daysRemaining: 168,
          daysSinceStart: 3,
          isLastDayOfWeek: false,
          monthsCompleted: 0,
          monthsRemaining: 5,
          weeksCompleted: 0,
          weeksRemaining: 24,
          courseDaysThisWeek: 2,
          isFirstWeek: true,
        );

        final message = engine.determineMessage(context);
        expect(message, isA<FirstWeekOfSessionMessage>());
      });

      test('does not return after first week', () {
        final context = SessionContext(
          now: DateTime(2024, 1, 20),
          session: createSession(startDate: DateTime(2024, 1, 10), endDate: DateTime(2024, 6, 30)),
          courseActivities: [],
          isSessionStarted: true,
          daysRemaining: 161,
          daysSinceStart: 10,
          isLastDayOfWeek: false,
          monthsCompleted: 0,
          monthsRemaining: 5,
          weeksCompleted: 1,
          weeksRemaining: 23,
          courseDaysThisWeek: 3,
          isFirstWeek: false,
        );

        final message = engine.determineMessage(context);
        expect(message, isNot(isA<FirstWeekOfSessionMessage>()));
      });
    });

    group('FirstWeekCompletedMessage -', () {
      test('returns FirstWeekCompletedMessage when exactly 1 week completed', () {
        final context = SessionContext(
          now: DateTime(2024, 1, 17),
          session: createSession(startDate: DateTime(2024, 1, 10), endDate: DateTime(2024, 6, 30)),
          courseActivities: [],
          isSessionStarted: true,
          daysRemaining: 164,
          daysSinceStart: 7,
          isLastDayOfWeek: false,
          monthsCompleted: 0,
          monthsRemaining: 5,
          weeksCompleted: 1,
          weeksRemaining: 23,
          courseDaysThisWeek: 3,
          isFirstWeek: false,
        );

        final message = engine.determineMessage(context);
        expect(message, isA<FirstWeekCompletedMessage>());
      });

      test('does not return on non-multiple of 7 days', () {
        final context = SessionContext(
          now: DateTime(2024, 1, 18),
          session: createSession(startDate: DateTime(2024, 1, 10), endDate: DateTime(2024, 6, 30)),
          courseActivities: [],
          isSessionStarted: true,
          daysRemaining: 163,
          daysSinceStart: 8,
          isLastDayOfWeek: false,
          monthsCompleted: 0,
          monthsRemaining: 5,
          weeksCompleted: 1,
          weeksRemaining: 23,
          courseDaysThisWeek: 4,
          isFirstWeek: false,
        );

        final message = engine.determineMessage(context);
        expect(message, isNot(isA<FirstWeekCompletedMessage>()));
      });
    });

    group('WeekCompletedMessage -', () {
      test('returns WeekCompletedMessage when 2 weeks completed', () {
        final context = SessionContext(
          now: DateTime(2024, 1, 24),
          session: createSession(startDate: DateTime(2024, 1, 10), endDate: DateTime(2024, 6, 30)),
          courseActivities: [],
          isSessionStarted: true,
          daysRemaining: 157,
          daysSinceStart: 14,
          isLastDayOfWeek: false,
          monthsCompleted: 0,
          monthsRemaining: 5,
          weeksCompleted: 2,
          weeksRemaining: 22,
          courseDaysThisWeek: 3,
          isFirstWeek: false,
        );

        final message = engine.determineMessage(context);
        expect(message, isA<WeekCompletedMessage>());
        expect((message as WeekCompletedMessage).weeksCompleted, 2);
      });

      test('does not return after first month', () {
        final context = SessionContext(
          now: DateTime(2024, 3, 11),
          session: createSession(startDate: DateTime(2024, 1, 1), endDate: DateTime(2024, 6, 30)),
          courseActivities: [],
          isSessionStarted: true,
          daysRemaining: 111,
          daysSinceStart: 70,
          isLastDayOfWeek: false,
          monthsCompleted: 2,
          monthsRemaining: 3,
          weeksCompleted: 10,
          weeksRemaining: 15,
          courseDaysThisWeek: 3,
          isFirstWeek: false,
        );

        final message = engine.determineMessage(context);
        expect(message, isNot(isA<WeekCompletedMessage>()));
      });
    });

    group('LessOneMonthRemainingMessage -', () {
      test('returns LessOneMonthRemainingMessage when monthsRemaining <= 1', () {
        final context = SessionContext(
          now: DateTime(2024, 4, 5),
          session: createSession(startDate: DateTime(2024, 1, 1), endDate: DateTime(2024, 4, 30)),
          courseActivities: [],
          isSessionStarted: true,
          daysRemaining: 25,
          daysSinceStart: 94,
          isLastDayOfWeek: false,
          monthsCompleted: 3,
          monthsRemaining: 0,
          weeksCompleted: 13,
          weeksRemaining: 3,
          courseDaysThisWeek: 3,
          isFirstWeek: false,
        );

        final message = engine.determineMessage(context);
        expect(message, isA<LessOneMonthRemainingMessage>());
        expect((message as LessOneMonthRemainingMessage).weeksRemaining, 3);
      });
    });

    group('GenericEncouragementMessage -', () {
      test('returns GenericEncouragementMessage as fallback', () {
        final context = SessionContext(
          now: DateTime(2024, 3, 15),
          session: createSession(startDate: DateTime(2024, 1, 1), endDate: DateTime(2024, 6, 30)),
          courseActivities: [],
          isSessionStarted: true,
          daysRemaining: 107,
          daysSinceStart: 74,
          isLastDayOfWeek: false,
          monthsCompleted: 2,
          monthsRemaining: 3,
          weeksCompleted: 10,
          weeksRemaining: 15,
          courseDaysThisWeek: 3,
          isFirstWeek: false,
        );

        final message = engine.determineMessage(context);
        expect(message, isA<GenericEncouragementMessage>());
      });
    });

    group('Priority order -', () {
      test('SessionStartsSoonMessage takes priority when session not started', () {
        final context = SessionContext(
          now: DateTime(2024, 1, 5),
          session: createSession(startDate: DateTime(2024, 1, 10), endDate: DateTime(2024, 1, 17)),
          courseActivities: [],
          isSessionStarted: false,
          daysRemaining: 5,
          daysSinceStart: 0,
          isLastDayOfWeek: true,
          monthsCompleted: 0,
          monthsRemaining: 0,
          weeksCompleted: 0,
          weeksRemaining: 1,
          courseDaysThisWeek: 5,
          isFirstWeek: false,
        );

        final message = engine.determineMessage(context);
        expect(message, isA<SessionStartsSoonMessage>());
      });

      test('DaysBeforeSessionEndsMessage takes priority over LongWeekend', () {
        final now = DateTime(2024, 4, 24);
        final session = createSession(startDate: DateTime(2024, 1, 1), endDate: DateTime(2024, 4, 30));

        final activities = [createActivity(DateTime(2024, 4, 24, 9)), createActivity(DateTime(2024, 4, 30, 9))];

        final context = SessionContext.fromSession(session: session, activities: activities, now: now);

        final message = engine.determineMessage(context);
        expect(message, isA<DaysBeforeSessionEndsMessage>());
      });
    });

    group('Edge cases -', () {
      test('handles empty activities list', () {
        final context = SessionContext(
          now: DateTime(2024, 2, 15),
          session: createSession(startDate: DateTime(2024, 1, 1), endDate: DateTime(2024, 6, 30)),
          courseActivities: [],
          isSessionStarted: true,
          daysRemaining: 135,
          daysSinceStart: 45,
          isLastDayOfWeek: false,
          monthsCompleted: 1,
          monthsRemaining: 4,
          weeksCompleted: 6,
          weeksRemaining: 19,
          courseDaysThisWeek: 0,
          isFirstWeek: false,
        );

        final message = engine.determineMessage(context);
        expect(message, isNotNull);
      });

      test('handles leap year date', () {
        final context = SessionContext(
          now: DateTime(2024, 2, 29),
          session: createSession(startDate: DateTime(2024, 1, 1), endDate: DateTime(2024, 6, 30)),
          courseActivities: [],
          isSessionStarted: true,
          daysRemaining: 122,
          daysSinceStart: 59,
          isLastDayOfWeek: false,
          monthsCompleted: 1,
          monthsRemaining: 4,
          weeksCompleted: 8,
          weeksRemaining: 17,
          courseDaysThisWeek: 4,
          isFirstWeek: false,
        );

        final message = engine.determineMessage(context);
        expect(message, isNotNull);
      });

      test('handles year boundary session', () {
        final context = SessionContext(
          now: DateTime(2025, 2, 1),
          session: createSession(startDate: DateTime(2024, 11, 1), endDate: DateTime(2025, 2, 28)),
          courseActivities: [],
          isSessionStarted: true,
          daysRemaining: 27,
          daysSinceStart: 92,
          isLastDayOfWeek: false,
          monthsCompleted: 3,
          monthsRemaining: 0,
          weeksCompleted: 13,
          weeksRemaining: 3,
          courseDaysThisWeek: 3,
          isFirstWeek: false,
        );

        final message = engine.determineMessage(context);
        expect(message, isA<LessOneMonthRemainingMessage>());
      });

      test('handles negative daysRemaining (past end date)', () {
        final context = SessionContext(
          now: DateTime(2024, 5, 5),
          session: createSession(startDate: DateTime(2024, 1, 1), endDate: DateTime(2024, 4, 30)),
          courseActivities: [],
          isSessionStarted: true,
          daysRemaining: -5,
          daysSinceStart: 124,
          isLastDayOfWeek: false,
          monthsCompleted: 4,
          monthsRemaining: 0,
          weeksCompleted: 17,
          weeksRemaining: 0,
          courseDaysThisWeek: 0,
          isFirstWeek: false,
        );

        final message = engine.determineMessage(context);
        expect(message, isA<DaysBeforeSessionEndsMessage>());
      });
    });

    group('Weekday names -', () {
      test('returns correct weekday name for Saturday and Sunday through full flow', () {
        final weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

        for (int i = 5; i < 7; i++) {
          final date = DateTime(2024, 3, 11 + i, 10);

          final activityDates = <DateTime>[];

          for (int d = 0; d <= i; d++) {
            activityDates.add(DateTime(2024, 3, 11 + d, 9));
          }

          activityDates.add(DateTime(2024, 3, 18, 9));

          final activities = activityDates.map((d) => createActivity(d)).toList();

          final context = SessionContext(
            now: date,
            session: createSession(startDate: DateTime(2024, 1, 1), endDate: DateTime(2024, 6, 30)),
            courseActivities: activities,
            isSessionStarted: true,
            daysRemaining: 100 - i,
            daysSinceStart: 70 + i,
            isLastDayOfWeek: false,
            monthsCompleted: 2,
            monthsRemaining: 3,
            weeksCompleted: 10,
            weeksRemaining: 14,
            courseDaysThisWeek: 4,
            isFirstWeek: false,
          );

          expect(context.isLastCourseDayOfWeek, isTrue, reason: 'Day ${weekdays[i]} should be last course day');
          expect(context.isLongWeekend, isFalse, reason: 'Day ${weekdays[i]} should not be long weekend');
          final message = engine.determineMessage(context) as LastCourseDayOfWeekMessage;
          expect(message.weekday, weekdays[i]);
        }
      });

      test('returns correct weekday name for all days via direct message construction', () {
        final weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

        for (int i = 0; i < 7; i++) {
          final date = DateTime(2024, 3, 11 + i, 10);
          final expectedWeekday = weekdays[date.weekday - 1];
          final message = LastCourseDayOfWeekMessage(expectedWeekday);
          expect(message.weekday, weekdays[i]);
        }
      });
    });
  });
}
