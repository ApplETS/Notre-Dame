import 'package:clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:notredame/data/repositories/settings_repository.dart';
import 'package:notredame/data/services/signets-api/models/course_activity.dart';
import 'package:notredame/data/services/signets-api/models/replaced_day.dart';
import 'package:notredame/data/services/signets-api/models/session.dart';
import 'package:notredame/l10n/app_localizations.dart';
import 'package:notredame/locator.dart';
import 'package:notredame/ui/dashboard/services/dynamic_messages_service.dart';

import '../../helpers.dart';
import '../mocks/repositories/course_repository_mock.mocks.dart';
import '../mocks/repositories/settings_repository_mock.dart';

void main() {
  late AppIntl mockIntl;
  late DynamicMessagesService service;
  late MockCourseRepository mockCourseRepository;
  late SettingsRepositoryMock mockSettingsRepository;
  final DateTime fakeNow = DateTime(2025, 06, 15);

  setUp(() async {
    mockCourseRepository = setupCourseRepositoryMock();
    mockSettingsRepository = SettingsRepositoryMock();
    locator.registerSingleton<SettingsRepository>(mockSettingsRepository);
    mockIntl = await setupAppIntl();
    service = DynamicMessagesService(mockIntl);
  });

  tearDown(() {
    unregister<SettingsRepository>();
    locator.reset();
  });

  group('sessionHasStarted - ', () {
    test('returns true when current date is after session start date', () {
      final session = Session(
        shortName: 'NOW',
        name: 'now',
        startDate: fakeNow.subtract(Duration(days: 10)),
        endDate: DateTime(2026),
        endDateCourses: DateTime(2025),
        startDateRegistration: DateTime(2025),
        deadlineRegistration: DateTime(2025),
        startDateCancellationWithRefund: DateTime(2025),
        deadlineCancellationWithRefund: DateTime(2025),
        deadlineCancellationWithRefundNewStudent: DateTime(2025),
        startDateCancellationWithoutRefundNewStudent: DateTime(2025),
        deadlineCancellationWithoutRefundNewStudent: DateTime(2025),
        deadlineCancellationASEQ: DateTime(2025),
      );

      when(mockCourseRepository.activeSessions).thenReturn([session]);

      withClock(Clock.fixed(fakeNow), () {
        expect(service.sessionHasStarted(), isTrue);
      });
    });

    test('returns false when current date is before session start date', () {
      final session = Session(
        shortName: 'BEFORE',
        name: 'BEFORE',
        startDate: fakeNow.add(Duration(days: 10)),
        endDate: DateTime(2025),
        endDateCourses: DateTime(2025),
        startDateRegistration: DateTime(2025),
        deadlineRegistration: DateTime(2025),
        startDateCancellationWithRefund: DateTime(2025),
        deadlineCancellationWithRefund: DateTime(2025),
        deadlineCancellationWithRefundNewStudent: DateTime(2025),
        startDateCancellationWithoutRefundNewStudent: DateTime(2025),
        deadlineCancellationWithoutRefundNewStudent: DateTime(2025),
        deadlineCancellationASEQ: DateTime(2025),
      );

      when(mockCourseRepository.activeSessions).thenReturn([session]);

      withClock(Clock.fixed(fakeNow), () {
        expect(service.sessionHasStarted(), isFalse);
      });
    });
  });

  group('oneWeekRemainingUntilSessionEnd - ', () {
    test('returns true if less than 7 days remain to session', () {
      final session = Session(
        shortName: 'SESSION',
        name: 'SESSION',
        startDate: DateTime(2025),
        endDate: fakeNow.add(Duration(days: 3)),
        endDateCourses: DateTime(2025),
        startDateRegistration: DateTime(2025),
        deadlineRegistration: DateTime(2025),
        startDateCancellationWithRefund: DateTime(2025),
        deadlineCancellationWithRefund: DateTime(2025),
        deadlineCancellationWithRefundNewStudent: DateTime(2025),
        startDateCancellationWithoutRefundNewStudent: DateTime(2025),
        deadlineCancellationWithoutRefundNewStudent: DateTime(2025),
        deadlineCancellationASEQ: DateTime(2025),
      );

      when(mockCourseRepository.activeSessions).thenReturn([session]);

      withClock(Clock.fixed(fakeNow), () {
        expect(service.oneWeekRemainingUntilSessionEnd(), isTrue);
      });
    });

    test('returns true when exactly one week remain', () {
      final session = Session(
        shortName: 'SESSION',
        name: 'SESSION',
        startDate: DateTime(2025),
        endDate: fakeNow.add(Duration(days: 7)),
        endDateCourses: DateTime(2025),
        startDateRegistration: DateTime(2025),
        deadlineRegistration: DateTime(2025),
        startDateCancellationWithRefund: DateTime(2025),
        deadlineCancellationWithRefund: DateTime(2025),
        deadlineCancellationWithRefundNewStudent: DateTime(2025),
        startDateCancellationWithoutRefundNewStudent: DateTime(2025),
        deadlineCancellationWithoutRefundNewStudent: DateTime(2025),
        deadlineCancellationASEQ: DateTime(2025),
      );

      when(mockCourseRepository.activeSessions).thenReturn([session]);

      withClock(Clock.fixed(fakeNow), () {
        expect(service.oneWeekRemainingUntilSessionEnd(), isTrue);
      });
    });

    test('returns false when more than 7 days remain', () {
      final session = Session(
        shortName: 'SESSION',
        name: 'SESSION',
        startDate: DateTime(2025),
        endDate: fakeNow.add(Duration(days: 8)),
        endDateCourses: DateTime(2025),
        startDateRegistration: DateTime(2025),
        deadlineRegistration: DateTime(2025),
        startDateCancellationWithRefund: DateTime(2025),
        deadlineCancellationWithRefund: DateTime(2025),
        deadlineCancellationWithRefundNewStudent: DateTime(2025),
        startDateCancellationWithoutRefundNewStudent: DateTime(2025),
        deadlineCancellationWithoutRefundNewStudent: DateTime(2025),
        deadlineCancellationASEQ: DateTime(2025),
      );

      when(mockCourseRepository.activeSessions).thenReturn([session]);

      withClock(Clock.fixed(fakeNow), () {
        expect(service.oneWeekRemainingUntilSessionEnd(), isFalse);
      });
    });
  });

  group('daysRemainingBeforeSessionEnds - ', () {
    test('returns number of days before session ends', () {
      final session = Session(
        shortName: 'SESSION',
        name: 'SESSION',
        startDate: DateTime(2025),
        endDate: fakeNow.add(Duration(days: 5)),
        endDateCourses: DateTime(2025),
        startDateRegistration: DateTime(2025),
        deadlineRegistration: DateTime(2025),
        startDateCancellationWithRefund: DateTime(2025),
        deadlineCancellationWithRefund: DateTime(2025),
        deadlineCancellationWithRefundNewStudent: DateTime(2025),
        startDateCancellationWithoutRefundNewStudent: DateTime(2025),
        deadlineCancellationWithoutRefundNewStudent: DateTime(2025),
        deadlineCancellationASEQ: DateTime(2025),
      );

      when(mockCourseRepository.activeSessions).thenReturn([session]);

      withClock(Clock.fixed(fakeNow), () {
        expect(service.daysRemainingBeforeSessionEnds(), 5);
      });
    });

    test('returns zero if session end date is current date', () {
      final session = Session(
        shortName: 'SESSION',
        name: 'SESSION',
        startDate: DateTime(2025),
        endDate: fakeNow,
        endDateCourses: DateTime(2025),
        startDateRegistration: DateTime(2025),
        deadlineRegistration: DateTime(2025),
        startDateCancellationWithRefund: DateTime(2025),
        deadlineCancellationWithRefund: DateTime(2025),
        deadlineCancellationWithRefundNewStudent: DateTime(2025),
        startDateCancellationWithoutRefundNewStudent: DateTime(2025),
        deadlineCancellationWithoutRefundNewStudent: DateTime(2025),
        deadlineCancellationASEQ: DateTime(2025),
      );

      when(mockCourseRepository.activeSessions).thenReturn([session]);

      withClock(Clock.fixed(fakeNow), () {
        expect(service.daysRemainingBeforeSessionEnds(), 0);
      });
    });
  });

  group('isEndOfWeek - ', () {
    final noWeekendCourses = [
      CourseActivity(
        courseGroup: "GEN101",
        courseName: "Generic course",
        activityName: "TD",
        activityDescription: "Activity description",
        activityLocation: "location",
        startDateTime: fakeNow.add(Duration(days: DateTime.wednesday, hours: 13)),
        endDateTime: fakeNow.add(Duration(days: DateTime.wednesday, hours: 17)),
      ),
      CourseActivity(
        courseGroup: "GEN102",
        courseName: "Generic course",
        activityName: "TD",
        activityDescription: "Activity description",
        activityLocation: "location",
        startDateTime: fakeNow.add(Duration(days: DateTime.monday, hours: 08)),
        endDateTime: fakeNow.add(Duration(days: DateTime.monday, hours: 12)),
      ),
      CourseActivity(
        courseGroup: "GEN103",
        courseName: "Generic course",
        activityName: "TD",
        activityDescription: "Activity description",
        activityLocation: "location",
        startDateTime: fakeNow.add(Duration(days: DateTime.tuesday, hours: 08)),
        endDateTime: fakeNow.add(Duration(days: DateTime.tuesday, hours: 12)),
      ),
    ];

    final weekdayNames = {
      DateTime.monday: 'Monday',
      DateTime.tuesday: 'Tuesday',
      DateTime.wednesday: 'Wednesday',
      DateTime.thursday: 'Thursday',
    };

    for (final weekday in [DateTime.monday, DateTime.tuesday, DateTime.wednesday, DateTime.thursday]) {
      test('returns true when it\'s ${weekdayNames[weekday]} with no weekend courses', () {
        when(mockCourseRepository.coursesActivities).thenReturn(noWeekendCourses);
        withClock(Clock.fixed(fakeNow.add(Duration(days: DateTime.friday))), () {
          expect(service.isEndOfWeek(), isTrue);
        });
      });
    }

    for (final weekday in [DateTime.monday, DateTime.tuesday, DateTime.wednesday, DateTime.thursday]) {
      test('returns false ${weekdayNames[weekday]}', () {
        withClock(Clock.fixed(fakeNow.add(Duration(days: weekday))), () {
          expect(service.isEndOfWeek(), isFalse);
        });
      });
    }
  });

  group('hasUpcomingHoliday - ', () {
    test("returns false when there are no replacedDays", () {
      when(mockCourseRepository.replacedDays).thenReturn([]);

      withClock(Clock.fixed(fakeNow), () {
        expect(service.hasUpcomingHoliday(), isFalse);
      });
    });

    test("returns true when there is a holiday in exactly 7 days", () {
      final replacedDays = [
        ReplacedDay(
          originalDate: fakeNow.add(Duration(days: 7)),
          replacementDate: fakeNow.add(Duration(days: 7)),
          description: "test",
        ),
        ReplacedDay(
          originalDate: fakeNow.add(Duration(days: 10)),
          replacementDate: fakeNow.add(Duration(days: 10)),
          description: "test",
        ),
        ReplacedDay(
          originalDate: fakeNow.add(Duration(days: 30)),
          replacementDate: fakeNow.add(Duration(days: 30)),
          description: "test",
        ),
      ];

      when(mockCourseRepository.replacedDays).thenReturn(replacedDays);

      withClock(Clock.fixed(fakeNow), () {
        expect(service.hasUpcomingHoliday(), isTrue);
      });
    });

    test("returns true when there is a holiday in less than 7 days", () {
      final replacedDays = [
        ReplacedDay(
          originalDate: fakeNow.add(Duration(days: 10)),
          replacementDate: fakeNow.add(Duration(days: 10)),
          description: "test",
        ),
        ReplacedDay(
          originalDate: fakeNow.add(Duration(days: 4)),
          replacementDate: fakeNow.add(Duration(days: 4)),
          description: "test",
        ),
        ReplacedDay(
          originalDate: fakeNow.add(Duration(days: 30)),
          replacementDate: fakeNow.add(Duration(days: 30)),
          description: "test",
        ),
      ];

      when(mockCourseRepository.replacedDays).thenReturn(replacedDays);

      withClock(Clock.fixed(fakeNow), () {
        expect(service.hasUpcomingHoliday(), isTrue);
      });
    });

    test("returns true when there are multiple holidays in less than 7 days", () {
      final replacedDays = [
        ReplacedDay(
          originalDate: fakeNow.add(Duration(days: 10)),
          replacementDate: fakeNow.add(Duration(days: 10)),
          description: "test",
        ),
        ReplacedDay(
          originalDate: fakeNow.add(Duration(days: 4)),
          replacementDate: fakeNow.add(Duration(days: 4)),
          description: "test",
        ),
        ReplacedDay(
          originalDate: fakeNow.add(Duration(days: 3)),
          replacementDate: fakeNow.add(Duration(days: 3)),
          description: "test",
        ),
      ];

      when(mockCourseRepository.replacedDays).thenReturn(replacedDays);

      withClock(Clock.fixed(fakeNow), () {
        expect(service.hasUpcomingHoliday(), isTrue);
      });
    });

    test("returns false when there is no holiday in the next 7 days", () {
      final replacedDays = [
        ReplacedDay(
          originalDate: fakeNow.add(Duration(days: 15)),
          replacementDate: fakeNow.add(Duration(days: 15)),
          description: "test",
        ),
        ReplacedDay(
          originalDate: fakeNow.add(Duration(days: 8)),
          replacementDate: fakeNow.add(Duration(days: 8)),
          description: "test",
        ),
        ReplacedDay(
          originalDate: fakeNow.add(Duration(days: 30)),
          replacementDate: fakeNow.add(Duration(days: 30)),
          description: "test",
        ),
      ];

      when(mockCourseRepository.replacedDays).thenReturn(replacedDays);

      withClock(Clock.fixed(fakeNow), () {
        expect(service.hasUpcomingHoliday(), isFalse);
      });
    });
  });

  group('shouldDisplayLastCourseDayOfCurWeek - ', () {
    final courseActivities = [
      CourseActivity(
        courseGroup: "GEN101",
        courseName: "Generic course",
        activityName: "TD",
        activityDescription: "Activity description",
        activityLocation: "location",
        startDateTime: fakeNow.add(Duration(days: DateTime.wednesday, hours: 13)),
        endDateTime: fakeNow.add(Duration(days: DateTime.wednesday, hours: 17)),
      ),
      CourseActivity(
        courseGroup: "GEN102",
        courseName: "Generic course",
        activityName: "TD",
        activityDescription: "Activity description",
        activityLocation: "location",
        startDateTime: fakeNow.add(Duration(days: DateTime.monday, hours: 08)),
        endDateTime: fakeNow.add(Duration(days: DateTime.monday, hours: 12)),
      ),
      CourseActivity(
        courseGroup: "GEN103",
        courseName: "Generic course",
        activityName: "TD",
        activityDescription: "Activity description",
        activityLocation: "location",
        startDateTime: fakeNow.add(Duration(days: DateTime.monday, hours: 08)),
        endDateTime: fakeNow.add(Duration(days: DateTime.monday, hours: 12)),
      ),
      CourseActivity(
        courseGroup: "GEN104",
        courseName: "Generic course",
        activityName: "TD",
        activityDescription: "Activity description",
        activityLocation: "location",
        startDateTime: fakeNow.add(Duration(days: DateTime.thursday, hours: 08)),
        endDateTime: fakeNow.add(Duration(days: DateTime.thursday, hours: 12)),
      ),
      CourseActivity(
        courseGroup: "GEN105",
        courseName: "Generic course",
        activityName: "TD",
        activityDescription: "Activity description",
        activityLocation: "location",
        startDateTime: fakeNow.add(Duration(days: DateTime.wednesday, hours: 08)),
        endDateTime: fakeNow.add(Duration(days: DateTime.wednesday, hours: 12)),
      ),
    ];

    test(
      'return true if current day is the last day of the week with courses and there are at least 3 course days',
      () {
        when(mockCourseRepository.coursesActivities).thenReturn(courseActivities);
        withClock(Clock.fixed(fakeNow.add(Duration(days: DateTime.thursday))), () {
          expect(service.shouldDisplayLastCourseDayOfCurWeek(), isTrue);
        });
      },
    );

    test(
      'return false if current day is before the last day of the week with courses  and there are at least 3 course days',
      () {
        when(mockCourseRepository.coursesActivities).thenReturn(courseActivities);
        withClock(Clock.fixed(fakeNow.add(Duration(days: DateTime.wednesday))), () {
          expect(service.shouldDisplayLastCourseDayOfCurWeek(), isFalse);
        });
      },
    );

    test(
      'return false if current day is before the last day of the week with courses and there are at least 3 course days',
      () {
        when(mockCourseRepository.coursesActivities).thenReturn(courseActivities);
        withClock(Clock.fixed(fakeNow.add(Duration(days: DateTime.wednesday))), () {
          expect(service.shouldDisplayLastCourseDayOfCurWeek(), isFalse);
        });
      },
    );

    test(
      'return false if current day is the last day of the week with courses and there are less than 3 course days',
      () {
        final lessThanThreeCourseActivities = [
          CourseActivity(
            courseGroup: "GEN101",
            courseName: "Generic course",
            activityName: "TD",
            activityDescription: "Activity description",
            activityLocation: "location",
            startDateTime: fakeNow.add(Duration(days: DateTime.wednesday, hours: 13)),
            endDateTime: fakeNow.add(Duration(days: DateTime.wednesday, hours: 17)),
          ),
          CourseActivity(
            courseGroup: "GEN102",
            courseName: "Generic course",
            activityName: "TD",
            activityDescription: "Activity description",
            activityLocation: "location",
            startDateTime: fakeNow.add(Duration(days: DateTime.monday, hours: 08)),
            endDateTime: fakeNow.add(Duration(days: DateTime.monday, hours: 12)),
          ),
        ];

        when(mockCourseRepository.coursesActivities).thenReturn(lessThanThreeCourseActivities);
        withClock(Clock.fixed(fakeNow.add(Duration(days: DateTime.wednesday))), () {
          expect(service.shouldDisplayLastCourseDayOfCurWeek(), isFalse);
        });
      },
    );

    test('return true if current day is the last day of the week with courses and there are exactly 3 course days', () {
      final lessThanThreeCourseActivities = [
        CourseActivity(
          courseGroup: "GEN101",
          courseName: "Generic course",
          activityName: "TD",
          activityDescription: "Activity description",
          activityLocation: "location",
          startDateTime: fakeNow.add(Duration(days: DateTime.wednesday, hours: 13)),
          endDateTime: fakeNow.add(Duration(days: DateTime.wednesday, hours: 17)),
        ),
        CourseActivity(
          courseGroup: "GEN102",
          courseName: "Generic course",
          activityName: "TD",
          activityDescription: "Activity description",
          activityLocation: "location",
          startDateTime: fakeNow.add(Duration(days: DateTime.friday, hours: 08)),
          endDateTime: fakeNow.add(Duration(days: DateTime.friday, hours: 12)),
        ),
        CourseActivity(
          courseGroup: "GEN103",
          courseName: "Generic course",
          activityName: "TD",
          activityDescription: "Activity description",
          activityLocation: "location",
          startDateTime: fakeNow.add(Duration(days: DateTime.monday, hours: 08)),
          endDateTime: fakeNow.add(Duration(days: DateTime.monday, hours: 12)),
        ),
      ];

      when(mockCourseRepository.coursesActivities).thenReturn(lessThanThreeCourseActivities);
      withClock(Clock.fixed(fakeNow.add(Duration(days: DateTime.friday))), () {
        expect(service.shouldDisplayLastCourseDayOfCurWeek(), isTrue);
      });
    });

    test('return false if there are no course activities', () {
      when(mockCourseRepository.coursesActivities).thenReturn([]);
      withClock(Clock.fixed(fakeNow.add(Duration(days: DateTime.wednesday))), () {
        expect(service.shouldDisplayLastCourseDayOfCurWeek(), isFalse);
      });
    });
  });

  group('getLatestCourseEndTime - ', () {
    final courseActivities = [
      CourseActivity(
        courseGroup: "GEN101",
        courseName: "Generic course",
        activityName: "TD",
        activityDescription: "Activity description",
        activityLocation: "location",
        startDateTime: fakeNow.add(Duration(days: DateTime.wednesday, hours: 13)),
        endDateTime: fakeNow.add(Duration(days: DateTime.wednesday, hours: 17)),
      ),
      CourseActivity(
        courseGroup: "GEN102",
        courseName: "Generic course",
        activityName: "TD",
        activityDescription: "Activity description",
        activityLocation: "location",
        startDateTime: fakeNow.add(Duration(days: DateTime.thursday, hours: 08, minutes: 30)),
        endDateTime: fakeNow.add(Duration(days: DateTime.thursday, hours: 12, minutes: 30)),
      ),
      CourseActivity(
        courseGroup: "GEN103",
        courseName: "Generic course",
        activityName: "TD",
        activityDescription: "Activity description",
        activityLocation: "location",
        startDateTime: fakeNow.add(Duration(days: DateTime.thursday, hours: 19, minutes: 00)),
        endDateTime: fakeNow.add(Duration(days: DateTime.thursday, hours: 19, minutes: 30)),
      ),
      CourseActivity(
        courseGroup: "GEN104",
        courseName: "Generic course",
        activityName: "TD",
        activityDescription: "Activity description",
        activityLocation: "location",
        startDateTime: fakeNow.add(Duration(days: DateTime.thursday, hours: 12, minutes: 30)),
        endDateTime: fakeNow.add(Duration(days: DateTime.thursday, hours: 16, minutes: 00)),
      ),
      CourseActivity(
        courseGroup: "GEN105",
        courseName: "Generic course",
        activityName: "TD",
        activityDescription: "Activity description",
        activityLocation: "location",
        startDateTime: fakeNow.add(Duration(days: DateTime.friday, hours: 08)),
        endDateTime: fakeNow.add(Duration(days: DateTime.friday, hours: 12)),
      ),
    ];

    test('return end time of the latest course of the day', () {
      when(mockCourseRepository.coursesActivities).thenReturn(courseActivities);
      withClock(Clock.fixed(fakeNow), () {
        expect(
          service.getLatestCourseEndTime(fakeNow.add(Duration(days: DateTime.thursday))),
          fakeNow.add(Duration(days: DateTime.thursday, hours: 19, minutes: 30)),
        );
      });
    });

    test('return null if no courses that day', () {
      when(mockCourseRepository.coursesActivities).thenReturn(courseActivities);
      withClock(Clock.fixed(fakeNow), () {
        expect(service.getLatestCourseEndTime(fakeNow.add(Duration(days: DateTime.saturday))), null);
      });
    });
  });
}
