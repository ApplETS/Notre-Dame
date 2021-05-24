// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

// CONSTANTS
import 'package:notredame/core/constants/preferences_flags.dart';

// MANAGERS
import 'package:notredame/core/managers/course_repository.dart';
import 'package:notredame/core/managers/settings_manager.dart';

// MODEL
import 'package:notredame/core/models/session.dart';

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

  // Needed to support FlutterToast.
  TestWidgetsFlutterBinding.ensureInitialized();

  // Cards
  final Map<PreferencesFlag, int> dashboard = {
    PreferencesFlag.aboutUsCard: 0,
    PreferencesFlag.scheduleCard: 1,
    PreferencesFlag.progressBarCard: 2
  };

  // Reorderered Cards
  final Map<PreferencesFlag, int> reorderedDashboard = {
    PreferencesFlag.aboutUsCard: 1,
    PreferencesFlag.scheduleCard: 2,
    PreferencesFlag.progressBarCard: 0
  };

  // Reorderered Cards with hidden scheduleCard
  final Map<PreferencesFlag, int> hiddenCardDashboard = {
    PreferencesFlag.aboutUsCard: 0,
    PreferencesFlag.scheduleCard: -1,
    PreferencesFlag.progressBarCard: 1
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
      settingsManager = setupSettingsManagerMock();
      preferenceService = setupPreferencesServiceMock();

      setupFlutterToastMock();
      courseRepository = setupCourseRepositoryMock();

      viewModel = DashboardViewModel(intl: await setupAppIntl());
      CourseRepositoryMock.stubGetSessions(
          courseRepository as CourseRepositoryMock,
          toReturn: [session]);
      CourseRepositoryMock.stubActiveSessions(
          courseRepository as CourseRepositoryMock,
          toReturn: [session]);
    });

    tearDown(() {
      unregister<SettingsManager>();
      tearDownFlutterToastMock();
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
