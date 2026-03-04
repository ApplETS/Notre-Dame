// Dart imports:
import 'dart:async';

// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

// Project imports:
import 'package:notredame/data/services/signets-api/models/course.dart';
import 'package:notredame/data/services/signets-api/models/session.dart';
import 'package:notredame/domain/constants/preferences_flags.dart';
import 'package:notredame/locator.dart';
import 'package:notredame/ui/dashboard/view_model/dashboard_viewmodel.dart';
import '../../../data/mocks/repositories/course_repository_mock.dart';
import '../../../data/mocks/repositories/list_sessions_repository_mock.dart';
import '../../../data/mocks/repositories/settings_repository_mock.dart';
import '../../../data/mocks/services/in_app_review_service_mock.dart';
import '../../../data/mocks/services/launch_url_service_mock.dart';
import '../../../data/mocks/services/preferences_service_mock.dart';
import '../../../data/mocks/services/remote_config_service_mock.dart';
import '../../../helpers.dart';

void main() {
  late SettingsRepositoryMock settingsManagerMock;
  late CourseRepositoryMock courseRepositoryMock;
  late RemoteConfigServiceMock remoteConfigServiceMock;
  late PreferencesServiceMock preferencesServiceMock;
  late InAppReviewServiceMock inAppReviewServiceMock;
  late ListSessionsRepositoryMock listSessionsRepositoryMock;
  late LaunchUrlServiceMock launchUrlServiceMock;

  late DashboardViewModel viewModel;

  // Needed to support FlutterToast.
  TestWidgetsFlutterBinding.ensureInitialized();

  // Courses
  final Course courseSummer = Course(
    acronym: 'GEN101',
    group: '02',
    session: 'É2020',
    programCode: '999',
    grade: 'C+',
    numberOfCredits: 3,
    title: 'Cours générique',
  );

  final Course courseSummer2 = Course(
    acronym: 'GEN106',
    group: '02',
    session: 'É2020',
    programCode: '999',
    grade: 'C+',
    numberOfCredits: 3,
    title: 'Cours générique',
  );

  final courses = [courseSummer, courseSummer2];

  // Session
  final Session session = Session(
    shortName: "É2020",
    name: "Ete 2020",
    startDate: DateTime(2020).subtract(const Duration(days: 1)),
    endDate: DateTime(2020).add(const Duration(days: 1)),
    endDateCourses: DateTime(2022, 1, 10, 1, 1),
    startDateRegistration: DateTime(2017, 1, 9, 1, 1),
    deadlineRegistration: DateTime(2017, 1, 10, 1, 1),
    startDateCancellationWithRefund: DateTime(2017, 1, 10, 1, 1),
    deadlineCancellationWithRefund: DateTime(2017, 1, 11, 1, 1),
    deadlineCancellationWithRefundNewStudent: DateTime(2017, 1, 11, 1, 1),
    startDateCancellationWithoutRefundNewStudent: DateTime(2017, 1, 12, 1, 1),
    deadlineCancellationWithoutRefundNewStudent: DateTime(2017, 1, 12, 1, 1),
    deadlineCancellationASEQ: DateTime(2017, 1, 11, 1, 1),
  );

  group("DashboardViewModel - ", () {
    setUp(() async {
      // Setting up mocks
      courseRepositoryMock = setupCourseRepositoryMock();
      remoteConfigServiceMock = setupRemoteConfigServiceMock();
      settingsManagerMock = setupSettingsRepositoryMock();
      preferencesServiceMock = setupPreferencesServiceMock();
      setupAnalyticsServiceMock();
      setupBroadcastMessageRepositoryMock();
      listSessionsRepositoryMock = setupListSessionsRepositoryMock();
      launchUrlServiceMock = setupLaunchUrlServiceMock();

      // Setup stubs for ListSessionsRepository
      ListSessionsRepositoryMock.stubGetStream(listSessionsRepositoryMock, stream: Stream.empty());
      ListSessionsRepositoryMock.stubGetActiveSession(listSessionsRepositoryMock, session: null);

      viewModel = DashboardViewModel(intl: await setupAppIntl());
      CourseRepositoryMock.stubGetSessions(courseRepositoryMock, toReturn: [session]);
      CourseRepositoryMock.stubActiveSessions(courseRepositoryMock, toReturn: [session]);
      CourseRepositoryMock.stubCoursesActivities(courseRepositoryMock);
      CourseRepositoryMock.stubGetCoursesActivities(courseRepositoryMock, fromCacheOnly: true);
      CourseRepositoryMock.stubGetCoursesActivities(courseRepositoryMock);
      SettingsRepositoryMock.stubDateTimeNow(settingsManagerMock, toReturn: DateTime(2020));

      RemoteConfigServiceMock.stubGetBroadcastEnabled(remoteConfigServiceMock);
      RemoteConfigServiceMock.stubGetBroadcastEn(remoteConfigServiceMock, toReturn: "");

      inAppReviewServiceMock = setupInAppReviewServiceMock();
    });

    tearDown(() {
      locator.reset();
      viewModel.dispose();
    });

    group('futureToRunGrades -', () {
      test('first load from cache than call SignetsAPI to get the courses', () async {
        CourseRepositoryMock.stubSessions(courseRepositoryMock, toReturn: [session]);
        CourseRepositoryMock.stubGetSessions(courseRepositoryMock, toReturn: [session]);
        CourseRepositoryMock.stubActiveSessions(courseRepositoryMock, toReturn: [session]);
        CourseRepositoryMock.stubGetCourses(courseRepositoryMock, toReturn: courses, fromCacheOnly: true);

        CourseRepositoryMock.stubGetCourses(courseRepositoryMock, toReturn: courses);

        expect(await viewModel.futureToRunGrades(), courses);

        await untilCalled(courseRepositoryMock.sessions);
        await untilCalled(courseRepositoryMock.sessions);

        expect(viewModel.courses, courses);

        verifyInOrder([
          courseRepositoryMock.sessions,
          courseRepositoryMock.sessions,
          courseRepositoryMock.activeSessions,
          courseRepositoryMock.activeSessions,
          courseRepositoryMock.getCourses(fromCacheOnly: true),
          courseRepositoryMock.getCourses(),
        ]);

        verifyNoMoreInteractions(courseRepositoryMock);
      });

      test('Signets throw an error while trying to get courses', () async {
        setupFlutterToastMock();
        CourseRepositoryMock.stubSessions(courseRepositoryMock, toReturn: [session]);
        CourseRepositoryMock.stubGetSessions(courseRepositoryMock, toReturn: [session]);
        CourseRepositoryMock.stubActiveSessions(courseRepositoryMock, toReturn: [session]);

        CourseRepositoryMock.stubGetCourses(courseRepositoryMock, toReturn: courses, fromCacheOnly: true);

        CourseRepositoryMock.stubGetCoursesException(courseRepositoryMock);

        CourseRepositoryMock.stubGetCourses(courseRepositoryMock, toReturn: courses);

        expect(
          await viewModel.futureToRunGrades(),
          courses,
          reason: "Even if SignetsAPI call fails, should return the cache contents",
        );

        await untilCalled(courseRepositoryMock.sessions);
        await untilCalled(courseRepositoryMock.sessions);

        expect(viewModel.courses, courses);

        verifyInOrder([
          courseRepositoryMock.sessions,
          courseRepositoryMock.sessions,
          courseRepositoryMock.activeSessions,
          courseRepositoryMock.activeSessions,
          courseRepositoryMock.getCourses(fromCacheOnly: true),
          courseRepositoryMock.getCourses(),
        ]);

        verifyNoMoreInteractions(courseRepositoryMock);
      });

      test('There is no session active', () async {
        CourseRepositoryMock.stubSessions(courseRepositoryMock, toReturn: []);
        CourseRepositoryMock.stubActiveSessions(courseRepositoryMock, toReturn: []);

        expect(await viewModel.futureToRunGrades(), [], reason: "Should return empty if there is no session active.");

        await untilCalled(courseRepositoryMock.sessions);

        expect(viewModel.courses, []);

        verifyInOrder([
          courseRepositoryMock.sessions,
          courseRepositoryMock.sessions,
          courseRepositoryMock.getSessions(),
          courseRepositoryMock.activeSessions,
        ]);

        verifyNoMoreInteractions(courseRepositoryMock);
      });

      testWidgets('Course is not added when course is abandoned', (WidgetTester tester) async {
        final Course abandonedCourse = Course(
          acronym: 'GEN103',
          group: '02',
          session: 'É2020',
          programCode: '999',
          grade: 'XX',
          numberOfCredits: 3,
          title: 'Cours générique',
        );

        final List<Course> coursesWithAbandoned = [...courses, abandonedCourse];

        CourseRepositoryMock.stubSessions(courseRepositoryMock, toReturn: [session]);
        CourseRepositoryMock.stubGetSessions(courseRepositoryMock, toReturn: [session]);
        CourseRepositoryMock.stubActiveSessions(courseRepositoryMock, toReturn: [session]);
        CourseRepositoryMock.stubGetCourses(courseRepositoryMock, toReturn: coursesWithAbandoned, fromCacheOnly: true);
        CourseRepositoryMock.stubGetCourses(courseRepositoryMock, toReturn: coursesWithAbandoned);

        final List<Course> filteredCourses = await viewModel.futureToRunGrades();

        await untilCalled(courseRepositoryMock.sessions);

        // Check if the course abandoned is not included
        expect(filteredCourses, equals(courses));
        expect(filteredCourses.any((c) => c.acronym == 'GEN103'), isFalse);
      });
    });

    group("futureToRun - ", () {
      test("The initial cards are correctly loaded", () async {
        setupFlutterToastMock();
        CourseRepositoryMock.stubGetCoursesActivities(courseRepositoryMock, fromCacheOnly: true);
        CourseRepositoryMock.stubGetCourses(courseRepositoryMock, fromCacheOnly: true);
        CourseRepositoryMock.stubGetCoursesException(courseRepositoryMock, fromCacheOnly: true);
        CourseRepositoryMock.stubGetSessions(courseRepositoryMock);
        CourseRepositoryMock.stubActiveSessions(courseRepositoryMock, toReturn: [session]);
        CourseRepositoryMock.stubCoursesActivities(courseRepositoryMock);

        await viewModel.futureToRun();

        verify(listSessionsRepositoryMock.getSessions(forceUpdate: true)).called(1);
      });

      test("An exception is thrown during the preferenceService call", () async {
        setupFlutterToastMock();
        CourseRepositoryMock.stubGetCoursesActivities(courseRepositoryMock);
        CourseRepositoryMock.stubCoursesActivities(courseRepositoryMock);
        CourseRepositoryMock.stubGetCourses(courseRepositoryMock);

        PreferencesServiceMock.stubException(preferencesServiceMock, PreferencesFlag.aboutUsCard);
        PreferencesServiceMock.stubException(preferencesServiceMock, PreferencesFlag.scheduleCard);
        PreferencesServiceMock.stubException(preferencesServiceMock, PreferencesFlag.progressBarCard);

        await viewModel.futureToRun();
      });
    });


    group("In app review - ", () {
      test("returns true when todays date is after the day set in cache", () async {
        InAppReviewServiceMock.stubIsAvailable(inAppReviewServiceMock);
        InAppReviewServiceMock.stubRequestReview(inAppReviewServiceMock);

        final day = DateTime.now().add(const Duration(days: -1));
        PreferencesServiceMock.stubGetDateTime(preferencesServiceMock, PreferencesFlag.ratingTimer, toReturn: day);

        expect(await DashboardViewModel.launchInAppReview(), true);
        verify(preferencesServiceMock.setBool(PreferencesFlag.hasRatingBeenRequested, value: true)).called(1);
      });

      test(
        "returns false when todays date is after the day set in cache and when the function is called twice",
        () async {
          InAppReviewServiceMock.stubIsAvailable(inAppReviewServiceMock);
          InAppReviewServiceMock.stubRequestReview(inAppReviewServiceMock);
          final day = DateTime.now().add(const Duration(days: -1));
          PreferencesServiceMock.stubGetDateTime(preferencesServiceMock, PreferencesFlag.ratingTimer, toReturn: day);
          PreferencesServiceMock.stubGetBool(
            preferencesServiceMock,
            PreferencesFlag.hasRatingBeenRequested,
            toReturn: false,
          );

          expect(await DashboardViewModel.launchInAppReview(), true);

          PreferencesServiceMock.stubGetBool(preferencesServiceMock, PreferencesFlag.hasRatingBeenRequested);

          expect(await DashboardViewModel.launchInAppReview(), false);
        },
      );

      test(
        "returns false when today's date is after the day set in cache and when the function is called twice",
        () async {
          InAppReviewServiceMock.stubIsAvailable(inAppReviewServiceMock);
          InAppReviewServiceMock.stubRequestReview(inAppReviewServiceMock);
          final day = DateTime.now().add(const Duration(days: -1));
          PreferencesServiceMock.stubGetDateTime(preferencesServiceMock, PreferencesFlag.ratingTimer, toReturn: day);
          PreferencesServiceMock.stubGetBool(
            preferencesServiceMock,
            PreferencesFlag.hasRatingBeenRequested,
            toReturn: false,
          );

          expect(await DashboardViewModel.launchInAppReview(), true);

          PreferencesServiceMock.stubGetBool(preferencesServiceMock, PreferencesFlag.hasRatingBeenRequested);

          expect(await DashboardViewModel.launchInAppReview(), false);
        },
      );

      test("returns false when today's date is the before the day set in cache", () async {
        InAppReviewServiceMock.stubIsAvailable(inAppReviewServiceMock);
        InAppReviewServiceMock.stubRequestReview(inAppReviewServiceMock);
        final day = DateTime.now().add(const Duration(days: 2));
        PreferencesServiceMock.stubGetDateTime(preferencesServiceMock, PreferencesFlag.ratingTimer, toReturn: day);

        expect(await DashboardViewModel.launchInAppReview(), false);
      });

      test("returns false when the cache date hasn't been set (null)", () async {
        InAppReviewServiceMock.stubIsAvailable(inAppReviewServiceMock);
        InAppReviewServiceMock.stubRequestReview(inAppReviewServiceMock);
        PreferencesServiceMock.stubGetDateTime(preferencesServiceMock, PreferencesFlag.ratingTimer);

        expect(await DashboardViewModel.launchInAppReview(), false);
      });
    });

    group("launchBroadcastUrl - ", () {
      test("calls launchInBrowser with the provided url", () async {
        const url = "https://example.com";
        await DashboardViewModel.launchBroadcastUrl(url);
        verify(launchUrlServiceMock.launchInBrowser(url)).called(1);
      });
    });
  });
}
