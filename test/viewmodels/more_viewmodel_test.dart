// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mockito/mockito.dart';
import 'package:notredame/core/managers/course_repository.dart';

// SERVICES / MANAGERS
import 'package:notredame/core/managers/user_repository.dart';
import 'package:notredame/core/models/course_activity.dart';
import 'package:notredame/core/models/session.dart';
import 'package:notredame/core/services/navigation_service.dart';
import 'package:notredame/core/managers/cache_manager.dart';
import 'package:notredame/core/managers/settings_manager.dart';
import 'package:notredame/core/services/preferences_service.dart';

// VIEW MODEL
import 'package:notredame/core/viewmodels/more_viewmodel.dart';

// CONSTANTS
import 'package:notredame/core/constants/router_paths.dart';
import 'package:oktoast/oktoast.dart';

// OTHER
import '../helpers.dart';
import '../mock/managers/cache_manager_mock.dart';
import '../mock/managers/course_repository_mock.dart';
import '../mock/managers/settings_manager_mock.dart';
import '../mock/managers/user_repository_mock.dart';

void main() {
  CacheManagerMock cacheManagerMock;
  SettingsManagerMock settingsManagerMock;
  CourseRepositoryMock courseRepositoryMock;
  PreferencesService preferenceService;
  UserRepositoryMock userRepositoryMock;
  NavigationService navigationService;
  AppIntl appIntl;

  MoreViewModel viewModel;

  final List<Session> sessions = [
    Session(
        name: 'Hivers 2XXX',
        shortName: 'H1',
        deadlineCancellationASEQ: null,
        deadlineCancellationWithoutRefundNewStudent: null,
        deadlineCancellationWithRefund: null,
        deadlineCancellationWithRefundNewStudent: null,
        deadlineRegistration: null,
        startDate: null,
        startDateCancellationWithoutRefundNewStudent: null,
        startDateCancellationWithRefund: null,
        startDateRegistration: null,
        endDate: null,
        endDateCourses: null),
  ];

  final List<CourseActivity> coursesActivities = [
    CourseActivity(
        courseName: 'sample course',
        courseGroup: '',
        activityName: '',
        activityDescription: '',
        activityLocation: '',
        startDateTime: null,
        endDateTime: null),
  ];
  group('MoreViewModel - ', () {
    setUp(() async {
      cacheManagerMock = setupCacheManagerMock() as CacheManagerMock;
      settingsManagerMock = setupSettingsManagerMock() as SettingsManagerMock;
      courseRepositoryMock =
          setupCourseRepositoryMock() as CourseRepositoryMock;
      preferenceService = setupPreferencesServiceMock();
      userRepositoryMock = setupUserRepositoryMock() as UserRepositoryMock;
      navigationService = setupNavigationServiceMock();
      setupLogger();
      appIntl = await setupAppIntl();

      viewModel = MoreViewModel(intl: appIntl);

      CourseRepositoryMock.stubSessions(courseRepositoryMock,
          toReturn: sessions);
      CourseRepositoryMock.stubCoursesActivities(courseRepositoryMock,
          toReturn: coursesActivities);
    });

    tearDown(() {
      unregister<CacheManager>();
      unregister<SettingsManager>();
      unregister<CourseRepository>();
      unregister<PreferencesService>();
      unregister<UserRepository>();
      unregister<NavigationService>();
    });

    group('logout - ', () {
      test('If cache manager is emptied', () async {
        await viewModel.logout();
        verify(cacheManagerMock.empty());
      });

      test('If preference manager is clear', () async {
        await viewModel.logout();
        verify(preferenceService.clear());
      });

      test('If user repository is logOut is called', () async {
        await viewModel.logout();
        verify(userRepositoryMock.logOut());
      });

      test('If the cache for courses activities and sessions is cleared',
          () async {
        await viewModel.logout();
        expect(courseRepositoryMock.sessions.length, 0);
        expect(courseRepositoryMock.coursesActivities.length, 0);
      });

      test('If the navigationService is rerouted to login', () async {
        await viewModel.logout();
        verify(navigationService.pop());
        verify(navigationService.pushNamedAndRemoveUntil(RouterPaths.login));
      });
    });
    group('sendFeedback - ', () {
      test('If the navigationService is rerouted to login', () async {
        await viewModel.sendFeedback();
        verify(navigationService.pop());
        verify(navigationService.pushNamedAndRemoveUntil(RouterPaths.login));
      });
    });
  });
}
