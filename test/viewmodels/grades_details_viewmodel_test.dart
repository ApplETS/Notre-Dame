// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';

// MODELS
import 'package:notredame/core/models/course_summary.dart';
import 'package:notredame/core/models/evaluation.dart' as model;

// VIEWMODEL
import 'package:notredame/core/viewmodels/grades_details_viewmodel.dart';

// MANAGER
import 'package:notredame/core/models/course.dart';
import 'package:notredame/core/managers/course_repository.dart';
import '../mock/managers/course_repository_mock.dart';

// HELPERS
import '../helpers.dart';

void main() {
  GradesDetailsViewModel viewModel;
  CourseRepository courseRepository;
  WidgetsFlutterBinding.ensureInitialized();

  final CourseSummary courseSummary = CourseSummary(
    currentMark: 5,
    currentMarkInPercent: 50,
    markOutOf: 10,
    passMark: 6,
    standardDeviation: 2.3,
    median: 4.5,
    percentileRank: 99,
    evaluations: [
      model.Evaluation(
        courseGroup: "02",
        title: "Laboratoire 1",
        weight: 10,
        teacherMessage: null,
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
      model.Evaluation(
        courseGroup: "02",
        title: "Laboratoire 2",
        weight: 10,
        teacherMessage: null,
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
      courseRepository = setupCourseRepositoryMock();
      final AppIntl intl = await setupAppIntl();

      viewModel = GradesDetailsViewModel(intl: intl, course: courseWithoutSummary);
    });

    tearDown(() {
      unregister<CourseRepository>();
    });

    group('FutureToRun - -', () {
      test('SignetsAPI gets the summary', () async {
        CourseRepositoryMock.stubGetCourseSummary(courseRepository as CourseRepositoryMock, courseWithoutSummary,
            toReturn: courseWithSummary);

        await viewModel.futureToRun();

        expect(viewModel.course, courseWithSummary);
      });

      test('Signets raised an exception while trying to recover summary', () async {
        CourseRepositoryMock.stubGetCourseSummaryException(
            courseRepository as CourseRepositoryMock, courseWithoutSummary);

        await viewModel.futureToRun();

        expect(viewModel.course, courseWithoutSummary);
      });
    });

    group('refresh -', () {
      test('Call SignetsAPI to get the summary of the course selected', () async {
        CourseRepositoryMock.stubGetCourseSummary(courseRepository as CourseRepositoryMock, courseWithoutSummary,
            toReturn: courseWithSummary);

        await viewModel.refresh();

        expect(viewModel.course, courseWithSummary);
      });
    });
  });
}
