// FLUTTER / DART / THIRD-PARTIES
import 'package:feature_discovery/feature_discovery.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// MANAGERS
import 'package:notredame/core/managers/course_repository.dart';
import 'package:notredame/core/managers/settings_manager.dart';
import 'package:notredame/core/models/session.dart';

// VIEW
import 'package:notredame/ui/views/dashboard_view.dart';

// CONSTANTS
import 'package:notredame/core/constants/preferences_flags.dart';

// OTHERS
import '../../helpers.dart';

// MOCKS
import '../../mock/managers/course_repository_mock.dart';
import '../../mock/managers/settings_manager_mock.dart';

void main() {
  SettingsManager settingsManager;
  CourseRepository courseRepository;
  AppIntl intl;

  // Cards
  Map<PreferencesFlag, int> dashboard = {
    PreferencesFlag.aboutUsCard: 0,
    PreferencesFlag.scheduleCard: 1,
    PreferencesFlag.progressBarCard: 2
  };

  // Session
  final Session session = Session(
      shortName: "É2020",
      name: "Ete 2020",
      startDate: DateTime(2020).subtract(const Duration(days: 1)),
      endDate: DateTime(2020).add(const Duration(days: 1)),
      endDateCourses: DateTime(2022, 1, 10, 1, 1),
      startDateRegistration: DateTime(2017, 1, 9, 1, 1),
      deadlineRegistration: DateTime(2017, 1, 10, 1, 1),
      startDateCancellationWithRefund: DateTime(2017, 1, 10, 1, 1),
      deadlineCancellationWithRefund: DateTime(2017, 1, 11, 1, 1),
      deadlineCancellationWithRefundNewStudent: DateTime(2017, 1, 11, 1, 1),
      startDateCancellationWithoutRefundNewStudent: DateTime(2017, 1, 12, 1, 1),
      deadlineCancellationWithoutRefundNewStudent: DateTime(2017, 1, 12, 1, 1),
      deadlineCancellationASEQ: DateTime(2017, 1, 11, 1, 1));

  final numberOfCards = dashboard.entries.length;

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

      CourseRepositoryMock.stubGetSessions(
          courseRepository as CourseRepositoryMock,
          toReturn: [session]);
      CourseRepositoryMock.stubActiveSessions(
          courseRepository as CourseRepositoryMock,
          toReturn: [session]);
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
        final aboutUsCard = find.widgetWithText(Card, intl.card_applets_text);
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
        SettingsManagerMock.stubGetDashboard(
            settingsManager as SettingsManagerMock,
            toReturn: dashboard);

        SettingsManagerMock.stubSetInt(settingsManager as SettingsManagerMock,
            PreferencesFlag.aboutUsCard);

        SettingsManagerMock.stubSetInt(settingsManager as SettingsManagerMock,
            PreferencesFlag.scheduleCard);

        SettingsManagerMock.stubSetInt(settingsManager as SettingsManagerMock,
            PreferencesFlag.progressBarCard);

        await tester.pumpWidget(localizedWidget(
            child: FeatureDiscovery(child: const DashboardView())));
        await tester.pumpAndSettle();

        // Find Dismissible Cards
        expect(find.byType(Dismissible), findsNWidgets(3));
        expect(find.text(intl.card_applets_title), findsOneWidget);

        // Swipe Dismissible aboutUs Card horizontally
        await tester.drag(
            find.byType(Dismissible).first, const Offset(1000.0, 0.0));

        // Check that the card is now absent from the view
        await tester.pumpAndSettle();
        expect(find.byType(Dismissible), findsNWidgets(2));
        expect(find.text(intl.card_applets_title), findsNothing);

        // Tap the restoreCards button
        await tester.tap(find.byIcon(Icons.restore));

        await tester.pumpAndSettle();

        // Check that the card is now present in the view
        expect(find.byType(Dismissible), findsNWidgets(3));
        expect(find.text(intl.card_applets_title), findsOneWidget);
      });

      testWidgets('AboutUsCard is reorderable and can be restored',
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

        await tester.pumpWidget(localizedWidget(
            child: FeatureDiscovery(child: const DashboardView())));
        await tester.pumpAndSettle();

        // Find Dismissible Cards
        expect(find.byType(Dismissible), findsNWidgets(3));

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
            tester.getCenter(find.text(intl.progress_bar_title)) +
                const Offset(0.0, 1000));

        await tester.pumpAndSettle();

        expect(find.byType(Dismissible), findsNWidgets(3));

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

        expect(find.byType(Dismissible), findsNWidgets(3));

        // Check that the first card is now AboutUs
        expect((text as Text).data, intl.card_applets_title);
      });
    });

    group("UI - progressBar", () {
      testWidgets('Has card progressBar displayed',
          (WidgetTester tester) async {
        SettingsManagerMock.stubGetDashboard(
            settingsManager as SettingsManagerMock,
            toReturn: dashboard);

        await tester.pumpWidget(localizedWidget(
            child: FeatureDiscovery(child: const DashboardView())));
        await tester.pumpAndSettle();

        // Find progress card
        final progressCard = find.widgetWithText(Card, intl.progress_bar_title);
        expect(progressCard, findsOneWidget);

        // Find progress card Title
        final progressTitle = find.text(intl.progress_bar_title);
        expect(progressTitle, findsOneWidget);

        // Find progress card linearProgressBar
        final linearProgressBar = find.byType(LinearProgressIndicator);
        expect(linearProgressBar, findsOneWidget);
      });

      testWidgets('progressCard is dismissible and can be restored',
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

        await tester.pumpWidget(localizedWidget(
            child: FeatureDiscovery(child: const DashboardView())));
        await tester.pumpAndSettle();

        // Find Dismissible Cards
        expect(find.byType(Dismissible), findsNWidgets(numberOfCards));
        expect(find.text(intl.progress_bar_title), findsOneWidget);

        // Swipe Dismissible progress Card horizontally
        await tester.drag(
            find.widgetWithText(Dismissible, intl.progress_bar_title),
            const Offset(1000.0, 0.0));

        // Check that the card is now absent from the view
        await tester.pumpAndSettle();
        expect(find.byType(Dismissible), findsNWidgets(numberOfCards - 1));
        expect(find.text(intl.progress_bar_title), findsNothing);

        // Tap the restoreCards button
        await tester.tap(find.byIcon(Icons.restore));

        await tester.pumpAndSettle();

        // Check that the card is now present in the view
        expect(find.byType(Dismissible), findsNWidgets(numberOfCards));
        expect(find.text(intl.progress_bar_title), findsOneWidget);
      });

      testWidgets('progressBarCard is reorderable and can be restored',
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

        await tester.pumpWidget(localizedWidget(
            child: FeatureDiscovery(child: const DashboardView())));
        await tester.pumpAndSettle();

        // Find Dismissible Cards
        expect(find.byType(Dismissible), findsNWidgets(numberOfCards));

        // Find progressBar card
        expect(find.text(intl.progress_bar_title), findsOneWidget);

        // Check that the progressBar card is in the first position
        var text = tester.firstWidget(find.descendant(
          of: find.widgetWithText(Dismissible, intl.progress_bar_title).first,
          matching: find.byType(Text),
        ));

        expect((text as Text).data, intl.progress_bar_title);

        // Long press then drag and drop card at the end of the list
        await longPressDrag(
            tester,
            tester.getCenter(find.text(intl.progress_bar_title)),
            tester.getCenter(find.text(intl.card_applets_title)) +
                const Offset(0.0, 1000));

        await tester.pumpAndSettle();

        expect(find.byType(Dismissible), findsNWidgets(numberOfCards));

        // Check that the card is now in last position
        text = tester.firstWidget(find.descendant(
          of: find.widgetWithText(Dismissible, intl.progress_bar_title).last,
          matching: find.byType(Text),
        ));
        expect((text as Text).data, intl.progress_bar_title);

        // Tap the restoreCards button
        await tester.tap(find.byIcon(Icons.restore));

        await tester.pumpAndSettle();

        text = tester.firstWidget(find.descendant(
          of: find.widgetWithText(Dismissible, intl.progress_bar_title).first,
          matching: find.byType(Text),
        ));

        expect(find.byType(Dismissible), findsNWidgets(numberOfCards));

        // Check that the first card is now AboutUs
        expect((text as Text).data, intl.progress_bar_title);
      });
    });

    group("golden - ", () {
      testWidgets("Applets Card", (WidgetTester tester) async {
        tester.binding.window.physicalSizeTestValue = const Size(800, 1410);

        dashboard = {
          PreferencesFlag.aboutUsCard: 0,
        };

        SettingsManagerMock.stubGetDashboard(
            settingsManager as SettingsManagerMock,
            toReturn: dashboard);

        await tester.pumpWidget(localizedWidget(
            child: FeatureDiscovery(child: const DashboardView())));
        await tester.pumpAndSettle();

        await expectLater(find.byType(DashboardView),
            matchesGoldenFile(goldenFilePath("dashboardView_appletsCard_1")));
      });
      testWidgets("progressBar Card", (WidgetTester tester) async {
        tester.binding.window.physicalSizeTestValue = const Size(800, 1410);

        dashboard = {
          PreferencesFlag.progressBarCard: 0,
        };

        SettingsManagerMock.stubGetDashboard(
            settingsManager as SettingsManagerMock,
            toReturn: dashboard);

        await tester.pumpWidget(localizedWidget(
            child: FeatureDiscovery(child: const DashboardView())));
        await tester.pumpAndSettle();

        await expectLater(
            find.byType(DashboardView),
            matchesGoldenFile(
                goldenFilePath("dashboardView_progressBarCard_1")));
      });
    });
  });
}
