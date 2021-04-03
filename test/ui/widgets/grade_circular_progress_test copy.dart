// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// MODELS
import 'package:notredame/core/models/course.dart';
import 'package:notredame/core/models/course_summary.dart';
import 'package:notredame/core/models/evaluation.dart' as model;

// SERVICE
import 'package:notredame/core/services/navigation_service.dart';

// HELPERS
import '../../helpers.dart';

void main() {
  AppIntl intl;

  final Course courseWithSummaryAndEvaluations = Course(
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

  group("GradeButton -", () {
    setUp(() async {
      intl = await setupAppIntl();
    });

    tearDown(() {
      unregister<NavigationService>();
    });

    group("UI -", () {
      testWidgets("Display the grade of the evaluation", (WidgetTester tester) async {});
    });
  });
}
