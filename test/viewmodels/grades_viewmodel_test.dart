// Package imports:
import 'package:ets_api_clients/models.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

// Project imports:
import 'package:notredame/core/managers/course_repository.dart';
import 'package:notredame/core/managers/settings_manager.dart';
import 'package:notredame/core/services/navigation_service.dart';
import 'package:notredame/core/viewmodels/grades_viewmodel.dart';
import '../helpers.dart';
import '../mock/managers/course_repository_mock.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late AppIntl intl;

  late CourseRepositoryMock courseRepositoryMock;

  late GradesViewModel viewModel;

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
      courseRepositoryMock = setupCourseRepositoryMock();
      intl = await setupAppIntl();
      setupSettingsManagerMock();
      setupNavigationServiceMock();

      viewModel = GradesViewModel(intl: intl);
    });

    tearDown(() {
      unregister<CourseRepository>();
      unregister<NavigationService>();
      unregister<SettingsManager>();
    });

    group('futureToRun -', () {
      test('first load from cache than call SignetsAPI to get the courses',
          () async {
        CourseRepositoryMock.stubGetCourses(courseRepositoryMock,
            toReturn: courses, fromCacheOnly: true);
        CourseRepositoryMock.stubGetCourses(courseRepositoryMock,
            toReturn: courses);
        CourseRepositoryMock.stubCourses(courseRepositoryMock,
            toReturn: courses);

        expect(await viewModel.futureToRun(), coursesBySession);

        await untilCalled(courseRepositoryMock.courses);

        expect(viewModel.coursesBySession, coursesBySession);
        expect(viewModel.sessionOrder, sessionOrder);

        verifyInOrder([
          courseRepositoryMock.getCourses(fromCacheOnly: true),
          courseRepositoryMock.getCourses(),
          courseRepositoryMock.courses,
          courseRepositoryMock.courses
        ]);

        verifyNoMoreInteractions(courseRepositoryMock);
      });

      test('Signets throw an error while trying to get courses', () async {
        CourseRepositoryMock.stubGetCourses(courseRepositoryMock,
            toReturn: courses, fromCacheOnly: true);
        CourseRepositoryMock.stubGetCoursesException(courseRepositoryMock);
        CourseRepositoryMock.stubCourses(courseRepositoryMock,
            toReturn: courses);
        setupFlutterToastMock();

        expect(await viewModel.futureToRun(), coursesBySession,
            reason:
                "Even if SignetsAPI call fails, should return the cache contents");

        await untilCalled(courseRepositoryMock.getCourses());

        expect(viewModel.coursesBySession, coursesBySession);
        expect(viewModel.sessionOrder, sessionOrder);

        verifyInOrder([
          courseRepositoryMock.getCourses(fromCacheOnly: true),
          courseRepositoryMock.getCourses()
        ]);

        verifyNoMoreInteractions(courseRepositoryMock);
      });
    });

    group('refresh -', () {
      test(
          'Call SignetsAPI to get the courses than reload the coursesBySession',
          () async {
        CourseRepositoryMock.stubGetCourses(courseRepositoryMock,
            toReturn: courses);
        CourseRepositoryMock.stubCourses(courseRepositoryMock,
            toReturn: courses);

        await viewModel.refresh();

        expect(viewModel.coursesBySession, coursesBySession);
        expect(viewModel.sessionOrder, sessionOrder);

        verifyInOrder([
          courseRepositoryMock.getCourses(),
          courseRepositoryMock.courses,
          courseRepositoryMock.courses
        ]);

        verifyNoMoreInteractions(courseRepositoryMock);
      });

      test('Signets throw an error', () async {
        CourseRepositoryMock.stubGetCourses(courseRepositoryMock,
            toReturn: courses, fromCacheOnly: true);
        CourseRepositoryMock.stubGetCourses(courseRepositoryMock);
        CourseRepositoryMock.stubCourses(courseRepositoryMock,
            toReturn: courses);
        setupFlutterToastMock();

        // Populate the list of courses
        await viewModel.futureToRun();
        expect(viewModel.coursesBySession, coursesBySession);
        expect(viewModel.sessionOrder, sessionOrder);

        reset(courseRepositoryMock);
        CourseRepositoryMock.stubCourses(courseRepositoryMock,
            toReturn: courses);
        CourseRepositoryMock.stubGetCoursesException(courseRepositoryMock);

        await viewModel.refresh();

        expect(viewModel.coursesBySession, coursesBySession,
            reason:
                "The list of courses should not change even when an error occurs");
        expect(viewModel.sessionOrder, sessionOrder);

        verifyInOrder([
          courseRepositoryMock.getCourses(),
          courseRepositoryMock.courses,
          courseRepositoryMock.courses
        ]);

        verifyNoMoreInteractions(courseRepositoryMock);
      });
    });
  });
}
