// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mockito/mockito.dart';

// CONSTANTS
import 'package:notredame/core/constants/preferences_flags.dart';

// MANAGERS
import 'package:notredame/core/managers/settings_manager.dart';

// MODELS
import 'package:ets_api_clients/models.dart';
// SERVICE
import 'package:notredame/core/services/navigation_service.dart';

// OTHERS
import 'package:notredame/core/constants/router_paths.dart';

// WIDGET
import 'package:notredame/ui/widgets/grade_button.dart';

// HELPERS
import '../../helpers.dart';
import '../../mock/managers/settings_manager_mock.dart';

void main() {
  AppIntl intl;
  NavigationService navigationService;
  SettingsManager settingsManager;

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
      settingsManager = setupSettingsManagerMock();
      intl = await setupAppIntl();
      setupNavigationServiceMock();
      navigationService = setupNavigationServiceMock();
    });

    tearDown(() {
      unregister<SettingsManager>();
      unregister<NavigationService>();
    });

    group("UI -", () {
      testWidgets("Display acronym of the course and the current grade",
          (WidgetTester tester) async {
        SettingsManagerMock.stubGetString(
            settingsManager as SettingsManagerMock,
            PreferencesFlag.discoveryStudentGrade,
            toReturn: 'true');

        await tester.pumpWidget(localizedWidget(
            child: GradeButton(courseWithGrade, showDiscovery: false)));
        await tester.pumpAndSettle();

        expect(find.text(courseWithGrade.acronym), findsOneWidget);
        expect(find.text(courseWithGrade.grade), findsOneWidget);
      });

      testWidgets("Grade not available and summary is loaded.",
          (WidgetTester tester) async {
        SettingsManagerMock.stubGetString(
            settingsManager as SettingsManagerMock,
            PreferencesFlag.discoveryStudentGrade,
            toReturn: 'true');

        await tester.pumpWidget(localizedWidget(
            child: GradeButton(courseWithSummary, showDiscovery: false)));
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
        SettingsManagerMock.stubGetString(
            settingsManager as SettingsManagerMock,
            PreferencesFlag.discoveryStudentGrade,
            toReturn: 'true');

        await tester.pumpWidget(localizedWidget(
            child: GradeButton(gradesNotAvailable, showDiscovery: false)));
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
        SettingsManagerMock.stubGetBool(settingsManager as SettingsManagerMock,
            PreferencesFlag.discoveryStudentGrade,
            toReturn: true);
        await tester.pumpWidget(localizedWidget(
            child: GradeButton(courseWithGrade, showDiscovery: false)));
        await tester.pumpAndSettle();

        await tester.tap(find.text(courseWithGrade.acronym));

        verify(navigationService.pushNamed(RouterPaths.gradeDetails,
            arguments: courseWithGrade));
      });

      testWidgets(
          'Grade button does not redirect to grades view if the grades discovery did not already launch',
          (WidgetTester tester) async {
        await tester.pumpWidget(localizedWidget(
            child: GradeButton(courseWithGrade, showDiscovery: false)));
        await tester.pumpAndSettle();

        await tester.tap(find.text(courseWithGrade.acronym));

        verifyNever(navigationService.pushNamed(RouterPaths.gradeDetails,
            arguments: courseWithGrade));
      });
    });
  });
}
