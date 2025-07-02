// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

// Project imports:
import 'package:notredame/data/models/activity_code.dart';
import 'package:notredame/data/repositories/settings_repository.dart';
import 'package:notredame/data/services/signets-api/models/course.dart';
import 'package:notredame/data/services/signets-api/models/course_activity.dart';
import 'package:notredame/data/services/signets-api/models/session.dart';
import 'package:notredame/domain/constants/preferences_flags.dart';
import 'package:notredame/ui/dashboard/view_model/dashboard_viewmodel.dart';
import 'package:notredame/ui/dashboard/view_model/progress_bar_text_options.dart';
import '../../../data/mocks/repositories/course_repository_mock.dart';
import '../../../data/mocks/repositories/settings_repository_mock.dart';
import '../../../data/mocks/services/analytics_service_mock.dart';
import '../../../data/mocks/services/in_app_review_service_mock.dart';
import '../../../data/mocks/services/preferences_service_mock.dart';
import '../../../data/mocks/services/remote_config_service_mock.dart';
import '../../../helpers.dart';

void main() {
  late PreferencesServiceMock preferenceServiceMock;
  late SettingsRepositoryMock settingsManagerMock;
  late CourseRepositoryMock courseRepositoryMock;
  late RemoteConfigServiceMock remoteConfigServiceMock;
  late PreferencesServiceMock preferencesServiceMock;
  late InAppReviewServiceMock inAppReviewServiceMock;
  late AnalyticsServiceMock analyticsServiceMock;

  late DashboardViewModel viewModel;

  final gen101 = CourseActivity(
    courseGroup: "GEN101",
    courseName: "Generic course",
    activityName: "TD",
    activityDescription: "Activity description",
    activityLocation: "location",
    startDateTime: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 9),
    endDateTime: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 12),
  );
  final gen102 = CourseActivity(
    courseGroup: "GEN102",
    courseName: "Generic course",
    activityName: "TD",
    activityDescription: "Activity description",
    activityLocation: "location",
    startDateTime: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 13),
    endDateTime: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 16),
  );
  final gen103 = CourseActivity(
    courseGroup: "GEN103",
    courseName: "Generic course",
    activityName: "TD",
    activityDescription: "Activity description",
    activityLocation: "location",
    startDateTime: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 18),
    endDateTime: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 21),
  );
  final gen104LabA = CourseActivity(
    courseGroup: "GEN103",
    courseName: "Generic course",
    activityName: "TD",
    activityDescription: ActivityDescriptionName.labA,
    activityLocation: "location",
    startDateTime: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 18),
    endDateTime: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 21),
  );
  final gen104LabB = CourseActivity(
    courseGroup: "GEN103",
    courseName: "Generic course",
    activityName: "TD",
    activityDescription: ActivityDescriptionName.labB,
    activityLocation: "location",
    startDateTime: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 18),
    endDateTime: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 21),
  );
  final gen105 = CourseActivity(
    courseGroup: "GEN105",
    courseName: "Generic course",
    activityName: "TD",
    activityDescription: "Activity description",
    activityLocation: "location",
    startDateTime: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day + 1, 8),
    endDateTime: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day + 1, 12),
  );
  final gen106 = CourseActivity(
    courseGroup: "GEN106",
    courseName: "Generic course",
    activityName: "TD",
    activityDescription: "Activity description",
    activityLocation: "location",
    startDateTime: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day + 1, 13),
    endDateTime: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day + 1, 16),
  );
  final gen107 = CourseActivity(
    courseGroup: "GEN107",
    courseName: "Generic course",
    activityName: "TD",
    activityDescription: "Activity description",
    activityLocation: "location",
    startDateTime: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day + 2, 13),
    endDateTime: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day + 2, 16),
  );
  final List<CourseActivity> activities = [gen101, gen102, gen103, gen105, gen106, gen107];
  final List<CourseActivity> todayActivities = [gen101, gen102, gen103];
  final List<CourseActivity> tomorrowActivities = [gen105, gen106];

  final List<CourseActivity> activitiesWithLabs = [gen101, gen102, gen103, gen104LabA, gen104LabB];

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

  // Cards
  final Map<PreferencesFlag, int> dashboard = {
    PreferencesFlag.aboutUsCard: 0,
    PreferencesFlag.scheduleCard: 1,
    PreferencesFlag.progressBarCard: 2,
  };

  // Reorderered Cards
  final Map<PreferencesFlag, int> reorderedDashboard = {
    PreferencesFlag.aboutUsCard: 1,
    PreferencesFlag.scheduleCard: 2,
    PreferencesFlag.progressBarCard: 0,
  };

  // Reorderered Cards with hidden scheduleCard
  final Map<PreferencesFlag, int> hiddenCardDashboard = {
    PreferencesFlag.aboutUsCard: 0,
    PreferencesFlag.scheduleCard: -1,
    PreferencesFlag.progressBarCard: 1,
  };

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
      preferenceServiceMock = setupPreferencesServiceMock();
      analyticsServiceMock = setupAnalyticsServiceMock();
      preferencesServiceMock = setupPreferencesServiceMock();
      setupBroadcastMessageRepositoryMock();

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
      unregister<SettingsRepository>();
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

        SettingsRepositoryMock.stubGetDashboard(settingsManagerMock, toReturn: dashboard);

        await viewModel.futureToRun();
        expect(viewModel.cards, dashboard);
        expect(viewModel.cardsToDisplay, [
          PreferencesFlag.aboutUsCard,
          PreferencesFlag.scheduleCard,
          PreferencesFlag.progressBarCard,
        ]);

        verify(settingsManagerMock.getDashboard()).called(1);
        verify(settingsManagerMock.dateTimeNow).called(2);
        verifyNoMoreInteractions(settingsManagerMock);
      });

      test("build the list todays activities sorted by time", () async {
        CourseRepositoryMock.stubGetCoursesActivities(courseRepositoryMock);
        CourseRepositoryMock.stubCoursesActivities(courseRepositoryMock, toReturn: activities);
        CourseRepositoryMock.stubGetCourses(courseRepositoryMock, toReturn: courses);
        SettingsRepositoryMock.stubGetDashboard(settingsManagerMock, toReturn: dashboard);
        final now = DateTime.now();
        SettingsRepositoryMock.stubDateTimeNow(
          settingsManagerMock,
          toReturn: DateTime(now.year, now.month, now.day, 8),
        );

        await viewModel.futureToRun();

        await untilCalled(courseRepositoryMock.getCoursesActivities());

        expect(viewModel.scheduleEvents, todayActivities);

        verify(courseRepositoryMock.getCoursesActivities()).called(1);

        verify(courseRepositoryMock.coursesActivities).called(1);

        verify(settingsManagerMock.getDashboard()).called(1);
      });

      test("build the list todays activities (doesnt remove activity when pending completion)", () async {
        CourseRepositoryMock.stubGetCoursesActivities(courseRepositoryMock);
        CourseRepositoryMock.stubCoursesActivities(courseRepositoryMock, toReturn: activities);
        CourseRepositoryMock.stubGetCourses(courseRepositoryMock, toReturn: courses);
        SettingsRepositoryMock.stubGetDashboard(settingsManagerMock, toReturn: dashboard);
        final now = DateTime.now();
        SettingsRepositoryMock.stubDateTimeNow(
          settingsManagerMock,
          toReturn: DateTime(now.year, now.month, now.day, 11, 59),
        );

        await viewModel.futureToRun();

        await untilCalled(courseRepositoryMock.getCoursesActivities());

        expect(viewModel.scheduleEvents, todayActivities);

        verify(courseRepositoryMock.getCoursesActivities()).called(1);

        verify(courseRepositoryMock.coursesActivities).called(1);

        verify(settingsManagerMock.getDashboard()).called(1);
      });

      test("build the list todays activities (remove activity when finished)", () async {
        CourseRepositoryMock.stubGetCoursesActivities(courseRepositoryMock);
        CourseRepositoryMock.stubCoursesActivities(courseRepositoryMock, toReturn: activities);
        CourseRepositoryMock.stubGetCourses(courseRepositoryMock, toReturn: courses);
        SettingsRepositoryMock.stubGetDashboard(settingsManagerMock, toReturn: dashboard);
        final now = DateTime.now();
        SettingsRepositoryMock.stubDateTimeNow(
          settingsManagerMock,
          toReturn: DateTime(now.year, now.month, now.day, 12, 01),
        );

        await viewModel.futureToRun();

        await untilCalled(courseRepositoryMock.getCoursesActivities());

        final activitiesFinishedCourse = List<CourseActivity>.from(todayActivities)..remove(gen101);
        expect(viewModel.scheduleEvents, activitiesFinishedCourse);

        verify(courseRepositoryMock.getCoursesActivities()).called(1);

        verify(courseRepositoryMock.coursesActivities).called(1);

        verify(settingsManagerMock.getDashboard()).called(1);
      });

      test("build the list tomorrow activities sorted by time", () async {
        CourseRepositoryMock.stubGetCoursesActivities(courseRepositoryMock);
        CourseRepositoryMock.stubCoursesActivities(courseRepositoryMock, toReturn: activities);
        CourseRepositoryMock.stubGetCourses(courseRepositoryMock, toReturn: courses);
        SettingsRepositoryMock.stubGetDashboard(settingsManagerMock, toReturn: dashboard);
        final now = DateTime.now();
        SettingsRepositoryMock.stubDateTimeNow(
          settingsManagerMock,
          toReturn: DateTime(now.year, now.month, now.day, 21),
        );

        await viewModel.futureToRun();

        await untilCalled(courseRepositoryMock.getCoursesActivities());

        expect(viewModel.scheduleEvents, tomorrowActivities);

        verify(courseRepositoryMock.getCoursesActivities()).called(1);

        verify(courseRepositoryMock.coursesActivities).called(1);

        verify(settingsManagerMock.getDashboard()).called(1);
      });

      test("build the list todays activities with the right course activities (should not have labo A)", () async {
        CourseRepositoryMock.stubGetCoursesActivities(courseRepositoryMock);
        CourseRepositoryMock.stubCoursesActivities(courseRepositoryMock, toReturn: activitiesWithLabs);
        CourseRepositoryMock.stubGetCourses(courseRepositoryMock, toReturn: courses);
        SettingsRepositoryMock.stubGetDashboard(settingsManagerMock, toReturn: dashboard);
        final now = DateTime.now();
        SettingsRepositoryMock.stubDateTimeNow(
          settingsManagerMock,
          toReturn: DateTime(now.year, now.month, now.day, 8),
        );

        SettingsRepositoryMock.stubGetDynamicString(
          settingsManagerMock,
          PreferencesFlag.scheduleLaboratoryGroup,
          "GEN101",
        );

        SettingsRepositoryMock.stubGetDynamicString(
          settingsManagerMock,
          PreferencesFlag.scheduleLaboratoryGroup,
          "GEN102",
        );

        SettingsRepositoryMock.stubGetDynamicString(
          settingsManagerMock,
          PreferencesFlag.scheduleLaboratoryGroup,
          "GEN103",
          toReturn: ActivityCode.labGroupB,
        );

        await viewModel.futureToRun();

        await untilCalled(courseRepositoryMock.getCoursesActivities());

        expect(viewModel.scheduleEvents, [
          activitiesWithLabs[0],
          activitiesWithLabs[1],
          activitiesWithLabs[2],
          activitiesWithLabs[4],
        ]);
      });

      test("build the list todays activities with the right course activities (should not have labo B)", () async {
        CourseRepositoryMock.stubGetCoursesActivities(courseRepositoryMock);
        CourseRepositoryMock.stubCoursesActivities(courseRepositoryMock, toReturn: activitiesWithLabs);
        CourseRepositoryMock.stubGetCourses(courseRepositoryMock, toReturn: courses);
        SettingsRepositoryMock.stubGetDashboard(settingsManagerMock, toReturn: dashboard);
        final now = DateTime.now();
        SettingsRepositoryMock.stubDateTimeNow(
          settingsManagerMock,
          toReturn: DateTime(now.year, now.month, now.day, 8),
        );

        SettingsRepositoryMock.stubGetDynamicString(
          settingsManagerMock,
          PreferencesFlag.scheduleLaboratoryGroup,
          "GEN101",
        );

        SettingsRepositoryMock.stubGetDynamicString(
          settingsManagerMock,
          PreferencesFlag.scheduleLaboratoryGroup,
          "GEN102",
        );

        SettingsRepositoryMock.stubGetDynamicString(
          settingsManagerMock,
          PreferencesFlag.scheduleLaboratoryGroup,
          "GEN103",
          toReturn: ActivityCode.labGroupA,
        );

        await viewModel.futureToRun();

        await untilCalled(courseRepositoryMock.getCoursesActivities());

        expect(viewModel.scheduleEvents, [
          activitiesWithLabs[0],
          activitiesWithLabs[1],
          activitiesWithLabs[2],
          activitiesWithLabs[3],
        ]);
      });

      test("build the list todays activities with the right course activities (should have both labs)", () async {
        CourseRepositoryMock.stubGetCoursesActivities(courseRepositoryMock);
        CourseRepositoryMock.stubCoursesActivities(courseRepositoryMock, toReturn: activitiesWithLabs);
        CourseRepositoryMock.stubGetCourses(courseRepositoryMock, toReturn: courses);
        SettingsRepositoryMock.stubGetDashboard(settingsManagerMock, toReturn: dashboard);
        final now = DateTime.now();
        SettingsRepositoryMock.stubDateTimeNow(
          settingsManagerMock,
          toReturn: DateTime(now.year, now.month, now.day, 8),
        );

        SettingsRepositoryMock.stubGetDynamicString(
          settingsManagerMock,
          PreferencesFlag.scheduleLaboratoryGroup,
          "GEN101",
        );

        SettingsRepositoryMock.stubGetDynamicString(
          settingsManagerMock,
          PreferencesFlag.scheduleLaboratoryGroup,
          "GEN102",
        );

        SettingsRepositoryMock.stubGetDynamicString(
          settingsManagerMock,
          PreferencesFlag.scheduleLaboratoryGroup,
          "GEN103",
        );

        await viewModel.futureToRun();

        await untilCalled(courseRepositoryMock.getCoursesActivities());

        expect(viewModel.scheduleEvents, activitiesWithLabs);
      });

      test("An exception is thrown during the preferenceService call", () async {
        setupFlutterToastMock();
        CourseRepositoryMock.stubGetCoursesActivities(courseRepositoryMock);
        CourseRepositoryMock.stubCoursesActivities(courseRepositoryMock);
        CourseRepositoryMock.stubGetCourses(courseRepositoryMock);

        PreferencesServiceMock.stubException(preferenceServiceMock, PreferencesFlag.aboutUsCard);
        PreferencesServiceMock.stubException(preferenceServiceMock, PreferencesFlag.scheduleCard);
        PreferencesServiceMock.stubException(preferenceServiceMock, PreferencesFlag.progressBarCard);

        await viewModel.futureToRun();
        expect(viewModel.cardsToDisplay, []);

        verify(settingsManagerMock.getDashboard()).called(1);
      });
    });

    group("futureToRunSessionProgressBar - ", () {
      test("There is an active session", () async {
        CourseRepositoryMock.stubActiveSessions(courseRepositoryMock, toReturn: [session]);
        SettingsRepositoryMock.stubGetDashboard(settingsManagerMock, toReturn: dashboard);
        SettingsRepositoryMock.stubDateTimeNow(settingsManagerMock, toReturn: DateTime(2020));
        await viewModel.futureToRunSessionProgressBar();
        expect(viewModel.progress, 0.5);
        expect(viewModel.sessionDays, [1, 2]);
      });

      test("Invalid date (Superior limit)", () async {
        CourseRepositoryMock.stubActiveSessions(courseRepositoryMock, toReturn: [session]);
        SettingsRepositoryMock.stubGetDashboard(settingsManagerMock, toReturn: dashboard);
        SettingsRepositoryMock.stubDateTimeNow(settingsManagerMock, toReturn: DateTime(2020, 1, 20));
        await viewModel.futureToRunSessionProgressBar();
        expect(viewModel.progress, 1);
        expect(viewModel.sessionDays, [2, 2]);
      });

      test("Invalid date (Lower limit)", () async {
        CourseRepositoryMock.stubActiveSessions(courseRepositoryMock, toReturn: [session]);
        SettingsRepositoryMock.stubGetDashboard(settingsManagerMock, toReturn: dashboard);
        SettingsRepositoryMock.stubDateTimeNow(settingsManagerMock, toReturn: DateTime(2019, 12, 31));
        await viewModel.futureToRunSessionProgressBar();
        expect(viewModel.progress, 0);
        expect(viewModel.sessionDays, [0, 2]);
      });

      test("Active session is null", () async {
        CourseRepositoryMock.stubActiveSessions(courseRepositoryMock);

        await viewModel.futureToRunSessionProgressBar();
        expect(viewModel.progress, -1.0);
        expect(viewModel.sessionDays, [0, 0]);
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
  });
}
