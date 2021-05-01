// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mockito/mockito.dart';

// MANAGER
import 'package:notredame/core/managers/course_repository.dart';
import 'package:notredame/core/managers/settings_manager.dart';

// MODEL
import 'package:notredame/core/models/course.dart';
import 'package:notredame/core/models/session.dart';
import 'package:notredame/core/viewmodels/dashboard_viewmodel.dart';

import '../helpers.dart';
import '../mock/managers/course_repository_mock.dart';
import '../mock/managers/settings_manager_mock.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  CourseRepository courseRepository;
  AppIntl intl;
  DashboardViewModel viewModel;
  SettingsManager settingsManager;

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

  final Course courseSummer3 = Course(
      acronym: 'GEN101',
      group: '02',
      session: 'É2020',
      programCode: '999',
      grade: 'C+',
      numberOfCredits: 3,
      title: 'Cours générique');

  final Course courseSummer4 = Course(
      acronym: 'GEN101',
      group: '02',
      session: 'É2020',
      programCode: '999',
      grade: 'C+',
      numberOfCredits: 3,
      title: 'Cours générique');

  final Course courseSummer5 = Course(
      acronym: 'É2020',
      group: '01',
      session: 's.o.',
      programCode: '999',
      grade: 'K',
      numberOfCredits: 3,
      title: 'Cours générique');


  final courses = [courseSummer, courseSummer2];
  final coursesCache = [courseSummer3, courseSummer4,courseSummer5];

  final session = [session1];

  group('GradesViewModel -', () {
    setUp(() async {
      courseRepository = setupCourseRepositoryMock();
      intl = await setupAppIntl();
      setupFlutterToastMock();

      settingsManager = setupSettingsManagerMock();
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
            courseRepository as CourseRepositoryMock, toReturn: session);

        CourseRepositoryMock.stubGetCourses(
            courseRepository as CourseRepositoryMock,
            toReturn: courses,
            fromCacheOnly: true);

        CourseRepositoryMock.stubGetCourses(
            courseRepository as CourseRepositoryMock,
            toReturn: courses);

        expect(await viewModel.futureToRunGrades(),courses);
        await untilCalled(courseRepository.courses);

        expect(viewModel.courses, courses);

        verifyInOrder([
          courseRepository.getCourses(fromCacheOnly: true),
          courseRepository.getCourses(),
          courseRepository.courses
        ]);

        verifyNoMoreInteractions(courseRepository);
      });


    });
  });
}
