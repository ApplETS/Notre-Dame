// FLUTTER / DART / THIRD-PARTIES
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as image;
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mockito/mockito.dart';

// SERVICES / MANAGERS
import 'package:notredame/core/managers/user_repository.dart';
import 'package:notredame/core/models/course.dart';
import 'package:notredame/core/models/course_activity.dart';
import 'package:notredame/core/models/session.dart';
import 'package:notredame/core/services/github_api.dart';
import 'package:notredame/core/services/navigation_service.dart';
import 'package:notredame/core/managers/cache_manager.dart';
import 'package:notredame/core/managers/settings_manager.dart';
import 'package:notredame/core/services/preferences_service.dart';
import 'package:notredame/core/managers/course_repository.dart';
import 'package:notredame/core/utils/cache_exception.dart';

// VIEW MODEL
import 'package:notredame/core/viewmodels/more_viewmodel.dart';

// CONSTANTS
import 'package:notredame/core/constants/router_paths.dart';

// OTHER
import '../helpers.dart';
import '../mock/managers/cache_manager_mock.dart';
import '../mock/managers/course_repository_mock.dart';
import '../mock/managers/settings_manager_mock.dart';
import '../mock/managers/user_repository_mock.dart';
import '../mock/services/github_api_mock.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  CacheManagerMock cacheManagerMock;
  SettingsManagerMock settingsManagerMock;
  CourseRepositoryMock courseRepositoryMock;
  PreferencesService preferenceService;
  UserRepositoryMock userRepositoryMock;
  NavigationService navigationService;
  GithubApiMock githubApiMock;

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

  final List<Course> courses = [
    Course(
        acronym: "ABC123",
        title: "testCourse",
        group: "09",
        session: "H2021",
        programCode: "XYZ",
        numberOfCredits: 3),
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
      githubApiMock = setupGithubApiMock() as GithubApiMock;
      setupLogger();

      viewModel = MoreViewModel();

      CourseRepositoryMock.stubCourses(courseRepositoryMock, toReturn: courses);
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
      unregister<GithubApi>();
    });

    group('logout - ', () {
      test('If the correct function have been called when logout occur',
          () async {
        await viewModel.logout();

        // Check if the cacheManager has been emptied out
        verify(cacheManagerMock.empty());

        // Check if preference manager is clear
        verify(preferenceService.clear());

        // Check if user repository logOut is called
        verify(userRepositoryMock.logOut());

        // Check if the settings manager has reset lang and theme and notified his listener
        verify(settingsManagerMock.resetLanguageAndThemeMode());

        expect(courseRepositoryMock.sessions.length, 0,
            reason: 'has emptied out the sessions list');
        expect(courseRepositoryMock.coursesActivities.length, 0,
            reason: 'has emptied out the courseActivities list');
        expect(courseRepositoryMock.courses.length, 0,
            reason: 'has emptied out the courses list');

        // Check if navigation has been rerouted to login page
        verify(navigationService.pop());
        verify(navigationService.pushNamedAndRemoveUntil(RouterPaths.login));
      });

      test('If an error occur from the cache manager', () async {
        CacheManagerMock.stubEmptyException(cacheManagerMock);

        expect(() async => viewModel.logout(),
            throwsA(isInstanceOf<CacheException>()));
      });
    });

    group('sendFeedback - ', () {
      Uint8List screenshotData;

      setUp(() async {
        final ByteData bytes = await rootBundle
            .load('packages/notredame/assets/images/github_white.png');
        screenshotData = bytes.buffer.asUint8List();
      });

      test('If the file uploaded matches', () async {
        final File file = File('bugReportTest.png');
        GithubApiMock.stubLocalFile(githubApiMock, file);

        await file.writeAsBytes(image.encodePng(
            image.copyResize(image.decodeImage(screenshotData), width: 307)));

        await viewModel.sendFeedback('Notre-Dame bug report', screenshotData);

        verify(githubApiMock.uploadFileToGithub(
          filePath: file.path.replaceFirst(
              'storage/emulated/0/Android/data/ca.etsmtl.applets.notredame/files/',
              ''),
          file: file,
        ));
      });

      test('If the github issue has been created', () async {
        final File file = File('bugReportTest.png');
        GithubApiMock.stubLocalFile(githubApiMock, file);

        await viewModel.sendFeedback('Notre-Dame bug report', screenshotData);

        verify(githubApiMock.createGithubIssue(
            feedbackText: 'Notre-Dame bug report',
            fileName: file.path.replaceFirst(
                'storage/emulated/0/Android/data/ca.etsmtl.applets.notredame/files/',
                '')));
      });
    });
  });
}
