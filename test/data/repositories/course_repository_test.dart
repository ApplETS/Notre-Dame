// Dart imports:
import 'dart:convert';

// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:mockito/mockito.dart';

// Project imports:
import 'package:notredame/data/models/activity_code.dart';
import 'package:notredame/data/repositories/course_repository.dart';
import 'package:notredame/data/repositories/user_repository.dart';
import 'package:notredame/data/services/analytics_service.dart';
import 'package:notredame/data/services/cache_service.dart';
import 'package:notredame/data/services/signets-api/models/course.dart';
import 'package:notredame/data/services/signets-api/models/course_activity.dart';
import 'package:notredame/data/services/signets-api/models/course_evaluation.dart';
import 'package:notredame/data/services/signets-api/models/course_review.dart';
import 'package:notredame/data/services/signets-api/models/course_summary.dart';
import 'package:notredame/data/services/signets-api/models/replaced_day.dart';
import 'package:notredame/data/services/signets-api/models/schedule_activity.dart';
import 'package:notredame/data/services/signets-api/models/session.dart';
import 'package:notredame/data/services/signets-api/signets_api_client.dart';
import 'package:notredame/utils/api_exception.dart';
import '../../helpers.dart';
import '../mocks/repositories/user_repository_mock.dart';
import '../mocks/services/analytics_service_mock.dart';
import '../mocks/services/cache_service_mock.dart';
import '../mocks/services/networking_service_mock.dart';
import '../mocks/services/signets_api_mock.dart';

