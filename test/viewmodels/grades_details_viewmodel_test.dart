// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// MANAGER
import 'package:notredame/core/models/course.dart';
import 'package:notredame/core/managers/course_repository.dart';

// MODELS
import 'package:notredame/core/models/course_summary.dart';
import 'package:notredame/core/models/evaluation.dart' as model;

// VIEWMODEL
import 'package:notredame/core/viewmodels/grades_details_viewmodel.dart';

// HELPERS
import '../helpers.dart';

GradesDetailsViewModel viewModel;

void main() {
  CourseRepository courseRepository;

  group("GradesDetailsViewModel - ", () {
    final Course course = Course(
      acronym: 'GEN101',
      group: '02',
      session: 'H2020',
      programCode: '999',
      numberOfCredits: 3,
      title: 'Cours générique',
      summary: CourseSummary(
        currentMark: 5,
        currentMarkInPercent: 50,
        markOutOf: 10,
        passMark: 6,
        standardDeviation: 2.3,
        median: 4.5,
        percentileRank: 99,
        evaluations: [
          model.Evaluation(
            title: "Laboratoire 1",
            weight: 10,
            teacherMessage: null,
            ignore: false,
            mark: 24,
            passMark: 25,
            standardDeviation: 2,
            median: 80,
            percentileRank: 5,
            targetDate: DateTime(2021, 02, 02),
          ),
          model.Evaluation(
            title: "Laboratoire 2",
            weight: 10,
            teacherMessage: null,
            ignore: false,
            mark: 24,
            passMark: 25,
            standardDeviation: 2,
            median: 80,
            percentileRank: 5,
            targetDate: DateTime(2021, 02, 02),
          ),
          model.Evaluation(
            title: "Laboratoire Intra",
            weight: 10,
            teacherMessage: null,
            ignore: false,
            mark: 24,
            passMark: 25,
            standardDeviation: 2,
            median: 80,
            percentileRank: 5,
            targetDate: DateTime(2021, 02, 02),
          ),
        ],
      ),
    );

    setUp(() async {
      // Setting up mocks
      courseRepository = setupCourseRepositoryMock();
      final AppIntl intl = await setupAppIntl();

      viewModel = GradesDetailsViewModel(intl: intl, course: course);
    });

    tearDown(() {
      unregister<CourseRepository>();
    });
  });

  group('futureToRun -', () {
    test('first load from cache than call SignetsAPI to get the summary', () async {});

    test('Signets throw an error while trying to get summary', () async {});
  });

  group('refresh -', () {
    test('Call SignetsAPI to get the summary of the course selected', () async {});
  });
}
