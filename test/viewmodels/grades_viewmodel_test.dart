// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mockito/mockito.dart';

// MANAGER
import 'package:notredame/core/managers/course_repository.dart';

// SERVICES
import 'package:notredame/core/services/navigation_service.dart';

// MODEL
import 'package:notredame/core/models/course.dart';
import 'package:notredame/core/viewmodels/grades_viewmodel.dart';

// CONSTANTS
import 'package:notredame/core/constants/router_paths.dart';

// OTHER
import '../helpers.dart';

// MOCKS
import '../mock/managers/course_repository_mock.dart';
import '../mock/services/networking_service_mock.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  NavigationService navigationService;
  CourseRepository courseRepository;
  NetworkingServiceMock networkingService;
  AppIntl intl;
  GradesViewModel viewModel;

  final Course courseSummer = Course(
      acronym: 'GEN101',
      group: '02',
      session: 'É2020',
      programCode: '999',
      grade: 'C+',
      numberOfCredits: 3,
      title: 'Cours générique');

  final Course courseSummer2 = Course(
      acronym: 'GEN101',
      group: '02',
      session: 'É2019',
      programCode: '999',
      grade: 'C+',
      numberOfCredits: 3,
      title: 'Cours générique');

  final Course courseWinter = Course(
      acronym: 'GEN101',
      group: '02',
      session: 'H2020',
      programCode: '999',
      grade: 'C+',
      numberOfCredits: 3,
      title: 'Cours générique');

  final Course courseFall = Course(
      acronym: 'GEN101',
      group: '02',
      session: 'A2020',
      programCode: '999',
      grade: 'C+',
      numberOfCredits: 3,
      title: 'Cours générique');

  final Course courseWithoutSession = Course(
      acronym: 'GEN103',
      group: '01',
      session: 's.o.',
      programCode: '999',
      grade: 'K',
      numberOfCredits: 3,
      title: 'Cours générique');

  final sessionOrder = ['A2020', 'É2020', 'H2020', 'É2019', 's.o.'];
  final coursesBySession = {
    'A2020': [courseFall],
    'É2020': [courseSummer],
    'H2020': [courseWinter],
    'É2019': [courseSummer2],
    's.o.': [courseWithoutSession]
  };

  final courses = [
    courseSummer,
    courseSummer2,
    courseWinter,
    courseFall,
    courseWithoutSession
  ];

  group('GradesViewModel -', () {
    setUp(() async {
      courseRepository = setupCourseRepositoryMock();
      networkingService = setupNetworkingServiceMock() as NetworkingServiceMock;
      intl = await setupAppIntl();
      navigationService = setupNavigationServiceMock();
      setupFlutterToastMock();

      // Stub to simulate that the user has an active internet connection
      NetworkingServiceMock.stubHasConnectivity(networkingService);

      viewModel = GradesViewModel(intl: intl);
    });

    tearDown(() {
      unregister<CourseRepository>();
      unregister<NavigationService>();
      unregister<NetworkingServiceMock>();
      tearDownFlutterToastMock();
    });

    group('futureToRun -', () {
      test('first load from cache than call SignetsAPI to get the courses',
          () async {
        CourseRepositoryMock.stubGetCourses(
            courseRepository as CourseRepositoryMock,
            toReturn: courses,
            fromCacheOnly: true);
        CourseRepositoryMock.stubGetCourses(
            courseRepository as CourseRepositoryMock,
            toReturn: courses);
        CourseRepositoryMock.stubCourses(
            courseRepository as CourseRepositoryMock,
            toReturn: courses);

        expect(await viewModel.futureToRun(), coursesBySession);

        await untilCalled(courseRepository.courses);

        expect(viewModel.coursesBySession, coursesBySession);
        expect(viewModel.sessionOrder, sessionOrder);

        verifyInOrder([
          courseRepository.getCourses(fromCacheOnly: true),
          courseRepository.getCourses(),
          courseRepository.courses
        ]);

        verifyNoMoreInteractions(courseRepository);
      });

      test('Signets throw an error while trying to get courses', () async {
        CourseRepositoryMock.stubGetCourses(
            courseRepository as CourseRepositoryMock,
            toReturn: courses,
            fromCacheOnly: true);
        CourseRepositoryMock.stubGetCoursesException(
            courseRepository as CourseRepositoryMock,
            fromCacheOnly: false);
        CourseRepositoryMock.stubCourses(
            courseRepository as CourseRepositoryMock,
            toReturn: courses);

        expect(await viewModel.futureToRun(), coursesBySession,
            reason:
                "Even if SignetsAPI call fails, should return the cache contents");

        await untilCalled(courseRepository.getCourses());

        expect(viewModel.coursesBySession, coursesBySession);
        expect(viewModel.sessionOrder, sessionOrder);

        verifyInOrder([
          courseRepository.getCourses(fromCacheOnly: true),
          courseRepository.getCourses()
        ]);

        verifyNoMoreInteractions(courseRepository);
      });
    });

    group('refresh -', () {
      test(
          'Call SignetsAPI to get the courses than reload the coursesBySession',
          () async {
        CourseRepositoryMock.stubGetCourses(
            courseRepository as CourseRepositoryMock,
            toReturn: courses);
        CourseRepositoryMock.stubCourses(
            courseRepository as CourseRepositoryMock,
            toReturn: courses);

        await viewModel.refresh();

        expect(viewModel.coursesBySession, coursesBySession);
        expect(viewModel.sessionOrder, sessionOrder);

        verifyInOrder(
            [courseRepository.getCourses(), courseRepository.courses]);

        verifyNoMoreInteractions(courseRepository);
      });

      test('Signets throw an error', () async {
        CourseRepositoryMock.stubGetCourses(
            courseRepository as CourseRepositoryMock,
            toReturn: courses,
            fromCacheOnly: true);
        CourseRepositoryMock.stubGetCourses(
            courseRepository as CourseRepositoryMock,
            fromCacheOnly: false);
        CourseRepositoryMock.stubCourses(
            courseRepository as CourseRepositoryMock,
            toReturn: courses);

        // Populate the list of courses
        await viewModel.futureToRun();
        expect(viewModel.coursesBySession, coursesBySession);
        expect(viewModel.sessionOrder, sessionOrder);

        reset(courseRepository);
        CourseRepositoryMock.stubCourses(
            courseRepository as CourseRepositoryMock,
            toReturn: courses);
        CourseRepositoryMock.stubGetCoursesException(
            courseRepository as CourseRepositoryMock,
            fromCacheOnly: false);

        await viewModel.refresh();

        expect(viewModel.coursesBySession, coursesBySession,
            reason:
                "The list of courses should not change even when an error occurs");
        expect(viewModel.sessionOrder, sessionOrder);

        verifyInOrder(
            [courseRepository.getCourses(), courseRepository.courses]);

        verifyNoMoreInteractions(courseRepository);
      });
    });

  });
}
