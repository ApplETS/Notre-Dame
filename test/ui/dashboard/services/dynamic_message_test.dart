// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:notredame/data/services/signets-api/models/course_activity.dart';
import 'package:notredame/data/services/signets-api/models/replaced_day.dart';
import 'package:notredame/data/services/signets-api/models/session.dart';
import 'package:notredame/ui/dashboard/services/dynamic_message.dart';
import 'package:notredame/ui/dashboard/services/dynamic_messages_service.dart';
import 'package:notredame/ui/dashboard/services/session_context.dart';

void main() {
  late DynamicMessagesService engine;

  final referenceDate = DateTime(2024, 2, 12);

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

  SessionContext createContext({
    DateTime? now,
    Session? session,
    List<CourseActivity>? courseActivities,
    List<ReplacedDay>? replacedDays,
    bool? isSessionStarted,
    int? daysRemaining,
    int? monthsRemaining,
    int? weeksCompleted,
    int? weeksRemaining,
    int? courseDaysThisWeek,
  }) {
    final defaultSession = createSession(startDate: DateTime(2024, 1, 1), endDate: DateTime(2024, 6, 30));

    return SessionContext(
      now: now ?? DateTime(2024, 3, 15),
      session: session ?? defaultSession,
      courseActivities: courseActivities ?? [],
      replacedDays: replacedDays ?? [],
      isSessionStarted: isSessionStarted ?? true,
      daysRemaining: daysRemaining ?? 107,
      monthsRemaining: monthsRemaining ?? 3,
      weeksCompleted: weeksCompleted ?? 10,
      weeksRemaining: weeksRemaining ?? 15,
      courseDaysThisWeek: courseDaysThisWeek ?? 3,
    );
  }

  DateTime weekday(DateTime reference, int targetWeekday, {int week = 0, int hour = 0, int minute = 0}) {
    final startOfWeek = reference.subtract(Duration(days: reference.weekday - 1));
    final target = startOfWeek.add(Duration(days: (week * 7) + (targetWeekday - 1)));
    return DateTime(target.year, target.month, target.day, hour, minute);
  }

  setUp(() {
    engine = DynamicMessagesService();
  });

  group('DynamicMessagesService -', () {
    group('SessionStartsSoonMessage -', () {
      test('returns SessionStartsSoonMessage when session has not started', () {
        final now = DateTime(2024, 1, 1);
        final session = createSession(startDate: DateTime(2024, 1, 10), endDate: DateTime(2024, 4, 30));

        final context = SessionContext.fromSession(session: session, activities: [], replacedDays: [], now: now);

        final message = engine.determineMessage(context);
        expect(message, isA<SessionStartsSoonMessage>());
        expect((message as SessionStartsSoonMessage).startDate, DateTime(2024, 1, 10));
      });

      test('does not return SessionStartsSoonMessage when it is the session start day', () {
        final now = DateTime(2024, 1, 10);
        final session = createSession(startDate: DateTime(2024, 1, 10), endDate: DateTime(2024, 4, 30));

        final context = SessionContext.fromSession(session: session, activities: [], replacedDays: [], now: now);

        final message = engine.determineMessage(context);
        expect(message, isNot(isA<SessionStartsSoonMessage>()));
      });

      test('does not return SessionStartsSoonMessage when session has started', () {
        final now = DateTime(2024, 1, 11);
        final session = createSession(startDate: DateTime(2024, 1, 10), endDate: DateTime(2024, 4, 30));

        final context = SessionContext.fromSession(session: session, activities: [], replacedDays: [], now: now);

        final message = engine.determineMessage(context);
        expect(message, isNot(isA<SessionStartsSoonMessage>()));
      });
    });

    group('DaysBeforeSessionEndsMessage -', () {
      test('returns DaysBeforeSessionEndsMessage when daysRemaining <= 7', () {
        final context = createContext(daysRemaining: 7);

        final message = engine.determineMessage(context);
        expect(message, isA<DaysBeforeSessionEndsMessage>());
        expect((message as DaysBeforeSessionEndsMessage).daysRemaining, 7);
      });

      test('returns DaysBeforeSessionEndsMessage when daysRemaining is 6', () {
        final context = createContext(daysRemaining: 6);
        final message = engine.determineMessage(context);
        expect(message, isA<DaysBeforeSessionEndsMessage>());
        expect((message as DaysBeforeSessionEndsMessage).daysRemaining, 6);
      });

      test('returns DaysBeforeSessionEndsMessage when 0 days remaining', () {
        final context = createContext(daysRemaining: 0);

        final message = engine.determineMessage(context);
        expect(message, isA<DaysBeforeSessionEndsMessage>());
        expect((message as DaysBeforeSessionEndsMessage).daysRemaining, 0);
      });

      test('does not trigger when negative days remaining', () {
        final context = createContext(daysRemaining: -1);

        final message = engine.determineMessage(context);
        expect(message, isNot(isA<DaysBeforeSessionEndsMessage>()));
      });

      test('does not trigger when more than 7 days remaining', () {
        final context = createContext(daysRemaining: 8);

        final message = engine.determineMessage(context);
        expect(message, isNot(isA<DaysBeforeSessionEndsMessage>()));
      });
    });

    group('ReplacedDayMessage -', () {
      test('returns NoCoursesOnDayMessage when cancellation', () {
        final reference = DateTime(2024, 3, 25);
        final now = weekday(reference, DateTime.wednesday);
        final replacedDay = ReplacedDay(
          originalDate: weekday(reference, DateTime.friday),
          replacementDate: DateTime(2024, 1, 1),
          description: 'Holiday',
        );

        final context = createContext(now: now, replacedDays: [replacedDay], daysRemaining: 60);

        final message = engine.determineMessage(context);
        expect(message, isA<NoCoursesOnDayMessage>());
        expect((message as NoCoursesOnDayMessage).weekday, DateTime.friday);
        expect(message.reason, 'Holiday');
      });

      test('returns DayFollowsScheduleMessage when schedule follows another day', () {
        final reference = DateTime(2024, 4, 1);
        final now = weekday(reference, DateTime.monday);
        final replacedDay = ReplacedDay(
          originalDate: weekday(reference, DateTime.wednesday),
          replacementDate: weekday(reference, DateTime.friday),
          description: 'Special Day',
        );

        final context = createContext(now: now, replacedDays: [replacedDay], daysRemaining: 60);

        final message = engine.determineMessage(context);
        expect(message, isA<DayFollowsScheduleMessage>());
        final msg = message as DayFollowsScheduleMessage;
        expect(msg.originalWeekday, DateTime.wednesday);
        expect(msg.replacementWeekday, DateTime.friday);
        expect(msg.reason, 'Special Day');
      });

      test('does not return message when replaced day is outside upcoming range', () {
        final now = DateTime(2024, 3, 27);
        final replacedDay = ReplacedDay(
          originalDate: DateTime(2024, 4, 10),
          replacementDate: DateTime(2024, 1, 1),
          description: 'Holiday',
        );

        final context = createContext(now: now, replacedDays: [replacedDay]);

        final message = engine.determineMessage(context);
        expect(message, isNot(isA<NoCoursesOnDayMessage>()));
      });

      test('returns earliest upcoming replaced day when list is unsorted', () {
        final reference = DateTime(2024, 3, 25);
        final now = weekday(reference, DateTime.monday);

        final early = ReplacedDay(
          originalDate: weekday(reference, DateTime.wednesday),
          replacementDate: DateTime(2024, 1, 1),
          description: 'Early holiday',
        );

        final late = ReplacedDay(
          originalDate: weekday(reference, DateTime.friday),
          replacementDate: weekday(reference, DateTime.monday, week: 1),
          description: 'Later schedule',
        );

        final context = createContext(now: now, replacedDays: [late, early], daysRemaining: 60);

        final message = engine.determineMessage(context);
        expect(message, isA<NoCoursesOnDayMessage>());
        final msg = message as NoCoursesOnDayMessage;
        expect(msg.weekday, DateTime.wednesday);
        expect(msg.reason, 'Early holiday');
      });

      test('returns NoCoursesOnDayMessage when replaced day is today', () {
        final reference = DateTime(2024, 3, 25);
        final now = weekday(reference, DateTime.wednesday);

        final replacedDay = ReplacedDay(
          originalDate: now,
          replacementDate: DateTime(2024, 1, 1),
          description: 'Holiday',
        );

        final context = createContext(now: now, replacedDays: [replacedDay], daysRemaining: 60);

        final message = engine.determineMessage(context);
        expect(message, isA<NoCoursesOnDayMessage>());
        expect((message as NoCoursesOnDayMessage).weekday, DateTime.wednesday);
      });
    });

    group('LongWeekendIncomingMessage -', () {
      test('returns LongWeekendIncomingMessage when isLongWeekend is true', () {
        final now = weekday(referenceDate, DateTime.wednesday, hour: 10);
        final session = createSession(startDate: DateTime(2024, 1, 1), endDate: DateTime(2024, 6, 30));

        final activities = [
          createActivity(weekday(referenceDate, DateTime.wednesday, hour: 9)),
          createActivity(weekday(referenceDate, DateTime.thursday, hour: 9)),
          createActivity(weekday(referenceDate, DateTime.tuesday, week: 1, hour: 9)),
        ];

        final context = createContext(
          now: now,
          session: session,
          courseActivities: activities,
          daysRemaining: 10,
          courseDaysThisWeek: 2,
        );

        expect(context.isLongWeekendIncoming, isTrue);
        expect(context.isInsideLongWeekend, isFalse);

        final message = engine.determineMessage(context);
        expect(message, isA<LongWeekendIncomingMessage>());
      });

      test('does not return when not a long weekend', () {
        final now = DateTime(2024, 2, 15, 10);
        final session = createSession(startDate: DateTime(2024, 1, 1), endDate: DateTime(2024, 6, 30));

        final activities = [createActivity(DateTime(2024, 2, 15, 9)), createActivity(DateTime(2024, 2, 16, 9))];

        final context = SessionContext.fromSession(
          session: session,
          activities: activities,
          replacedDays: [],
          now: now,
        );

        final message = engine.determineMessage(context);
        expect(message, isNot(isA<LongWeekendIncomingMessage>()));
      });

      test('does not trigger when upcoming gap matches usual weekend gap', () {
        final now = weekday(referenceDate, DateTime.wednesday, hour: 10);
        final session = createSession(startDate: DateTime(2024, 1, 1), endDate: DateTime(2024, 6, 30));

        final activities = [
          createActivity(weekday(referenceDate, DateTime.friday, week: -2, hour: 9)),
          createActivity(weekday(referenceDate, DateTime.monday, week: -1, hour: 9)),
          createActivity(weekday(referenceDate, DateTime.friday, week: -1, hour: 9)),
          createActivity(weekday(referenceDate, DateTime.monday, week: 0, hour: 9)),
          createActivity(weekday(referenceDate, DateTime.wednesday, hour: 9)),
          createActivity(weekday(referenceDate, DateTime.friday, hour: 9)),
          createActivity(weekday(referenceDate, DateTime.monday, week: 1, hour: 9)),
        ];

        final context = createContext(
          now: now,
          session: session,
          courseActivities: activities,
          daysRemaining: 10,
          courseDaysThisWeek: 3,
        );

        expect(context.isLongWeekendIncoming, isFalse);
        final message = engine.determineMessage(context);
        expect(message, isNot(isA<LongWeekendIncomingMessage>()));
      });

      test('triggers when upcoming gap is longer than usual weekend gap', () {
        final now = weekday(referenceDate, DateTime.thursday, hour: 10);
        final session = createSession(startDate: DateTime(2024, 1, 1), endDate: DateTime(2024, 6, 30));

        final activities = [
          createActivity(weekday(referenceDate, DateTime.friday, week: -2, hour: 9)),
          createActivity(weekday(referenceDate, DateTime.monday, week: -1, hour: 9)),
          createActivity(weekday(referenceDate, DateTime.friday, week: -1, hour: 9)),
          createActivity(weekday(referenceDate, DateTime.monday, week: 0, hour: 9)),
          createActivity(weekday(referenceDate, DateTime.monday, hour: 9)),
          createActivity(weekday(referenceDate, DateTime.thursday, hour: 9)),
          createActivity(weekday(referenceDate, DateTime.tuesday, week: 1, hour: 9)),
        ];

        final context = createContext(
          now: now,
          session: session,
          courseActivities: activities,
          daysRemaining: 10,
          courseDaysThisWeek: 2,
        );

        expect(context.isLongWeekendIncoming, isTrue);
        final message = engine.determineMessage(context);
        expect(message, isA<LongWeekendIncomingMessage>());
      });
    });

    group('LongWeekendCurrentlyMessage -', () {
      test('returns LongWeekendCurrentlyMessage when inside a long weekend gap', () {
        final now = weekday(referenceDate, DateTime.sunday);
        final session = createSession(startDate: DateTime(2024, 1, 1), endDate: DateTime(2024, 6, 30));

        final activities = [
          createActivity(weekday(referenceDate, DateTime.friday, hour: 9)),
          createActivity(weekday(referenceDate, DateTime.tuesday, week: 1, hour: 9)),
        ];

        final context = createContext(now: now, session: session, courseActivities: activities, daysRemaining: 10);

        expect(context.isInsideLongWeekend, isTrue);

        final message = engine.determineMessage(context);
        expect(message, isA<LongWeekendCurrentlyMessage>());
      });

      test('detects long weekend immediately after last course ends', () {
        final now = weekday(referenceDate, DateTime.friday, hour: 13);
        final session = createSession(startDate: DateTime(2024, 1, 1), endDate: DateTime(2024, 6, 30));

        final activities = [
          createActivity(weekday(referenceDate, DateTime.friday, hour: 9)),
          createActivity(weekday(referenceDate, DateTime.tuesday, week: 1, hour: 9)),
        ];

        final context = createContext(now: now, session: session, courseActivities: activities, daysRemaining: 10);

        expect(context.isInsideLongWeekend, isTrue);
        final message = engine.determineMessage(context);
        expect(message, isA<LongWeekendCurrentlyMessage>());
      });

      test('does not detect long weekend before last course of the day ends', () {
        final now = weekday(referenceDate, DateTime.friday, hour: 11, minute: 59);
        final session = createSession(startDate: DateTime(2024, 1, 1), endDate: DateTime(2024, 6, 30));

        final activities = [
          createActivity(weekday(referenceDate, DateTime.friday, hour: 9)),
          createActivity(weekday(referenceDate, DateTime.tuesday, week: 1, hour: 9)),
        ];

        final context = createContext(now: now, session: session, courseActivities: activities, daysRemaining: 10);

        expect(context.isInsideLongWeekend, isFalse);
        final message = engine.determineMessage(context);
        expect(message, isNot(isA<LongWeekendCurrentlyMessage>()));
      });

      test('does not return during normal weekend', () {
        final now = weekday(referenceDate, DateTime.sunday);
        final session = createSession(startDate: DateTime(2024, 1, 1), endDate: DateTime(2024, 6, 30));

        final activities = [
          createActivity(weekday(referenceDate, DateTime.friday, hour: 9)),
          createActivity(weekday(referenceDate, DateTime.monday, week: 1, hour: 9)),
        ];

        final context = createContext(now: now, session: session, courseActivities: activities, daysRemaining: 10);

        expect(context.isInsideLongWeekend, isFalse);

        final message = engine.determineMessage(context);
        expect(message, isNot(isA<LongWeekendCurrentlyMessage>()));
      });
    });

    group('LastCourseDayOfWeekMessage -', () {
      test('returns LastCourseDayOfWeekMessage when last course day and >= 3 course days', () {
        final now = weekday(referenceDate, DateTime.sunday, hour: 10);
        final session = createSession(startDate: DateTime(2024, 1, 1), endDate: DateTime(2024, 6, 30));

        final activities = [
          createActivity(weekday(referenceDate, DateTime.monday, hour: 9)),
          createActivity(weekday(referenceDate, DateTime.wednesday, hour: 9)),
          createActivity(weekday(referenceDate, DateTime.sunday, hour: 9)),
          createActivity(weekday(referenceDate, DateTime.monday, week: 1, hour: 9)),
        ];

        final context = createContext(
          now: now,
          session: session,
          courseActivities: activities,
          courseDaysThisWeek: 3,
          daysRemaining: 8,
        );

        expect(context.isLongWeekendIncoming, isFalse);
        expect(context.isLastCourseDayOfWeek, isTrue);

        final message = engine.determineMessage(context);
        expect(message, isA<LastCourseDayOfWeekMessage>());
        expect((message as LastCourseDayOfWeekMessage).weekday, DateTime.sunday);
      });

      test('does not return when less than 3 course days', () {
        final now = weekday(referenceDate, DateTime.wednesday, hour: 10);
        final session = createSession(startDate: DateTime(2024, 1, 1), endDate: DateTime(2024, 6, 30));

        final activities = [
          createActivity(weekday(referenceDate, DateTime.monday, hour: 9)),
          createActivity(weekday(referenceDate, DateTime.wednesday, hour: 9)),
          createActivity(weekday(referenceDate, DateTime.monday, week: 1, hour: 9)),
        ];

        final context = SessionContext.fromSession(
          session: session,
          activities: activities,
          replacedDays: [],
          now: now,
        );

        final message = engine.determineMessage(context);
        expect(message, isNot(isA<LastCourseDayOfWeekMessage>()));
      });

      test('does not return when not last course day of week', () {
        final now = weekday(referenceDate, DateTime.wednesday, hour: 10);
        final session = createSession(startDate: DateTime(2024, 1, 1), endDate: DateTime(2024, 6, 30));

        final activities = [
          createActivity(weekday(referenceDate, DateTime.monday, hour: 9)),
          createActivity(weekday(referenceDate, DateTime.wednesday, hour: 9)),
          createActivity(weekday(referenceDate, DateTime.thursday, hour: 9)),
          createActivity(weekday(referenceDate, DateTime.friday, hour: 9)),
          createActivity(weekday(referenceDate, DateTime.monday, week: 1, hour: 9)),
        ];

        final context = SessionContext.fromSession(
          session: session,
          activities: activities,
          replacedDays: [],
          now: now,
        );

        expect(context.isLastCourseDayOfWeek, isFalse);

        final message = engine.determineMessage(context);
        expect(message, isNot(isA<LastCourseDayOfWeekMessage>()));
      });
    });

    group('FirstWeekOfSessionMessage -', () {
      test('returns FirstWeekOfSessionMessage in the first week', () {
        final context = createContext(weeksCompleted: 0, daysRemaining: 8);

        final message = engine.determineMessage(context);
        expect(message, isA<FirstWeekOfSessionMessage>());
      });

      test('does not return after first week', () {
        final context = createContext(weeksCompleted: 2, daysRemaining: 8);

        final message = engine.determineMessage(context);
        expect(message, isNot(isA<FirstWeekOfSessionMessage>()));
      });
    });

    group('FirstWeekCompletedMessage -', () {
      test('returns FirstWeekCompletedMessage when exactly 1 week completed and after last course', () {
        // Now is Saturday morning, last course was Friday at 9-12
        final now = weekday(referenceDate, DateTime.saturday, hour: 10);
        final session = createSession(
          startDate: weekday(referenceDate, DateTime.monday, week: -1),
          endDate: DateTime(2024, 6, 30),
        );

        final activities = [
          createActivity(weekday(referenceDate, DateTime.monday, hour: 9)),
          createActivity(weekday(referenceDate, DateTime.wednesday, hour: 9)),
          createActivity(weekday(referenceDate, DateTime.friday, hour: 9)),
          createActivity(weekday(referenceDate, DateTime.monday, week: 1, hour: 9)),
        ];

        final context = createContext(
          now: now,
          session: session,
          courseActivities: activities,
          weeksCompleted: 1,
          daysRemaining: 100,
        );

        expect(context.isAfterLastCourseOfWeek, isTrue);
        final message = engine.determineMessage(context);
        expect(message, isA<FirstWeekCompletedMessage>());
      });

      test('does not return when last course of week has not ended yet', () {
        // Now is Friday morning, before the last course ends
        final now = weekday(referenceDate, DateTime.friday, hour: 8);
        final session = createSession(
          startDate: weekday(referenceDate, DateTime.monday, week: -1),
          endDate: DateTime(2024, 6, 30),
        );

        final activities = [
          createActivity(weekday(referenceDate, DateTime.monday, hour: 9)),
          createActivity(weekday(referenceDate, DateTime.wednesday, hour: 9)),
          createActivity(weekday(referenceDate, DateTime.friday, hour: 9)),
          createActivity(weekday(referenceDate, DateTime.monday, week: 1, hour: 9)),
        ];

        final context = createContext(
          now: now,
          session: session,
          courseActivities: activities,
          weeksCompleted: 1,
          daysRemaining: 100,
        );

        expect(context.isAfterLastCourseOfWeek, isFalse);
        final message = engine.determineMessage(context);
        expect(message, isNot(isA<FirstWeekCompletedMessage>()));
      });
    });

    group('WeekCompletedMessage -', () {
      test('returns WeekCompletedMessage when 2 weeks completed and after last course', () {
        // Now is Saturday, last course was Friday
        final now = weekday(referenceDate, DateTime.saturday, hour: 10);
        final session = createSession(
          startDate: weekday(referenceDate, DateTime.monday, week: -2),
          endDate: DateTime(2024, 6, 30),
        );

        final activities = [
          createActivity(weekday(referenceDate, DateTime.monday, hour: 9)),
          createActivity(weekday(referenceDate, DateTime.wednesday, hour: 9)),
          createActivity(weekday(referenceDate, DateTime.friday, hour: 9)),
          createActivity(weekday(referenceDate, DateTime.monday, week: 1, hour: 9)),
        ];

        final context = createContext(
          now: now,
          session: session,
          courseActivities: activities,
          weeksCompleted: 2,
          daysRemaining: 100,
        );

        expect(context.isAfterLastCourseOfWeek, isTrue);
        final message = engine.determineMessage(context);
        expect(message, isA<WeekCompletedMessage>());
        expect((message as WeekCompletedMessage).weeksCompleted, 2);
      });

      test('returns WeekCompletedMessage even after first month', () {
        // Now is Sunday morning, last course was Friday
        final now = weekday(referenceDate, DateTime.sunday, hour: 10);
        final session = createSession(startDate: DateTime(2024, 1, 1), endDate: DateTime(2024, 6, 30));

        final activities = [
          createActivity(weekday(referenceDate, DateTime.monday, hour: 9)),
          createActivity(weekday(referenceDate, DateTime.wednesday, hour: 9)),
          createActivity(weekday(referenceDate, DateTime.friday, hour: 9)),
          createActivity(weekday(referenceDate, DateTime.monday, week: 1, hour: 9)),
        ];

        final context = createContext(
          now: now,
          session: session,
          courseActivities: activities,
          weeksCompleted: 10,
          daysRemaining: 100,
        );

        expect(context.isAfterLastCourseOfWeek, isTrue);
        final message = engine.determineMessage(context);
        expect(message, isA<WeekCompletedMessage>());
        expect((message as WeekCompletedMessage).weeksCompleted, 10);
      });

      test('persists through entire weekend after last course ends', () {
        final session = createSession(startDate: DateTime(2024, 1, 1), endDate: DateTime(2024, 6, 30));

        final activities = [
          createActivity(weekday(referenceDate, DateTime.monday, hour: 9)),
          createActivity(weekday(referenceDate, DateTime.friday, hour: 9)),
          createActivity(weekday(referenceDate, DateTime.monday, week: 1, hour: 9)),
        ];

        // Test Saturday
        final saturdayContext = createContext(
          now: weekday(referenceDate, DateTime.saturday, hour: 10),
          session: session,
          courseActivities: activities,
          weeksCompleted: 3,
          daysRemaining: 100,
        );
        expect(saturdayContext.isAfterLastCourseOfWeek, isTrue);
        expect(engine.determineMessage(saturdayContext), isA<WeekCompletedMessage>());

        // Test Sunday
        final sundayContext = createContext(
          now: weekday(referenceDate, DateTime.sunday, hour: 23),
          session: session,
          courseActivities: activities,
          weeksCompleted: 3,
          daysRemaining: 100,
        );
        expect(sundayContext.isAfterLastCourseOfWeek, isTrue);
        expect(engine.determineMessage(sundayContext), isA<WeekCompletedMessage>());
      });
    });

    group('LessOneMonthRemainingMessage -', () {
      test('returns LessOneMonthRemainingMessage when monthsRemaining <= 1', () {
        final context = createContext(monthsRemaining: 0, weeksRemaining: 3, daysRemaining: 25);

        final message = engine.determineMessage(context);
        expect(message, isA<LessOneMonthRemainingMessage>());
        expect((message as LessOneMonthRemainingMessage).weeksRemaining, 3);
      });
    });

    group('GenericEncouragementMessage -', () {
      test('returns GenericEncouragementMessage as fallback', () {
        final context = createContext(
          daysRemaining: 30,
          monthsRemaining: 2,
          weeksCompleted: 10,
        );

        final message = engine.determineMessage(context);
        expect(message, isA<GenericEncouragementMessage>());
      });
    });

    group('Priority order -', () {
      test('SessionStartsSoonMessage takes priority when session not started', () {
        final context = createContext(isSessionStarted: false, daysRemaining: 5);

        final message = engine.determineMessage(context);
        expect(message, isA<SessionStartsSoonMessage>());
      });

      test('DaysBeforeSessionEndsMessage takes priority over LongWeekend', () {
        final now = DateTime(2024, 4, 24);
        final session = createSession(startDate: DateTime(2024, 1, 1), endDate: DateTime(2024, 4, 30));

        final activities = [createActivity(DateTime(2024, 4, 24, 9)), createActivity(DateTime(2024, 4, 30, 9))];

        final context = SessionContext.fromSession(
          session: session,
          activities: activities,
          replacedDays: [],
          now: now,
        );

        final message = engine.determineMessage(context);
        expect(message, isA<DaysBeforeSessionEndsMessage>());
      });

      test('DaysBeforeSessionEndsMessage takes priority over ReplacedDayMessage', () {
        final now = DateTime(2024, 4, 25);
        final replacedDay = ReplacedDay(
          originalDate: DateTime(2024, 4, 26),
          replacementDate: DateTime(2024, 1, 1),
          description: 'Test',
        );

        final context = createContext(now: now, replacedDays: [replacedDay], daysRemaining: 5);

        final message = engine.determineMessage(context);
        expect(message, isA<DaysBeforeSessionEndsMessage>());
      });

      test('ReplacedDayMessage takes priority over LongWeekend', () {
        final reference = DateTime(2024, 5, 13);
        final now = weekday(reference, DateTime.friday, hour: 10);
        final session = createSession(startDate: DateTime(2024, 1, 1), endDate: DateTime(2024, 6, 30));

        final activities = [
          createActivity(weekday(reference, DateTime.friday, hour: 9)),
          createActivity(weekday(reference, DateTime.tuesday, week: 1, hour: 9)),
        ];

        final replacedDay = ReplacedDay(
          originalDate: weekday(reference, DateTime.monday, week: 1),
          replacementDate: DateTime(2024, 1, 1),
          description: 'Holiday',
        );

        final context = createContext(
          now: now,
          session: session,
          courseActivities: activities,
          replacedDays: [replacedDay],
          daysRemaining: 20,
        );

        expect(context.isLongWeekendIncoming, isTrue);

        final message = engine.determineMessage(context);
        expect(message, isA<NoCoursesOnDayMessage>());
      });

      test('LongWeekendIncomingMessage takes priority over LastCourseDayOfWeekMessage', () {
        final reference = DateTime(2024, 5, 13);
        final now = weekday(reference, DateTime.friday, hour: 10);
        final session = createSession(startDate: DateTime(2024, 1, 1), endDate: DateTime(2024, 6, 30));

        final activities = [
          createActivity(weekday(reference, DateTime.friday, hour: 9)),
          createActivity(weekday(reference, DateTime.tuesday, week: 1, hour: 9)),
          createActivity(weekday(reference, DateTime.wednesday, hour: 9)),
          createActivity(weekday(reference, DateTime.monday, hour: 9)),
        ];

        final context = SessionContext.fromSession(
          session: session,
          activities: activities,
          replacedDays: [],
          now: now,
        );

        expect(context.isLongWeekendIncoming, isTrue, reason: 'Should be long weekend incoming');
        expect(context.isLastCourseDayOfWeek, isTrue, reason: 'Should be last course day');

        final message = engine.determineMessage(context);
        expect(message, isA<LongWeekendIncomingMessage>());
      });
    });

    group('Integration with SessionContext -', () {
      test('does not trigger DaysBeforeSessionEndsMessage in middle of session', () {
        final now = DateTime(2024, 2, 15);
        final session = createSession(startDate: DateTime(2024, 1, 1), endDate: DateTime(2024, 4, 30));

        final context = SessionContext.fromSession(session: session, activities: [], replacedDays: [], now: now);

        final message = engine.determineMessage(context);
        expect(message, isNot(isA<DaysBeforeSessionEndsMessage>()));
        expect(message, isA<GenericEncouragementMessage>());
      });

      test('triggers FirstWeekCompletedMessage after first week last course ends', () {
        final reference = DateTime(2024, 1, 8);
        final startDate = weekday(reference, DateTime.monday);
        final now = weekday(reference, DateTime.saturday, week: 1, hour: 10);
        final session = createSession(startDate: startDate, endDate: DateTime(2024, 4, 30));

        // Activities for the first week and next week
        final activities = [
          createActivity(weekday(reference, DateTime.monday, week: 1, hour: 9)),
          createActivity(weekday(reference, DateTime.wednesday, week: 1, hour: 9)),
          createActivity(weekday(reference, DateTime.friday, week: 1, hour: 9)),
          createActivity(weekday(reference, DateTime.monday, week: 2, hour: 9)),
        ];

        final context = SessionContext.fromSession(
          session: session,
          activities: activities,
          replacedDays: [],
          now: now,
        );

        expect(context.isAfterLastCourseOfWeek, isTrue);
        final message = engine.determineMessage(context);
        expect(message, isA<FirstWeekCompletedMessage>());
      });
    });

    group('Edge cases -', () {
      test('handles empty activities list', () {
        final context = createContext(courseActivities: [], daysRemaining: 30, monthsRemaining: 2);

        final message = engine.determineMessage(context);
        expect(message, isNotNull);
      });

      test('handles leap year date', () {
        final context = createContext(now: DateTime(2024, 2, 29), daysRemaining: 30, monthsRemaining: 2);

        final message = engine.determineMessage(context);
        expect(message, isNotNull);
      });

      test('handles year boundary session', () {
        final context = createContext(daysRemaining: 27, monthsRemaining: 0, weeksRemaining: 3);

        final message = engine.determineMessage(context);
        expect(message, isA<LessOneMonthRemainingMessage>());
      });

      test('handles negative daysRemaining (past end date)', () {
        final context = createContext(daysRemaining: -5);

        final message = engine.determineMessage(context);
        expect(message, isNot(isA<DaysBeforeSessionEndsMessage>()));
      });
    });

    group('Weekday names -', () {
      test('returns correct weekday name for Saturday and Sunday through full flow', () {
        final weekdays = [
          DateTime.monday,
          DateTime.tuesday,
          DateTime.wednesday,
          DateTime.thursday,
          DateTime.friday,
          DateTime.saturday,
          DateTime.sunday,
        ];

        for (int i = 5; i < 7; i++) {
          final date = DateTime(2024, 3, 11 + i, 10);

          final activityDates = <DateTime>[];

          for (int d = 0; d <= i; d++) {
            activityDates.add(DateTime(2024, 3, 11 + d, 9));
          }

          activityDates.add(DateTime(2024, 3, 18, 9));

          final activities = activityDates.map((d) => createActivity(d)).toList();

          final context = createContext(
            now: date,
            courseActivities: activities,
            courseDaysThisWeek: 4,
            daysRemaining: 30,
            monthsRemaining: 2,
          );

          expect(context.isLastCourseDayOfWeek, isTrue, reason: 'Day ${weekdays[i]} should be last course day');
          expect(context.isLongWeekendIncoming, isFalse, reason: 'Day ${weekdays[i]} should not be long weekend');
          final message = engine.determineMessage(context) as LastCourseDayOfWeekMessage;
          expect(message.weekday, weekdays[i]);
        }
      });

      test('returns correct weekday name for all days via direct message construction', () {
        final weekdays = [
          DateTime.monday,
          DateTime.tuesday,
          DateTime.wednesday,
          DateTime.thursday,
          DateTime.friday,
          DateTime.saturday,
          DateTime.sunday,
        ];

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
