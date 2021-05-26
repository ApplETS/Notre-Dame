// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mockito/mockito.dart';

// MODELS
import 'package:notredame/core/models/course.dart';
import 'package:notredame/core/models/course_summary.dart';

// SERVICE
import 'package:notredame/core/services/navigation_service.dart';

// OTHERS
import 'package:notredame/core/constants/router_paths.dart';

// WIDGET
import 'package:notredame/ui/widgets/grade_button.dart';

// HELPERS
import '../../helpers.dart';

void main() {
  AppIntl intl;
  NavigationService _navigationService;

  final Course courseWithGrade = Course(
      acronym: 'GEN101',
      group: '02',
      session: 'H2020',
      programCode: '999',
      grade: 'C+',
      numberOfCredits: 3,
      title: 'Cours générique');

  final Course courseWithSummary = Course(
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
          evaluations: []));

  final Course gradesNotAvailable = Course(
      acronym: 'GEN101',
      group: '02',
      session: 'H2020',
      programCode: '999',
      numberOfCredits: 3,
      title: 'Cours générique');

  group("GradeButton -", () {
    setUp(() async {
      intl = await setupAppIntl();
      setupNavigationServiceMock();
      _navigationService = setupNavigationServiceMock();
    });

    tearDown(() {
      unregister<NavigationService>();
    });

    group("UI -", () {
      testWidgets("Display acronym of the course and the current grade",
          (WidgetTester tester) async {
        await tester
            .pumpWidget(localizedWidget(child: GradeButton(courseWithGrade)));
        await tester.pumpAndSettle();

        expect(find.text(courseWithGrade.acronym), findsOneWidget);
        expect(find.text(courseWithGrade.grade), findsOneWidget);
      });

      testWidgets("Grade not available and summary is loaded.",
          (WidgetTester tester) async {
        await tester
            .pumpWidget(localizedWidget(child: GradeButton(courseWithSummary)));
        await tester.pumpAndSettle();

        expect(find.text(courseWithGrade.acronym), findsOneWidget);
        expect(
            find.text(intl.grades_grade_in_percentage(
                courseWithSummary.summary.currentMarkInPercent.round())),
            findsOneWidget,
            reason:
                'There is no grade available and the course summary exists so the '
                'current mark in percentage should be displayed');
      });

      testWidgets("Grade and summary not available.",
          (WidgetTester tester) async {
        await tester.pumpWidget(
            localizedWidget(child: GradeButton(gradesNotAvailable)));
        await tester.pumpAndSettle();

        expect(find.text(courseWithGrade.acronym), findsOneWidget);
        expect(find.text(intl.grades_not_available), findsOneWidget,
            reason:
                'There is no grade available and the course summary doesnt exists '
                'so "N/A" should be displayed');
      });
    });

    group('navigate when tapped to grade button - ', () {
      testWidgets('Display acronym of the course and the current grade ', (WidgetTester tester) async {
        await tester
            .pumpWidget(localizedWidget(child: GradeButton(courseWithGrade)));
        await tester.pumpAndSettle();

        await tester.tap(find.text(courseWithGrade.acronym));

        verify(_navigationService.pushNamed(RouterPaths.gradeDetails, arguments: courseWithGrade));
      });

      testWidgets('Grade not available and summary is loaded ', (WidgetTester tester) async {
        await tester.pumpWidget(
            localizedWidget(child: GradeButton(courseWithSummary)));
        await tester.pumpAndSettle();

        await tester.tap(find.text(courseWithGrade.acronym));

        verify(_navigationService.pushNamed(RouterPaths.gradeDetails, arguments: courseWithSummary));
      });

      testWidgets('Grade and summary not available. ', (WidgetTester tester) async {
        await tester.pumpWidget(
            localizedWidget(child: GradeButton(gradesNotAvailable)));
        await tester.pumpAndSettle();

        await tester.tap(find.text(courseWithGrade.acronym));

        verify(_navigationService.pushNamed(RouterPaths.gradeDetails, arguments: gradesNotAvailable));
      });

    });
  });
}
