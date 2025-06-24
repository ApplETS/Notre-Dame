import 'package:intl/intl.dart';
import 'package:notredame/data/models/activity_code.dart';
import 'package:notredame/data/services/signets-api/models/schedule_activity.dart';
import 'package:notredame/locator.dart';
import 'package:notredame/data/repositories/settings_repository.dart';
import 'package:notredame/data/services/signets-api/models/course_activity.dart';
import 'package:notredame/data/services/signets-api/models/replaced_day.dart';
import 'package:notredame/data/services/signets-api/models/session.dart';
import 'package:notredame/l10n/app_localizations.dart';
import 'package:notredame/ui/dashboard/services/dynamic_messages_service.dart';
import 'package:notredame/ui/dashboard/services/long_weekend_status.dart';

import 'package:clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

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

  group('getIncomingLongWeekendStatus - ', () {
    final List<ScheduleActivity> scheduleActivities = [
      ScheduleActivity(
        courseAcronym: "GEN101",
        courseGroup: "01",
        courseTitle: "Generic Course",
        dayOfTheWeek: 1,
        day: "Lundi",
        startTime: DateFormat("hh:mm").parse("08:30"),
        endTime: DateFormat("hh:mm").parse("12:00"),
        activityCode: ActivityCode.lectureCourse,
        isPrincipalActivity: true,
        activityLocation: "En ligne",
        name: "Activité de cours",
      ),
      ScheduleActivity(
        courseAcronym: "GEN102",
        courseGroup: "01",
        courseTitle: "Generic Course",
        dayOfTheWeek: 2,
        day: "Mardi",
        startTime: DateFormat("hh:mm").parse("13:30"),
        endTime: DateFormat("hh:mm").parse("15:00"),
        activityCode: ActivityCode.labGroupA,
        isPrincipalActivity: true,
        activityLocation: "D-4001",
        name: "Laboratoire (Groupe A)",
      ),
      ScheduleActivity(
        courseAcronym: "GEN103",
        courseGroup: "02",
        courseTitle: "Generic Course",
        dayOfTheWeek: 4,
        day: "Jeudi",
        startTime: DateFormat("hh:mm").parse("09:00"),
        endTime: DateFormat("hh:mm").parse("13:30"),
        activityCode: ActivityCode.lectureCourse,
        isPrincipalActivity: true,
        activityLocation: "D-2003",
        name: "Activité de cours",
      ),
      ScheduleActivity(
        courseAcronym: "GEN104",
        courseGroup: "03",
        courseTitle: "Generic Course",
        dayOfTheWeek: 4,
        day: "Jeudi",
        startTime: DateFormat("hh:mm").parse("10:15"),
        endTime: DateFormat("hh:mm").parse("12:45"),
        activityCode: ActivityCode.lectureCourse,
        isPrincipalActivity: false,
        activityLocation: "D-3005",
        name: "Activité de cours",
      ),
    ];

    DateTime firstDayOfWeek = fakeNow.add(Duration(days: DateTime.monday));
    List<CourseActivity> courseActivities = [];

    for (int week = 0; week < 15; week++) {
      final weekStart = firstDayOfWeek.add(Duration(days: week * 7));

      // GEN101 - Monday 9:00-12:00
      courseActivities.add(
        CourseActivity(
          courseGroup: "01",
          courseName: "Generic Course",
          activityName: "Lecture",
          activityDescription: "Weekly lecture",
          activityLocation: "Online",
          startDateTime: DateTime(weekStart.year, weekStart.month, weekStart.day, 9),
          endDateTime: DateTime(weekStart.year, weekStart.month, weekStart.day, 12),
        ),
      );

      // GEN102 - Tuesday 13:30-15:00
      courseActivities.add(
        CourseActivity(
          courseGroup: "01",
          courseName: "Generic Course",
          activityName: "Lab Group A",
          activityDescription: "Weekly lab session",
          activityLocation: "D-4001",
          startDateTime: DateTime(weekStart.year, weekStart.month, weekStart.day + 1, 13, 30),
          endDateTime: DateTime(weekStart.year, weekStart.month, weekStart.day + 1, 15),
        ),
      );

      // GEN103 - Thursday 9:00-13:30
      courseActivities.add(
        CourseActivity(
          courseGroup: "02",
          courseName: "Generic Course",
          activityName: "Lecture",
          activityDescription: "Weekly lecture",
          activityLocation: "D-2003",
          startDateTime: DateTime(weekStart.year, weekStart.month, weekStart.day + 3, 9),
          endDateTime: DateTime(weekStart.year, weekStart.month, weekStart.day + 3, 13, 30),
        ),
      );

      // GEN104 - Thursday 10:15-12:45
      courseActivities.add(
        CourseActivity(
          courseGroup: "03",
          courseName: "Generic Course",
          activityName: "Tutorial",
          activityDescription: "Weekly tutorial session",
          activityLocation: "D-3005",
          startDateTime: DateTime(weekStart.year, weekStart.month, weekStart.day + 3, 10, 15),
          endDateTime: DateTime(weekStart.year, weekStart.month, weekStart.day + 3, 12, 45),
        ),
      );
    }

    test('return none if schedule is empty', () {
      when(mockCourseRepository.scheduleActivities).thenReturn([]);
      when(mockCourseRepository.coursesActivities).thenReturn([]);

      withClock(Clock.fixed(fakeNow), () {
        expect(service.getIncomingLongWeekendStatus(), LongWeekendStatus.none);
      });
    });

    test('return none if there are missed courses during the week', () {
      when(mockCourseRepository.scheduleActivities).thenReturn(scheduleActivities);
      when(mockCourseRepository.coursesActivities).thenReturn(courseActivities);

      withClock(Clock.fixed(fakeNow.add(Duration(days: DateTime.monday))), () {
        expect(service.getIncomingLongWeekendStatus(), LongWeekendStatus.none);
      });
    });

    test('return incoming if the last day of the week is missed and we are not currently in weekend', () {
      List<CourseActivity> courseActivities = [];

      for (int week = 0; week < 15; week++) {
        final weekStart = firstDayOfWeek.add(Duration(days: week * 7));

        // GEN101 - Monday 9:00-12:00
        courseActivities.add(
          CourseActivity(
            courseGroup: "01",
            courseName: "Generic Course",
            activityName: "Lecture",
            activityDescription: "Weekly lecture",
            activityLocation: "Online",
            startDateTime: DateTime(weekStart.year, weekStart.month, weekStart.day, 9),
            endDateTime: DateTime(weekStart.year, weekStart.month, weekStart.day, 12),
          ),
        );

        // GEN102 - Tuesday 13:30-15:00
        courseActivities.add(
          CourseActivity(
            courseGroup: "01",
            courseName: "Generic Course",
            activityName: "Lab Group A",
            activityDescription: "Weekly lab session",
            activityLocation: "D-4001",
            startDateTime: DateTime(weekStart.year, weekStart.month, weekStart.day + 1, 13, 30),
            endDateTime: DateTime(weekStart.year, weekStart.month, weekStart.day + 1, 15),
          ),
        );

        // Simulate missing last day of classes for second week
        if (week != 1) {
          // GEN103 - Thursday 9:00-13:30
          courseActivities.add(
            CourseActivity(
              courseGroup: "02",
              courseName: "Generic Course",
              activityName: "Lecture",
              activityDescription: "Weekly lecture",
              activityLocation: "D-2003",
              startDateTime: DateTime(weekStart.year, weekStart.month, weekStart.day + 3, 9),
              endDateTime: DateTime(weekStart.year, weekStart.month, weekStart.day + 3, 13, 30),
            ),
          );

          // GEN104 - Thursday 10:15-12:45
          courseActivities.add(
            CourseActivity(
              courseGroup: "03",
              courseName: "Generic Course",
              activityName: "Tutorial",
              activityDescription: "Weekly tutorial session",
              activityLocation: "D-3005",
              startDateTime: DateTime(weekStart.year, weekStart.month, weekStart.day + 3, 10, 15),
              endDateTime: DateTime(weekStart.year, weekStart.month, weekStart.day + 3, 12, 45),
            ),
          );
        }
      }

      when(mockCourseRepository.scheduleActivities).thenReturn(scheduleActivities);
      when(mockCourseRepository.coursesActivities).thenReturn(courseActivities);

      withClock(Clock.fixed(fakeNow.add(Duration(days: DateTime.monday + 7))), () {
        expect(service.getIncomingLongWeekendStatus(), LongWeekendStatus.incoming);
      });
    });

    test('return none if the last day of the a week that isn\'t current week is missed and we are not currently in weekend', () {
      List<CourseActivity> courseActivities = [];

      for (int week = 0; week < 15; week++) {
        final weekStart = firstDayOfWeek.add(Duration(days: week * 7));

        // GEN101 - Monday 9:00-12:00
        courseActivities.add(
          CourseActivity(
            courseGroup: "01",
            courseName: "Generic Course",
            activityName: "Lecture",
            activityDescription: "Weekly lecture",
            activityLocation: "Online",
            startDateTime: DateTime(weekStart.year, weekStart.month, weekStart.day, 9),
            endDateTime: DateTime(weekStart.year, weekStart.month, weekStart.day, 12),
          ),
        );

        // GEN102 - Tuesday 13:30-15:00
        courseActivities.add(
          CourseActivity(
            courseGroup: "01",
            courseName: "Generic Course",
            activityName: "Lab Group A",
            activityDescription: "Weekly lab session",
            activityLocation: "D-4001",
            startDateTime: DateTime(weekStart.year, weekStart.month, weekStart.day + 1, 13, 30),
            endDateTime: DateTime(weekStart.year, weekStart.month, weekStart.day + 1, 15),
          ),
        );

        // Simulate missing last day of classes for second week
        if (week != 1) {
          // GEN103 - Thursday 9:00-13:30
          courseActivities.add(
            CourseActivity(
              courseGroup: "02",
              courseName: "Generic Course",
              activityName: "Lecture",
              activityDescription: "Weekly lecture",
              activityLocation: "D-2003",
              startDateTime: DateTime(weekStart.year, weekStart.month, weekStart.day + 3, 9),
              endDateTime: DateTime(weekStart.year, weekStart.month, weekStart.day + 3, 13, 30),
            ),
          );

          // GEN104 - Thursday 10:15-12:45
          courseActivities.add(
            CourseActivity(
              courseGroup: "03",
              courseName: "Generic Course",
              activityName: "Tutorial",
              activityDescription: "Weekly tutorial session",
              activityLocation: "D-3005",
              startDateTime: DateTime(weekStart.year, weekStart.month, weekStart.day + 3, 10, 15),
              endDateTime: DateTime(weekStart.year, weekStart.month, weekStart.day + 3, 12, 45),
            ),
          );
        }
      }

      when(mockCourseRepository.scheduleActivities).thenReturn(scheduleActivities);
      when(mockCourseRepository.coursesActivities).thenReturn(courseActivities);

      withClock(Clock.fixed(fakeNow.add(Duration(days: DateTime.monday + (7 * 2)))), () {
        expect(service.getIncomingLongWeekendStatus(), LongWeekendStatus.none);
      });
    });
  });
}
