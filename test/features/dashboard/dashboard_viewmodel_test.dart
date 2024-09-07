// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import 'package:notredame/constants/preferences_flags.dart';
import 'package:notredame/features/app/signets-api/models/course.dart';
import 'package:notredame/features/app/signets-api/models/session.dart';
import 'package:notredame/features/dashboard/dashboard_viewmodel.dart';
import 'package:notredame/features/more/settings/settings_manager.dart';
import '../../common/helpers.dart';
import '../app/analytics/mocks/analytics_service_mock.dart';
import '../app/analytics/mocks/remote_config_service_mock.dart';
import '../app/repository/mocks/course_repository_mock.dart';
import '../app/storage/mocks/preferences_service_mock.dart';
import '../more/feedback/mocks/in_app_review_service_mock.dart';
import '../more/settings/mocks/settings_manager_mock.dart';

void main() {
  late PreferencesServiceMock preferenceServiceMock;
  late SettingsManagerMock settingsManagerMock;
  late CourseRepositoryMock courseRepositoryMock;
  late RemoteConfigServiceMock remoteConfigServiceMock;
  late PreferencesServiceMock preferencesServiceMock;
  late InAppReviewServiceMock inAppReviewServiceMock;
  late AnalyticsServiceMock analyticsServiceMock;

  late DashboardViewModel viewModel;

  // Needed to support FlutterToast.
  TestWidgetsFlutterBinding.ensureInitialized();

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
      courseRepositoryMock = setupCourseRepositoryMock();
      remoteConfigServiceMock = setupRemoteConfigServiceMock();
      settingsManagerMock = setupSettingsManagerMock();
      preferenceServiceMock = setupPreferencesServiceMock();
      analyticsServiceMock = setupAnalyticsServiceMock();
      preferencesServiceMock = setupPreferencesServiceMock();
      // TODO: Remove when 4.50.1 is released
      SharedPreferences.setMockInitialValues({});
      // TODO: End remove when 4.50.1 is released

      viewModel = DashboardViewModel(intl: await setupAppIntl());
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

    group("futureToRun - ", () {
      // test("The initial cards are correctly loaded", () async {
      //   setupFlutterToastMock();
      //   CourseRepositoryMock.stubGetCoursesActivities(courseRepositoryMock,
      //       fromCacheOnly: true);
      //   CourseRepositoryMock.stubGetCourses(courseRepositoryMock,
      //       fromCacheOnly: true);
      //   CourseRepositoryMock.stubGetCoursesException(courseRepositoryMock,
      //       fromCacheOnly: true);
      //   CourseRepositoryMock.stubGetSessions(courseRepositoryMock);
      //   CourseRepositoryMock.stubActiveSessions(courseRepositoryMock,
      //       toReturn: [session]);
      //   CourseRepositoryMock.stubCoursesActivities(courseRepositoryMock);
      //
      //   SettingsManagerMock.stubGetDashboard(settingsManagerMock,
      //       toReturn: dashboard);
      //
      //   await viewModel.futureToRun();
      //   expect(viewModel.cards, dashboard);
      //   expect(viewModel.cardsToDisplay, [
      //     PreferencesFlag.aboutUsCard,
      //     PreferencesFlag.scheduleCard,
      //     PreferencesFlag.progressBarCard
      //   ]);
      //
      //   verify(settingsManagerMock.getDashboard()).called(1);
      //   verify(settingsManagerMock.getString(PreferencesFlag.progressBarText))
      //       .called(1);
      //   verify(settingsManagerMock.dateTimeNow).called(2);
      //   verifyNoMoreInteractions(settingsManagerMock);
      // });

      test("An exception is thrown during the preferenceService call",
          () async {
        setupFlutterToastMock();
        CourseRepositoryMock.stubGetCoursesActivities(courseRepositoryMock);
        CourseRepositoryMock.stubCoursesActivities(courseRepositoryMock);
        CourseRepositoryMock.stubGetCourses(courseRepositoryMock);

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

    group("interact with cards - ", () {
      test("can hide a card and reset cards to default layout", () async {
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
        expect(viewModel.cardsToDisplay,
            [PreferencesFlag.aboutUsCard, PreferencesFlag.progressBarCard]);

        verify(analyticsServiceMock.logEvent(
            "DashboardViewModel", "Deleting scheduleCard"));
        verify(settingsManagerMock.setInt(PreferencesFlag.scheduleCard, -1))
            .called(1);
        verify(settingsManagerMock.setInt(PreferencesFlag.aboutUsCard, 0))
            .called(1);
        verify(settingsManagerMock.setInt(PreferencesFlag.progressBarCard, 1))
            .called(1);

        // Call the setter.
        viewModel.setAllCardsVisible();

        await untilCalled(
            settingsManagerMock.setInt(PreferencesFlag.progressBarCard, 2));

        expect(viewModel.cards, dashboard);
        expect(viewModel.cardsToDisplay, [
          PreferencesFlag.aboutUsCard,
          PreferencesFlag.scheduleCard,
          PreferencesFlag.progressBarCard
        ]);

        verify(analyticsServiceMock.logEvent(
            "DashboardViewModel", "Restoring cards"));
        verify(settingsManagerMock.getDashboard()).called(1);
        verify(settingsManagerMock.setInt(PreferencesFlag.aboutUsCard, 0))
            .called(1);
        verify(settingsManagerMock.setInt(PreferencesFlag.scheduleCard, 1))
            .called(1);
        verify(settingsManagerMock.setInt(PreferencesFlag.progressBarCard, 2))
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
            settingsManagerMock, PreferencesFlag.aboutUsCard);
        SettingsManagerMock.stubSetInt(
            settingsManagerMock, PreferencesFlag.scheduleCard);
        SettingsManagerMock.stubSetInt(
            settingsManagerMock, PreferencesFlag.progressBarCard);

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
            settingsManagerMock.setInt(PreferencesFlag.progressBarCard, 0));

        expect(viewModel.cards, reorderedDashboard);
        expect(viewModel.cardsToDisplay, [
          PreferencesFlag.progressBarCard,
          PreferencesFlag.aboutUsCard,
          PreferencesFlag.scheduleCard
        ]);

        verify(analyticsServiceMock.logEvent(
            "DashboardViewModel", "Reordoring progressBarCard"));
        verify(settingsManagerMock.getDashboard()).called(1);
        verify(settingsManagerMock.setInt(PreferencesFlag.progressBarCard, 0))
            .called(1);
        verify(settingsManagerMock.setInt(PreferencesFlag.aboutUsCard, 1))
            .called(1);
        verify(settingsManagerMock.setInt(PreferencesFlag.scheduleCard, 2))
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
