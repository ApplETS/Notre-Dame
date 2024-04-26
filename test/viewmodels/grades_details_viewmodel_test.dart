// Package imports:
import 'package:ets_api_clients/models.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

// Project imports:
import 'package:notredame/core/managers/course_repository.dart';
import 'package:notredame/core/managers/settings_manager.dart';
import 'package:notredame/core/viewmodels/grades_details_viewmodel.dart';
import '../helpers.dart';
import '../mock/managers/course_repository_mock.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late AppIntl intl;

  late CourseRepositoryMock courseRepositoryMock;

  late GradesDetailsViewModel viewModel;

  final CourseSummary courseSummary = CourseSummary(
    currentMark: 5,
    currentMarkInPercent: 50,
    markOutOf: 10,
    passMark: 6,
    standardDeviation: 2.3,
    median: 4.5,
    percentileRank: 99,
    evaluations: [
      CourseEvaluation(
        courseGroup: "02",
        title: "Laboratoire 1",
        weight: 10,
        teacherMessage: '',
        ignore: false,
        mark: 24,
        correctedEvaluationOutOf: "35",
        passMark: 25,
        standardDeviation: 2,
        median: 80,
        percentileRank: 5,
        published: true,
        targetDate: DateTime(2021, 01, 05),
      ),
      CourseEvaluation(
        courseGroup: "02",
        title: "Laboratoire 2",
        weight: 10,
        teacherMessage: '',
        ignore: false,
        mark: 24,
        correctedEvaluationOutOf: "30",
        passMark: 25,
        standardDeviation: 2,
        median: 80,
        percentileRank: 5,
        published: true,
        targetDate: DateTime(2021, 02, 02),
      ),
    ],
  );

  final Course courseWithSummary = Course(
      acronym: 'GEN101',
      group: '02',
      session: 'H2020',
      programCode: '999',
      numberOfCredits: 3,
      title: 'Cours générique',
      summary: courseSummary);

  final Course courseWithoutSummary = Course(
    acronym: 'GEN101',
    group: '02',
    session: 'H2020',
    programCode: '999',
    numberOfCredits: 3,
    title: 'Cours générique',
  );

  group("GradesDetailsViewModel - ", () {
    setUp(() async {
      // Setting up mocks
      courseRepositoryMock = setupCourseRepositoryMock();
      intl = await setupAppIntl();
      setupSettingsManagerMock();

      viewModel =
          GradesDetailsViewModel(course: courseWithoutSummary, intl: intl);
    });

    tearDown(() {
      unregister<CourseRepository>();
      unregister<SettingsManager>();
    });

    group('FutureToRun - -', () {
      test('SignetsAPI gets the summary', () async {
        CourseRepositoryMock.stubGetCourseSummary(
            courseRepositoryMock, courseWithoutSummary,
            toReturn: courseWithSummary);

        await viewModel.futureToRun();

        expect(viewModel.course, courseWithSummary);
      });

      test('Signets raised an exception while trying to recover course',
          () async {
        setupFlutterToastMock();
        CourseRepositoryMock.stubGetCourseSummaryException(
            courseRepositoryMock, courseWithoutSummary);
        await viewModel.futureToRun();

        expect(viewModel.course, courseWithoutSummary);
      });
    });

    group('refresh -', () {
      test('Call SignetsAPI to get the summary of the course selected',
          () async {
        setupFlutterToastMock();
        CourseRepositoryMock.stubGetCourseSummary(
            courseRepositoryMock, courseWithoutSummary,
            toReturn: courseWithSummary);

        await viewModel.refresh();

        expect(viewModel.course, courseWithSummary);
      });

      test('Signets throw an error', () async {
        CourseRepositoryMock.stubGetCourseSummaryException(
            courseRepositoryMock, courseWithoutSummary);
        setupFlutterToastMock();
        await viewModel.refresh();

        expect(viewModel.course, courseWithoutSummary);

        verify(courseRepositoryMock.getCourseSummary(viewModel.course));

        verifyNoMoreInteractions(courseRepositoryMock);
      });
    });
  });
}