void main() {
  late AnalyticsServiceMock analyticsServiceMock;
  late NetworkingServiceMock networkingServiceMock;
  late UserRepositoryMock userRepositoryMock;
  late CacheServiceMock cacheManagerMock;
  late SignetsAPIClientMock signetsApiMock;

  late CourseRepository manager;

  final Session session = Session(
    shortName: 'NOW',
    name: 'now',
    startDate: DateTime(2020),
    endDate: DateTime.now().add(const Duration(days: 10)),
    endDateCourses: DateTime(2020),
    startDateRegistration: DateTime(2020),
    deadlineRegistration: DateTime(2020),
    startDateCancellationWithRefund: DateTime(2020),
    deadlineCancellationWithRefund: DateTime(2020),
    deadlineCancellationWithRefundNewStudent: DateTime(2020),
    startDateCancellationWithoutRefundNewStudent: DateTime(2020),
    deadlineCancellationWithoutRefundNewStudent: DateTime(2020),
    deadlineCancellationASEQ: DateTime(2020),
  );

  group("CourseRepository - ", () {
    setUp(() {
      // Setup needed services and managers
      analyticsServiceMock = setupAnalyticsServiceMock();
      signetsApiMock = setupSignetsApiMock();
      userRepositoryMock = setupUserRepositoryMock();
      cacheManagerMock = setupCacheManagerMock();
      networkingServiceMock = setupNetworkingServiceMock();
      setupLogger();

      manager = CourseRepository();
    });

    tearDown(() {
      clearInteractions(analyticsServiceMock);
      unregister<AnalyticsService>();
      clearInteractions(signetsApiMock);
      unregister<SignetsAPIClient>();
      clearInteractions(userRepositoryMock);
      unregister<UserRepository>();
      clearInteractions(cacheManagerMock);
      unregister<CacheService>();
      clearInteractions(networkingServiceMock);
      unregister<NetworkingServiceMock>();
    });

    group("getCoursesActivities - ", () {
      final CourseActivity activity = CourseActivity(
        courseGroup: "GEN101",
        courseName: "Generic course",
        activityName: "TD",
        activityDescription: "Activity description",
        activityLocation: "location",
        startDateTime: DateTime(2020, 1, 1, 18),
        endDateTime: DateTime(2020, 1, 1, 21),
      );

      final List<CourseActivity> activities = [activity];

      setUp(() {
        // Stub some sessions
        CacheServiceMock.stubGet(cacheManagerMock, CourseRepository.sessionsCacheKey, jsonEncode([]));
        SignetsAPIClientMock.stubGetSessions(signetsApiMock, [session]);

        // Stub to simulate that the user has an active internet connection
        NetworkingServiceMock.stubHasConnectivity(networkingServiceMock);
      });

      test("Activities are loaded from cache.", () async {
        // Stub the cache to return 1 activity
        CacheServiceMock.stubGet(cacheManagerMock, CourseRepository.coursesActivitiesCacheKey, jsonEncode(activities));

        // Stub the SignetsAPI to return 0 activities
        SignetsAPIClientMock.stubGetCoursesActivities(signetsApiMock, session.shortName, []);

        expect(manager.coursesActivities, isNull);
        final List<CourseActivity>? results = await manager.getCoursesActivities(fromCacheOnly: true);

        expect(results, isInstanceOf<List<CourseActivity>>());
        expect(results, activities);
        expect(manager.coursesActivities, activities, reason: "The list of activities should not be empty");

        verifyInOrder([cacheManagerMock.get(CourseRepository.coursesActivitiesCacheKey)]);
      });

      test("Activities are only loaded from cache.", () async {
        // Stub the cache to return 1 activity
        CacheServiceMock.stubGet(cacheManagerMock, CourseRepository.coursesActivitiesCacheKey, jsonEncode(activities));

        expect(manager.coursesActivities, isNull);
        final List<CourseActivity>? results = await manager.getCoursesActivities(fromCacheOnly: true);

        expect(results, isInstanceOf<List<CourseActivity>>());
        expect(results, activities);
        expect(manager.coursesActivities, activities, reason: "The list of activities should not be empty");

        verifyInOrder([cacheManagerMock.get(CourseRepository.coursesActivitiesCacheKey)]);

        verifyNoMoreInteractions(signetsApiMock);
        verifyNoMoreInteractions(userRepositoryMock);
      });

      test("Trying to recover activities from cache but an exception is raised.", () async {
        // Stub the cache to throw an exception
        CacheServiceMock.stubGetException(cacheManagerMock, CourseRepository.coursesActivitiesCacheKey);

        // Stub the SignetsAPI to return 0 activities
        SignetsAPIClientMock.stubGetCoursesActivities(signetsApiMock, session.shortName, []);

        expect(manager.coursesActivities, isNull);
        final List<CourseActivity>? results = await manager.getCoursesActivities();

        expect(results, isInstanceOf<List<CourseActivity>>());
        expect(results, isEmpty);
        expect(manager.coursesActivities, isEmpty, reason: "The list of activities should be empty");

        verifyInOrder([
          cacheManagerMock.get(CourseRepository.coursesActivitiesCacheKey),
          signetsApiMock.getCoursesActivities(session: session.shortName),
          cacheManagerMock.update(CourseRepository.coursesActivitiesCacheKey, any),
        ]);

        verify(signetsApiMock.getSessions()).called(1);
      });

      test("Doesn't retrieve sessions if they are already loaded", () async {
        // Stub the cache to return 1 activity
        CacheServiceMock.stubGet(cacheManagerMock, CourseRepository.coursesActivitiesCacheKey, jsonEncode(activities));

        // Stub the SignetsAPI to return 1 activities
        SignetsAPIClientMock.stubGetCoursesActivities(signetsApiMock, session.shortName, activities);

        // Load the sessions
        await manager.getSessions();
        expect(manager.sessions, isNotEmpty);
        clearInteractions(cacheManagerMock);
        clearInteractions(userRepositoryMock);
        clearInteractions(signetsApiMock);

        expect(manager.coursesActivities, isNull);
        final List<CourseActivity>? results = await manager.getCoursesActivities();

        expect(results, isInstanceOf<List<CourseActivity>>());
        expect(results, activities);
        expect(manager.coursesActivities, activities, reason: "The list of activities should not be empty");

        verifyInOrder([
          cacheManagerMock.get(CourseRepository.coursesActivitiesCacheKey),
          signetsApiMock.getCoursesActivities(session: session.shortName),
          cacheManagerMock.update(CourseRepository.coursesActivitiesCacheKey, any),
        ]);

        verifyNoMoreInteractions(signetsApiMock);
      });

      test("getSessions fails", () async {
        // Stub SignetsApi to throw an exception
        reset(signetsApiMock);
        SignetsAPIClientMock.stubGetSessionsException(signetsApiMock);

        // Stub the cache to return 1 activity
        CacheServiceMock.stubGet(cacheManagerMock, CourseRepository.coursesActivitiesCacheKey, jsonEncode(activities));

        // Stub the SignetsAPI to return 0 activities
        SignetsAPIClientMock.stubGetCoursesActivities(signetsApiMock, session.shortName, []);

        expect(manager.coursesActivities, isNull);
        expect(manager.getCoursesActivities(), throwsA(isInstanceOf<ApiException>()));

        await untilCalled(networkingServiceMock.hasConnectivity());
        expect(manager.coursesActivities, isEmpty, reason: "The list of activities should be empty");

        await untilCalled(analyticsServiceMock.logError(CourseRepository.tag, any, any, any));

        verifyInOrder([
          cacheManagerMock.get(CourseRepository.coursesActivitiesCacheKey),
          analyticsServiceMock.logError(CourseRepository.tag, any, any, any),
        ]);
      });

      test("SignetsAPI returns new activities, the old ones should be maintained and the cache updated.", () async {
        // Stub the cache to return 1 activity
        CacheServiceMock.stubGet(cacheManagerMock, CourseRepository.coursesActivitiesCacheKey, jsonEncode(activities));

        final CourseActivity courseActivity = CourseActivity(
          courseGroup: "GEN102",
          courseName: "Generic course",
          activityName: "Another activity name",
          activityDescription: "Activity description",
          activityLocation: "Another location",
          startDateTime: DateTime(2020, 1, 2, 18),
          endDateTime: DateTime(2020, 1, 2, 21),
        );

        // Stub the SignetsAPI to return 2 activities
        SignetsAPIClientMock.stubGetCoursesActivities(signetsApiMock, session.shortName, [activity, courseActivity]);

        expect(manager.coursesActivities, isNull);
        final List<CourseActivity>? results = await manager.getCoursesActivities();

        expect(results, isInstanceOf<List<CourseActivity>>());
        expect(results, [activity, courseActivity]);
        expect(manager.coursesActivities, [
          activity,
          courseActivity,
        ], reason: "The list of activities should not be empty");

        verifyInOrder([
          cacheManagerMock.get(CourseRepository.coursesActivitiesCacheKey),
          signetsApiMock.getCoursesActivities(session: session.shortName),
          cacheManagerMock.update(CourseRepository.coursesActivitiesCacheKey, jsonEncode([activity, courseActivity])),
        ]);
      });

      test("SignetsAPI returns activities that already exists, should avoid duplicata.", () async {
        // Stub the cache to return 1 activity
        CacheServiceMock.stubGet(cacheManagerMock, CourseRepository.coursesActivitiesCacheKey, jsonEncode(activities));

        // Stub the SignetsAPI to return the same activity as the cache
        SignetsAPIClientMock.stubGetCoursesActivities(signetsApiMock, session.shortName, activities);

        expect(manager.coursesActivities, isNull);
        final List<CourseActivity>? results = await manager.getCoursesActivities();

        expect(results, isInstanceOf<List<CourseActivity>>());
        expect(results, activities);
        expect(manager.coursesActivities, activities, reason: "The list of activities should not have duplicata");

        verifyInOrder([
          cacheManagerMock.get(CourseRepository.coursesActivitiesCacheKey),
          signetsApiMock.getCoursesActivities(session: session.shortName),
          cacheManagerMock.update(CourseRepository.coursesActivitiesCacheKey, jsonEncode(activities)),
        ]);
      });

      test("SignetsAPI returns activities that changed (for example class location changed).", () async {
        // Stub the cache to return 1 activity
        CacheServiceMock.stubGet(cacheManagerMock, CourseRepository.coursesActivitiesCacheKey, jsonEncode(activities));

        // Load the sessions
        await manager.getSessions();
        expect(manager.sessions, isNotEmpty);
        clearInteractions(cacheManagerMock);
        clearInteractions(userRepositoryMock);
        clearInteractions(signetsApiMock);

        final changedActivity = CourseActivity(
          courseGroup: activity.courseGroup,
          courseName: activity.courseName,
          activityName: activity.activityName,
          activityDescription: 'Another description',
          activityLocation: 'Changed location',
          startDateTime: activity.startDateTime,
          endDateTime: activity.endDateTime,
        );

        // Stub the SignetsAPI to return the same activity as the cache
        SignetsAPIClientMock.stubGetCoursesActivities(signetsApiMock, session.shortName, [changedActivity]);

        expect(manager.coursesActivities, isNull);
        final List<CourseActivity>? results = await manager.getCoursesActivities();

        expect(results, isInstanceOf<List<CourseActivity>>());
        expect(results, [changedActivity]);
        expect(manager.coursesActivities, [changedActivity], reason: "The list of activities should be updated");

        verifyInOrder([
          cacheManagerMock.get(CourseRepository.coursesActivitiesCacheKey),
          signetsApiMock.getCoursesActivities(session: session.shortName),
          cacheManagerMock.update(CourseRepository.coursesActivitiesCacheKey, jsonEncode([changedActivity])),
        ]);
      });

      test("SignetsAPI raise a exception.", () async {
        // Stub the cache to return no activity
        CacheServiceMock.stubGet(cacheManagerMock, CourseRepository.coursesActivitiesCacheKey, jsonEncode([]));

        // Stub the SignetsAPI to throw an exception
        SignetsAPIClientMock.stubGetCoursesActivitiesException(
          signetsApiMock,
          session.shortName,
          exceptionToThrow: const ApiException(prefix: CourseRepository.tag),
        );

        expect(manager.coursesActivities, isNull);
        expect(manager.getCoursesActivities(), throwsA(isInstanceOf<ApiException>()));

        await untilCalled(networkingServiceMock.hasConnectivity());
        expect(manager.coursesActivities, isEmpty, reason: "The list of activities should be empty");

        await untilCalled(analyticsServiceMock.logError(CourseRepository.tag, any, any, any));

        verifyInOrder([
          cacheManagerMock.get(CourseRepository.coursesActivitiesCacheKey),
          signetsApiMock.getCoursesActivities(session: session.shortName),
          analyticsServiceMock.logError(CourseRepository.tag, any, any, any),
        ]);
      });

      test("Cache update fails, should still return the updated list of activities.", () async {
        // Stub the cache to return 1 activity
        CacheServiceMock.stubGet(cacheManagerMock, CourseRepository.coursesActivitiesCacheKey, jsonEncode(activities));

        // Stub the SignetsAPI to return 1 activity
        SignetsAPIClientMock.stubGetCoursesActivities(signetsApiMock, session.shortName, activities);

        CacheServiceMock.stubUpdateException(cacheManagerMock, CourseRepository.coursesActivitiesCacheKey);

        expect(manager.coursesActivities, isNull);
        final List<CourseActivity>? results = await manager.getCoursesActivities();

        expect(results, isInstanceOf<List<CourseActivity>>());
        expect(results, activities);
        expect(manager.coursesActivities, activities, reason: "The list of activities should not be empty");

        verifyInOrder([
          cacheManagerMock.get(CourseRepository.coursesActivitiesCacheKey),
          signetsApiMock.getCoursesActivities(session: session.shortName),
        ]);
      });

      test("Should force fromCacheOnly mode when user has no connectivity", () async {
        // Stub the cache to return 1 activity
        CacheServiceMock.stubGet(cacheManagerMock, CourseRepository.coursesActivitiesCacheKey, jsonEncode(activities));

        //Stub the networkingService to return no connectivity
        reset(networkingServiceMock);
        NetworkingServiceMock.stubHasConnectivity(networkingServiceMock, hasConnectivity: false);

        final activitiesCache = await manager.getCoursesActivities();
        expect(activitiesCache, activities);
      });
    });

    group("getScheduleActivities - ", () {
      final Session session = Session(
        shortName: 'NOW',
        name: 'now',
        startDate: DateTime(2020),
        endDate: DateTime.now().add(const Duration(days: 10)),
        endDateCourses: DateTime(2020),
        startDateRegistration: DateTime(2020),
        deadlineRegistration: DateTime(2020),
        startDateCancellationWithRefund: DateTime(2020),
        deadlineCancellationWithRefund: DateTime(2020),
        deadlineCancellationWithRefundNewStudent: DateTime(2020),
        startDateCancellationWithoutRefundNewStudent: DateTime(2020),
        deadlineCancellationWithoutRefundNewStudent: DateTime(2020),
        deadlineCancellationASEQ: DateTime(2020),
      );

      final ScheduleActivity scheduleActivity = ScheduleActivity(
        courseAcronym: 'GEN101',
        courseGroup: '01',
        dayOfTheWeek: 1,
        day: 'Lundi',
        activityCode: ActivityCode.labEvery2Weeks,
        name: 'Laboratoire aux 2 semaines',
        isPrincipalActivity: false,
        startTime: DateFormat('HH:mm').parse("08:30"),
        endTime: DateFormat('HH:mm').parse("12:30"),
        activityLocation: 'À distance',
        courseTitle: 'Generic title',
      );

      final List<ScheduleActivity> scheduleActivities = [scheduleActivity];

      setUp(() {
        // Stub some sessions
        CacheServiceMock.stubGet(cacheManagerMock, CourseRepository.sessionsCacheKey, jsonEncode([]));
        SignetsAPIClientMock.stubGetSessions(signetsApiMock, [session]);

        // Stub to simulate that the user has an active internet connection
        NetworkingServiceMock.stubHasConnectivity(networkingServiceMock);
      });

      test("Activities are loaded from cache.", () async {
        // Stub the cache to return 1 activity
        CacheServiceMock.stubGet(
          cacheManagerMock,
          CourseRepository.scheduleActivitiesCacheKey,
          jsonEncode(scheduleActivities),
        );

        // Stub the SignetsAPI to return 0 activities
        SignetsAPIClientMock.stubGetScheduleActivities(signetsApiMock, session.shortName, []);

        expect(manager.coursesActivities, isNull);
        final List<ScheduleActivity> results = await manager.getScheduleActivities();

        expect(results, isInstanceOf<List<ScheduleActivity>>());
        expect(results, scheduleActivities);
        expect(manager.scheduleActivities, scheduleActivities, reason: "The list of activities should not be empty");

        verifyInOrder([
          cacheManagerMock.get(CourseRepository.scheduleActivitiesCacheKey),
          signetsApiMock.getScheduleActivities(session: session.shortName),
          cacheManagerMock.update(CourseRepository.scheduleActivitiesCacheKey, any),
        ]);
      });

      test("Activities are only loaded from cache.", () async {
        // Stub the cache to return 1 activity
        CacheServiceMock.stubGet(
          cacheManagerMock,
          CourseRepository.scheduleActivitiesCacheKey,
          jsonEncode(scheduleActivities),
        );

        expect(manager.scheduleActivities, isNull);
        final List<ScheduleActivity> results = await manager.getScheduleActivities(fromCacheOnly: true);

        expect(results, isInstanceOf<List<ScheduleActivity>>());
        expect(results, scheduleActivities);
        expect(manager.scheduleActivities, scheduleActivities, reason: "The list of activities should not be empty");

        verifyInOrder([cacheManagerMock.get(CourseRepository.scheduleActivitiesCacheKey)]);

        verifyNoMoreInteractions(signetsApiMock);
        verifyNoMoreInteractions(userRepositoryMock);
      });

      test("Trying to recover activities from cache but an exception is raised.", () async {
        // Stub the cache to throw an exception
        CacheServiceMock.stubGetException(cacheManagerMock, CourseRepository.scheduleActivitiesCacheKey);

        // Stub the SignetsAPI to return 0 activities
        SignetsAPIClientMock.stubGetScheduleActivities(signetsApiMock, session.shortName, []);

        expect(manager.scheduleActivities, isNull);
        final List<ScheduleActivity> results = await manager.getScheduleActivities();

        expect(results, isInstanceOf<List<ScheduleActivity>>());
        expect(results, isEmpty);
        expect(manager.scheduleActivities, isEmpty, reason: "The list of activities should be empty");

        verifyInOrder([
          cacheManagerMock.get(CourseRepository.scheduleActivitiesCacheKey),
          signetsApiMock.getScheduleActivities(session: session.shortName),
          cacheManagerMock.update(CourseRepository.scheduleActivitiesCacheKey, any),
        ]);

        verify(signetsApiMock.getSessions()).called(1);
      });

      test("Doesn't retrieve sessions if they are already loaded", () async {
        // Stub the cache to return 1 activity
        CacheServiceMock.stubGet(
          cacheManagerMock,
          CourseRepository.scheduleActivitiesCacheKey,
          jsonEncode(scheduleActivities),
        );

        // Stub the SignetsAPI to return 0 activities
        SignetsAPIClientMock.stubGetScheduleActivities(signetsApiMock, session.shortName, []);

        // Load the sessions
        await manager.getSessions();
        expect(manager.sessions, isNotEmpty);
        clearInteractions(cacheManagerMock);
        clearInteractions(userRepositoryMock);
        clearInteractions(signetsApiMock);

        expect(manager.scheduleActivities, isNull);
        final List<ScheduleActivity> results = await manager.getScheduleActivities();

        expect(results, isInstanceOf<List<ScheduleActivity>>());
        expect(results, scheduleActivities);
        expect(manager.scheduleActivities, scheduleActivities, reason: "The list of activities should not be empty");

        verifyInOrder([
          cacheManagerMock.get(CourseRepository.scheduleActivitiesCacheKey),
          signetsApiMock.getScheduleActivities(session: session.shortName),
          cacheManagerMock.update(CourseRepository.scheduleActivitiesCacheKey, any),
        ]);

        verifyNoMoreInteractions(signetsApiMock);
      });

      test("getSessions fails", () async {
        // Stub SignetsApi to throw an exception
        reset(signetsApiMock);
        SignetsAPIClientMock.stubGetSessionsException(signetsApiMock);

        // Stub the cache to return 1 activity
        CacheServiceMock.stubGet(
          cacheManagerMock,
          CourseRepository.scheduleActivitiesCacheKey,
          jsonEncode(scheduleActivities),
        );

        // Stub the SignetsAPI to return 0 activities
        SignetsAPIClientMock.stubGetScheduleActivities(signetsApiMock, session.shortName, []);

        expect(manager.scheduleActivities, isNull);
        expect(manager.getScheduleActivities(), throwsA(isInstanceOf<ApiException>()));

        await untilCalled(networkingServiceMock.hasConnectivity());
        expect(manager.scheduleActivities, isEmpty, reason: "The list of activities should be empty");

        await untilCalled(analyticsServiceMock.logError(CourseRepository.tag, any, any, any));

        verifyInOrder([
          cacheManagerMock.get(CourseRepository.scheduleActivitiesCacheKey),
          analyticsServiceMock.logError(CourseRepository.tag, any, any, any),
        ]);
      });

      test("SignetsAPI returns activities that already exists, should avoid duplicata.", () async {
        // Stub the cache to return 1 activity
        CacheServiceMock.stubGet(
          cacheManagerMock,
          CourseRepository.scheduleActivitiesCacheKey,
          jsonEncode(scheduleActivities),
        );

        // Stub the SignetsAPI to return the same activity as the cache
        SignetsAPIClientMock.stubGetScheduleActivities(signetsApiMock, session.shortName, scheduleActivities);

        expect(manager.scheduleActivities, isNull);
        final List<ScheduleActivity> results = await manager.getScheduleActivities();

        expect(results, isInstanceOf<List<ScheduleActivity>>());
        expect(results, scheduleActivities);
        expect(
          manager.scheduleActivities,
          scheduleActivities,
          reason: "The list of activities should not have duplicata",
        );

        verifyInOrder([
          cacheManagerMock.get(CourseRepository.scheduleActivitiesCacheKey),
          signetsApiMock.getScheduleActivities(session: session.shortName),
          cacheManagerMock.update(CourseRepository.scheduleActivitiesCacheKey, jsonEncode(scheduleActivities)),
        ]);
      });

      test("SignetsAPI raise a exception.", () async {
        // Stub the cache to return no activity
        CacheServiceMock.stubGet(cacheManagerMock, CourseRepository.scheduleActivitiesCacheKey, jsonEncode([]));

        // Stub the SignetsAPI to throw an exception
        SignetsAPIClientMock.stubGetScheduleActivitiesException(
          signetsApiMock,
          session.shortName,
          exceptionToThrow: const ApiException(prefix: CourseRepository.tag),
        );

        expect(manager.scheduleActivities, isNull);
        expect(manager.getScheduleActivities(), throwsA(isInstanceOf<ApiException>()));

        await untilCalled(networkingServiceMock.hasConnectivity());
        expect(manager.scheduleActivities, isEmpty, reason: "The list of activities should be empty");

        await untilCalled(analyticsServiceMock.logError(CourseRepository.tag, any, any, any));

        verifyInOrder([
          cacheManagerMock.get(CourseRepository.scheduleActivitiesCacheKey),
          signetsApiMock.getScheduleActivities(session: session.shortName),
          analyticsServiceMock.logError(CourseRepository.tag, any, any, any),
        ]);
      });
    });

    group("getSessions - ", () {
      final List<Session> sessions = [
        Session(
          shortName: 'H2018',
          name: 'Hiver 2018',
          startDate: DateTime(2018, 1, 4),
          endDate: DateTime(2018, 4, 23),
          endDateCourses: DateTime(2018, 4, 11),
          startDateRegistration: DateTime(2017, 10, 30),
          deadlineRegistration: DateTime(2017, 11, 14),
          startDateCancellationWithRefund: DateTime(2018, 1, 4),
          deadlineCancellationWithRefund: DateTime(2018, 1, 17),
          deadlineCancellationWithRefundNewStudent: DateTime(2018, 1, 31),
          startDateCancellationWithoutRefundNewStudent: DateTime(2018, 2),
          deadlineCancellationWithoutRefundNewStudent: DateTime(2018, 3, 14),
          deadlineCancellationASEQ: DateTime(2018, 1, 31),
        ),
      ];

      setUp(() {
        // Stub to simulate presence of session cache
        CacheServiceMock.stubGet(cacheManagerMock, CourseRepository.sessionsCacheKey, jsonEncode(sessions));

        // Stub SignetsApi answer to test only the cache retrieving
        SignetsAPIClientMock.stubGetSessions(signetsApiMock, []);

        // Stub to simulate that the user has an active internet connection
        NetworkingServiceMock.stubHasConnectivity(networkingServiceMock);
      });

      test("Sessions are loaded from cache", () async {
        expect(manager.sessions, isNull);
        final results = await manager.getSessions();

        expect(results, isInstanceOf<List<Session>>());
        expect(results, sessions);
        expect(manager.sessions, sessions, reason: 'The sessions list should now be loaded.');

        verifyInOrder([
          cacheManagerMock.get(CourseRepository.sessionsCacheKey),
          signetsApiMock.getSessions(),
          cacheManagerMock.update(CourseRepository.sessionsCacheKey, jsonEncode(sessions)),
        ]);
      });

      test("Trying to load sessions from cache but cache doesn't exist", () async {
        // Stub to simulate an exception when trying to get the sessions from the cache
        reset(cacheManagerMock);
        CacheServiceMock.stubGetException(cacheManagerMock, CourseRepository.sessionsCacheKey);

        expect(manager.sessions, isNull);
        final results = await manager.getSessions();

        expect(results, isInstanceOf<List<Session>>());
        expect(results, []);
        expect(manager.sessions, []);

        verifyInOrder([
          cacheManagerMock.get(CourseRepository.sessionsCacheKey),
          signetsApiMock.getSessions(),
          cacheManagerMock.update(CourseRepository.sessionsCacheKey, jsonEncode([])),
        ]);
      });

      test("SignetsAPI return another session", () async {
        // Stub to simulate presence of session cache
        reset(cacheManagerMock);
        CacheServiceMock.stubGet(cacheManagerMock, CourseRepository.sessionsCacheKey, jsonEncode([]));

        // Stub SignetsApi answer to test only the cache retrieving
        reset(signetsApiMock);
        SignetsAPIClientMock.stubGetSessions(signetsApiMock, sessions);

        expect(manager.sessions, isNull);
        final results = await manager.getSessions();

        expect(results, isInstanceOf<List<Session>>());
        expect(results, sessions);
        expect(manager.sessions, sessions, reason: 'The sessions list should now be loaded.');

        verifyInOrder([
          cacheManagerMock.get(CourseRepository.sessionsCacheKey),
          signetsApiMock.getSessions(),
          cacheManagerMock.update(CourseRepository.sessionsCacheKey, jsonEncode(sessions)),
        ]);
      });

      test("SignetsAPI return a session that already exists", () async {
        // Stub SignetsApi answer to test only the cache retrieving
        reset(signetsApiMock);
        SignetsAPIClientMock.stubGetSessions(signetsApiMock, sessions);

        expect(manager.sessions, isNull);
        final results = await manager.getSessions();

        expect(results, isInstanceOf<List<Session>>());
        expect(results, sessions);
        expect(manager.sessions, sessions, reason: 'The sessions list should not have any duplicata..');

        verifyInOrder([
          cacheManagerMock.get(CourseRepository.sessionsCacheKey),
          signetsApiMock.getSessions(),
          cacheManagerMock.update(CourseRepository.sessionsCacheKey, jsonEncode(sessions)),
        ]);
      });

      test("SignetsAPI return an exception", () async {
        // Stub to simulate presence of session cache
        reset(cacheManagerMock);
        CacheServiceMock.stubGet(cacheManagerMock, CourseRepository.sessionsCacheKey, jsonEncode([]));

        // Stub SignetsApi answer to test only the cache retrieving
        SignetsAPIClientMock.stubGetSessionsException(signetsApiMock);

        expect(manager.sessions, isNull);
        expect(manager.getSessions(), throwsA(isInstanceOf<ApiException>()));
        expect(manager.sessions, [], reason: 'The session list should be empty');

        await untilCalled(analyticsServiceMock.logError(CourseRepository.tag, any, any, any));

        verifyInOrder([
          cacheManagerMock.get(CourseRepository.sessionsCacheKey),
          signetsApiMock.getSessions(),
          analyticsServiceMock.logError(CourseRepository.tag, any, any, any),
        ]);

        verifyNever(cacheManagerMock.update(CourseRepository.sessionsCacheKey, any));
      });

      test("Cache update fail", () async {
        // Stub to simulate presence of session cache
        reset(cacheManagerMock);
        CacheServiceMock.stubGet(cacheManagerMock, CourseRepository.sessionsCacheKey, jsonEncode([]));

        // Stub to simulate exception when updating cache
        CacheServiceMock.stubUpdateException(cacheManagerMock, CourseRepository.sessionsCacheKey);

        // Stub SignetsApi answer to test only the cache retrieving
        SignetsAPIClientMock.stubGetSessions(signetsApiMock, sessions);

        expect(manager.sessions, isNull);
        final results = await manager.getSessions();

        expect(results, isInstanceOf<List<Session>>());
        expect(results, sessions);
        expect(manager.sessions, sessions, reason: 'The sessions list should now be loaded even if the caching fails.');

        verifyInOrder([cacheManagerMock.get(CourseRepository.sessionsCacheKey), signetsApiMock.getSessions()]);
      });

      test("UserRepository return an exception", () async {
        // Stub to simulate presence of session cache
        reset(cacheManagerMock);
        CacheServiceMock.stubGet(cacheManagerMock, CourseRepository.sessionsCacheKey, jsonEncode([]));
        SignetsAPIClientMock.stubGetSessionsException(signetsApiMock);

        expect(manager.sessions, isNull);
        expect(manager.getSessions(), throwsA(isInstanceOf<ApiException>()));
        expect(manager.sessions, [], reason: 'The session list should be empty');

        await untilCalled(analyticsServiceMock.logError(CourseRepository.tag, any, any, any));

        verifyInOrder([
          cacheManagerMock.get(CourseRepository.sessionsCacheKey),
          analyticsServiceMock.logError(CourseRepository.tag, any, any, any),
        ]);

        verifyNever(cacheManagerMock.update(CourseRepository.sessionsCacheKey, any));
      });

      test("Should not try to fetch from signets when offline", () async {
        CacheServiceMock.stubGet(cacheManagerMock, CourseRepository.sessionsCacheKey, jsonEncode(sessions));

        //Stub the networkingService to return no connectivity
        reset(networkingServiceMock);
        NetworkingServiceMock.stubHasConnectivity(networkingServiceMock, hasConnectivity: false);

        final sessionsCache = await manager.getSessions();
        expect(sessionsCache, sessions);
        verifyNever(signetsApiMock.getSessions());
      });
    });

    group("activeSessions - ", () {
      final now = DateTime.now();

      final Session oldSession = Session(
        shortName: 'H2018',
        name: 'Hiver 2018',
        startDate: DateTime(2018, 1, 4),
        endDate: DateTime(2018, 4, 23),
        endDateCourses: DateTime(2018, 4, 11),
        startDateRegistration: DateTime(2017, 10, 30),
        deadlineRegistration: DateTime(2017, 11, 14),
        startDateCancellationWithRefund: DateTime(2018, 1, 4),
        deadlineCancellationWithRefund: DateTime(2018, 1, 17),
        deadlineCancellationWithRefundNewStudent: DateTime(2018, 1, 31),
        startDateCancellationWithoutRefundNewStudent: DateTime(2018, 2),
        deadlineCancellationWithoutRefundNewStudent: DateTime(2018, 3, 14),
        deadlineCancellationASEQ: DateTime(2018, 1, 31),
      );

      test("current session ends today", () async {
        final Session active = Session(
          shortName: 'NOW',
          name: 'now',
          startDate: DateTime(2020),
          endDate: DateTime(now.year, now.month, now.day),
          endDateCourses: DateTime(2020),
          startDateRegistration: DateTime(2020),
          deadlineRegistration: DateTime(2020),
          startDateCancellationWithRefund: DateTime(2020),
          deadlineCancellationWithRefund: DateTime(2020),
          deadlineCancellationWithRefundNewStudent: DateTime(2020),
          startDateCancellationWithoutRefundNewStudent: DateTime(2020),
          deadlineCancellationWithoutRefundNewStudent: DateTime(2020),
          deadlineCancellationASEQ: DateTime(2020),
        );

        final sessions = [oldSession, active];

        SignetsAPIClientMock.stubGetSessions(signetsApiMock, sessions);
        CacheServiceMock.stubGet(cacheManagerMock, CourseRepository.sessionsCacheKey, jsonEncode(sessions));
        NetworkingServiceMock.stubHasConnectivity(networkingServiceMock);

        await manager.getSessions();

        expect(manager.activeSessions, [active]);
      });

      test("current session ended yesterday", () async {
        final Session old = Session(
          shortName: 'NOW',
          name: 'now',
          startDate: DateTime(2020),
          endDate: DateTime(now.year, now.month, now.day).subtract(const Duration(days: 1)),
          endDateCourses: DateTime(2020),
          startDateRegistration: DateTime(2020),
          deadlineRegistration: DateTime(2020),
          startDateCancellationWithRefund: DateTime(2020),
          deadlineCancellationWithRefund: DateTime(2020),
          deadlineCancellationWithRefundNewStudent: DateTime(2020),
          startDateCancellationWithoutRefundNewStudent: DateTime(2020),
          deadlineCancellationWithoutRefundNewStudent: DateTime(2020),
          deadlineCancellationASEQ: DateTime(2020),
        );

        final sessions = [oldSession, old];

        SignetsAPIClientMock.stubGetSessions(signetsApiMock, sessions);
        CacheServiceMock.stubGet(cacheManagerMock, CourseRepository.sessionsCacheKey, jsonEncode(sessions));
        NetworkingServiceMock.stubHasConnectivity(networkingServiceMock);

        await manager.getSessions();

        expect(manager.activeSessions, []);
      });

      test("current session ends tomorrow", () async {
        final Session active = Session(
          shortName: 'NOW',
          name: 'now',
          startDate: DateTime(2020),
          endDate: DateTime(now.year, now.month, now.day).add(const Duration(days: 1)),
          endDateCourses: DateTime(2020),
          startDateRegistration: DateTime(2020),
          deadlineRegistration: DateTime(2020),
          startDateCancellationWithRefund: DateTime(2020),
          deadlineCancellationWithRefund: DateTime(2020),
          deadlineCancellationWithRefundNewStudent: DateTime(2020),
          startDateCancellationWithoutRefundNewStudent: DateTime(2020),
          deadlineCancellationWithoutRefundNewStudent: DateTime(2020),
          deadlineCancellationASEQ: DateTime(2020),
        );

        final sessions = [oldSession, active];

        SignetsAPIClientMock.stubGetSessions(signetsApiMock, sessions);
        CacheServiceMock.stubGet(cacheManagerMock, CourseRepository.sessionsCacheKey, jsonEncode(sessions));
        NetworkingServiceMock.stubHasConnectivity(networkingServiceMock);

        await manager.getSessions();

        expect(manager.activeSessions, [active]);
      });

      test("there is no session", () async {
        SignetsAPIClientMock.stubGetSessions(signetsApiMock, []);
        CacheServiceMock.stubGet(cacheManagerMock, CourseRepository.sessionsCacheKey, jsonEncode([]));
        NetworkingServiceMock.stubHasConnectivity(networkingServiceMock);

        await manager.getSessions();

        expect(manager.activeSessions, []);
      });

      test("there is no session loaded", () async {
        expect(manager.activeSessions, []);
      });
    });

    group("getCourses - ", () {
      final Course courseWithGrade = Course(
        acronym: 'GEN101',
        group: '02',
        session: 'H2020',
        programCode: '999',
        grade: 'C+',
        numberOfCredits: 3,
        title: 'Cours générique',
        reviews: <CourseReview>[
          CourseReview(
            acronym: 'GEN101',
            group: '02',
            teacherName: 'April, Alain',
            startAt: DateTime(2020),
            endAt: DateTime(2020, 1, 1, 23, 59),
            isCompleted: true,
            type: 'Cours',
          ),
        ],
      );
      final Course courseWithGradeDuplicate = Course(
        acronym: 'GEN101',
        group: '02',
        session: 'É2020',
        programCode: '999',
        grade: 'C+',
        numberOfCredits: 3,
        title: 'Cours générique',
      );

      final Course courseWithoutGrade = Course(
        acronym: 'GEN101',
        group: '02',
        session: 'H2020',
        programCode: '999',
        numberOfCredits: 3,
        title: 'Cours générique',
        summary: CourseSummary(
          currentMark: 5,
          currentMarkInPercent: 50,
          markOutOf: 10,
          passMark: 6,
          standardDeviation: 2.3,
          median: 4.5,
          percentileRank: 99,
          evaluations: [
            CourseEvaluation(
              courseGroup: 'GEN101-02',
              title: 'Test',
              correctedEvaluationOutOf: "20",
              weight: 10,
              published: false,
              teacherMessage: '',
              ignore: false,
            ),
          ],
        ),
      );
      final Course courseWithoutGradeAndSummaryAndEvaluation = Course(
        acronym: 'GEN101',
        group: '02',
        session: 'H2020',
        programCode: '999',
        numberOfCredits: 3,
        title: 'Cours générique',
      );

      setUp(() {
        // Stub some sessions
        SignetsAPIClientMock.stubGetSessions(signetsApiMock, [session]);
        CacheServiceMock.stubGet(cacheManagerMock, CourseRepository.sessionsCacheKey, jsonEncode([]));

        // Stub to simulate that the user has an active internet connection
        NetworkingServiceMock.stubHasConnectivity(networkingServiceMock);
      });

      test("Courses are loaded from cache and cache is updated", () async {
        SignetsAPIClientMock.stubGetCourses(signetsApiMock, coursesToReturn: [courseWithGrade]);
        SignetsAPIClientMock.stubGetCourseReviews(signetsApiMock);
        CacheServiceMock.stubGet(cacheManagerMock, CourseRepository.coursesCacheKey, jsonEncode([courseWithGrade]));

        expect(manager.courses, isNull);
        final results = await manager.getCourses();

        expect(results, isInstanceOf<List<Course>>());
        expect(results, [courseWithGrade]);
        expect(manager.courses, [courseWithGrade], reason: 'The courses list should now be loaded.');

        verifyInOrder([
          cacheManagerMock.get(CourseRepository.coursesCacheKey),
          cacheManagerMock.update(CourseRepository.coursesCacheKey, jsonEncode([courseWithGrade])),
        ]);
      });

      test("Courses are only loaded from cache", () async {
        expect(manager.courses, isNull);
        CacheServiceMock.stubGet(
          cacheManagerMock,
          CourseRepository.coursesCacheKey,
          jsonEncode([courseWithGrade, courseWithoutGrade, courseWithoutGradeAndSummaryAndEvaluation]),
        );
        final results = await manager.getCourses(fromCacheOnly: true);

        expect(results, isInstanceOf<List<Course>>());
        expect(results, [courseWithGrade, courseWithoutGrade, courseWithoutGradeAndSummaryAndEvaluation]);
        expect(manager.courses, [
          courseWithGrade,
          courseWithoutGrade,
          courseWithoutGradeAndSummaryAndEvaluation,
        ], reason: 'The courses list should now be loaded.');

        verifyInOrder([cacheManagerMock.get(CourseRepository.coursesCacheKey)]);

        verifyNoMoreInteractions(signetsApiMock);
        verifyNoMoreInteractions(cacheManagerMock);
        verifyNoMoreInteractions(userRepositoryMock);
      });

      test("Signets return a updated version of a course", () async {
        final Course courseFetched = Course(
          acronym: 'GEN101',
          group: '02',
          session: 'H2020',
          programCode: '999',
          grade: 'A+',
          numberOfCredits: 3,
          title: 'Cours générique',
        );

        CacheServiceMock.stubGet(
          cacheManagerMock,
          CourseRepository.coursesCacheKey,
          jsonEncode([courseWithGrade, courseWithGradeDuplicate]),
        );
        SignetsAPIClientMock.stubGetCourses(signetsApiMock, coursesToReturn: [courseFetched, courseWithGradeDuplicate]);
        SignetsAPIClientMock.stubGetCourseReviews(signetsApiMock);

        expect(manager.courses, isNull);
        final results = await manager.getCourses();

        expect(results, isInstanceOf<List<Course>>());
        expect(results, [courseFetched, courseWithGradeDuplicate]);
        expect(manager.courses, [
          courseFetched,
          courseWithGradeDuplicate,
        ], reason: 'The courses list should now be loaded.');

        verifyInOrder([
          cacheManagerMock.get(CourseRepository.coursesCacheKey),
          signetsApiMock.getCourses(),
          cacheManagerMock.update(
            CourseRepository.coursesCacheKey,
            jsonEncode([courseFetched, courseWithGradeDuplicate]),
          ),
        ]);
      });

      test("Trying to recover courses from cache failed (exception raised)", () async {
        expect(manager.courses, isNull);
        SignetsAPIClientMock.stubGetCourses(signetsApiMock);
        CacheServiceMock.stubGetException(cacheManagerMock, CourseRepository.coursesCacheKey);

        final results = await manager.getCourses(fromCacheOnly: true);

        expect(results, isInstanceOf<List<Course>>());
        expect(results, []);
        expect(manager.courses, [], reason: 'The courses list should be empty.');

        verifyInOrder([cacheManagerMock.get(CourseRepository.coursesCacheKey)]);

        verifyNoMoreInteractions(signetsApiMock);
        verifyNoMoreInteractions(cacheManagerMock);
      });

      test("Signets raised an exception while trying to recover courses", () async {
        CacheServiceMock.stubGet(cacheManagerMock, CourseRepository.coursesCacheKey, jsonEncode([]));
        SignetsAPIClientMock.stubGetCoursesException(signetsApiMock);

        expect(manager.courses, isNull);

        expect(manager.getCourses(), throwsA(isInstanceOf<ApiException>()));

        await untilCalled(networkingServiceMock.hasConnectivity());
        expect(manager.courses, []);

        await untilCalled(analyticsServiceMock.logError(CourseRepository.tag, any, any, any));

        verifyInOrder([
          cacheManagerMock.get(CourseRepository.coursesCacheKey),
          signetsApiMock.getCourses(),
          analyticsServiceMock.logError(CourseRepository.tag, any, any, any),
        ]);

        verifyNoMoreInteractions(signetsApiMock);
        verifyNoMoreInteractions(cacheManagerMock);
        verifyNoMoreInteractions(userRepositoryMock);
      });

      test("Student dropped out of a course, the course should disappear", () async {
        CacheServiceMock.stubGet(cacheManagerMock, CourseRepository.coursesCacheKey, jsonEncode([courseWithoutGrade]));
        SignetsAPIClientMock.stubGetCoursesException(signetsApiMock);

        expect(manager.courses, isNull);

        expect(manager.getCourses(), throwsA(isInstanceOf<ApiException>()));

        await untilCalled(networkingServiceMock.hasConnectivity());
        expect(manager.courses, []);

        await untilCalled(analyticsServiceMock.logError(CourseRepository.tag, any, any, any));

        verifyInOrder([
          cacheManagerMock.get(CourseRepository.coursesCacheKey),
          signetsApiMock.getCourses(),
          analyticsServiceMock.logError(CourseRepository.tag, any, any, any),
        ]);

        verifyNoMoreInteractions(signetsApiMock);
        verifyNoMoreInteractions(cacheManagerMock);
        verifyNoMoreInteractions(userRepositoryMock);
      });

      test("Courses don't have grade so getCourseSummary is called", () async {
        final Course courseFetched = Course(
          acronym: 'GEN101',
          group: '02',
          session: 'H2020',
          programCode: '999',
          numberOfCredits: 3,
          title: 'Cours générique',
        );
        final CourseSummary summary = CourseSummary(
          currentMark: 5,
          currentMarkInPercent: 50,
          markOutOf: 10,
          passMark: 6,
          standardDeviation: 2.3,
          median: 4.5,
          percentileRank: 99,
          evaluations: [],
        );
        final Course courseUpdated = Course(
          acronym: 'GEN101',
          group: '02',
          session: 'H2020',
          programCode: '999',
          numberOfCredits: 3,
          title: 'Cours générique',
          summary: summary,
        );

        SignetsAPIClientMock.stubGetCourses(signetsApiMock, coursesToReturn: [courseFetched]);
        SignetsAPIClientMock.stubGetCourseReviews(signetsApiMock);
        SignetsAPIClientMock.stubGetCourseSummary(signetsApiMock, courseFetched, summaryToReturn: summary);
        CacheServiceMock.stubGet(cacheManagerMock, CourseRepository.coursesCacheKey, jsonEncode([]));

        expect(manager.courses, isNull);
        final results = await manager.getCourses();

        expect(results, isInstanceOf<List<Course>>());
        expect(results, [courseUpdated]);
        expect(manager.courses, [courseUpdated], reason: 'The courses list should now be loaded.');

        verifyInOrder([
          cacheManagerMock.get(CourseRepository.coursesCacheKey),
          signetsApiMock.getCourses(),
          signetsApiMock.getCourseSummary(
            session: courseFetched.session,
            acronym: courseFetched.acronym,
            group: courseFetched.group,
          ),
          cacheManagerMock.update(CourseRepository.coursesCacheKey, jsonEncode([courseUpdated])),
        ]);
      });

      test("getCourseSummary fails", () async {
        final Course courseFetched = Course(
          acronym: 'GEN101',
          group: '02',
          session: 'H2020',
          programCode: '999',
          numberOfCredits: 3,
          title: 'Cours générique',
        );

        SignetsAPIClientMock.stubGetCourses(signetsApiMock, coursesToReturn: [courseFetched]);
        SignetsAPIClientMock.stubGetCourseReviews(signetsApiMock);
        SignetsAPIClientMock.stubGetCourseSummaryException(signetsApiMock, courseFetched);
        CacheServiceMock.stubGet(cacheManagerMock, CourseRepository.coursesCacheKey, jsonEncode([]));

        expect(manager.courses, isNull);
        final results = await manager.getCourses();

        expect(results, isInstanceOf<List<Course>>());
        expect(results, [courseFetched]);
        expect(manager.courses, [courseFetched], reason: 'The courses list should now be loaded.');

        verifyInOrder([
          cacheManagerMock.get(CourseRepository.coursesCacheKey),
          signetsApiMock.getCourses(),
          signetsApiMock.getCourseSummary(
            session: courseFetched.session,
            acronym: courseFetched.acronym,
            group: courseFetched.group,
          ),
          cacheManagerMock.update(CourseRepository.coursesCacheKey, jsonEncode([courseFetched])),
        ]);
      });

      test("Cache update fails, should still return the list of courses", () async {
        SignetsAPIClientMock.stubGetCourses(signetsApiMock, coursesToReturn: [courseWithGrade]);
        SignetsAPIClientMock.stubGetCourseReviews(signetsApiMock);
        CacheServiceMock.stubGet(cacheManagerMock, CourseRepository.coursesCacheKey, jsonEncode([courseWithGrade]));
        CacheServiceMock.stubUpdateException(cacheManagerMock, CourseRepository.coursesCacheKey);

        expect(manager.courses, isNull);
        final results = await manager.getCourses();

        expect(results, isInstanceOf<List<Course>>());
        expect(results, [courseWithGrade]);
        expect(manager.courses, [
          courseWithGrade,
        ], reason: 'The courses list should now be loaded even if the caching fails.');

        verifyInOrder([
          cacheManagerMock.get(CourseRepository.coursesCacheKey),
          signetsApiMock.getCourses(),
          cacheManagerMock.update(CourseRepository.coursesCacheKey, jsonEncode([courseWithGrade])),
        ]);
      });

      test("UserRepository return an exception", () async {
        // Stub to simulate presence of session cache
        reset(cacheManagerMock);
        CacheServiceMock.stubGet(cacheManagerMock, CourseRepository.coursesCacheKey, jsonEncode([]));
        SignetsAPIClientMock.stubGetCoursesException(signetsApiMock);

        expect(manager.sessions, isNull);
        expect(manager.getCourses(), throwsA(isInstanceOf<ApiException>()));

        await untilCalled(networkingServiceMock.hasConnectivity());
        expect(manager.courses, [], reason: 'The courses list should be empty');

        await untilCalled(analyticsServiceMock.logError(CourseRepository.tag, any, any, any));

        verifyInOrder([
          cacheManagerMock.get(CourseRepository.coursesCacheKey),
          analyticsServiceMock.logError(CourseRepository.tag, any, any, any),
        ]);

        verifyNever(cacheManagerMock.update(CourseRepository.coursesCacheKey, any));
      });

      test("Should force fromCacheOnly mode when user has no connectivity", () async {
        // Stub the cache to return 1 activity
        CacheServiceMock.stubGet(cacheManagerMock, CourseRepository.coursesCacheKey, jsonEncode([courseWithGrade]));

        //Stub the networkingService to return no connectivity
        reset(networkingServiceMock);
        NetworkingServiceMock.stubHasConnectivity(networkingServiceMock, hasConnectivity: false);

        final coursesCache = await manager.getCourses();
        expect(coursesCache, [courseWithGrade]);
      });

      test("there is no evaluation for a course, should return null", () async {
        final Course courseFetched = Course(
          acronym: 'GEN101',
          group: '02',
          session: 'H2020',
          grade: 'A+',
          programCode: '999',
          numberOfCredits: 3,
          title: 'Cours générique',
        );

        SignetsAPIClientMock.stubGetCourses(signetsApiMock, coursesToReturn: [courseFetched]);
        SignetsAPIClientMock.stubGetCourseReviews(signetsApiMock, session: session);
        CacheServiceMock.stubGet(cacheManagerMock, CourseRepository.coursesCacheKey, jsonEncode([]));

        expect(manager.courses, isNull);
        final results = await manager.getCourses();

        expect(results, isInstanceOf<List<Course>>());
        expect(results, [courseFetched]);
        expect(manager.courses, [courseFetched], reason: 'The courses list should now be loaded.');

        verifyInOrder([
          cacheManagerMock.get(CourseRepository.coursesCacheKey),
          signetsApiMock.getCourses(),
          signetsApiMock.getCourseReviews(session: session.shortName),
          cacheManagerMock.update(CourseRepository.coursesCacheKey, jsonEncode([courseFetched])),
        ]);
      });

      test("there is an evaluation for a course, course should be updated", () async {
        final Course courseFetched = Course(
          acronym: 'GEN101',
          group: '02',
          session: 'NOW',
          grade: 'A+',
          programCode: '999',
          numberOfCredits: 3,
          title: 'Cours générique',
        );

        final courseReviews = <CourseReview>[
          CourseReview(
            acronym: 'GEN101',
            group: '02',
            teacherName: 'April, Alain',
            startAt: DateTime(2021, 03, 19),
            endAt: DateTime(2021, 03, 28, 23, 59),
            type: 'Cours',
            isCompleted: true,
          ),
        ];

        final Course updated = Course(
          acronym: 'GEN101',
          group: '02',
          session: 'NOW',
          grade: 'A+',
          programCode: '999',
          numberOfCredits: 3,
          title: 'Cours générique',
          reviews: courseReviews,
        );

        SignetsAPIClientMock.stubGetCourses(signetsApiMock, coursesToReturn: [courseFetched]);
        SignetsAPIClientMock.stubGetCourseReviews(
          signetsApiMock,
          session: session,
          reviewsToReturn: [courseReviews[0]],
        );
        CacheServiceMock.stubGet(cacheManagerMock, CourseRepository.coursesCacheKey, jsonEncode([]));

        expect(manager.courses, isNull);
        final results = await manager.getCourses();

        expect(results, isInstanceOf<List<Course>>());
        expect(results, [updated]);
        expect(manager.courses, [updated], reason: 'The courses list should now be loaded.');

        verifyInOrder([
          cacheManagerMock.get(CourseRepository.coursesCacheKey),
          signetsApiMock.getCourses(),
          signetsApiMock.getCourseReviews(session: session.shortName),
          cacheManagerMock.update(CourseRepository.coursesCacheKey, jsonEncode([updated])),
        ]);
      });

      test("_getCourseReviewss fails", () async {
        final Course courseFetched = Course(
          acronym: 'GEN101',
          group: '02',
          session: 'H2020',
          grade: 'A+',
          programCode: '999',
          numberOfCredits: 3,
          title: 'Cours générique',
        );

        SignetsAPIClientMock.stubGetCourses(signetsApiMock, coursesToReturn: [courseFetched]);
        SignetsAPIClientMock.stubGetCourseReviewsException(signetsApiMock, session: session);
        CacheServiceMock.stubGet(cacheManagerMock, CourseRepository.coursesCacheKey, jsonEncode([]));

        expect(manager.courses, isNull);
        final results = await manager.getCourses();

        expect(results, isInstanceOf<List<Course>>());
        expect(results, [courseFetched]);
        expect(manager.courses, [courseFetched], reason: 'The courses list should now be loaded.');

        verifyInOrder([
          cacheManagerMock.get(CourseRepository.coursesCacheKey),
          signetsApiMock.getCourses(),
          signetsApiMock.getCourseReviews(session: session.shortName),
          cacheManagerMock.update(CourseRepository.coursesCacheKey, jsonEncode([courseFetched])),
        ]);
      });
    });

    group("getCourseSummary - ", () {
      late Course course;

      late Course courseUpdated;

      setUp(() {
        // Reset models
        course = Course(
          acronym: 'GEN101',
          group: '02',
          session: 'H2020',
          programCode: '999',
          numberOfCredits: 3,
          title: 'Cours générique',
        );
        courseUpdated = Course(
          acronym: 'GEN101',
          group: '02',
          session: 'H2020',
          programCode: '999',
          numberOfCredits: 3,
          title: 'Cours générique',
          summary: CourseSummary(
            currentMark: 5,
            currentMarkInPercent: 50,
            markOutOf: 10,
            passMark: 6,
            standardDeviation: 2.3,
            median: 4.5,
            percentileRank: 99,
            evaluations: [
              CourseEvaluation(
                courseGroup: 'GEN101-02',
                title: 'Test',
                correctedEvaluationOutOf: "20",
                weight: 10,
                published: false,
                teacherMessage: '',
                ignore: false,
              ),
            ],
          ),
        );

        // Stub to simulate that the user has an active internet connection
        NetworkingServiceMock.stubHasConnectivity(networkingServiceMock);
      });

      test("CourseSummary is fetched and cache is updated", () async {
        SignetsAPIClientMock.stubGetCourseSummary(signetsApiMock, course, summaryToReturn: courseUpdated.summary);

        expect(manager.courses, isNull);
        final results = await manager.getCourseSummary(course);

        expect(results, isInstanceOf<Course>());
        expect(results, courseUpdated);
        expect(manager.courses, [courseUpdated], reason: 'The courses list should now be loaded.');

        verifyInOrder([
          signetsApiMock.getCourseSummary(session: course.session, acronym: course.acronym, group: course.group),
          cacheManagerMock.update(CourseRepository.coursesCacheKey, jsonEncode([courseUpdated])),
        ]);
      });

      test("Course is updated on the repository", () async {
        CacheServiceMock.stubGet(cacheManagerMock, CourseRepository.coursesCacheKey, jsonEncode([course]));
        SignetsAPIClientMock.stubGetCourseSummary(signetsApiMock, course, summaryToReturn: courseUpdated.summary);

        // Load a course
        await manager.getCourses(fromCacheOnly: true);

        clearInteractions(cacheManagerMock);
        clearInteractions(signetsApiMock);
        clearInteractions(userRepositoryMock);

        expect(manager.courses, [course]);

        final results = await manager.getCourseSummary(course);

        expect(results, isInstanceOf<Course>());
        expect(results, courseUpdated);
        expect(manager.courses, [courseUpdated], reason: 'The courses list should now be updated.');

        verifyInOrder([
          signetsApiMock.getCourseSummary(session: course.session, acronym: course.acronym, group: course.group),
          cacheManagerMock.update(CourseRepository.coursesCacheKey, jsonEncode([courseUpdated])),
        ]);
      });

      test("Signets raised an exception while trying to recover summary", () async {
        SignetsAPIClientMock.stubGetCourseSummaryException(signetsApiMock, course);

        expect(manager.courses, isNull);

        expect(manager.getCourseSummary(course), throwsA(isInstanceOf<ApiException>()));
        expect(manager.courses, isNull);

        await untilCalled(analyticsServiceMock.logError(CourseRepository.tag, any, any, any));

        verifyInOrder([
          signetsApiMock.getCourseSummary(session: course.session, acronym: course.acronym, group: course.group),
          analyticsServiceMock.logError(CourseRepository.tag, any, any, any),
        ]);

        verifyNoMoreInteractions(signetsApiMock);
        verifyNoMoreInteractions(cacheManagerMock);
        verifyNoMoreInteractions(userRepositoryMock);
      });

      test("Cache update fails, should still return the course with its summary", () async {
        SignetsAPIClientMock.stubGetCourseSummary(signetsApiMock, course, summaryToReturn: courseUpdated.summary);
        CacheServiceMock.stubUpdateException(cacheManagerMock, CourseRepository.coursesCacheKey);

        expect(manager.courses, isNull);
        final results = await manager.getCourseSummary(course);

        expect(results, isInstanceOf<Course>());
        expect(results, courseUpdated);
        expect(manager.courses, [
          courseUpdated,
        ], reason: 'The courses list should now be loaded even if the caching fails.');

        verifyInOrder([
          signetsApiMock.getCourseSummary(session: course.session, acronym: course.acronym, group: course.group),
          cacheManagerMock.update(CourseRepository.coursesCacheKey, jsonEncode([courseUpdated])),
        ]);
      });

      test("UserRepository return an exception", () async {
        // Stub to simulate presence of session cache
        reset(cacheManagerMock);
        CacheServiceMock.stubGet(cacheManagerMock, CourseRepository.coursesCacheKey, jsonEncode([]));
        SignetsAPIClientMock.stubGetCourseSummaryException(signetsApiMock, course);

        expect(manager.sessions, isNull);
        expect(manager.getCourseSummary(course), throwsA(isInstanceOf<ApiException>()));
        expect(manager.courses, isNull);

        await untilCalled(analyticsServiceMock.logError(CourseRepository.tag, any, any, any));

        verifyInOrder([
          signetsApiMock.getCourseSummary(session: course.session, acronym: course.acronym, group: course.group),
          analyticsServiceMock.logError(CourseRepository.tag, any, any, any),
        ]);

        verifyNoMoreInteractions(signetsApiMock);
        verifyNoMoreInteractions(cacheManagerMock);
      });

      test("Should not try to update course summary when offline", () async {
        //Stub the networkingService to return no connectivity
        reset(networkingServiceMock);
        NetworkingServiceMock.stubHasConnectivity(networkingServiceMock, hasConnectivity: false);

        final results = await manager.getCourseSummary(course);
        expect(results, course);
        verifyNever(
          signetsApiMock.getCourseSummary(session: course.session, acronym: course.acronym, group: course.group),
        );
      });
    });

    group("getReplacedDays - ", () {
      final ReplacedDay replacedDay = ReplacedDay(
        originalDate: DateTime(2025, 05, 10),
        replacementDate: DateTime(2025, 05, 15),
        description: "Action de grâces",
      );

      final List<ReplacedDay> replacedDays = [replacedDay];

      setUp(() {
        // Stub some sessions
        CacheServiceMock.stubGet(cacheManagerMock, CourseRepository.sessionsCacheKey, jsonEncode([]));
        SignetsAPIClientMock.stubGetSessions(signetsApiMock, [session]);

        // Stub to simulate that the user has an active internet connection
        NetworkingServiceMock.stubHasConnectivity(networkingServiceMock);
      });

      test("Replaced days are loaded from cache.", () async {
        // Stub the cache to return 1 replaced day
        CacheServiceMock.stubGet(cacheManagerMock, CourseRepository.replacedDaysCacheKey, jsonEncode(replacedDays));

        // Stub the SignetsAPI to return 0 replaced days
        SignetsAPIClientMock.stubGetReplacedDays(signetsApiMock, session.shortName, []);

        expect(manager.replacedDays, isNull);
        final List<ReplacedDay>? results = await manager.getReplacedDays(fromCacheOnly: true);

        expect(results, isInstanceOf<List<ReplacedDay>>());
        expect(results, replacedDays);
        expect(manager.replacedDays, replacedDays, reason: "The list of replaced days should not be empty");

        verifyInOrder([cacheManagerMock.get(CourseRepository.replacedDaysCacheKey)]);
      });

      test("Replaced days are only loaded from cache.", () async {
        // Stub the cache to return 1 replaced day
        CacheServiceMock.stubGet(cacheManagerMock, CourseRepository.replacedDaysCacheKey, jsonEncode(replacedDays));

        expect(manager.replacedDays, isNull);
        final List<ReplacedDay>? results = await manager.getReplacedDays(fromCacheOnly: true);

        expect(results, isInstanceOf<List<ReplacedDay>>());
        expect(results, replacedDays);
        expect(manager.replacedDays, replacedDays, reason: "The list of replaced days should not be empty");

        verifyInOrder([cacheManagerMock.get(CourseRepository.replacedDaysCacheKey)]);

        verifyNoMoreInteractions(signetsApiMock);
        verifyNoMoreInteractions(userRepositoryMock);
      });

      test("Trying to recover replaced days from cache but an exception is raised.", () async {
        // Stub the cache to throw an exception
        CacheServiceMock.stubGetException(cacheManagerMock, CourseRepository.replacedDaysCacheKey);

        // Stub the SignetsAPI to return 0 activities
        SignetsAPIClientMock.stubGetReplacedDays(signetsApiMock, session.shortName, []);

        expect(manager.replacedDays, isNull);
        final List<ReplacedDay>? results = await manager.getReplacedDays();

        expect(results, isInstanceOf<List<ReplacedDay>>());
        expect(results, isEmpty);
        expect(manager.replacedDays, isEmpty, reason: "The list of replaced days should be empty");

        verifyInOrder([
          cacheManagerMock.get(CourseRepository.replacedDaysCacheKey),
          signetsApiMock.getReplacedDays(session: session.shortName),
          cacheManagerMock.update(CourseRepository.replacedDaysCacheKey, any),
        ]);

        verify(signetsApiMock.getSessions()).called(1);
      });

      test("Doesn't retrieve sessions if they are already loaded", () async {
        // Stub the cache to return 1 replaced day
        CacheServiceMock.stubGet(cacheManagerMock, CourseRepository.replacedDaysCacheKey, jsonEncode(replacedDays));

        // Stub the SignetsAPI to return 1 activities
        SignetsAPIClientMock.stubGetReplacedDays(signetsApiMock, session.shortName, replacedDays);

        // Load the sessions
        await manager.getSessions();
        expect(manager.sessions, isNotEmpty);
        clearInteractions(cacheManagerMock);
        clearInteractions(userRepositoryMock);
        clearInteractions(signetsApiMock);

        expect(manager.replacedDays, isNull);
        final List<ReplacedDay>? results = await manager.getReplacedDays();

        expect(results, isInstanceOf<List<ReplacedDay>>());
        expect(results, replacedDays);
        expect(manager.replacedDays, replacedDays, reason: "The list of replaced days should not be empty");

        verifyInOrder([
          cacheManagerMock.get(CourseRepository.replacedDaysCacheKey),
          signetsApiMock.getReplacedDays(session: session.shortName),
          cacheManagerMock.update(CourseRepository.replacedDaysCacheKey, any),
        ]);

        verifyNoMoreInteractions(signetsApiMock);
      });

      test("getSessions fails", () async {
        // Stub SignetsApi to throw an exception
        reset(signetsApiMock);
        SignetsAPIClientMock.stubGetSessionsException(signetsApiMock);

        // Stub the cache to return 1 replaced day
        CacheServiceMock.stubGet(cacheManagerMock, CourseRepository.replacedDaysCacheKey, jsonEncode(replacedDays));

        // Stub the SignetsAPI to return 0 activities
        SignetsAPIClientMock.stubGetCoursesActivities(signetsApiMock, session.shortName, []);

        expect(manager.replacedDays, isNull);
        expect(manager.getReplacedDays(), throwsA(isInstanceOf<ApiException>()));

        await untilCalled(networkingServiceMock.hasConnectivity());
        expect(manager.replacedDays, isEmpty, reason: "The list of replaced days should be empty");

        await untilCalled(analyticsServiceMock.logError(CourseRepository.tag, any, any, any));

        verifyInOrder([
          cacheManagerMock.get(CourseRepository.replacedDaysCacheKey),
          analyticsServiceMock.logError(CourseRepository.tag, any, any, any),
        ]);
      });

      test("SignetsAPI returns new replaced days, the old ones should be maintained and the cache updated.", () async {
        // Stub the cache to return 1 replaced day
        CacheServiceMock.stubGet(cacheManagerMock, CourseRepository.replacedDaysCacheKey, jsonEncode(replacedDays));

        final ReplacedDay replacedDayNew = ReplacedDay(
          originalDate: DateTime(2025, 06, 20),
          replacementDate: DateTime(2025, 06, 27),
          description: "Fête du Canada",
        );

        // Stub the SignetsAPI to return 2 replaced days
        SignetsAPIClientMock.stubGetReplacedDays(signetsApiMock, session.shortName, [replacedDay, replacedDayNew]);

        expect(manager.replacedDays, isNull);
        final List<ReplacedDay>? results = await manager.getReplacedDays();

        expect(results, isInstanceOf<List<ReplacedDay>>());
        expect(results, [replacedDay, replacedDayNew]);
        expect(manager.replacedDays, [
          replacedDay,
          replacedDayNew,
        ], reason: "The list of replaced days should not be empty");

        verifyInOrder([
          cacheManagerMock.get(CourseRepository.replacedDaysCacheKey),
          signetsApiMock.getReplacedDays(session: session.shortName),
          cacheManagerMock.update(CourseRepository.replacedDaysCacheKey, jsonEncode([replacedDay, replacedDayNew])),
        ]);
      });

      test("SignetsAPI returns replaced days that already exists, should avoid duplicate.", () async {
        // Stub the cache to return 1 replaced day
        CacheServiceMock.stubGet(cacheManagerMock, CourseRepository.replacedDaysCacheKey, jsonEncode(replacedDays));

        // Stub the SignetsAPI to return the same replaced day as the cache
        SignetsAPIClientMock.stubGetReplacedDays(signetsApiMock, session.shortName, replacedDays);

        expect(manager.coursesActivities, isNull);
        final List<ReplacedDay>? results = await manager.getReplacedDays();

        expect(results, isInstanceOf<List<ReplacedDay>>());
        expect(results, replacedDays);
        expect(manager.replacedDays, replacedDays, reason: "The list of replaced days should not have duplicate");

        verifyInOrder([
          cacheManagerMock.get(CourseRepository.replacedDaysCacheKey),
          signetsApiMock.getReplacedDays(session: session.shortName),
          cacheManagerMock.update(CourseRepository.replacedDaysCacheKey, jsonEncode(replacedDays)),
        ]);
      });

      test("SignetsAPI returns replaced days that changed (for example replacement date changed).", () async {
        // Stub the cache to return 1 replaced day
        CacheServiceMock.stubGet(cacheManagerMock, CourseRepository.replacedDaysCacheKey, jsonEncode(replacedDays));

        // Load the sessions
        await manager.getSessions();
        expect(manager.sessions, isNotEmpty);
        clearInteractions(cacheManagerMock);
        clearInteractions(userRepositoryMock);
        clearInteractions(signetsApiMock);

        final changedReplacedDay = ReplacedDay(
          originalDate: DateTime(2025, 06, 20),
          replacementDate: DateTime(2025, 06, 27),
          description: "Fête du Canada",
        );

        // Stub the SignetsAPI to return the same replaced days as the cache
        SignetsAPIClientMock.stubGetReplacedDays(signetsApiMock, session.shortName, [changedReplacedDay]);

        expect(manager.coursesActivities, isNull);
        final List<ReplacedDay>? results = await manager.getReplacedDays();

        expect(results, isInstanceOf<List<ReplacedDay>>());
        expect(results, [changedReplacedDay]);
        expect(manager.replacedDays, [changedReplacedDay], reason: "The list of replaced days should be updated");

        verifyInOrder([
          cacheManagerMock.get(CourseRepository.replacedDaysCacheKey),
          signetsApiMock.getReplacedDays(session: session.shortName),
          cacheManagerMock.update(CourseRepository.replacedDaysCacheKey, jsonEncode([changedReplacedDay])),
        ]);
      });

      test("SignetsAPI raise a exception.", () async {
        // Stub the cache to return no replaced days
        CacheServiceMock.stubGet(cacheManagerMock, CourseRepository.replacedDaysCacheKey, jsonEncode([]));

        // Stub the SignetsAPI to throw an exception
        SignetsAPIClientMock.stubGetReplacedDaysException(
          signetsApiMock,
          session.shortName,
          exceptionToThrow: const ApiException(prefix: CourseRepository.tag),
        );

        expect(manager.replacedDays, isNull);
        expect(manager.getReplacedDays(), throwsA(isInstanceOf<ApiException>()));

        await untilCalled(networkingServiceMock.hasConnectivity());
        expect(manager.replacedDays, isEmpty, reason: "The list of replaced days should be empty");

        await untilCalled(analyticsServiceMock.logError(CourseRepository.tag, any, any, any));

        verifyInOrder([
          cacheManagerMock.get(CourseRepository.replacedDaysCacheKey),
          signetsApiMock.getReplacedDays(session: session.shortName),
          analyticsServiceMock.logError(CourseRepository.tag, any, any, any),
        ]);
      });

      test("Cache update fails, should still return the updated list of replaced days.", () async {
        // Stub the cache to return 1 replaced day
        CacheServiceMock.stubGet(cacheManagerMock, CourseRepository.replacedDaysCacheKey, jsonEncode(replacedDays));

        // Stub the SignetsAPI to return 1 replaced day
        SignetsAPIClientMock.stubGetReplacedDays(signetsApiMock, session.shortName, replacedDays);

        CacheServiceMock.stubUpdateException(cacheManagerMock, CourseRepository.replacedDaysCacheKey);

        expect(manager.replacedDays, isNull);
        final List<ReplacedDay>? results = await manager.getReplacedDays();

        expect(results, isInstanceOf<List<ReplacedDay>>());
        expect(results, replacedDays);
        expect(manager.replacedDays, replacedDays, reason: "The list of replaced days should not be empty");

        verifyInOrder([
          cacheManagerMock.get(CourseRepository.replacedDaysCacheKey),
          signetsApiMock.getReplacedDays(session: session.shortName),
        ]);
      });

      test("Should force fromCacheOnly mode when user has no connectivity", () async {
        // Stub the cache to return 1 replaced day
        CacheServiceMock.stubGet(cacheManagerMock, CourseRepository.replacedDaysCacheKey, jsonEncode(replacedDays));

        //Stub the networkingService to return no connectivity
        reset(networkingServiceMock);
        NetworkingServiceMock.stubHasConnectivity(networkingServiceMock, hasConnectivity: false);

        final replacedDaysCache = await manager.getReplacedDays();
        expect(replacedDaysCache, replacedDays);
      });
    });
  });
}
