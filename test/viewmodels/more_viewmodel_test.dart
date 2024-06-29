// Package imports:
import 'package:ets_api_clients/models.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:notredame/features/app/analytics/analytics_service.dart';

// Project imports:
import 'package:notredame/features/app/navigation/router_paths.dart';
import 'package:notredame/features/app/storage/cache_manager.dart';
import 'package:notredame/features/app/repository/course_repository.dart';
import 'package:notredame/features/more/settings/settings_manager.dart';
import 'package:notredame/features/app/repository/user_repository.dart';
import 'package:notredame/features/app/navigation/navigation_service.dart';
import 'package:notredame/features/app/storage/preferences_service.dart';
import 'package:notredame/features/more/more_viewmodel.dart';
import '../helpers.dart';
import '../mock/managers/cache_manager_mock.dart';
import '../mock/managers/course_repository_mock.dart';
import '../mock/managers/settings_manager_mock.dart';
import '../mock/managers/user_repository_mock.dart';
import '../mock/services/navigation_service_mock.dart';
import '../mock/services/preferences_service_mock.dart';
import '../mock/services/remote_config_service_mock.dart';

void main() {
  // Needed to support FlutterToast.
  TestWidgetsFlutterBinding.ensureInitialized();

  late CacheManagerMock cacheManagerMock;
  late SettingsManagerMock settingsManagerMock;
  late CourseRepositoryMock courseRepositoryMock;
  late PreferencesServiceMock preferenceServiceMock;
  late RemoteConfigServiceMock remoteConfigServiceMock;
  late UserRepositoryMock userRepositoryMock;
  late NavigationServiceMock navigationServiceMock;

  late AppIntl appIntl;
  late MoreViewModel viewModel;

  final DateTime now = DateTime.now();

  final List<Session> sessions = [
    Session(
        name: 'Hivers 2XXX',
        shortName: 'H1',
        deadlineCancellationASEQ: now,
        deadlineCancellationWithoutRefundNewStudent: now,
        deadlineCancellationWithRefund: now,
        deadlineCancellationWithRefundNewStudent: now,
        deadlineRegistration: now,
        startDate: now,
        startDateCancellationWithoutRefundNewStudent: now,
        startDateCancellationWithRefund: now,
        startDateRegistration: now,
        endDate: now,
        endDateCourses: now),
  ];

  final List<CourseActivity> coursesActivities = [
    CourseActivity(
        courseName: 'sample course',
        courseGroup: '',
        activityName: '',
        activityDescription: '',
        activityLocation: '',
        startDateTime: now,
        endDateTime: now.add(const Duration(hours: 1))),
  ];

  final List<Course> courses = [
    Course(
        acronym: "ABC123",
        title: "testCourse",
        group: "09",
        session: "H2021",
        programCode: "XYZ",
        numberOfCredits: 3),
  ];

  /// Verify all the required functions that are called from the logout function
  void verifyEveryFunctionsInLogout() {
    verifyInOrder([
      // Check if the cacheManager has been emptied out
      cacheManagerMock.empty(),
      // Check if preference manager is clear
      preferenceServiceMock.clearWithoutPersistentKey(),
      // Check if user repository logOut is called
      userRepositoryMock.logOut(),
      // Check if the settings manager has reset lang and theme and notified his listener
      settingsManagerMock.resetLanguageAndThemeMode(),
    ]);
    verifyNoMoreInteractions(cacheManagerMock);
    verifyNoMoreInteractions(preferenceServiceMock);
    verifyNoMoreInteractions(userRepositoryMock);
    verifyNoMoreInteractions(settingsManagerMock);

    // Make sure that the registered cache
    expect(courseRepositoryMock.sessions!.length, 0,
        reason: 'has emptied out the sessions list');
    expect(courseRepositoryMock.coursesActivities!.length, 0,
        reason: 'has emptied out the courseActivities list');
    expect(courseRepositoryMock.courses!.length, 0,
        reason: 'has emptied out the courses list');

    // Check if navigation has been rerouted to login page
    verifyInOrder([
      navigationServiceMock.pushNamedAndRemoveUntil(
          RouterPaths.login, RouterPaths.chooseLanguage)
    ]);

    verifyNoMoreInteractions(navigationServiceMock);
  }

  group('MoreViewModel - ', () {
    setUp(() async {
      cacheManagerMock = setupCacheManagerMock();
      settingsManagerMock = setupSettingsManagerMock();
      courseRepositoryMock = setupCourseRepositoryMock();
      remoteConfigServiceMock = setupRemoteConfigServiceMock();
      preferenceServiceMock = setupPreferencesServiceMock();
      userRepositoryMock = setupUserRepositoryMock();
      navigationServiceMock = setupNavigationServiceMock();
      appIntl = await setupAppIntl();
      setupLogger();

      viewModel = MoreViewModel(intl: appIntl);

      CourseRepositoryMock.stubCourses(courseRepositoryMock, toReturn: courses);
      CourseRepositoryMock.stubSessions(courseRepositoryMock,
          toReturn: sessions);
      CourseRepositoryMock.stubCoursesActivities(courseRepositoryMock,
          toReturn: coursesActivities);
      RemoteConfigServiceMock.stubGetPrivacyPolicyEnabled(
          remoteConfigServiceMock);
    });

    tearDown(() {
      unregister<AnalyticsService>();
      unregister<CacheManager>();
      unregister<SettingsManager>();
      unregister<CourseRepository>();
      unregister<PreferencesService>();
      unregister<UserRepository>();
      unregister<NavigationService>();
    });

    group('logout - ', () {
      test('If the correct function have been called when logout occur',
          () async {
        RemoteConfigServiceMock.stubGetPrivacyPolicyEnabled(
            remoteConfigServiceMock,
            toReturn: false);
        setupFlutterToastMock();
        UserRepositoryMock.stubLogOut(userRepositoryMock);

        await viewModel.logout();

        verifyEveryFunctionsInLogout();
      });

      test(
          'If an error occur from the cache manager that the logout function finishes out',
          () async {
        RemoteConfigServiceMock.stubGetPrivacyPolicyEnabled(
            remoteConfigServiceMock,
            toReturn: false);
        setupFlutterToastMock();
        CacheManagerMock.stubEmptyException(cacheManagerMock);
        UserRepositoryMock.stubLogOut(userRepositoryMock);

        await viewModel.logout();

        verifyEveryFunctionsInLogout();
      });
    });
  });
}
