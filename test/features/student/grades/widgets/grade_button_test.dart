// Package imports:
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

// Project imports:
import 'package:notredame/constants/preferences_flags.dart';
import 'package:notredame/features/app/navigation/navigation_service.dart';
import 'package:notredame/features/app/navigation/router_paths.dart';
import 'package:notredame/features/app/signets-api/models/course.dart';
import 'package:notredame/features/app/signets-api/models/course_summary.dart';
import 'package:notredame/features/more/settings/settings_manager.dart';
import 'package:notredame/features/student/grades/widgets/grade_button.dart';
import '../../../../common/helpers.dart';
import '../../../app/navigation/mocks/navigation_service_mock.dart';
import '../../../more/settings/mocks/settings_manager_mock.dart';

void main() {
  late AppIntl intl;
  late NavigationServiceMock navigationServiceMock;
  late SettingsManagerMock settingsManagerMock;

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
      settingsManagerMock = setupSettingsManagerMock();
      intl = await setupAppIntl();
      setupNavigationServiceMock();
      navigationServiceMock = setupNavigationServiceMock();
    });

    tearDown(() {
      unregister<SettingsManager>();
      unregister<NavigationService>();
    });

    group("UI -", () {
      testWidgets("Display acronym of the course and the current grade",
          (WidgetTester tester) async {
        SettingsManagerMock.stubGetString(
            settingsManagerMock, PreferencesFlag.discoveryStudentGrade,
            toReturn: 'true');

        await tester
            .pumpWidget(localizedWidget(child: GradeButton(courseWithGrade)));
        await tester.pumpAndSettle();

        expect(find.text(courseWithGrade.acronym), findsOneWidget);
        expect(find.text(courseWithGrade.grade!), findsOneWidget);
      });

      testWidgets("Grade not available and summary is loaded.",
          (WidgetTester tester) async {
        SettingsManagerMock.stubGetString(
            settingsManagerMock, PreferencesFlag.discoveryStudentGrade,
            toReturn: 'true');

        await tester
            .pumpWidget(localizedWidget(child: GradeButton(courseWithSummary)));
        await tester.pumpAndSettle();

        expect(find.text(courseWithGrade.acronym), findsOneWidget);
        expect(
            find.text(intl.grades_grade_in_percentage(
                courseWithSummary.summary!.currentMarkInPercent.round())),
            findsOneWidget,
            reason:
                'There is no grade available and the course summary exists so the '
                'current mark in percentage should be displayed');
      });

      testWidgets("Grade and summary not available.",
          (WidgetTester tester) async {
        SettingsManagerMock.stubGetString(
            settingsManagerMock, PreferencesFlag.discoveryStudentGrade,
            toReturn: 'true');

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

    group('Interactions - ', () {
      testWidgets('Grade button redirects to grades view when tapped ',
          (WidgetTester tester) async {
        SettingsManagerMock.stubGetBool(
            settingsManagerMock, PreferencesFlag.discoveryStudentGrade,
            toReturn: true);
        await tester
            .pumpWidget(localizedWidget(child: GradeButton(courseWithGrade)));
        await tester.pumpAndSettle();

        await tester.tap(find.text(courseWithGrade.acronym));

        verify(navigationServiceMock.pushNamed(RouterPaths.gradeDetails,
            arguments: courseWithGrade));
      });

      testWidgets(
          'Grade button does not redirect to grades view if the grades discovery did not already launch',
          (WidgetTester tester) async {
        await tester
            .pumpWidget(localizedWidget(child: GradeButton(courseWithGrade)));
        await tester.pumpAndSettle();

        await tester.tap(find.text(courseWithGrade.acronym));

        verifyNever(navigationServiceMock.pushNamed(RouterPaths.gradeDetails,
            arguments: courseWithGrade));
      });
    });
  });
}
