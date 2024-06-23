// Package imports:
import 'package:ets_api_clients/models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

// Project imports:
import 'package:notredame/constants/preferences_flags.dart';
import 'package:notredame/features/dashboard/progress_bar_text_options.dart';
import 'package:notredame/features/more/settings/settings_manager.dart';
import 'package:notredame/features/dashboard/dashboard_viewmodel.dart';
import '../helpers.dart';
import '../mock/managers/course_repository_mock.dart';
import '../mock/managers/settings_manager_mock.dart';
import '../mock/services/analytics_service_mock.dart';
import '../mock/services/in_app_review_service_mock.dart';
import '../mock/services/preferences_service_mock.dart';
import '../mock/services/remote_config_service_mock.dart';

void main() {
  late PreferencesServiceMock preferenceServiceMock;
  late SettingsManagerMock settingsManagerMock;
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
      startDateTime: DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day, 9),
      endDateTime: DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day, 12));
  final gen102 = CourseActivity(
      courseGroup: "GEN102",
      courseName: "Generic course",
      activityName: "TD",
      activityDescription: "Activity description",
      activityLocation: "location",
      startDateTime: DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day, 13),
      endDateTime: DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day, 16));
  final gen103 = CourseActivity(
      courseGroup: "GEN103",
      courseName: "Generic course",
      activityName: "TD",
      activityDescription: "Activity description",
      activityLocation: "location",
      startDateTime: DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day, 18),
      endDateTime: DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day, 21));
  final gen104LabA = CourseActivity(
      courseGroup: "GEN103",
      courseName: "Generic course",
      activityName: "TD",
      activityDescription: ActivityDescriptionName.labA,
      activityLocation: "location",
      startDateTime: DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day, 18),
      endDateTime: DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day, 21));
  final gen104LabB = CourseActivity(
      courseGroup: "GEN103",
      courseName: "Generic course",
      activityName: "TD",
      activityDescription: ActivityDescriptionName.labB,
      activityLocation: "location",
      startDateTime: DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day, 18),
      endDateTime: DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day, 21));
  final gen105 = CourseActivity(
      courseGroup: "GEN105",
      courseName: "Generic course",
      activityName: "TD",
      activityDescription: "Activity description",
      activityLocation: "location",
      startDateTime: DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day + 1, 8),
      endDateTime: DateTime(DateTime.now().year, DateTime.now().month,
          DateTime.now().day + 1, 12));
  final gen106 = CourseActivity(
      courseGroup: "GEN106",
      courseName: "Generic course",
      activityName: "TD",
      activityDescription: "Activity description",
      activityLocation: "location",
      startDateTime: DateTime(DateTime.now().year, DateTime.now().month,
          DateTime.now().day + 1, 13),
      endDateTime: DateTime(DateTime.now().year, DateTime.now().month,
          DateTime.now().day + 1, 16));
  final gen107 = CourseActivity(
      courseGroup: "GEN107",
      courseName: "Generic course",
      activityName: "TD",
      activityDescription: "Activity description",
      activityLocation: "location",
      startDateTime: DateTime(DateTime.now().year, DateTime.now().month,
          DateTime.now().day + 2, 13),
      endDateTime: DateTime(DateTime.now().year, DateTime.now().month,
          DateTime.now().day + 2, 16));
  final List<CourseActivity> activities = [
    gen101,
    gen102,
    gen103,
    gen105,
    gen106,
    gen107
  ];
  final List<CourseActivity> todayActivities = [gen101, gen102, gen103];
  final List<CourseActivity> tomorrowActivities = [gen105, gen106];

  final List<CourseActivity> activitiesWithLabs = [
    gen101,
    gen102,
    gen103,
    gen104LabA,
    gen104LabB
  ];

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
      title: 'Cours générique');

  final Course courseSummer2 = Course(
      acronym: 'GEN106',
      group: '02',
      session: 'É2020',
      programCode: '999',
      grade: 'C+',
      numberOfCredits: 3,
      title: 'Cours générique');

  final courses = [courseSummer, courseSummer2];

  // Cards
  final Map<PreferencesFlag, int> dashboard = {
    PreferencesFlag.broadcastCard: 0,
    PreferencesFlag.aboutUsCard: 1,
    PreferencesFlag.scheduleCard: 2,
    PreferencesFlag.progressBarCard: 3,
  };

  // Reorderered Cards
  final Map<PreferencesFlag, int> reorderedDashboard = {
    PreferencesFlag.broadcastCard: 1,
    PreferencesFlag.aboutUsCard: 2,
    PreferencesFlag.scheduleCard: 3,
    PreferencesFlag.progressBarCard: 0,
  };

  // Reorderered Cards with hidden scheduleCard
  final Map<PreferencesFlag, int> hiddenCardDashboard = {
    PreferencesFlag.broadcastCard: 0,
    PreferencesFlag.aboutUsCard: 1,
    PreferencesFlag.scheduleCard: -1,
    PreferencesFlag.progressBarCard: 2,
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
      deadlineCancellationASEQ: DateTime(2017, 1, 11, 1, 1));

  group("DashboardViewModel - ", () {
    setUp(() async {
      // Setting up mocks
      courseRepositoryMock = setupCourseRepositoryMock();
      remoteConfigServiceMock = setupRemoteConfigServiceMock();
      settingsManagerMock = setupSettingsManagerMock();
      preferenceServiceMock = setupPreferencesServiceMock();
      analyticsServiceMock = setupAnalyticsServiceMock();
      setupAppWidgetServiceMock();
      preferencesServiceMock = setupPreferencesServiceMock();

      viewModel = DashboardViewModel(intl: await setupAppIntl());
      CourseRepositoryMock.stubGetSessions(courseRepositoryMock,
          toReturn: [session]);
      CourseRepositoryMock.stubActiveSessions(courseRepositoryMock,
          toReturn: [session]);
      CourseRepositoryMock.stubCoursesActivities(courseRepositoryMock);
      CourseRepositoryMock.stubGetCoursesActivities(courseRepositoryMock,
          fromCacheOnly: true);
      CourseRepositoryMock.stubGetCoursesActivities(courseRepositoryMock);
      SettingsManagerMock.stubDateTimeNow(settingsManagerMock,
          toReturn: DateTime(2020));

      RemoteConfigServiceMock.stubGetBroadcastEnabled(remoteConfigServiceMock);
      RemoteConfigServiceMock.stubGetBroadcastEn(remoteConfigServiceMock,
          toReturn: "");

      inAppReviewServiceMock =
          setupInAppReviewServiceMock() as InAppReviewServiceMock;
    });

    tearDown(() {
      unregister<SettingsManager>();
    });

    group('futureToRunGrades -', () {
      test('first load from cache than call SignetsAPI to get the courses',
          () async {
        CourseRepositoryMock.stubSessions(courseRepositoryMock,
            toReturn: [session]);
        CourseRepositoryMock.stubGetSessions(courseRepositoryMock,
            toReturn: [session]);
        CourseRepositoryMock.stubActiveSessions(courseRepositoryMock,
            toReturn: [session]);
        CourseRepositoryMock.stubGetCourses(courseRepositoryMock,
            toReturn: courses, fromCacheOnly: true);

        CourseRepositoryMock.stubGetCourses(courseRepositoryMock,
            toReturn: courses);

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
        CourseRepositoryMock.stubSessions(courseRepositoryMock,
            toReturn: [session]);
        CourseRepositoryMock.stubGetSessions(courseRepositoryMock,
            toReturn: [session]);
        CourseRepositoryMock.stubActiveSessions(courseRepositoryMock,
            toReturn: [session]);

        CourseRepositoryMock.stubGetCourses(courseRepositoryMock,
            toReturn: courses, fromCacheOnly: true);

        CourseRepositoryMock.stubGetCoursesException(courseRepositoryMock);

        CourseRepositoryMock.stubGetCourses(courseRepositoryMock,
            toReturn: courses);

        expect(await viewModel.futureToRunGrades(), courses,
            reason:
                "Even if SignetsAPI call fails, should return the cache contents");

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
        CourseRepositoryMock.stubActiveSessions(courseRepositoryMock,
            toReturn: []);

        expect(await viewModel.futureToRunGrades(), [],
            reason: "Should return empty if there is no session active.");

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
    });

    group("futureToRun - ", () {
      test("The initial cards are correctly loaded", () async {
        setupFlutterToastMock();
        CourseRepositoryMock.stubGetCoursesActivities(courseRepositoryMock,
            fromCacheOnly: true);
        CourseRepositoryMock.stubGetCourses(courseRepositoryMock,
            fromCacheOnly: true);
        CourseRepositoryMock.stubGetCoursesException(courseRepositoryMock,
            fromCacheOnly: true);
        CourseRepositoryMock.stubGetSessions(courseRepositoryMock);
        CourseRepositoryMock.stubActiveSessions(courseRepositoryMock,
            toReturn: [session]);
        CourseRepositoryMock.stubCoursesActivities(courseRepositoryMock);

        SettingsManagerMock.stubGetDashboard(settingsManagerMock,
            toReturn: dashboard);

        await viewModel.futureToRun();
        expect(viewModel.cards, dashboard);
        expect(viewModel.cardsToDisplay, [
          PreferencesFlag.broadcastCard,
          PreferencesFlag.aboutUsCard,
          PreferencesFlag.scheduleCard,
          PreferencesFlag.progressBarCard
        ]);

        verify(settingsManagerMock.getDashboard()).called(1);
        verify(settingsManagerMock.getString(PreferencesFlag.progressBarText))
            .called(1);
        verify(settingsManagerMock.dateTimeNow).called(2);
        verifyNoMoreInteractions(settingsManagerMock);
      });

      test("build the list todays activities sorted by time", () async {
        CourseRepositoryMock.stubGetCoursesActivities(courseRepositoryMock);
        CourseRepositoryMock.stubCoursesActivities(courseRepositoryMock,
            toReturn: activities);
        CourseRepositoryMock.stubGetCourses(courseRepositoryMock,
            toReturn: courses);
        SettingsManagerMock.stubGetDashboard(settingsManagerMock,
            toReturn: dashboard);
        final now = DateTime.now();
        SettingsManagerMock.stubDateTimeNow(settingsManagerMock,
            toReturn: DateTime(now.year, now.month, now.day, 8));

        await viewModel.futureToRun();

        await untilCalled(courseRepositoryMock.getCoursesActivities());

        expect(viewModel.todayDateEvents, todayActivities);

        verify(courseRepositoryMock.getCoursesActivities()).called(1);

        verify(courseRepositoryMock.getCoursesActivities(fromCacheOnly: true))
            .called(1);

        verify(courseRepositoryMock.coursesActivities).called(2);

        verify(settingsManagerMock.getDashboard()).called(1);
      });

      test(
          "build the list todays activities (doesnt remove activity when pending completion)",
          () async {
        CourseRepositoryMock.stubGetCoursesActivities(courseRepositoryMock);
        CourseRepositoryMock.stubCoursesActivities(courseRepositoryMock,
            toReturn: activities);
        CourseRepositoryMock.stubGetCourses(courseRepositoryMock,
            toReturn: courses);
        SettingsManagerMock.stubGetDashboard(settingsManagerMock,
            toReturn: dashboard);
        final now = DateTime.now();
        SettingsManagerMock.stubDateTimeNow(settingsManagerMock,
            toReturn: DateTime(now.year, now.month, now.day, 11, 59));

        await viewModel.futureToRun();

        await untilCalled(courseRepositoryMock.getCoursesActivities());

        expect(viewModel.todayDateEvents, todayActivities);

        verify(courseRepositoryMock.getCoursesActivities()).called(1);

        verify(courseRepositoryMock.getCoursesActivities(fromCacheOnly: true))
            .called(1);

        verify(courseRepositoryMock.coursesActivities).called(2);

        verify(settingsManagerMock.getDashboard()).called(1);
      });

      test("build the list todays activities (remove activity when finished)",
          () async {
        CourseRepositoryMock.stubGetCoursesActivities(courseRepositoryMock);
        CourseRepositoryMock.stubCoursesActivities(courseRepositoryMock,
            toReturn: activities);
        CourseRepositoryMock.stubGetCourses(courseRepositoryMock,
            toReturn: courses);
        SettingsManagerMock.stubGetDashboard(settingsManagerMock,
            toReturn: dashboard);
        final now = DateTime.now();
        SettingsManagerMock.stubDateTimeNow(settingsManagerMock,
            toReturn: DateTime(now.year, now.month, now.day, 12, 01));

        await viewModel.futureToRun();

        await untilCalled(courseRepositoryMock.getCoursesActivities());

        final activitiesFinishedCourse =
            List<CourseActivity>.from(todayActivities)..remove(gen101);
        expect(viewModel.todayDateEvents, activitiesFinishedCourse);

        verify(courseRepositoryMock.getCoursesActivities()).called(1);

        verify(courseRepositoryMock.getCoursesActivities(fromCacheOnly: true))
            .called(1);

        verify(courseRepositoryMock.coursesActivities).called(2);

        verify(settingsManagerMock.getDashboard()).called(1);
      });

      test("build the list tomorrow activities sorted by time", () async {
        CourseRepositoryMock.stubGetCoursesActivities(courseRepositoryMock);
        CourseRepositoryMock.stubCoursesActivities(courseRepositoryMock,
            toReturn: activities);
        CourseRepositoryMock.stubGetCourses(courseRepositoryMock,
            toReturn: courses);
        SettingsManagerMock.stubGetDashboard(settingsManagerMock,
            toReturn: dashboard);
        final now = DateTime.now();
        SettingsManagerMock.stubDateTimeNow(settingsManagerMock,
            toReturn: DateTime(now.year, now.month, now.day, 8));

        await viewModel.futureToRun();

        await untilCalled(courseRepositoryMock.getCoursesActivities());

        expect(viewModel.tomorrowDateEvents, tomorrowActivities);

        verify(courseRepositoryMock.getCoursesActivities()).called(1);

        verify(courseRepositoryMock.getCoursesActivities(fromCacheOnly: true))
            .called(1);

        verify(courseRepositoryMock.coursesActivities).called(2);

        verify(settingsManagerMock.getDashboard()).called(1);
      });

      test(
          "build the list todays activities with the right course activities (should not have labo A)",
          () async {
        CourseRepositoryMock.stubGetCoursesActivities(courseRepositoryMock);
        CourseRepositoryMock.stubCoursesActivities(courseRepositoryMock,
            toReturn: activitiesWithLabs);

        SettingsManagerMock.stubGetDynamicString(settingsManagerMock,
            PreferencesFlag.scheduleLaboratoryGroup, "GEN101");

        SettingsManagerMock.stubGetDynamicString(settingsManagerMock,
            PreferencesFlag.scheduleLaboratoryGroup, "GEN102");

        SettingsManagerMock.stubGetDynamicString(settingsManagerMock,
            PreferencesFlag.scheduleLaboratoryGroup, "GEN103",
            toReturn: ActivityCode.labGroupB);

        expect(await viewModel.removeLaboratoryGroup(activitiesWithLabs), [
          activitiesWithLabs[0],
          activitiesWithLabs[1],
          activitiesWithLabs[2],
          activitiesWithLabs[4]
        ]);
      });

      test(
          "build the list todays activities with the right course activities (should not have labo B)",
          () async {
        CourseRepositoryMock.stubGetCoursesActivities(courseRepositoryMock);
        CourseRepositoryMock.stubCoursesActivities(courseRepositoryMock,
            toReturn: activitiesWithLabs);

        SettingsManagerMock.stubGetDynamicString(settingsManagerMock,
            PreferencesFlag.scheduleLaboratoryGroup, "GEN101");

        SettingsManagerMock.stubGetDynamicString(settingsManagerMock,
            PreferencesFlag.scheduleLaboratoryGroup, "GEN102");

        SettingsManagerMock.stubGetDynamicString(settingsManagerMock,
            PreferencesFlag.scheduleLaboratoryGroup, "GEN103",
            toReturn: ActivityCode.labGroupA);

        expect(await viewModel.removeLaboratoryGroup(activitiesWithLabs), [
          activitiesWithLabs[0],
          activitiesWithLabs[1],
          activitiesWithLabs[2],
          activitiesWithLabs[3]
        ]);
      });

      test(
          "build the list todays activities with the right course activities (should have both labs)",
          () async {
        CourseRepositoryMock.stubGetCoursesActivities(courseRepositoryMock);
        CourseRepositoryMock.stubCoursesActivities(courseRepositoryMock,
            toReturn: activitiesWithLabs);

        SettingsManagerMock.stubGetDynamicString(settingsManagerMock,
            PreferencesFlag.scheduleLaboratoryGroup, "GEN101");

        SettingsManagerMock.stubGetDynamicString(settingsManagerMock,
            PreferencesFlag.scheduleLaboratoryGroup, "GEN102");

        SettingsManagerMock.stubGetDynamicString(settingsManagerMock,
            PreferencesFlag.scheduleLaboratoryGroup, "GEN103");

        expect(await viewModel.removeLaboratoryGroup(activitiesWithLabs),
            activitiesWithLabs);
      });

      test("An exception is thrown during the preferenceService call",
          () async {
        setupFlutterToastMock();
        CourseRepositoryMock.stubGetCoursesActivities(courseRepositoryMock);
        CourseRepositoryMock.stubCoursesActivities(courseRepositoryMock);
        CourseRepositoryMock.stubGetCourses(courseRepositoryMock);

        PreferencesServiceMock.stubException(
            preferenceServiceMock, PreferencesFlag.broadcastCard);
        PreferencesServiceMock.stubException(
            preferenceServiceMock, PreferencesFlag.aboutUsCard);
        PreferencesServiceMock.stubException(
            preferenceServiceMock, PreferencesFlag.scheduleCard);
        PreferencesServiceMock.stubException(
            preferenceServiceMock, PreferencesFlag.progressBarCard);

        await viewModel.futureToRun();
        expect(viewModel.cardsToDisplay, []);

        verify(settingsManagerMock.getDashboard()).called(1);
      });
    });

    group("futureToRunSessionProgressBar - ", () {
      test("There is an active session", () async {
        CourseRepositoryMock.stubActiveSessions(courseRepositoryMock,
            toReturn: [session]);
        SettingsManagerMock.stubGetDashboard(settingsManagerMock,
            toReturn: dashboard);
        SettingsManagerMock.stubDateTimeNow(settingsManagerMock,
            toReturn: DateTime(2020));
        await viewModel.futureToRunSessionProgressBar();
        expect(viewModel.progress, 0.5);
        expect(viewModel.sessionDays, [1, 2]);
      });

      test("Invalid date (Superior limit)", () async {
        CourseRepositoryMock.stubActiveSessions(courseRepositoryMock,
            toReturn: [session]);
        SettingsManagerMock.stubGetDashboard(settingsManagerMock,
            toReturn: dashboard);
        SettingsManagerMock.stubDateTimeNow(settingsManagerMock,
            toReturn: DateTime(2020, 1, 20));
        await viewModel.futureToRunSessionProgressBar();
        expect(viewModel.progress, 1);
        expect(viewModel.sessionDays, [2, 2]);
      });

      test("Invalid date (Lower limit)", () async {
        CourseRepositoryMock.stubActiveSessions(courseRepositoryMock,
            toReturn: [session]);
        SettingsManagerMock.stubGetDashboard(settingsManagerMock,
            toReturn: dashboard);
        SettingsManagerMock.stubDateTimeNow(settingsManagerMock,
            toReturn: DateTime(2019, 12, 31));
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

      test(
          "currentProgressBarText should be set to ProgressBarText.percentage when it is the first time changeProgressBarText is called",
          () async {
        CourseRepositoryMock.stubActiveSessions(courseRepositoryMock);

        viewModel.changeProgressBarText();
        verify(settingsManagerMock.setString(PreferencesFlag.progressBarText,
                ProgressBarText.values[1].toString()))
            .called(1);
      });

      test(
          "currentProgressBarText flag should be set to ProgressBarText.remainingDays when it is the second time changeProgressBarText is called",
          () async {
        CourseRepositoryMock.stubActiveSessions(courseRepositoryMock);

        viewModel.changeProgressBarText();
        viewModel.changeProgressBarText();
        verify(settingsManagerMock.setString(PreferencesFlag.progressBarText,
                ProgressBarText.values[2].toString()))
            .called(1);
      });

      test(
          "currentProgressBarText flag should be set to ProgressBarText.daysElapsedWithTotalDays when it is the third time changeProgressBarText is called",
          () async {
        CourseRepositoryMock.stubActiveSessions(courseRepositoryMock);

        viewModel.changeProgressBarText();
        viewModel.changeProgressBarText();
        viewModel.changeProgressBarText();

        verify(settingsManagerMock.setString(PreferencesFlag.progressBarText,
                ProgressBarText.values[0].toString()))
            .called(1);
      });
    });

    group("interact with cards - ", () {
      test("can hide a card and reset cards to default layout", () async {
        SettingsManagerMock.stubSetInt(
            settingsManagerMock, PreferencesFlag.broadcastCard);
        SettingsManagerMock.stubSetInt(
            settingsManagerMock, PreferencesFlag.aboutUsCard);
        SettingsManagerMock.stubSetInt(
            settingsManagerMock, PreferencesFlag.scheduleCard);
        SettingsManagerMock.stubSetInt(
            settingsManagerMock, PreferencesFlag.progressBarCard);
        SettingsManagerMock.stubGetDashboard(settingsManagerMock,
            toReturn: dashboard);

        CourseRepositoryMock.stubGetCourses(courseRepositoryMock);

        await viewModel.futureToRun();

        // Call the setter.
        viewModel.hideCard(PreferencesFlag.scheduleCard);

        await untilCalled(
            settingsManagerMock.setInt(PreferencesFlag.scheduleCard, -1));

        expect(viewModel.cards, hiddenCardDashboard);
        expect(viewModel.cardsToDisplay, [
          PreferencesFlag.broadcastCard,
          PreferencesFlag.aboutUsCard,
          PreferencesFlag.progressBarCard
        ]);

        verify(analyticsServiceMock.logEvent(
            "DashboardViewModel", "Deleting scheduleCard"));
        verify(settingsManagerMock.setInt(PreferencesFlag.scheduleCard, -1))
            .called(1);
        verify(settingsManagerMock.setInt(PreferencesFlag.broadcastCard, 0))
            .called(1);
        verify(settingsManagerMock.setInt(PreferencesFlag.aboutUsCard, 1))
            .called(1);
        verify(settingsManagerMock.setInt(PreferencesFlag.progressBarCard, 2))
            .called(1);

        // Call the setter.
        viewModel.setAllCardsVisible();

        await untilCalled(
            settingsManagerMock.setInt(PreferencesFlag.progressBarCard, 3));

        expect(viewModel.cards, dashboard);
        expect(viewModel.cardsToDisplay, [
          PreferencesFlag.broadcastCard,
          PreferencesFlag.aboutUsCard,
          PreferencesFlag.scheduleCard,
          PreferencesFlag.progressBarCard
        ]);

        verify(analyticsServiceMock.logEvent(
            "DashboardViewModel", "Restoring cards"));
        verify(settingsManagerMock.getDashboard()).called(1);
        verify(settingsManagerMock.setInt(PreferencesFlag.broadcastCard, 0))
            .called(1);
        verify(settingsManagerMock.setInt(PreferencesFlag.aboutUsCard, 1))
            .called(1);
        verify(settingsManagerMock.setInt(PreferencesFlag.scheduleCard, 2))
            .called(1);
        verify(settingsManagerMock.setInt(PreferencesFlag.progressBarCard, 3))
            .called(1);
        verify(settingsManagerMock.getString(PreferencesFlag.progressBarText))
            .called(2);
        verify(settingsManagerMock.dateTimeNow).called(3);
        verifyNoMoreInteractions(settingsManagerMock);
      });

      test("can set new order for cards", () async {
        CourseRepositoryMock.stubGetCoursesActivities(courseRepositoryMock);
        CourseRepositoryMock.stubCoursesActivities(courseRepositoryMock);
        CourseRepositoryMock.stubGetCourses(courseRepositoryMock);

        SettingsManagerMock.stubGetDashboard(settingsManagerMock,
            toReturn: dashboard);

        SettingsManagerMock.stubSetInt(
            settingsManagerMock, PreferencesFlag.broadcastCard);
        SettingsManagerMock.stubSetInt(
            settingsManagerMock, PreferencesFlag.aboutUsCard);
        SettingsManagerMock.stubSetInt(
            settingsManagerMock, PreferencesFlag.scheduleCard);
        SettingsManagerMock.stubSetInt(
            settingsManagerMock, PreferencesFlag.progressBarCard);

        await viewModel.futureToRun();

        expect(viewModel.cards, dashboard);
        expect(viewModel.cardsToDisplay, [
          PreferencesFlag.broadcastCard,
          PreferencesFlag.aboutUsCard,
          PreferencesFlag.scheduleCard,
          PreferencesFlag.progressBarCard,
        ]);

        // Call the setter.
        viewModel.setOrder(PreferencesFlag.progressBarCard, 0);

        await untilCalled(
            settingsManagerMock.setInt(PreferencesFlag.progressBarCard, 0));

        expect(viewModel.cards, reorderedDashboard);
        expect(viewModel.cardsToDisplay, [
          PreferencesFlag.progressBarCard,
          PreferencesFlag.broadcastCard,
          PreferencesFlag.aboutUsCard,
          PreferencesFlag.scheduleCard
        ]);

        verify(analyticsServiceMock.logEvent(
            "DashboardViewModel", "Reordoring progressBarCard"));
        verify(settingsManagerMock.getDashboard()).called(1);
        verify(settingsManagerMock.setInt(PreferencesFlag.progressBarCard, 0))
            .called(1);
        verify(settingsManagerMock.setInt(PreferencesFlag.broadcastCard, 1))
            .called(1);
        verify(settingsManagerMock.setInt(PreferencesFlag.aboutUsCard, 2))
            .called(1);
        verify(settingsManagerMock.setInt(PreferencesFlag.scheduleCard, 3))
            .called(1);
        verify(settingsManagerMock.getString(PreferencesFlag.progressBarText))
            .called(1);
        verify(settingsManagerMock.dateTimeNow).called(2);
        verifyNoMoreInteractions(settingsManagerMock);
      });
    });

    group("In app review - ", () {
      test("returns true when todays date is after the day set in cache",
          () async {
        InAppReviewServiceMock.stubIsAvailable(inAppReviewServiceMock);
        InAppReviewServiceMock.stubRequestReview(inAppReviewServiceMock);

        final day = DateTime.now().add(const Duration(days: -1));
        PreferencesServiceMock.stubGetDateTime(
            preferencesServiceMock, PreferencesFlag.ratingTimer,
            toReturn: day);

        expect(await DashboardViewModel.launchInAppReview(), true);
        verify(preferencesServiceMock
                .setBool(PreferencesFlag.hasRatingBeenRequested, value: true))
            .called(1);
      });

      test(
          "returns false when todays date is after the day set in cache and when the function is called twice",
          () async {
        InAppReviewServiceMock.stubIsAvailable(inAppReviewServiceMock);
        InAppReviewServiceMock.stubRequestReview(inAppReviewServiceMock);
        final day = DateTime.now().add(const Duration(days: -1));
        PreferencesServiceMock.stubGetDateTime(
            preferencesServiceMock, PreferencesFlag.ratingTimer,
            toReturn: day);
        PreferencesServiceMock.stubGetBool(
            preferencesServiceMock, PreferencesFlag.hasRatingBeenRequested,
            toReturn: false);

        expect(await DashboardViewModel.launchInAppReview(), true);

        PreferencesServiceMock.stubGetBool(
            preferencesServiceMock, PreferencesFlag.hasRatingBeenRequested);

        expect(await DashboardViewModel.launchInAppReview(), false);
      });

      test(
          "returns false when today's date is after the day set in cache and when the function is called twice",
          () async {
        InAppReviewServiceMock.stubIsAvailable(inAppReviewServiceMock);
        InAppReviewServiceMock.stubRequestReview(inAppReviewServiceMock);
        final day = DateTime.now().add(const Duration(days: -1));
        PreferencesServiceMock.stubGetDateTime(
            preferencesServiceMock, PreferencesFlag.ratingTimer,
            toReturn: day);
        PreferencesServiceMock.stubGetBool(
            preferencesServiceMock, PreferencesFlag.hasRatingBeenRequested,
            toReturn: false);

        expect(await DashboardViewModel.launchInAppReview(), true);

        PreferencesServiceMock.stubGetBool(
            preferencesServiceMock, PreferencesFlag.hasRatingBeenRequested);

        expect(await DashboardViewModel.launchInAppReview(), false);
      });

      test("returns false when today's date is the before the day set in cache",
          () async {
        InAppReviewServiceMock.stubIsAvailable(inAppReviewServiceMock);
        InAppReviewServiceMock.stubRequestReview(inAppReviewServiceMock);
        final day = DateTime.now().add(const Duration(days: 2));
        PreferencesServiceMock.stubGetDateTime(
            preferencesServiceMock, PreferencesFlag.ratingTimer,
            toReturn: day);

        expect(await DashboardViewModel.launchInAppReview(), false);
      });

      test("returns false when the cache date hasn't been set (null)",
          () async {
        InAppReviewServiceMock.stubIsAvailable(inAppReviewServiceMock);
        InAppReviewServiceMock.stubRequestReview(inAppReviewServiceMock);
        PreferencesServiceMock.stubGetDateTime(
            preferencesServiceMock, PreferencesFlag.ratingTimer);

        expect(await DashboardViewModel.launchInAppReview(), false);
      });
    });
  });
}
