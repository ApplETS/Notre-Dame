// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:mockito/mockito.dart';

// CONSTANTS
import 'package:notredame/core/constants/preferences_flags.dart';
import 'package:notredame/core/constants/progress_bar_text_options.dart';

// MANAGERS
import 'package:notredame/core/managers/course_repository.dart';
import 'package:notredame/core/managers/settings_manager.dart';
import 'package:notredame/core/models/course.dart';

// MODEL
import 'package:notredame/core/models/session.dart';
import 'package:notredame/core/models/course_activity.dart';

// SERVICE
import 'package:notredame/core/services/preferences_service.dart';

// VIEWMODEL
import 'package:notredame/core/viewmodels/dashboard_viewmodel.dart';

// OTHER
import '../helpers.dart';

// MOCKS
import '../mock/managers/course_repository_mock.dart';
import '../mock/managers/settings_manager_mock.dart';
import '../mock/services/preferences_service_mock.dart';

void main() {
  PreferencesService preferenceService;
  SettingsManager settingsManager;
  DashboardViewModel viewModel;
  CourseRepository courseRepository;
  PreferencesServiceMock preferencesServiceMock;

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

  final List<CourseActivity> activities = [gen101, gen102, gen103];

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
      deadlineCancellationASEQ: DateTime(2017, 1, 11, 1, 1));

  group("DashboardViewModel - ", () {
    setUp(() async {
      // Setting up mocks
      courseRepository = setupCourseRepositoryMock();
      settingsManager = setupSettingsManagerMock();
      preferenceService = setupPreferencesServiceMock();
      courseRepository = setupCourseRepositoryMock();
      preferencesServiceMock =
          setupPreferencesServiceMock() as PreferencesServiceMock;

      courseRepository = setupCourseRepositoryMock();

      viewModel = DashboardViewModel(intl: await setupAppIntl());
      CourseRepositoryMock.stubGetSessions(
          courseRepository as CourseRepositoryMock,
          toReturn: [session]);
      CourseRepositoryMock.stubActiveSessions(
          courseRepository as CourseRepositoryMock,
          toReturn: [session]);
      CourseRepositoryMock.stubCoursesActivities(
          courseRepository as CourseRepositoryMock);
      CourseRepositoryMock.stubGetCoursesActivities(
          courseRepository as CourseRepositoryMock,
          fromCacheOnly: true);
      CourseRepositoryMock.stubGetCoursesActivities(
          courseRepository as CourseRepositoryMock,
          fromCacheOnly: false);
    });

    tearDown(() {
      unregister<SettingsManager>();
    });

    group('futureToRunGrades -', () {
      test('first load from cache than call SignetsAPI to get the courses',
          () async {
        CourseRepositoryMock.stubSessions(
            courseRepository as CourseRepositoryMock,
            toReturn: [session]);
        CourseRepositoryMock.stubGetSessions(
            courseRepository as CourseRepositoryMock,
            toReturn: [session]);
        CourseRepositoryMock.stubActiveSessions(
            courseRepository as CourseRepositoryMock,
            toReturn: [session]);
        CourseRepositoryMock.stubGetCourses(
            courseRepository as CourseRepositoryMock,
            toReturn: courses,
            fromCacheOnly: true);

        CourseRepositoryMock.stubGetCourses(
            courseRepository as CourseRepositoryMock,
            toReturn: courses);

        expect(await viewModel.futureToRunGrades(), courses);

        await untilCalled(courseRepository.sessions);
        await untilCalled(courseRepository.sessions);

        expect(viewModel.courses, courses);

        verifyInOrder([
          courseRepository.sessions,
          courseRepository.sessions,
          courseRepository.activeSessions,
          courseRepository.activeSessions,
          courseRepository.getCourses(fromCacheOnly: true),
          courseRepository.getCourses(),
        ]);

        verifyNoMoreInteractions(courseRepository);
      });

      test('Signets throw an error while trying to get courses', () async {
        setupFlutterToastMock();
        CourseRepositoryMock.stubSessions(
            courseRepository as CourseRepositoryMock,
            toReturn: [session]);
        CourseRepositoryMock.stubGetSessions(
            courseRepository as CourseRepositoryMock,
            toReturn: [session]);
        CourseRepositoryMock.stubActiveSessions(
            courseRepository as CourseRepositoryMock,
            toReturn: [session]);

        CourseRepositoryMock.stubGetCourses(
            courseRepository as CourseRepositoryMock,
            toReturn: courses,
            fromCacheOnly: true);

        CourseRepositoryMock.stubGetCoursesException(
            courseRepository as CourseRepositoryMock,
            fromCacheOnly: false);

        CourseRepositoryMock.stubGetCourses(
            courseRepository as CourseRepositoryMock,
            toReturn: courses);

        expect(await viewModel.futureToRunGrades(), courses,
            reason:
                "Even if SignetsAPI call fails, should return the cache contents");

        await untilCalled(courseRepository.sessions);
        await untilCalled(courseRepository.sessions);

        expect(viewModel.courses, courses);

        verifyInOrder([
          courseRepository.sessions,
          courseRepository.sessions,
          courseRepository.activeSessions,
          courseRepository.activeSessions,
          courseRepository.getCourses(fromCacheOnly: true),
          courseRepository.getCourses(),
        ]);

        verifyNoMoreInteractions(courseRepository);
      });

      test('There is no session active', () async {
        CourseRepositoryMock.stubSessions(
            courseRepository as CourseRepositoryMock,
            toReturn: []);
        CourseRepositoryMock.stubActiveSessions(
            courseRepository as CourseRepositoryMock,
            toReturn: []);

        expect(await viewModel.futureToRunGrades(), [],
            reason: "Should return empty if there is no session active.");

        await untilCalled(courseRepository.sessions);

        expect(viewModel.courses, []);

        verifyInOrder([
          courseRepository.sessions,
          courseRepository.sessions,
          courseRepository.getSessions(),
          courseRepository.activeSessions,
        ]);

        verifyNoMoreInteractions(courseRepository);
      });
    });

    group("futureToRun - ", () {
      test("The initial cards are correctly loaded", () async {
        setupFlutterToastMock();
        CourseRepositoryMock.stubGetCoursesActivities(
            courseRepository as CourseRepositoryMock);
        CourseRepositoryMock.stubCoursesActivities(
            courseRepository as CourseRepositoryMock);

        SettingsManagerMock.stubGetDashboard(
            settingsManager as SettingsManagerMock,
            toReturn: dashboard);

        await viewModel.futureToRun();
        expect(viewModel.cards, dashboard);
        expect(viewModel.cardsToDisplay, [
          PreferencesFlag.aboutUsCard,
          PreferencesFlag.scheduleCard,
          PreferencesFlag.progressBarCard
        ]);

        verify(settingsManager.getDashboard()).called(1);
        verify(settingsManager.getString(PreferencesFlag.progressBarText))
            .called(1);
        verifyNoMoreInteractions(settingsManager);
      });

      test("build the list todays activities sorted by time", () async {
        CourseRepositoryMock.stubGetCoursesActivities(
            courseRepository as CourseRepositoryMock);
        CourseRepositoryMock.stubCoursesActivities(
            courseRepository as CourseRepositoryMock,
            toReturn: activities);

        await viewModel.futureToRun();
        await viewModel.futureToRunSchedule();

        await untilCalled(courseRepository.getCoursesActivities());

        expect(viewModel.todayDateEvents, activities);

        verify(courseRepository.getCoursesActivities()).called(1);

        verify(courseRepository.getCoursesActivities(fromCacheOnly: true))
            .called(1);

        verify(courseRepository.coursesActivities).called(1);

        verify(settingsManager.getDashboard()).called(1);

        verifyNoMoreInteractions(courseRepository);
        verifyNoMoreInteractions(settingsManager);
      });

      test("An exception is thrown during the preferenceService call",
          () async {
        setupFlutterToastMock();
        CourseRepositoryMock.stubGetCoursesActivities(
            courseRepository as CourseRepositoryMock);
        CourseRepositoryMock.stubCoursesActivities(
            courseRepository as CourseRepositoryMock);

        PreferencesServiceMock.stubException(
            preferenceService as PreferencesServiceMock,
            PreferencesFlag.aboutUsCard);
        PreferencesServiceMock.stubException(
            preferenceService as PreferencesServiceMock,
            PreferencesFlag.scheduleCard);
        PreferencesServiceMock.stubException(
            preferenceService as PreferencesServiceMock,
            PreferencesFlag.progressBarCard);

        await viewModel.futureToRun();
        expect(viewModel.cardsToDisplay, []);

        verify(settingsManager.getDashboard()).called(1);
        verifyNoMoreInteractions(settingsManager);
      });
    });

    group("futureToRunSessionProgressBar - ", () {
      test("There is an active session", () async {
        CourseRepositoryMock.stubActiveSessions(
            courseRepository as CourseRepositoryMock,
            toReturn: [session]);
        SettingsManagerMock.stubGetDashboard(
            settingsManager as SettingsManagerMock,
            toReturn: dashboard);
        viewModel.todayDate = DateTime(2020);
        await viewModel.futureToRunSessionProgressBar();
        expect(viewModel.progress, 0.5);
        expect(viewModel.sessionDays, [1, 2]);
      });

      test("Active session is null", () async {
        CourseRepositoryMock.stubActiveSessions(
            courseRepository as CourseRepositoryMock);

        await viewModel.futureToRunSessionProgressBar();
        expect(viewModel.progress, -1.0);
        expect(viewModel.sessionDays, [0, 0]);
      });

      test(
          "currentProgressBarText should be set to ProgressBarText.percentage when it is the first time changeProgressBarText is called",
          () async {
        CourseRepositoryMock.stubActiveSessions(
            courseRepository as CourseRepositoryMock);

        viewModel.changeProgressBarText();
        verify(settingsManager.setString(PreferencesFlag.progressBarText,
                ProgressBarText.values[1].toString()))
            .called(1);
      });

      test(
          "currentProgressBarText flag should be set to ProgressBarText.remainingDays when it is the second time changeProgressBarText is called",
          () async {
        CourseRepositoryMock.stubActiveSessions(
            courseRepository as CourseRepositoryMock);

        viewModel.changeProgressBarText();
        viewModel.changeProgressBarText();
        verify(settingsManager.setString(PreferencesFlag.progressBarText,
                ProgressBarText.values[2].toString()))
            .called(1);
      });

      test(
          "currentProgressBarText flag should be set to ProgressBarText.daysElapsedWithTotalDays when it is the third time changeProgressBarText is called",
          () async {
        CourseRepositoryMock.stubActiveSessions(
            courseRepository as CourseRepositoryMock);

        viewModel.changeProgressBarText();
        viewModel.changeProgressBarText();
        viewModel.changeProgressBarText();

        verify(settingsManager.setString(PreferencesFlag.progressBarText,
                ProgressBarText.values[0].toString()))
            .called(1);
      });
    });

    group("interact with cards - ", () {
      test("can hide a card and reset cards to default layout", () async {
        SettingsManagerMock.stubSetInt(settingsManager as SettingsManagerMock,
            PreferencesFlag.aboutUsCard);
        SettingsManagerMock.stubSetInt(settingsManager as SettingsManagerMock,
            PreferencesFlag.scheduleCard);
        SettingsManagerMock.stubSetInt(settingsManager as SettingsManagerMock,
            PreferencesFlag.progressBarCard);
        SettingsManagerMock.stubGetDashboard(
            settingsManager as SettingsManagerMock,
            toReturn: dashboard);

        await viewModel.futureToRun();

        // Call the setter.
        viewModel.hideCard(PreferencesFlag.scheduleCard);

        await untilCalled(
            settingsManager.setInt(PreferencesFlag.scheduleCard, -1));

        expect(viewModel.cards, hiddenCardDashboard);
        expect(viewModel.cardsToDisplay,
            [PreferencesFlag.aboutUsCard, PreferencesFlag.progressBarCard]);

        verify(settingsManager.setInt(PreferencesFlag.scheduleCard, -1))
            .called(1);
        verify(settingsManager.setInt(PreferencesFlag.aboutUsCard, 0))
            .called(1);
        verify(settingsManager.setInt(PreferencesFlag.progressBarCard, 1))
            .called(1);

        // Call the setter.
        viewModel.setAllCardsVisible();

        await untilCalled(
            settingsManager.setInt(PreferencesFlag.progressBarCard, 2));

        expect(viewModel.cards, dashboard);
        expect(viewModel.cardsToDisplay, [
          PreferencesFlag.aboutUsCard,
          PreferencesFlag.scheduleCard,
          PreferencesFlag.progressBarCard
        ]);

        verify(settingsManager.getDashboard()).called(1);
        verify(settingsManager.setInt(PreferencesFlag.aboutUsCard, 0))
            .called(1);
        verify(settingsManager.setInt(PreferencesFlag.scheduleCard, 1))
            .called(1);
        verify(settingsManager.setInt(PreferencesFlag.progressBarCard, 2))
            .called(1);
        verify(settingsManager.getString(PreferencesFlag.progressBarText))
            .called(2);
        verifyNoMoreInteractions(settingsManager);
      });

      test("can set new order for cards", () async {
        CourseRepositoryMock.stubGetCoursesActivities(
            courseRepository as CourseRepositoryMock);
        CourseRepositoryMock.stubCoursesActivities(
            courseRepository as CourseRepositoryMock);

        SettingsManagerMock.stubGetDashboard(
            settingsManager as SettingsManagerMock,
            toReturn: dashboard);

        SettingsManagerMock.stubSetInt(settingsManager as SettingsManagerMock,
            PreferencesFlag.aboutUsCard);
        SettingsManagerMock.stubSetInt(settingsManager as SettingsManagerMock,
            PreferencesFlag.scheduleCard);
        SettingsManagerMock.stubSetInt(settingsManager as SettingsManagerMock,
            PreferencesFlag.progressBarCard);

        await viewModel.futureToRun();

        expect(viewModel.cards, dashboard);
        expect(viewModel.cardsToDisplay, [
          PreferencesFlag.aboutUsCard,
          PreferencesFlag.scheduleCard,
          PreferencesFlag.progressBarCard,
        ]);

        // Call the setter.
        viewModel.setOrder(PreferencesFlag.progressBarCard, 0);

        await untilCalled(
            settingsManager.setInt(PreferencesFlag.progressBarCard, 0));

        expect(viewModel.cards, reorderedDashboard);
        expect(viewModel.cardsToDisplay, [
          PreferencesFlag.progressBarCard,
          PreferencesFlag.aboutUsCard,
          PreferencesFlag.scheduleCard
        ]);

        verify(settingsManager.getDashboard()).called(1);
        verify(settingsManager.setInt(PreferencesFlag.progressBarCard, 0))
            .called(1);
        verify(settingsManager.setInt(PreferencesFlag.aboutUsCard, 1))
            .called(1);
        verify(settingsManager.setInt(PreferencesFlag.scheduleCard, 2))
            .called(1);
        verify(settingsManager.getString(PreferencesFlag.progressBarText))
            .called(1);
        verifyNoMoreInteractions(settingsManager);
      });
    });

    group("In app review - ", () {
      test("returns true when todays date is after the day set in cache",
          () async {
        final day = DateTime.now().add(const Duration(days: -1));
        setupInAppReview();
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
        final day = DateTime.now().add(const Duration(days: -1));
        setupInAppReview();
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
          "returns false when todays date is after the day set in cache and when the function is called twice",
          () async {
        final day = DateTime.now().add(const Duration(days: -1));
        setupInAppReview();
        PreferencesServiceMock.stubGetDateTime(
            preferencesServiceMock, PreferencesFlag.ratingTimer,
            toReturn: day);
        PreferencesServiceMock.stubGetBool(
            preferencesServiceMock, PreferencesFlag.hasRatingBeenRequested,
            toReturn: null);

        expect(await DashboardViewModel.launchInAppReview(), true);

        PreferencesServiceMock.stubGetBool(
            preferencesServiceMock, PreferencesFlag.hasRatingBeenRequested);

        expect(await DashboardViewModel.launchInAppReview(), false);
      });

      test("returns false when todays date is the before the day set in cache",
          () async {
        final day = DateTime.now().add(const Duration(days: 2));
        setupInAppReview();
        PreferencesServiceMock.stubGetDateTime(
            preferencesServiceMock, PreferencesFlag.ratingTimer,
            toReturn: day);

        expect(await DashboardViewModel.launchInAppReview(), false);
      });

      test("returns false when the cache date hasn't been set (null)",
          () async {
        setupInAppReview();
        PreferencesServiceMock.stubGetDateTime(
            preferencesServiceMock, PreferencesFlag.ratingTimer);

        expect(await DashboardViewModel.launchInAppReview(), false);
      });
    });
  });
}
