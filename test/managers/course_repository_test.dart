// FLUTTER / DART / THIRD-PARTIES
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

// SERVICES / MANAGER
import 'package:notredame/core/services/analytics_service.dart';
import 'package:notredame/core/services/signets_api.dart';
import 'package:notredame/core/managers/user_repository.dart';
import 'package:notredame/core/managers/cache_manager.dart';
import 'package:notredame/core/managers/course_repository.dart';

// MODELS
import 'package:notredame/core/models/session.dart';
import 'package:notredame/core/models/course_activity.dart';
import 'package:notredame/core/models/mon_ets_user.dart';

// UTILS
import 'package:notredame/core/utils/api_exception.dart';

import '../helpers.dart';
import '../mock/managers/cache_manager_mock.dart';
import '../mock/managers/user_repository_mock.dart';
import '../mock/services/signets_api_mock.dart';

// MOCKS

void main() {
  AnalyticsService analyticsService;
  SignetsApi signetsApi;
  UserRepository userRepository;
  CacheManager cacheManager;

  CourseRepository manager;

  group("CourseRepository - ", () {
    setUp(() {
      // Setup needed services and managers
      analyticsService = setupAnalyticsServiceMock();
      signetsApi = setupSignetsApiMock();
      userRepository = setupUserRepositoryMock();
      cacheManager = setupCacheManagerMock();
      setupLogger();

      manager = CourseRepository();
    });

    tearDown(() {
      clearInteractions(analyticsService);
      unregister<AnalyticsService>();
      clearInteractions(signetsApi);
      unregister<SignetsApi>();
      clearInteractions(userRepository);
      unregister<UserRepository>();
      clearInteractions(cacheManager);
      unregister<CacheManager>();
    });

    group("getCoursesActivities - ", () {
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
          deadlineCancellationASEQ: DateTime(2020));

      final CourseActivity activity = CourseActivity(
          courseGroup: "GEN101",
          courseName: "Generic course",
          activityName: "TD",
          activityDescription: "Activity description",
          activityLocation: "location",
          startDateTime: DateTime(2020, 1, 1, 18),
          endDateTime: DateTime(2020, 1, 1, 21));

      final List<CourseActivity> activities = [activity];

      const String username = "username";

      setUp(() {
        // Stub a user
        UserRepositoryMock.stubMonETSUser(userRepository as UserRepositoryMock,
            MonETSUser(domain: null, typeUsagerId: null, username: username));
        UserRepositoryMock.stubGetPassword(
            userRepository as UserRepositoryMock, "password");

        // Stub some sessions
        CacheManagerMock.stubGet(cacheManager as CacheManagerMock,
            CourseRepository.sessionsCacheKey, jsonEncode([]));
        SignetsApiMock.stubGetSessions(
            signetsApi as SignetsApiMock, username, [session]);
      });

      test("Activities are loaded from cache.", () async {
        // Stub the cache to return 1 activity
        CacheManagerMock.stubGet(cacheManager as CacheManagerMock,
            CourseRepository.coursesActivitiesCacheKey, jsonEncode(activities));

        // Stub the SignetsAPI to return 0 activities
        SignetsApiMock.stubGetCoursesActivities(
            signetsApi as SignetsApiMock, session.shortName, []);

        expect(manager.coursesActivities, isNull);
        final List<CourseActivity> results =
            await manager.getCoursesActivities();

        expect(results, isInstanceOf<List<CourseActivity>>());
        expect(results, activities);
        expect(manager.coursesActivities, activities,
            reason: "The list of activities should not be empty");

        verifyInOrder([
          cacheManager.get(CourseRepository.coursesActivitiesCacheKey),
          userRepository.getPassword(),
          userRepository.monETSUser,
          signetsApi.getCoursesActivities(
              username: username,
              password: anyNamed("password"),
              session: session.shortName),
          cacheManager.update(CourseRepository.coursesActivitiesCacheKey, any)
        ]);
      });

      test(
          "Trying to recover activities from cache but an exception is raised.",
          () async {
        // Stub the cache to throw an exception
        CacheManagerMock.stubGetException(cacheManager as CacheManagerMock,
            CourseRepository.coursesActivitiesCacheKey);

        // Stub the SignetsAPI to return 0 activities
        SignetsApiMock.stubGetCoursesActivities(
            signetsApi as SignetsApiMock, session.shortName, []);

        expect(manager.coursesActivities, isNull);
        final List<CourseActivity> results =
            await manager.getCoursesActivities();

        expect(results, isInstanceOf<List<CourseActivity>>());
        expect(results, isEmpty);
        expect(manager.coursesActivities, isEmpty,
            reason: "The list of activities should be empty");

        verifyInOrder([
          cacheManager.get(CourseRepository.coursesActivitiesCacheKey),
          userRepository.getPassword(),
          userRepository.monETSUser,
          signetsApi.getCoursesActivities(
              username: username,
              password: anyNamed("password"),
              session: session.shortName),
          cacheManager.update(CourseRepository.coursesActivitiesCacheKey, any)
        ]);

        verify(signetsApi.getSessions(
                username: username, password: anyNamed("password")))
            .called(1);
      });

      test("Doesn't retrieve sessions if they are already loaded", () async {
        // Stub the cache to return 1 activity
        CacheManagerMock.stubGet(cacheManager as CacheManagerMock,
            CourseRepository.coursesActivitiesCacheKey, jsonEncode(activities));

        // Stub the SignetsAPI to return 0 activities
        SignetsApiMock.stubGetCoursesActivities(
            signetsApi as SignetsApiMock, session.shortName, []);

        // Load the sessions
        await manager.getSessions();
        expect(manager.sessions, isNotEmpty);
        clearInteractions(cacheManager);
        clearInteractions(userRepository);
        clearInteractions(signetsApi);

        expect(manager.coursesActivities, isNull);
        final List<CourseActivity> results =
            await manager.getCoursesActivities();

        expect(results, isInstanceOf<List<CourseActivity>>());
        expect(results, activities);
        expect(manager.coursesActivities, activities,
            reason: "The list of activities should not be empty");

        verifyInOrder([
          cacheManager.get(CourseRepository.coursesActivitiesCacheKey),
          userRepository.getPassword(),
          userRepository.monETSUser,
          signetsApi.getCoursesActivities(
              username: username,
              password: anyNamed("password"),
              session: session.shortName),
          cacheManager.update(CourseRepository.coursesActivitiesCacheKey, any)
        ]);

        verifyNoMoreInteractions(signetsApi);
      });

      test("getSessions fails", () async {
        // Stub SignetsApi to throw an exception
        reset(signetsApi);
        SignetsApiMock.stubGetSessionsException(
            signetsApi as SignetsApiMock, username);

        // Stub the cache to return 1 activity
        CacheManagerMock.stubGet(cacheManager as CacheManagerMock,
            CourseRepository.coursesActivitiesCacheKey, jsonEncode(activities));

        // Stub the SignetsAPI to return 0 activities
        SignetsApiMock.stubGetCoursesActivities(
            signetsApi as SignetsApiMock, session.shortName, []);

        expect(manager.coursesActivities, isNull);
        expect(manager.getCoursesActivities(),
            throwsA(isInstanceOf<ApiException>()));
        expect(manager.coursesActivities, isEmpty,
            reason: "The list of activities should be empty");

        await untilCalled(analyticsService.logError(CourseRepository.tag, any));

        verifyInOrder([
          cacheManager.get(CourseRepository.coursesActivitiesCacheKey),
          userRepository.getPassword(),
          userRepository.monETSUser,
          analyticsService.logError(CourseRepository.tag, any)
        ]);
      });

      test("User authentication fails.", () async {
        // Stub the cache to return 0 activities
        CacheManagerMock.stubGet(cacheManager as CacheManagerMock,
            CourseRepository.coursesActivitiesCacheKey, jsonEncode([]));

        // Load the sessions
        await manager.getSessions();
        expect(manager.sessions, isNotEmpty);
        clearInteractions(signetsApi);

        // Stub an authentication error
        reset(userRepository);
        UserRepositoryMock.stubGetPasswordException(
            userRepository as UserRepositoryMock);

        expect(manager.getCoursesActivities(),
            throwsA(isInstanceOf<ApiException>()));
        expect(manager.coursesActivities, isEmpty,
            reason:
                "There isn't any activities saved in the cache so the list should be empty");

        await untilCalled(analyticsService.logError(CourseRepository.tag, any));

        verifyInOrder([
          cacheManager.get(CourseRepository.coursesActivitiesCacheKey),
          userRepository.getPassword(),
          analyticsService.logError(CourseRepository.tag, any)
        ]);

        verifyNoMoreInteractions(signetsApi);
        verifyNoMoreInteractions(userRepository);
      });

      test(
          "SignetsAPI returns new activities, the old ones should be maintained and the cache updated.",
          () async {
        // Stub the cache to return 1 activity
        CacheManagerMock.stubGet(cacheManager as CacheManagerMock,
            CourseRepository.coursesActivitiesCacheKey, jsonEncode(activities));

        final CourseActivity courseActivity = CourseActivity(
            courseGroup: "GEN102",
            courseName: "Generic course",
            activityName: "Class",
            activityDescription: "Activity description",
            activityLocation: "location",
            startDateTime: DateTime(2020, 1, 2, 18),
            endDateTime: DateTime(2020, 1, 2, 21));

        // Stub the SignetsAPI to return 1 activity
        SignetsApiMock.stubGetCoursesActivities(signetsApi as SignetsApiMock,
            session.shortName, [activity, courseActivity]);

        expect(manager.coursesActivities, isNull);
        final List<CourseActivity> results =
            await manager.getCoursesActivities();

        expect(results, isInstanceOf<List<CourseActivity>>());
        expect(results, [activity, courseActivity]);
        expect(manager.coursesActivities, [activity, courseActivity],
            reason: "The list of activities should not be empty");

        verifyInOrder([
          cacheManager.get(CourseRepository.coursesActivitiesCacheKey),
          userRepository.getPassword(),
          userRepository.monETSUser,
          signetsApi.getCoursesActivities(
              username: username,
              password: anyNamed("password"),
              session: session.shortName),
          cacheManager.update(CourseRepository.coursesActivitiesCacheKey,
              jsonEncode([activity, courseActivity]))
        ]);
      });

      test(
          "SignetsAPI returns activities that already exists, should avoid duplicata.",
          () async {
        // Stub the cache to return 1 activity
        CacheManagerMock.stubGet(cacheManager as CacheManagerMock,
            CourseRepository.coursesActivitiesCacheKey, jsonEncode(activities));

        // Stub the SignetsAPI to return the same activity as the cache
        SignetsApiMock.stubGetCoursesActivities(
            signetsApi as SignetsApiMock, session.shortName, activities);

        expect(manager.coursesActivities, isNull);
        final List<CourseActivity> results =
            await manager.getCoursesActivities();

        expect(results, isInstanceOf<List<CourseActivity>>());
        expect(results, activities);
        expect(manager.coursesActivities, activities,
            reason: "The list of activities should not have duplicata");

        verifyInOrder([
          cacheManager.get(CourseRepository.coursesActivitiesCacheKey),
          userRepository.getPassword(),
          userRepository.monETSUser,
          signetsApi.getCoursesActivities(
              username: username,
              password: anyNamed("password"),
              session: session.shortName),
          cacheManager.update(CourseRepository.coursesActivitiesCacheKey,
              jsonEncode(activities))
        ]);
      });

      test("SignetsAPI raise a exception.", () async {
        // Stub the cache to return no activity
        CacheManagerMock.stubGet(cacheManager as CacheManagerMock,
            CourseRepository.coursesActivitiesCacheKey, jsonEncode([]));

        // Stub the SignetsAPI to throw an exception
        SignetsApiMock.stubGetCoursesActivitiesException(
            signetsApi as SignetsApiMock, session.shortName);

        expect(manager.coursesActivities, isNull);
        expect(manager.getCoursesActivities(),
            throwsA(isInstanceOf<ApiException>()));
        expect(manager.coursesActivities, isEmpty,
            reason: "The list of activities should be empty");

        await untilCalled(analyticsService.logError(CourseRepository.tag, any));

        verifyInOrder([
          cacheManager.get(CourseRepository.coursesActivitiesCacheKey),
          userRepository.getPassword(),
          userRepository.monETSUser,
          signetsApi.getCoursesActivities(
              username: username,
              password: anyNamed("password"),
              session: session.shortName),
          analyticsService.logError(CourseRepository.tag, any)
        ]);
      });

      test(
          "Cache update fails, should still return the updated list of activities.",
          () async {
        // Stub the cache to return 1 activity
        CacheManagerMock.stubGet(cacheManager as CacheManagerMock,
            CourseRepository.coursesActivitiesCacheKey, jsonEncode(activities));

        // Stub the SignetsAPI to return 0 activities
        SignetsApiMock.stubGetCoursesActivities(
            signetsApi as SignetsApiMock, session.shortName, []);

        CacheManagerMock.stubUpdateException(cacheManager as CacheManagerMock,
            CourseRepository.coursesActivitiesCacheKey);

        expect(manager.coursesActivities, isNull);
        final List<CourseActivity> results =
            await manager.getCoursesActivities();

        expect(results, isInstanceOf<List<CourseActivity>>());
        expect(results, activities);
        expect(manager.coursesActivities, activities,
            reason: "The list of activities should not be empty");

        verifyInOrder([
          cacheManager.get(CourseRepository.coursesActivitiesCacheKey),
          userRepository.getPassword(),
          userRepository.monETSUser,
          signetsApi.getCoursesActivities(
              username: username,
              password: anyNamed("password"),
              session: session.shortName)
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
            deadlineCancellationASEQ: DateTime(2018, 1, 31))
      ];

      const String username = "username";
      const String password = "password";

      final MonETSUser user =
          MonETSUser(domain: "ENS", typeUsagerId: 1, username: username);

      setUp(() {
        // Stub to simulate presence of session cache
        CacheManagerMock.stubGet(cacheManager as CacheManagerMock,
            CourseRepository.sessionsCacheKey, jsonEncode(sessions));

        // Stub SignetsApi answer to test only the cache retrieving
        SignetsApiMock.stubGetSessions(
            signetsApi as SignetsApiMock, username, []);
        UserRepositoryMock.stubMonETSUser(
            userRepository as UserRepositoryMock, user);
        UserRepositoryMock.stubGetPassword(
            userRepository as UserRepositoryMock, password);
      });

      test("Sessions are loaded from cache", () async {
        expect(manager.sessions, isNull);
        final results = await manager.getSessions();

        expect(results, isInstanceOf<List<Session>>());
        expect(results, sessions);
        expect(manager.sessions, sessions,
            reason: 'The sessions list should now be loaded.');

        verifyInOrder([
          cacheManager.get(CourseRepository.sessionsCacheKey),
          userRepository.getPassword(),
          userRepository.monETSUser,
          signetsApi.getSessions(username: username, password: password),
          cacheManager.update(
              CourseRepository.sessionsCacheKey, jsonEncode(sessions))
        ]);
      });

      test("Trying to load sessions from cache but cache doesn't exist",
          () async {
        // Stub to simulate an exception when trying to get the sessions from the cache
        reset(cacheManager as CacheManagerMock);
        CacheManagerMock.stubGetException(cacheManager as CacheManagerMock,
            CourseRepository.sessionsCacheKey);

        expect(manager.sessions, isNull);
        final results = await manager.getSessions();

        expect(results, isInstanceOf<List<Session>>());
        expect(results, []);
        expect(manager.sessions, []);

        verifyInOrder([
          cacheManager.get(CourseRepository.sessionsCacheKey),
          userRepository.getPassword(),
          userRepository.monETSUser,
          signetsApi.getSessions(username: username, password: password),
          cacheManager.update(CourseRepository.sessionsCacheKey, jsonEncode([]))
        ]);
      });

      test("SignetsAPI return another session", () async {
        // Stub to simulate presence of session cache
        reset(cacheManager as CacheManagerMock);
        CacheManagerMock.stubGet(cacheManager as CacheManagerMock,
            CourseRepository.sessionsCacheKey, jsonEncode([]));

        // Stub SignetsApi answer to test only the cache retrieving
        reset(signetsApi as SignetsApiMock);
        SignetsApiMock.stubGetSessions(
            signetsApi as SignetsApiMock, username, sessions);

        expect(manager.sessions, isNull);
        final results = await manager.getSessions();

        expect(results, isInstanceOf<List<Session>>());
        expect(results, sessions);
        expect(manager.sessions, sessions,
            reason: 'The sessions list should now be loaded.');

        verifyInOrder([
          cacheManager.get(CourseRepository.sessionsCacheKey),
          userRepository.getPassword(),
          userRepository.monETSUser,
          signetsApi.getSessions(username: username, password: password),
          cacheManager.update(
              CourseRepository.sessionsCacheKey, jsonEncode(sessions))
        ]);
      });

      test("SignetsAPI return a session that already exists", () async {
        // Stub SignetsApi answer to test only the cache retrieving
        reset(signetsApi as SignetsApiMock);
        SignetsApiMock.stubGetSessions(
            signetsApi as SignetsApiMock, username, sessions);

        expect(manager.sessions, isNull);
        final results = await manager.getSessions();

        expect(results, isInstanceOf<List<Session>>());
        expect(results, sessions);
        expect(manager.sessions, sessions,
            reason: 'The sessions list should not have any duplicata..');

        verifyInOrder([
          cacheManager.get(CourseRepository.sessionsCacheKey),
          userRepository.getPassword(),
          userRepository.monETSUser,
          signetsApi.getSessions(username: username, password: password),
          cacheManager.update(
              CourseRepository.sessionsCacheKey, jsonEncode(sessions))
        ]);
      });

      test("SignetsAPI return an exception", () async {
        // Stub to simulate presence of session cache
        reset(cacheManager as CacheManagerMock);
        CacheManagerMock.stubGet(cacheManager as CacheManagerMock,
            CourseRepository.sessionsCacheKey, jsonEncode([]));

        // Stub SignetsApi answer to test only the cache retrieving
        SignetsApiMock.stubGetSessionsException(
            signetsApi as SignetsApiMock, username);

        expect(manager.sessions, isNull);
        expect(manager.getSessions(), throwsA(isInstanceOf<ApiException>()));
        expect(manager.sessions, [],
            reason: 'The session list should be empty');

        await untilCalled(analyticsService.logError(CourseRepository.tag, any));

        verifyInOrder([
          cacheManager.get(CourseRepository.sessionsCacheKey),
          userRepository.getPassword(),
          userRepository.monETSUser,
          signetsApi.getSessions(username: username, password: password),
          analyticsService.logError(CourseRepository.tag, any)
        ]);

        verifyNever(
            cacheManager.update(CourseRepository.sessionsCacheKey, any));
      });

      test("Cache update fail", () async {
        // Stub to simulate presence of session cache
        reset(cacheManager as CacheManagerMock);
        CacheManagerMock.stubGet(cacheManager as CacheManagerMock,
            CourseRepository.sessionsCacheKey, jsonEncode([]));

        // Stub to simulate exception when updating cache
        CacheManagerMock.stubUpdateException(cacheManager as CacheManagerMock,
            CourseRepository.sessionsCacheKey);

        // Stub SignetsApi answer to test only the cache retrieving
        SignetsApiMock.stubGetSessions(
            signetsApi as SignetsApiMock, username, sessions);

        expect(manager.sessions, isNull);
        final results = await manager.getSessions();

        expect(results, isInstanceOf<List<Session>>());
        expect(results, sessions);
        expect(manager.sessions, sessions,
            reason:
                'The sessions list should now be loaded even if the caching fails.');

        verifyInOrder([
          cacheManager.get(CourseRepository.sessionsCacheKey),
          userRepository.getPassword(),
          userRepository.monETSUser,
          signetsApi.getSessions(username: username, password: password)
        ]);
      });

      test("UserRepository return an exception", () async {
        // Stub to simulate presence of session cache
        reset(cacheManager as CacheManagerMock);
        CacheManagerMock.stubGet(cacheManager as CacheManagerMock,
            CourseRepository.sessionsCacheKey, jsonEncode([]));

        // Stub UserRepository to throw a exception
        UserRepositoryMock.stubGetPasswordException(
            userRepository as UserRepositoryMock);

        expect(manager.sessions, isNull);
        expect(manager.getSessions(), throwsA(isInstanceOf<ApiException>()));
        expect(manager.sessions, [],
            reason: 'The session list should be empty');

        await untilCalled(analyticsService.logError(CourseRepository.tag, any));

        verifyInOrder([
          cacheManager.get(CourseRepository.sessionsCacheKey),
          userRepository.getPassword(),
          analyticsService.logError(CourseRepository.tag, any)
        ]);

        verifyNever(signetsApi.getSessions(
            username: anyNamed("username"), password: anyNamed("password")));
        verifyNever(
            cacheManager.update(CourseRepository.sessionsCacheKey, any));
      });
    });

    group("activeSessions - ", () {
      const String username = "username";
      const String password = "password";

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
            deadlineCancellationASEQ: DateTime(2018, 1, 31))
      ];

      test("get the session active", () async {
        final Session active = Session(
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
            deadlineCancellationASEQ: DateTime(2020));

        sessions.add(active);

        SignetsApiMock.stubGetSessions(
            signetsApi as SignetsApiMock, username, sessions);
        UserRepositoryMock.stubMonETSUser(userRepository as UserRepositoryMock,
            MonETSUser(domain: null, typeUsagerId: null, username: username));
        UserRepositoryMock.stubGetPassword(
            userRepository as UserRepositoryMock, password);
        CacheManagerMock.stubGet(cacheManager as CacheManagerMock,
            CourseRepository.sessionsCacheKey, jsonEncode(sessions));

        await manager.getSessions();

        expect(manager.activeSessions, [active]);
      });
    });
  });
}
