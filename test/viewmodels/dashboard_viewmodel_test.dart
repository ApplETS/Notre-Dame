// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:notredame/core/constants/preferences_flags.dart';
import 'package:notredame/core/managers/course_repository.dart';

// MANAGERS
import 'package:notredame/core/managers/settings_manager.dart';
import 'package:notredame/core/models/course.dart';
import 'package:notredame/core/models/session.dart';
import 'package:notredame/core/services/preferences_service.dart';

// VIEW-MODEL
import 'package:notredame/core/viewmodels/dashboard_viewmodel.dart';

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

  // Needed to support FlutterToast.
  TestWidgetsFlutterBinding.ensureInitialized();

  // Session
  final Session session1 = Session(
      shortName: "É2020",
      name: "Ete 2020",
      startDate: DateTime(2020, 1, 10, 1, 1),
      endDate: DateTime(2022, 1, 10, 1, 1),
      endDateCourses: DateTime(2022, 1, 10, 1, 1),
      startDateRegistration: DateTime(2017, 1, 9, 1, 1),
      deadlineRegistration: DateTime(2017, 1, 10, 1, 1),
      startDateCancellationWithRefund: DateTime(2017, 1, 10, 1, 1),
      deadlineCancellationWithRefund: DateTime(2017, 1, 11, 1, 1),
      deadlineCancellationWithRefundNewStudent: DateTime(2017, 1, 11, 1, 1),
      startDateCancellationWithoutRefundNewStudent: DateTime(2017, 1, 12, 1, 1),
      deadlineCancellationWithoutRefundNewStudent: DateTime(2017, 1, 12, 1, 1),
      deadlineCancellationASEQ: DateTime(2017, 1, 11, 1, 1));

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

  final session = [session1];

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

  group("DashboardViewModel - ", () {
    setUp(() async {
      // Setting up mocks
      courseRepository = setupCourseRepositoryMock();
      settingsManager = setupSettingsManagerMock();
      preferenceService = setupPreferencesServiceMock();

      setupFlutterToastMock();

      viewModel = DashboardViewModel(intl: await setupAppIntl());
    });

    tearDown(() {
      unregister<SettingsManager>();
      tearDownFlutterToastMock();
    });

    group('futureToRunGrades -', () {
      test('first load from cache than call SignetsAPI to get the courses',
          () async {
        CourseRepositoryMock.stubSessions(
            courseRepository as CourseRepositoryMock,
            toReturn: session);
        CourseRepositoryMock.stubGetSessions(
            courseRepository as CourseRepositoryMock,
            toReturn: session);
        CourseRepositoryMock.stubActiveSessions(
            courseRepository as CourseRepositoryMock,
            toReturn: session);
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
          courseRepository.activeSessions,
          courseRepository.getCourses(fromCacheOnly: true),
          courseRepository.getCourses(),
        ]);

        verifyNoMoreInteractions(courseRepository);
      });

      test('Signets throw an error while trying to get courses', () async {
        CourseRepositoryMock.stubSessions(
            courseRepository as CourseRepositoryMock,
            toReturn: session);
        CourseRepositoryMock.stubGetSessions(
            courseRepository as CourseRepositoryMock,
            toReturn: session);
        CourseRepositoryMock.stubActiveSessions(
            courseRepository as CourseRepositoryMock,
            toReturn: session);

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
          courseRepository.activeSessions,
          courseRepository.getCourses(fromCacheOnly: true),
          courseRepository.getCourses(),
        ]);

        verifyNoMoreInteractions(courseRepository);
      });
    });

    group("futureToRun - ", () {
      test("The initial cards are correctly loaded", () async {
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
        verifyNoMoreInteractions(settingsManager);
      });

      test("An exception is thrown during the preferenceService call",
          () async {
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

    group("interact with cards - ", () {
      test("can hide a card and reset cards to default layout", () async {
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
        verifyNoMoreInteractions(settingsManager);
      });

      test("can set new order for cards", () async {
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
        verifyNoMoreInteractions(settingsManager);
      });
    });
  });
}
