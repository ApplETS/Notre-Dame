// FLUTTER / DART / THIRD-PARTIES
import 'package:feature_discovery/feature_discovery.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// MANAGERS
import 'package:notredame/core/managers/settings_manager.dart';
import 'package:notredame/core/managers/course_repository.dart';

// MODELS
import 'package:notredame/core/models/course.dart';
import 'package:notredame/core/models/session.dart';

// VIEW
import 'package:notredame/ui/views/dashboard_view.dart';
import 'package:notredame/ui/widgets/grade_button.dart';

// CONSTANTS
import 'package:notredame/core/constants/preferences_flags.dart';

// OTHERS
import '../../helpers.dart';

// MOCKS
import '../../mock/managers/course_repository_mock.dart';
import '../../mock/managers/settings_manager_mock.dart';

void main() {
  SettingsManager settingsManager;
  AppIntl intl;
  CourseRepository courseRepository;

  // Cards
  final Map<PreferencesFlag, int> dashboard = {
    PreferencesFlag.aboutUsCard: 0,
    PreferencesFlag.scheduleCard: 1,
    PreferencesFlag.progressBarCard: 2,
    PreferencesFlag.gradesCards: 3
  };

  final numberOfCards = dashboard.entries.length;

  // Session
  final Session session = Session(
      shortName: "É2020",
      name: "Ete 2020",
      startDate: DateTime.now().subtract(const Duration(days: 1)),
      endDate: DateTime.now().add(const Duration(days: 1)),
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
      acronym: 'GEN102',
      group: '02',
      session: 'É2020',
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

  final courses = [courseSummer, courseSummer2, courseWinter, courseFall];

  Future<void> longPressDrag(
      WidgetTester tester, Offset start, Offset end) async {
    final TestGesture drag = await tester.startGesture(start);
    await tester.pump(const Duration(seconds: 1));
    await drag.moveTo(end);
    await tester.pump(const Duration(seconds: 1));
    await drag.up();
  }

  group('DashboardView - ', () {
    setUp(() async {
      intl = await setupAppIntl();
      settingsManager = setupSettingsManagerMock();
      setupNavigationServiceMock();
      courseRepository = setupCourseRepositoryMock();

      CourseRepositoryMock.stubSessions(
          courseRepository as CourseRepositoryMock,
          toReturn: [session]);
      CourseRepositoryMock.stubCourses(
          courseRepository as CourseRepositoryMock);
      CourseRepositoryMock.stubGetCourses(
          courseRepository as CourseRepositoryMock,
          fromCacheOnly: true);
      CourseRepositoryMock.stubGetCourses(
          courseRepository as CourseRepositoryMock,
          fromCacheOnly: false);
    });

    tearDown(() {});

    group('UI - ', () {
      testWidgets('Has view title and restore button, displayed',
          (WidgetTester tester) async {
        SettingsManagerMock.stubGetDashboard(
            settingsManager as SettingsManagerMock,
            toReturn: dashboard);

        await tester.pumpWidget(localizedWidget(
            child: FeatureDiscovery(child: const DashboardView())));
        await tester.pumpAndSettle();

        // Find Dashboard Title
        final dashboardTitle = find.descendant(
          of: find.byType(AppBar),
          matching: find.byType(Text),
        );
        expect(dashboardTitle, findsOneWidget);

        // Find restoreCards Button
        final restoreCardsIcon = find.byIcon(Icons.restore);
        expect(restoreCardsIcon, findsOneWidget);
      });

      testWidgets('Has card aboutUs displayed', (WidgetTester tester) async {
        SettingsManagerMock.stubGetDashboard(
            settingsManager as SettingsManagerMock,
            toReturn: dashboard);

        await tester.pumpWidget(localizedWidget(
            child: FeatureDiscovery(child: const DashboardView())));
        await tester.pumpAndSettle();

        // Find aboutUs card
        final aboutUsCard = find.widgetWithText(Card, intl.card_applets_title);
        expect(aboutUsCard, findsOneWidget);

        // Find aboutUs card Title
        final aboutUsTitle = find.text(intl.card_applets_title);
        expect(aboutUsTitle, findsOneWidget);

        // Find aboutUs card Text Paragraph
        final aboutUsParagraph = find.textContaining(intl.card_applets_text);
        expect(aboutUsParagraph, findsOneWidget);

        // Find aboutUs card Link Buttons
        final aboutUsLinkButtons = find.byType(TextButton);
        expect(aboutUsLinkButtons, findsNWidgets(3));

        expect(find.text(intl.facebook.toUpperCase()), findsOneWidget);
        expect(find.text(intl.github.toUpperCase()), findsOneWidget);
        expect(find.text(intl.email.toUpperCase()), findsOneWidget);
      });

      testWidgets('AboutUsCard is dismissible and can be restored',
          (WidgetTester tester) async {
        SettingsManagerMock.stubSetInt(settingsManager as SettingsManagerMock,
            PreferencesFlag.aboutUsCard);

        SettingsManagerMock.stubSetInt(settingsManager as SettingsManagerMock,
            PreferencesFlag.scheduleCard);

        SettingsManagerMock.stubSetInt(settingsManager as SettingsManagerMock,
            PreferencesFlag.gradesCards);

        SettingsManagerMock.stubSetInt(settingsManager as SettingsManagerMock,
            PreferencesFlag.progressBarCard);

        SettingsManagerMock.stubGetDashboard(
            settingsManager as SettingsManagerMock,
            toReturn: dashboard);

        await tester.pumpWidget(localizedWidget(
            child: FeatureDiscovery(child: const DashboardView())));
        await tester.pumpAndSettle();

        // Find Dismissible Cards
        expect(find.byType(Dismissible), findsNWidgets(numberOfCards));
        expect(find.text(intl.card_applets_title), findsOneWidget);

        // Swipe Dismissible aboutUs Card horizontally
        await tester.drag(
            find.byType(Dismissible).first, const Offset(1000.0, 0.0));

        // Check that the card is now absent from the view
        await tester.pumpAndSettle();
        expect(find.byType(Dismissible), findsNWidgets(numberOfCards - 1));
        expect(find.text(intl.card_applets_title), findsNothing);

        // Tap the restoreCards button
        await tester.tap(find.byIcon(Icons.restore));

        await tester.pumpAndSettle();

        // Check that the card is now present in the view
        expect(find.byType(Dismissible), findsNWidgets(numberOfCards));
        expect(
            find.widgetWithText(Card, intl.card_applets_title), findsOneWidget);
      });

      testWidgets('AboutUsCard is reorderable and can be restored',
          (WidgetTester tester) async {
        final String progressBarCard =
            PreferencesFlag.progressBarCard.toString();

        SettingsManagerMock.stubSetInt(settingsManager as SettingsManagerMock,
            PreferencesFlag.aboutUsCard);

        SettingsManagerMock.stubSetInt(settingsManager as SettingsManagerMock,
            PreferencesFlag.scheduleCard);

        SettingsManagerMock.stubSetInt(settingsManager as SettingsManagerMock,
            PreferencesFlag.gradesCards);

        SettingsManagerMock.stubSetInt(settingsManager as SettingsManagerMock,
            PreferencesFlag.progressBarCard);

        SettingsManagerMock.stubGetDashboard(
            settingsManager as SettingsManagerMock,
            toReturn: dashboard);

        await tester.pumpWidget(localizedWidget(
            child: FeatureDiscovery(child: const DashboardView())));
        await tester.pumpAndSettle();

        // Find Dismissible Cards
        expect(find.byType(Dismissible), findsNWidgets(numberOfCards));

        // Find aboutUs card
        expect(find.text(intl.card_applets_title), findsOneWidget);

        // Check that the aboutUs card is in the first position
        var text = tester.firstWidget(find.descendant(
          of: find.byType(Dismissible).first,
          matching: find.byType(Text),
        ));

        expect((text as Text).data, intl.card_applets_title);

        // Long press then drag and drop card at the end of the list
        await longPressDrag(
            tester,
            tester.getCenter(find.text(intl.card_applets_title)),
            tester.getCenter(find.text(progressBarCard)) +
                const Offset(0.0, 1000));

        await tester.pumpAndSettle();

        expect(find.byType(Dismissible), findsNWidgets(numberOfCards));

        // Check that the card is now in last position
        text = tester.firstWidget(find.descendant(
          of: find.byType(Dismissible).last,
          matching: find.byType(Text),
        ));
        expect((text as Text).data, intl.card_applets_title);

        // Tap the restoreCards button
        await tester.tap(find.byIcon(Icons.restore));

        await tester.pumpAndSettle();

        text = tester.firstWidget(find.descendant(
          of: find.byType(Dismissible).first,
          matching: find.byType(Text),
        ));

        expect(find.byType(Dismissible), findsNWidgets(numberOfCards));

        // Check that the first card is now AboutUs
        expect((text as Text).data, intl.card_applets_title);
      });

      group('UI - gradesCard', () {
        testWidgets('Has card grades displayed - with no courses',
            (WidgetTester tester) async {
          SettingsManagerMock.stubGetDashboard(
              settingsManager as SettingsManagerMock,
              toReturn: dashboard);

          await tester.pumpWidget(localizedWidget(
              child: FeatureDiscovery(child: const DashboardView())));
          await tester.pumpAndSettle();

          // Find grades card
          final gradesCard = find.widgetWithText(Card, intl.grades_title);
          expect(gradesCard, findsOneWidget);

          // Find grades card Title
          final gradesTitle = find.text(intl.grades_title);
          expect(gradesTitle, findsOneWidget);

          // Find empty grades card
          final gradesEmptyTitle =
              find.text(intl.grades_msg_no_grades.split("\n").first);
          expect(gradesEmptyTitle, findsOneWidget);
        });

        testWidgets('Has card grades displayed - with courses',
            (WidgetTester tester) async {
          CourseRepositoryMock.stubCourses(
              courseRepository as CourseRepositoryMock,
              toReturn: courses);
          CourseRepositoryMock.stubGetCourses(
              courseRepository as CourseRepositoryMock,
              fromCacheOnly: true,
              toReturn: courses);
          CourseRepositoryMock.stubGetCourses(
              courseRepository as CourseRepositoryMock,
              fromCacheOnly: false,
              toReturn: courses);

          SettingsManagerMock.stubGetDashboard(
              settingsManager as SettingsManagerMock,
              toReturn: dashboard);

          await tester.pumpWidget(localizedWidget(
              child: FeatureDiscovery(child: const DashboardView())));
          await tester.pumpAndSettle();

          // Find grades card
          final gradesCard = find.widgetWithText(Card, intl.grades_title);
          expect(gradesCard, findsOneWidget);

          // Find grades card Title
          final gradesTitle = find.text(intl.grades_title);
          expect(gradesTitle, findsOneWidget);

          // Find grades buttons in the card
          final gradesButtons = find.byType(GradeButton);
          expect(gradesButtons, findsNWidgets(2));
        });

        testWidgets('gradesCard is dismissible and can be restored',
            (WidgetTester tester) async {
          SettingsManagerMock.stubGetDashboard(
              settingsManager as SettingsManagerMock,
              toReturn: dashboard);

          SettingsManagerMock.stubSetInt(settingsManager as SettingsManagerMock,
              PreferencesFlag.aboutUsCard);

          SettingsManagerMock.stubSetInt(settingsManager as SettingsManagerMock,
              PreferencesFlag.scheduleCard);

          SettingsManagerMock.stubSetInt(settingsManager as SettingsManagerMock,
              PreferencesFlag.progressBarCard);

          SettingsManagerMock.stubSetInt(settingsManager as SettingsManagerMock,
              PreferencesFlag.gradesCards);

          await tester.pumpWidget(localizedWidget(
              child: FeatureDiscovery(child: const DashboardView())));
          await tester.pumpAndSettle();

          // Find Dismissible Cards
          expect(find.byType(Dismissible), findsNWidgets(numberOfCards));
          expect(find.text(intl.grades_title), findsOneWidget);

          // Swipe Dismissible grades Card horizontally
          await tester.drag(find.widgetWithText(Dismissible, intl.grades_title),
              const Offset(1000.0, 0.0));

          // Check that the card is now absent from the view
          await tester.pumpAndSettle();
          expect(find.byType(Dismissible), findsNWidgets(numberOfCards - 1));
          expect(find.text(intl.grades_title), findsNothing);

          // Tap the restoreCards button
          await tester.tap(find.byIcon(Icons.restore));

          await tester.pumpAndSettle();

          // Check that the card is now present in the view
          expect(find.byType(Dismissible), findsNWidgets(numberOfCards));
          expect(find.text(intl.grades_title), findsOneWidget);
        });
      });
    });

    group("golden - ", () {
      testWidgets("default view", (WidgetTester tester) async {
        tester.binding.window.physicalSizeTestValue = const Size(800, 1410);

        SettingsManagerMock.stubGetDashboard(
            settingsManager as SettingsManagerMock,
            toReturn: dashboard);

        await tester.pumpWidget(localizedWidget(
            child: FeatureDiscovery(child: const DashboardView())));
        await tester.pumpAndSettle();

        await expectLater(find.byType(DashboardView),
            matchesGoldenFile(goldenFilePath("dashboardView_1")));
      });
    });
  });
}
