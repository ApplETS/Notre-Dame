// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:feature_discovery/feature_discovery.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import 'package:notredame/constants/preferences_flags.dart';
import 'package:notredame/constants/update_code.dart';
import 'package:notredame/features/app/signets-api/models/course_activity.dart';
import 'package:notredame/features/app/signets-api/models/session.dart';
import 'package:notredame/features/dashboard/dashboard_view.dart';
import '../../common/helpers.dart';
import '../app/analytics/mocks/remote_config_service_mock.dart';
import '../app/repository/mocks/course_repository_mock.dart';
import '../more/feedback/mocks/in_app_review_service_mock.dart';
import '../more/settings/mocks/settings_manager_mock.dart';

void main() {
  late SettingsManagerMock settingsManagerMock;
  late CourseRepositoryMock courseRepositoryMock;
  late RemoteConfigServiceMock remoteConfigServiceMock;
  late InAppReviewServiceMock inAppReviewServiceMock;

  late AppIntl intl;

  // Activities for today
  final gen101 = CourseActivity(
      courseGroup: "GEN101",
      courseName: "Generic course",
      activityName: "TD",
      activityDescription: "Activity description",
      activityLocation: "location",
      startDateTime: DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day, 9),
      endDateTime: DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day, 12));

  final gen102 = CourseActivity(
      courseGroup: "GEN102",
      courseName: "Generic course",
      activityName: "TD",
      activityDescription: "Activity description",
      activityLocation: "location",
      startDateTime: DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day, 13),
      endDateTime: DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day, 16));

  final gen103 = CourseActivity(
      courseGroup: "GEN103",
      courseName: "Generic course",
      activityName: "TD",
      activityDescription: "Activity description",
      activityLocation: "location",
      startDateTime: DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day, 18),
      endDateTime: DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day, 21));

  final List<CourseActivity> activities = [gen101, gen102, gen103];

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
      settingsManagerMock = setupSettingsManagerMock();
      courseRepositoryMock = setupCourseRepositoryMock();
      remoteConfigServiceMock = setupRemoteConfigServiceMock();
      setupNavigationServiceMock();
      setupNetworkingServiceMock();
      setupAnalyticsServiceMock();
      setupPreferencesServiceMock();
      // TODO: Remove when 4.50.1 is released
      SharedPreferences.setMockInitialValues({});
      // End TODO: Remove when 4.50.1 is released

      inAppReviewServiceMock =
          setupInAppReviewServiceMock() as InAppReviewServiceMock;
      InAppReviewServiceMock.stubIsAvailable(inAppReviewServiceMock,
          toReturn: false);

      CourseRepositoryMock.stubSessions(courseRepositoryMock,
          toReturn: [session]);
      CourseRepositoryMock.stubGetSessions(courseRepositoryMock,
          toReturn: [session]);
      CourseRepositoryMock.stubCoursesActivities(courseRepositoryMock);

      RemoteConfigServiceMock.stubGetBroadcastEnabled(remoteConfigServiceMock,
          toReturn: false);

      SettingsManagerMock.stubGetBool(
          settingsManagerMock, PreferencesFlag.discoveryDashboard,
          toReturn: true);

      SettingsManagerMock.stubSetInt(
          settingsManagerMock, PreferencesFlag.aboutUsCard);

      SettingsManagerMock.stubSetInt(
          settingsManagerMock, PreferencesFlag.scheduleCard);

      SettingsManagerMock.stubSetInt(
          settingsManagerMock, PreferencesFlag.progressBarCard);

      SettingsManagerMock.stubSetInt(
          settingsManagerMock, PreferencesFlag.gradesCard);

      SettingsManagerMock.stubDateTimeNow(settingsManagerMock,
          toReturn: DateTime.now());
    });

    tearDown(() {});

    group('UI - ', () {
      testWidgets('Has view title restore button and cards, displayed',
          (WidgetTester tester) async {
        SettingsManagerMock.stubGetDashboard(settingsManagerMock,
            toReturn: dashboard);

        await tester.pumpWidget(localizedWidget(
            child: FeatureDiscovery(
                child: const DashboardView(updateCode: UpdateCode.none))));
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

      testWidgets('Has card aboutUs displayed properly',
          (WidgetTester tester) async {
        CourseRepositoryMock.stubCoursesActivities(courseRepositoryMock,
            toReturn: activities);

        CourseRepositoryMock.stubGetCoursesActivities(courseRepositoryMock,
            fromCacheOnly: true);
        CourseRepositoryMock.stubGetCoursesActivities(courseRepositoryMock);

        SettingsManagerMock.stubGetDashboard(settingsManagerMock,
            toReturn: dashboard);

        await tester.pumpWidget(localizedWidget(
            child: FeatureDiscovery(
                child: const DashboardView(updateCode: UpdateCode.none))));
        await tester.pumpAndSettle();

        // Find aboutUs card
        final aboutUsCard = find.widgetWithText(Card, intl.card_applets_title);
        expect(aboutUsCard, findsOneWidget);

        // Find aboutUs card Text Paragraph
        final aboutUsParagraph = find.textContaining(intl.card_applets_text);
        expect(aboutUsParagraph, findsOneWidget);

        // Find aboutUs card Link Buttons
        final aboutUsLinkButtons = find.byType(IconButton);
        expect(aboutUsLinkButtons, findsNWidgets(6));
      });
    });

    group('Interactions - ', () {
      testWidgets('AboutUsCard is dismissible and can be restored',
          (WidgetTester tester) async {
        CourseRepositoryMock.stubCoursesActivities(courseRepositoryMock);

        CourseRepositoryMock.stubGetCoursesActivities(courseRepositoryMock,
            fromCacheOnly: true);
        CourseRepositoryMock.stubGetCoursesActivities(courseRepositoryMock);

        SettingsManagerMock.stubGetDashboard(settingsManagerMock,
            toReturn: dashboard);

        SettingsManagerMock.stubSetInt(
            settingsManagerMock, PreferencesFlag.aboutUsCard);

        SettingsManagerMock.stubSetInt(
            settingsManagerMock, PreferencesFlag.scheduleCard);

        SettingsManagerMock.stubSetInt(
            settingsManagerMock, PreferencesFlag.gradesCard);

        SettingsManagerMock.stubSetInt(
            settingsManagerMock, PreferencesFlag.progressBarCard);

        await tester.pumpWidget(localizedWidget(
            child: FeatureDiscovery(
                child: const DashboardView(updateCode: UpdateCode.none))));
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
        SettingsManagerMock.stubGetDashboard(settingsManagerMock,
            toReturn: dashboard);

        CourseRepositoryMock.stubCoursesActivities(courseRepositoryMock);
        CourseRepositoryMock.stubGetCoursesActivities(courseRepositoryMock,
            fromCacheOnly: true);
        CourseRepositoryMock.stubGetCoursesActivities(courseRepositoryMock);

        SettingsManagerMock.stubSetInt(
            settingsManagerMock, PreferencesFlag.aboutUsCard);

        SettingsManagerMock.stubSetInt(
            settingsManagerMock, PreferencesFlag.scheduleCard);

        SettingsManagerMock.stubSetInt(
            settingsManagerMock, PreferencesFlag.gradesCard);

        SettingsManagerMock.stubSetInt(
            settingsManagerMock, PreferencesFlag.progressBarCard);

        await tester.pumpWidget(localizedWidget(
            child: FeatureDiscovery(
                child: const DashboardView(updateCode: UpdateCode.none))));
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
        SettingsManagerMock.stubGetDashboard(settingsManagerMock,
            toReturn: dashboard);

        await tester.pumpWidget(localizedWidget(
            child: FeatureDiscovery(
                child: const DashboardView(updateCode: UpdateCode.none))));
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
    });
  });
}
