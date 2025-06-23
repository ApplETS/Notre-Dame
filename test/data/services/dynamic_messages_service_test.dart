import 'package:clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:notredame/data/repositories/settings_repository.dart';
import 'package:notredame/data/services/signets-api/models/course_activity.dart';
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

  group('sessionHasStarted -', () {
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

  group('oneWeekRemainingUntilSessionEnd -', () {
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

  group('daysRemainingBeforeSessionEnds -', () {
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

  group('isEndOfWeek -', () {
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
}
