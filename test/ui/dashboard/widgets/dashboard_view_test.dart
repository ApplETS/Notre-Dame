// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:notredame/data/services/signets-api/models/session.dart';
import 'package:notredame/domain/constants/preferences_flags.dart';
import 'package:notredame/ui/core/ui/dismissible_card.dart';
import 'package:notredame/ui/dashboard/widgets/dashboard_view.dart';
import '../../../data/mocks/repositories/course_repository_mock.dart';
import '../../../data/mocks/repositories/settings_repository_mock.dart';
import '../../../data/mocks/services/in_app_review_service_mock.dart';
import '../../../data/mocks/services/remote_config_service_mock.dart';
import '../../../helpers.dart';

void main() {
  late SettingsRepositoryMock settingsManagerMock;
  late CourseRepositoryMock courseRepositoryMock;
  late RemoteConfigServiceMock remoteConfigServiceMock;
  late InAppReviewServiceMock inAppReviewServiceMock;

  late AppIntl intl;

  // Cards
  final Map<PreferencesFlag, int> dashboard = {
    PreferencesFlag.aboutUsCard: 0,
    PreferencesFlag.scheduleCard: 1,
    PreferencesFlag.progressBarCard: 2,
    PreferencesFlag.gradesCard: 3
  };

  final numberOfCards = dashboard.entries.length;

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
      settingsManagerMock = setupSettingsRepositoryMock();
      courseRepositoryMock = setupCourseRepositoryMock();
      remoteConfigServiceMock = setupRemoteConfigServiceMock();
      setupNavigationServiceMock();
      courseRepositoryMock = setupCourseRepositoryMock();
      setupNetworkingServiceMock();
      setupAnalyticsServiceMock();
      setupLaunchUrlServiceMock();
      setupPreferencesServiceMock();

      inAppReviewServiceMock =
          setupInAppReviewServiceMock() as InAppReviewServiceMock;
      InAppReviewServiceMock.stubIsAvailable(inAppReviewServiceMock,
          toReturn: false);

      CourseRepositoryMock.stubSessions(courseRepositoryMock,
          toReturn: [session]);
      CourseRepositoryMock.stubGetSessions(courseRepositoryMock,
          toReturn: [session]);
      CourseRepositoryMock.stubActiveSessions(courseRepositoryMock,
          toReturn: [session]);
      CourseRepositoryMock.stubCourses(courseRepositoryMock);
      CourseRepositoryMock.stubGetCourses(courseRepositoryMock,
          fromCacheOnly: true);
      CourseRepositoryMock.stubGetCourses(courseRepositoryMock);
      CourseRepositoryMock.stubCoursesActivities(courseRepositoryMock);
      CourseRepositoryMock.stubGetCoursesActivities(courseRepositoryMock,
          fromCacheOnly: true);

      RemoteConfigServiceMock.stubGetBroadcastEnabled(remoteConfigServiceMock,
          toReturn: false);

      SettingsRepositoryMock.stubSetInt(
          settingsManagerMock, PreferencesFlag.aboutUsCard);

      SettingsRepositoryMock.stubSetInt(
          settingsManagerMock, PreferencesFlag.scheduleCard);

      SettingsRepositoryMock.stubSetInt(
          settingsManagerMock, PreferencesFlag.progressBarCard);

      SettingsRepositoryMock.stubSetInt(
          settingsManagerMock, PreferencesFlag.gradesCard);

      SettingsRepositoryMock.stubDateTimeNow(settingsManagerMock,
          toReturn: DateTime.now());
    });

    tearDown(() {});

    group('UI - ', () {
      testWidgets('Has view title restore button and cards, displayed',
          (WidgetTester tester) async {
        SettingsRepositoryMock.stubGetDashboard(settingsManagerMock,
            toReturn: dashboard);

        await tester.pumpWidget(localizedWidget(child: const DashboardView()));
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

        // Find cards
        expect(find.byType(Card, skipOffstage: false),
            findsNWidgets(numberOfCards));
      });
    });

    group('Interactions - ', () {
      testWidgets('AboutUsCard is dismissible and can be restored',
          (WidgetTester tester) async {
        CourseRepositoryMock.stubCoursesActivities(courseRepositoryMock);

        CourseRepositoryMock.stubGetCoursesActivities(courseRepositoryMock,
            fromCacheOnly: true);
        CourseRepositoryMock.stubGetCoursesActivities(courseRepositoryMock);

        SettingsRepositoryMock.stubGetDashboard(settingsManagerMock,
            toReturn: dashboard);

        SettingsRepositoryMock.stubSetInt(
            settingsManagerMock, PreferencesFlag.aboutUsCard);

        SettingsRepositoryMock.stubSetInt(
            settingsManagerMock, PreferencesFlag.scheduleCard);

        SettingsRepositoryMock.stubSetInt(
            settingsManagerMock, PreferencesFlag.gradesCard);

        SettingsRepositoryMock.stubSetInt(
            settingsManagerMock, PreferencesFlag.progressBarCard);

        await tester.pumpWidget(localizedWidget(child: const DashboardView()));
        await tester.pumpAndSettle();

        // Find Dismissible Cards
        expect(find.byType(Dismissible, skipOffstage: false),
            findsNWidgets(numberOfCards));
        expect(find.text(intl.card_applets_title), findsOneWidget);

        // Swipe Dismissible aboutUs Card horizontally
        await tester.drag(find.byType(Dismissible, skipOffstage: false).at(0),
            const Offset(1000.0, 0.0));

        // Check that the card is now absent from the view
        await tester.pumpAndSettle();
        expect(find.byType(Dismissible, skipOffstage: false),
            findsNWidgets(numberOfCards - 1));
        expect(find.text(intl.card_applets_title), findsNothing);

        // Tap the restoreCards button
        await tester.tap(find.byIcon(Icons.restore));

        await tester.pumpAndSettle();

        // Check that the card is now present in the view
        expect(find.byType(Dismissible, skipOffstage: false),
            findsNWidgets(numberOfCards));
        expect(find.text(intl.card_applets_title), findsOneWidget);
      });

      testWidgets('AboutUsCard is reorderable and can be restored',
          (WidgetTester tester) async {
        SettingsRepositoryMock.stubGetDashboard(settingsManagerMock,
            toReturn: dashboard);

        CourseRepositoryMock.stubCoursesActivities(courseRepositoryMock);
        CourseRepositoryMock.stubGetCoursesActivities(courseRepositoryMock,
            fromCacheOnly: true);
        CourseRepositoryMock.stubGetCoursesActivities(courseRepositoryMock);

        SettingsRepositoryMock.stubSetInt(
            settingsManagerMock, PreferencesFlag.aboutUsCard);

        SettingsRepositoryMock.stubSetInt(
            settingsManagerMock, PreferencesFlag.scheduleCard);

        SettingsRepositoryMock.stubSetInt(
            settingsManagerMock, PreferencesFlag.gradesCard);

        SettingsRepositoryMock.stubSetInt(
            settingsManagerMock, PreferencesFlag.progressBarCard);

        await tester.pumpWidget(localizedWidget(child: const DashboardView()));
        await tester.pumpAndSettle();

        // Find Dismissible Cards
        expect(find.byType(Dismissible, skipOffstage: false),
            findsNWidgets(numberOfCards));

        // Find aboutUs card
        expect(find.text(intl.card_applets_title), findsOneWidget);

        // Check that the aboutUs card is in the first position
        var text = tester.firstWidget(find.descendant(
          of: find.byType(Dismissible, skipOffstage: false).at(0),
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

        expect(find.byType(Dismissible, skipOffstage: false),
            findsNWidgets(numberOfCards));

        // Check that the card is now in last position
        text = tester.firstWidget(find.descendant(
          of: find.byType(Dismissible, skipOffstage: false).last,
          matching: find.byType(Text),
        ));
        expect(text.data, intl.card_applets_title);

        // Tap the restoreCards button
        await tester.tap(find.byIcon(Icons.restore));

        await tester.pumpAndSettle();

        text = tester.firstWidget(find.descendant(
          of: find.byType(Dismissible, skipOffstage: false).at(0),
          matching: find.byType(Text),
        ));

        expect(find.byType(Dismissible, skipOffstage: false),
            findsNWidgets(numberOfCards));

        // Check that the first card is now AboutUs
        expect(text.data, intl.card_applets_title);
      });

      testWidgets('ScheduleCard is dismissible and can be restored',
          (WidgetTester tester) async {
        SettingsRepositoryMock.stubGetDashboard(settingsManagerMock,
            toReturn: dashboard);

        await tester.pumpWidget(localizedWidget(child: const DashboardView()));
        await tester.pumpAndSettle();

        // Find Dismissible Cards
        expect(find.byType(Dismissible, skipOffstage: false),
            findsNWidgets(numberOfCards));
        expect(find.widgetWithText(Dismissible, intl.title_schedule),
            findsOneWidget);

        // Swipe Dismissible schedule Card horizontally
        await tester.drag(find.byType(Dismissible, skipOffstage: false).at(1),
            const Offset(1000.0, 0.0));

        // Check that the card is now absent from the view
        await tester.pumpAndSettle();

        expect(find.byType(Dismissible, skipOffstage: false),
            findsNWidgets(numberOfCards - 1));
        expect(find.widgetWithText(Dismissible, intl.title_schedule),
            findsNothing);

        // Tap the restoreCards button
        await tester.tap(find.byIcon(Icons.restore));

        await tester.pumpAndSettle();

        // Check that the card is now present in the view
        expect(find.byType(Dismissible, skipOffstage: false),
            findsNWidgets(numberOfCards));
        expect(find.widgetWithText(Dismissible, intl.title_schedule),
            findsOneWidget);
      });

      group('UI - gradesCard', () {
        testWidgets('gradesCard is dismissible and can be restored',
            (WidgetTester tester) async {
          SettingsRepositoryMock.stubSetInt(
              settingsManagerMock, PreferencesFlag.aboutUsCard);

          SettingsRepositoryMock.stubSetInt(
              settingsManagerMock, PreferencesFlag.scheduleCard);

          SettingsRepositoryMock.stubSetInt(
              settingsManagerMock, PreferencesFlag.progressBarCard);

          SettingsRepositoryMock.stubSetInt(
              settingsManagerMock, PreferencesFlag.gradesCard);
          SettingsRepositoryMock.stubGetDashboard(settingsManagerMock,
              toReturn: dashboard);

          await tester
              .pumpWidget(localizedWidget(child: const DashboardView()));
          await tester.pumpAndSettle();

          // Find Dismissible Cards
          expect(find.byType(Dismissible, skipOffstage: false),
              findsNWidgets(numberOfCards));
          expect(find.text(intl.grades_title, skipOffstage: false),
              findsOneWidget);

          // Swipe Dismissible grades Card horizontally
          final finder = find.widgetWithText(Dismissible, intl.grades_title,
              skipOffstage: false);
          await tester.scrollUntilVisible(finder, 100);
          await tester.pumpAndSettle();
          await tester.drag(finder, const Offset(1000.0, 0.0));

          // Check that the card is now absent from the view
          await tester.pumpAndSettle();
          expect(find.byType(Dismissible), findsNWidgets(numberOfCards - 1));
          expect(find.text(intl.grades_title), findsNothing);

          // Tap the restoreCards button
          await tester.tap(find.byIcon(Icons.restore));

          await tester.pumpAndSettle();

          // Check that the card is now present in the view
          expect(find.byType(Dismissible, skipOffstage: false),
              findsNWidgets(numberOfCards));
          expect(find.text(intl.grades_title, skipOffstage: false),
              findsOneWidget);
        });
      });
    });

    group("UI - progressBar", () {
      testWidgets('Has card progressBar displayed',
          (WidgetTester tester) async {
        SettingsRepositoryMock.stubGetDashboard(settingsManagerMock,
            toReturn: dashboard);

        await tester.pumpWidget(localizedWidget(child: const DashboardView()));
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
        SettingsRepositoryMock.stubGetDashboard(settingsManagerMock,
            toReturn: dashboard);

        await tester.pumpWidget(localizedWidget(child: const DashboardView()));
        await tester.pumpAndSettle();

        // Find Dismissible Cards
        expect(find.byType(DismissibleCard, skipOffstage: false),
            findsNWidgets(numberOfCards));
        expect(find.text(intl.progress_bar_title), findsOneWidget);

        // Swipe Dismissible progress Card horizontally
        final discardCard =
            find.widgetWithText(DismissibleCard, intl.progress_bar_title);
        await tester.ensureVisible(discardCard);
        await tester.pumpAndSettle();
        await tester.drag(discardCard, const Offset(-1000.0, 0.0));

        // Check that the card is now absent from the view
        await tester.pumpAndSettle();
        expect(find.byType(DismissibleCard, skipOffstage: false),
            findsNWidgets(numberOfCards - 1));
        expect(find.text(intl.progress_bar_title), findsNothing);

        // Tap the restoreCards button
        await tester.tap(find.byIcon(Icons.restore));

        await tester.pumpAndSettle();

        // Check that the card is now present in the view
        expect(find.byType(DismissibleCard, skipOffstage: false),
            findsNWidgets(numberOfCards));
        expect(find.text(intl.progress_bar_title), findsOneWidget);
      });

      testWidgets('progressBarCard is reorderable and can be restored',
          (WidgetTester tester) async {
        InAppReviewServiceMock.stubIsAvailable(inAppReviewServiceMock);
        SettingsRepositoryMock.stubGetDashboard(settingsManagerMock,
            toReturn: dashboard);

        await tester.pumpWidget(localizedWidget(child: const DashboardView()));
        await tester.pumpAndSettle();

        // Find Dismissible Cards
        expect(find.byType(Dismissible, skipOffstage: false),
            findsNWidgets(numberOfCards));

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

        expect(find.byType(Dismissible, skipOffstage: false),
            findsNWidgets(numberOfCards));

        // Check that the card is now in last position
        final discardCard = find.widgetWithText(
            Dismissible, intl.progress_bar_title,
            skipOffstage: false);
        await tester.ensureVisible(discardCard);
        await tester.pumpAndSettle();

        text = tester.firstWidget(find.descendant(
          of: discardCard,
          matching: find.byType(Text),
        ));
        expect(text.data, intl.progress_bar_title);

        // Tap the restoreCards button
        await tester.tap(find.byIcon(Icons.restore));

        await tester.pumpAndSettle();

        text = tester.firstWidget(find.descendant(
          of: find.widgetWithText(Dismissible, intl.progress_bar_title).first,
          matching: find.byType(Text),
        ));

        expect(find.byType(Dismissible, skipOffstage: false),
            findsNWidgets(numberOfCards));

        // Check that the first card is now AboutUs
        expect(text.data, intl.progress_bar_title);
      });
    });
  });
}
