// Package imports:
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

// Project imports:
import 'package:notredame/data/repositories/course_repository.dart';
import 'package:notredame/data/repositories/settings_repository.dart';
import 'package:notredame/data/repositories/user_repository.dart';
import 'package:notredame/data/services/analytics_service.dart';
import 'package:notredame/data/services/auth_service.dart';
import 'package:notredame/data/services/cache_service.dart';
import 'package:notredame/data/services/navigation_service.dart';
import 'package:notredame/data/services/preferences_service.dart';
import 'package:notredame/data/services/remote_config_service.dart';
import 'package:notredame/data/services/signets-api/models/course.dart';
import 'package:notredame/data/services/signets-api/models/course_activity.dart';
import 'package:notredame/data/services/signets-api/models/session.dart';
import 'package:notredame/domain/constants/preferences_flags.dart';
import 'package:notredame/domain/constants/router_paths.dart';
import 'package:notredame/ui/more/view_model/more_viewmodel.dart';
import '../../../data/mocks/repositories/course_repository_mock.dart';
import '../../../data/mocks/repositories/settings_repository_mock.dart';
import '../../../data/mocks/repositories/user_repository_mock.dart';
import '../../../data/mocks/services/auth_service_mock.dart';
import '../../../data/mocks/services/cache_service_mock.dart';
import '../../../data/mocks/services/navigation_service_mock.dart';
import '../../../data/mocks/services/preferences_service_mock.dart';
import '../../../data/mocks/services/remote_config_service_mock.dart';
import '../../../helpers.dart';

void main() {
  // Needed to support FlutterToast.
  TestWidgetsFlutterBinding.ensureInitialized();

  late CacheServiceMock cacheManagerMock;
  late SettingsRepositoryMock settingsManagerMock;
  late CourseRepositoryMock courseRepositoryMock;
  late PreferencesServiceMock preferenceServiceMock;
  late RemoteConfigServiceMock remoteConfigServiceMock;
  late UserRepositoryMock userRepositoryMock;
  late NavigationServiceMock navigationServiceMock;
  late AuthServiceMock authServiceMock;

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
      authServiceMock.signOut(),
      // Check if the settings manager has reset lang and theme and notified his listener
      settingsManagerMock.resetLanguageAndThemeMode(),
      settingsManagerMock.setBool(PreferencesFlag.isLoggedIn, false),
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
          RouterPaths.startup, RouterPaths.chooseLanguage)
    ]);

    verifyNoMoreInteractions(navigationServiceMock);
  }

  group('MoreViewModel - ', () {
    setUp(() async {
      setupAnalyticsServiceMock();
      cacheManagerMock = setupCacheManagerMock();
      settingsManagerMock = setupSettingsRepositoryMock();
      courseRepositoryMock = setupCourseRepositoryMock();
      remoteConfigServiceMock = setupRemoteConfigServiceMock();
      preferenceServiceMock = setupPreferencesServiceMock();
      userRepositoryMock = setupUserRepositoryMock();
      navigationServiceMock = setupNavigationServiceMock();
      authServiceMock = setupAuthServiceMock();
      appIntl = await setupAppIntl();

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
      unregister<CacheService>();
      unregister<SettingsRepository>();
      unregister<CourseRepository>();
      unregister<RemoteConfigService>();
      unregister<PreferencesService>();
      unregister<UserRepository>();
      unregister<NavigationService>();
      unregister<AuthService>();
      unregister<AppIntl>();
    });

    group('logout - ', () {
      test('If the correct function have been called when logout occur',
          () async {
        RemoteConfigServiceMock.stubGetPrivacyPolicyEnabled(
            remoteConfigServiceMock,
            toReturn: false);
        setupFlutterToastMock();
        AuthServiceMock.stubSignOut(authServiceMock);

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
        CacheServiceMock.stubEmptyException(cacheManagerMock);
        UserRepositoryMock.stubLogOut(userRepositoryMock);

        await viewModel.logout();

        verifyEveryFunctionsInLogout();
      });
    });
  });
}
