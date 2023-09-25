// FLUTTER / DART / THIRD-PARTIES
import 'dart:io';
import 'package:feature_discovery/feature_discovery.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// MANAGERS
import 'package:notredame/core/managers/course_repository.dart';
import 'package:notredame/core/managers/settings_manager.dart';

// MODELS
import 'package:ets_api_clients/models.dart';

// VIEW
import 'package:notredame/ui/views/dashboard_view.dart';
import 'package:notredame/ui/widgets/course_activity_tile.dart';
import 'package:notredame/ui/widgets/grade_button.dart';

// CONSTANTS
import 'package:notredame/core/constants/preferences_flags.dart';

// SERVICES
import 'package:notredame/core/services/remote_config_service.dart';

// OTHERS
import '../../helpers.dart';

// MOCKS
import '../../mock/managers/course_repository_mock.dart';
import '../../mock/managers/settings_manager_mock.dart';
import '../../mock/services/in_app_review_service_mock.dart';
import '../../mock/services/remote_config_service_mock.dart';

void main() {
  SettingsManager settingsManager;
  CourseRepository courseRepository;
  RemoteConfigService remoteConfigService;
  AppIntl intl;
  InAppReviewServiceMock inAppReviewServiceMock;

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
  Map<PreferencesFlag, int> dashboard = {
    PreferencesFlag.broadcastCard: 0,
    PreferencesFlag.aboutUsCard: 1,
    PreferencesFlag.scheduleCard: 2,
    PreferencesFlag.progressBarCard: 3,
    PreferencesFlag.gradesCard: 4
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

  Future<Widget> testDashboardSchedule(WidgetTester tester, DateTime now,
      List<CourseActivity> courses, int expected) async {
    CourseRepositoryMock.stubCoursesActivities(
        courseRepository as CourseRepositoryMock,
        toReturn: courses);

    CourseRepositoryMock.stubGetCoursesActivities(
        courseRepository as CourseRepositoryMock,
        fromCacheOnly: true);
    CourseRepositoryMock.stubGetCoursesActivities(
        courseRepository as CourseRepositoryMock,
        fromCacheOnly: false);

    SettingsManagerMock.stubGetDashboard(settingsManager as SettingsManagerMock,
        toReturn: dashboard);

    SettingsManagerMock.stubDateTimeNow(settingsManager as SettingsManagerMock,
        toReturn: now);

    await tester.pumpWidget(
        localizedWidget(child: FeatureDiscovery(child: const DashboardView())));
    await tester.pumpAndSettle();

    // Find schedule card in second position by its title
    return tester.firstWidget(find.descendant(
      of: find.byType(Dismissible, skipOffstage: false).at(2),
      matching: find.byType(Text),
    ));
  }

  group('DashboardView - ', () {
    setUp(() async {
      intl = await setupAppIntl();
      settingsManager = setupSettingsManagerMock();
      courseRepository = setupCourseRepositoryMock();
      remoteConfigService = setupRemoteConfigServiceMock();
      setupNavigationServiceMock();
      courseRepository = setupCourseRepositoryMock();
      setupNetworkingServiceMock();
      setupAnalyticsServiceMock();
      setupAppWidgetServiceMock();
      setupPreferencesServiceMock();

      inAppReviewServiceMock =
          setupInAppReviewServiceMock() as InAppReviewServiceMock;
      InAppReviewServiceMock.stubIsAvailable(inAppReviewServiceMock,
          toReturn: false);

      CourseRepositoryMock.stubSessions(
          courseRepository as CourseRepositoryMock,
          toReturn: [session]);
      CourseRepositoryMock.stubGetSessions(
          courseRepository as CourseRepositoryMock,
          toReturn: [session]);
      CourseRepositoryMock.stubActiveSessions(
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
      CourseRepositoryMock.stubCoursesActivities(
          courseRepository as CourseRepositoryMock);
      CourseRepositoryMock.stubGetCoursesActivities(
          courseRepository as CourseRepositoryMock,
          fromCacheOnly: true);
      CourseRepositoryMock.stubGetCoursesActivities(
          courseRepository as CourseRepositoryMock,
          fromCacheOnly: false);

      RemoteConfigServiceMock.stubGetBroadcastEnabled(
          remoteConfigService as RemoteConfigServiceMock);
      RemoteConfigServiceMock.stubGetBroadcastColor(
          remoteConfigService as RemoteConfigServiceMock);
      RemoteConfigServiceMock.stubGetBroadcastEn(
          remoteConfigService as RemoteConfigServiceMock);
      RemoteConfigServiceMock.stubGetBroadcastFr(
          remoteConfigService as RemoteConfigServiceMock);
      RemoteConfigServiceMock.stubGetBroadcastTitleEn(
          remoteConfigService as RemoteConfigServiceMock);
      RemoteConfigServiceMock.stubGetBroadcastTitleFr(
          remoteConfigService as RemoteConfigServiceMock);
      RemoteConfigServiceMock.stubGetBroadcastType(
          remoteConfigService as RemoteConfigServiceMock);
      RemoteConfigServiceMock.stubGetBroadcastUrl(
          remoteConfigService as RemoteConfigServiceMock);

      SettingsManagerMock.stubGetBool(settingsManager as SettingsManagerMock,
          PreferencesFlag.discoveryDashboard,
          toReturn: true);

      SettingsManagerMock.stubSetInt(settingsManager as SettingsManagerMock,
          PreferencesFlag.broadcastCard);

      SettingsManagerMock.stubSetInt(
          settingsManager as SettingsManagerMock, PreferencesFlag.aboutUsCard);

      SettingsManagerMock.stubSetInt(
          settingsManager as SettingsManagerMock, PreferencesFlag.scheduleCard);

      SettingsManagerMock.stubSetInt(settingsManager as SettingsManagerMock,
          PreferencesFlag.progressBarCard);

      SettingsManagerMock.stubSetInt(
          settingsManager as SettingsManagerMock, PreferencesFlag.gradesCard);

      SettingsManagerMock.stubDateTimeNow(
          settingsManager as SettingsManagerMock,
          toReturn: DateTime.now());
    });

    tearDown(() {});

    group('UI - ', () {
      testWidgets('Has view title restore button and cards, displayed',
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

        // Find cards
        expect(find.byType(Card, skipOffstage: false),
            findsNWidgets(numberOfCards));
      });

      testWidgets('Has card aboutUs displayed properly',
          (WidgetTester tester) async {
        CourseRepositoryMock.stubCoursesActivities(
            courseRepository as CourseRepositoryMock,
            toReturn: activities);

        CourseRepositoryMock.stubGetCoursesActivities(
            courseRepository as CourseRepositoryMock,
            fromCacheOnly: true);
        CourseRepositoryMock.stubGetCoursesActivities(
            courseRepository as CourseRepositoryMock,
            fromCacheOnly: false);

        SettingsManagerMock.stubGetDashboard(
            settingsManager as SettingsManagerMock,
            toReturn: dashboard);

        await tester.pumpWidget(localizedWidget(
            child: FeatureDiscovery(child: const DashboardView())));
        await tester.pumpAndSettle();

        // Find aboutUs card
        final aboutUsCard = find.widgetWithText(Card, intl.card_applets_title);
        expect(aboutUsCard, findsOneWidget);

        // Find aboutUs card Text Paragraph
        final aboutUsParagraph = find.textContaining(intl.card_applets_text);
        expect(aboutUsParagraph, findsOneWidget);

        // Find aboutUs card Link Buttons
        final aboutUsLinkButtons = find.byType(IconButton);
        expect(aboutUsLinkButtons, findsNWidgets(5));
      });

      testWidgets("Has card schedule displayed today's events properly",
          (WidgetTester tester) async {
        final now = DateTime.now();
        final simulatedDate = DateTime(now.year, now.month, now.day, 8);
        final scheduleTitle =
            await testDashboardSchedule(tester, simulatedDate, activities, 3);
        expect((scheduleTitle as Text).data, intl.title_schedule);

        // Find three activities in the card
        expect(
            find.descendant(
              of: find.byType(Dismissible, skipOffstage: false),
              matching: find.byType(CourseActivityTile),
            ),
            findsNWidgets(3));
      });

      testWidgets(
          "Has card schedule displayed tomorrow events properly after today's last event",
          (WidgetTester tester) async {
        final now = DateTime.now();
        final simulatedDate = DateTime(now.year, now.month, now.day, 21, 0, 1);
        final gen104 = CourseActivity(
            courseGroup: "GEN104",
            courseName: "Generic course",
            activityName: "TD",
            activityDescription: "Activity description",
            activityLocation: "location",
            startDateTime: DateTime(now.year, now.month, now.day + 1, 9),
            endDateTime: DateTime(now.year, now.month, now.day + 1, 12));
        final courses = List<CourseActivity>.from(activities)..add(gen104);
        final scheduleTitle =
            await testDashboardSchedule(tester, simulatedDate, courses, 1);
        expect((scheduleTitle as Text).data,
            intl.title_schedule + intl.card_schedule_tomorrow);

        // Find one activities in the card
        expect(
            find.descendant(
              of: find.byType(Dismissible, skipOffstage: false),
              matching: find.byType(CourseActivityTile),
            ),
            findsNWidgets(1));
      });

      testWidgets(
          "Has card schedule displayed no event when today's last activity is finished and no events the day after",
          (WidgetTester tester) async {
        final now = DateTime.now();
        final simulatedDate = DateTime(now.year, now.month, now.day, 21, 0, 1);

        final scheduleTitle =
            await testDashboardSchedule(tester, simulatedDate, activities, 1);
        expect((scheduleTitle as Text).data, intl.title_schedule);

        // Find no activity and no grade available text boxes
        expect(
            find.descendant(
              of: find.byType(SizedBox, skipOffstage: false),
              matching: find.byType(Text),
            ),
            findsNWidgets(1));
      });
    });

    group('Interactions - ', () {
      testWidgets('AboutUsCard is dismissible and can be restored',
          (WidgetTester tester) async {
        CourseRepositoryMock.stubCoursesActivities(
            courseRepository as CourseRepositoryMock);

        CourseRepositoryMock.stubGetCoursesActivities(
            courseRepository as CourseRepositoryMock,
            fromCacheOnly: true);
        CourseRepositoryMock.stubGetCoursesActivities(
            courseRepository as CourseRepositoryMock,
            fromCacheOnly: false);

        SettingsManagerMock.stubGetDashboard(
            settingsManager as SettingsManagerMock,
            toReturn: dashboard);

        SettingsManagerMock.stubSetInt(settingsManager as SettingsManagerMock,
            PreferencesFlag.broadcastCard);

        SettingsManagerMock.stubSetInt(settingsManager as SettingsManagerMock,
            PreferencesFlag.aboutUsCard);

        SettingsManagerMock.stubSetInt(settingsManager as SettingsManagerMock,
            PreferencesFlag.scheduleCard);

        SettingsManagerMock.stubSetInt(
            settingsManager as SettingsManagerMock, PreferencesFlag.gradesCard);

        SettingsManagerMock.stubSetInt(settingsManager as SettingsManagerMock,
            PreferencesFlag.progressBarCard);

        await tester.pumpWidget(localizedWidget(
            child: FeatureDiscovery(child: const DashboardView())));
        await tester.pumpAndSettle();

        // Find Dismissible Cards
        expect(find.byType(Dismissible, skipOffstage: false),
            findsNWidgets(numberOfCards));
        expect(find.text(intl.card_applets_title), findsOneWidget);

        // Swipe Dismissible aboutUs Card horizontally
        await tester.drag(find.byType(Dismissible, skipOffstage: false).at(1),
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
        SettingsManagerMock.stubGetDashboard(
            settingsManager as SettingsManagerMock,
            toReturn: dashboard);

        CourseRepositoryMock.stubCoursesActivities(
            courseRepository as CourseRepositoryMock);
        CourseRepositoryMock.stubGetCoursesActivities(
            courseRepository as CourseRepositoryMock,
            fromCacheOnly: true);
        CourseRepositoryMock.stubGetCoursesActivities(
            courseRepository as CourseRepositoryMock,
            fromCacheOnly: false);

        SettingsManagerMock.stubSetInt(settingsManager as SettingsManagerMock,
            PreferencesFlag.broadcastCard);

        SettingsManagerMock.stubSetInt(settingsManager as SettingsManagerMock,
            PreferencesFlag.aboutUsCard);

        SettingsManagerMock.stubSetInt(settingsManager as SettingsManagerMock,
            PreferencesFlag.scheduleCard);

        SettingsManagerMock.stubSetInt(
            settingsManager as SettingsManagerMock, PreferencesFlag.gradesCard);

        SettingsManagerMock.stubSetInt(settingsManager as SettingsManagerMock,
            PreferencesFlag.progressBarCard);

        await tester.pumpWidget(localizedWidget(
            child: FeatureDiscovery(child: const DashboardView())));
        await tester.pumpAndSettle();

        // Find Dismissible Cards
        expect(find.byType(Dismissible, skipOffstage: false),
            findsNWidgets(numberOfCards));

        // Find aboutUs card
        expect(find.text(intl.card_applets_title), findsOneWidget);

        // Check that the aboutUs card is in the first position
        var text = tester.firstWidget(find.descendant(
          of: find.byType(Dismissible, skipOffstage: false).at(1),
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
        expect((text as Text).data, intl.card_applets_title);

        // Tap the restoreCards button
        await tester.tap(find.byIcon(Icons.restore));

        await tester.pumpAndSettle();

        text = tester.firstWidget(find.descendant(
          of: find.byType(Dismissible, skipOffstage: false).at(1),
          matching: find.byType(Text),
        ));

        expect(find.byType(Dismissible, skipOffstage: false),
            findsNWidgets(numberOfCards));

        // Check that the first card is now AboutUs
        expect((text as Text).data, intl.card_applets_title);
      });

      testWidgets('ScheduleCard is dismissible and can be restored',
          (WidgetTester tester) async {
        SettingsManagerMock.stubGetDashboard(
            settingsManager as SettingsManagerMock,
            toReturn: dashboard);

        await tester.pumpWidget(localizedWidget(
            child: FeatureDiscovery(child: const DashboardView())));
        await tester.pumpAndSettle();

        // Find Dismissible Cards
        expect(find.byType(Dismissible, skipOffstage: false),
            findsNWidgets(numberOfCards));
        expect(find.widgetWithText(Dismissible, intl.title_schedule),
            findsOneWidget);

        // Swipe Dismissible schedule Card horizontally
        await tester.drag(find.byType(Dismissible, skipOffstage: false).at(2),
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
        testWidgets('Has card grades displayed - with no courses',
            (WidgetTester tester) async {
          SettingsManagerMock.stubGetDashboard(
              settingsManager as SettingsManagerMock,
              toReturn: dashboard);

          await tester.pumpWidget(localizedWidget(
              child: FeatureDiscovery(child: const DashboardView())));
          await tester.pumpAndSettle();

          // Find grades card
          final gradesCard =
              find.widgetWithText(Card, intl.grades_title, skipOffstage: false);
          expect(gradesCard, findsOneWidget);

          // Find grades card Title
          final gradesTitle = find.text(intl.grades_title, skipOffstage: false);
          expect(gradesTitle, findsOneWidget);

          // Find empty grades card
          final gradesEmptyTitle = find.text(
              intl.grades_msg_no_grades.split("\n").first,
              skipOffstage: false);
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
          final gradesCard =
              find.widgetWithText(Card, intl.grades_title, skipOffstage: false);
          expect(gradesCard, findsOneWidget);

          // Find grades card Title
          final gradesTitle = find.text(intl.grades_title, skipOffstage: false);
          expect(gradesTitle, findsOneWidget);

          // Find grades buttons in the card
          final gradesButtons = find.byType(GradeButton, skipOffstage: false);
          expect(gradesButtons, findsNWidgets(2));
        });

        testWidgets('gradesCard is dismissible and can be restored',
            (WidgetTester tester) async {
          SettingsManagerMock.stubSetInt(settingsManager as SettingsManagerMock,
              PreferencesFlag.broadcastCard);

          SettingsManagerMock.stubSetInt(settingsManager as SettingsManagerMock,
              PreferencesFlag.aboutUsCard);

          SettingsManagerMock.stubSetInt(settingsManager as SettingsManagerMock,
              PreferencesFlag.scheduleCard);

          SettingsManagerMock.stubSetInt(settingsManager as SettingsManagerMock,
              PreferencesFlag.progressBarCard);

          SettingsManagerMock.stubSetInt(settingsManager as SettingsManagerMock,
              PreferencesFlag.gradesCard);
          SettingsManagerMock.stubGetDashboard(
              settingsManager as SettingsManagerMock,
              toReturn: dashboard);

          await tester.pumpWidget(localizedWidget(
              child: FeatureDiscovery(child: const DashboardView())));
          await tester.pumpAndSettle();

          // Find Dismissible Cards
          expect(find.byType(Dismissible, skipOffstage: false),
              findsNWidgets(numberOfCards));
          expect(find.text(intl.grades_title, skipOffstage: false),
              findsOneWidget);

          // Swipe Dismissible grades Card horizontally
          await tester.drag(
              find.widgetWithText(Dismissible, intl.grades_title,
                  skipOffstage: false),
              const Offset(1000.0, 0.0));

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

        await tester.pumpWidget(localizedWidget(
            child: FeatureDiscovery(child: const DashboardView())));
        await tester.pumpAndSettle();

        // Find Dismissible Cards
        expect(find.byType(Dismissible, skipOffstage: false),
            findsNWidgets(numberOfCards));
        expect(find.text(intl.progress_bar_title), findsOneWidget);

        // Swipe Dismissible progress Card horizontally
        await tester.drag(
            find.widgetWithText(Dismissible, intl.progress_bar_title),
            const Offset(1000.0, 0.0));

        // Check that the card is now absent from the view
        await tester.pumpAndSettle();
        expect(find.byType(Dismissible, skipOffstage: false),
            findsNWidgets(numberOfCards - 1));
        expect(find.text(intl.progress_bar_title), findsNothing);

        // Tap the restoreCards button
        await tester.tap(find.byIcon(Icons.restore));

        await tester.pumpAndSettle();

        // Check that the card is now present in the view
        expect(find.byType(Dismissible, skipOffstage: false),
            findsNWidgets(numberOfCards));
        expect(find.text(intl.progress_bar_title), findsOneWidget);
      });

      testWidgets('progressBarCard is reorderable and can be restored',
          (WidgetTester tester) async {
        InAppReviewServiceMock.stubIsAvailable(inAppReviewServiceMock);
        SettingsManagerMock.stubGetDashboard(
            settingsManager as SettingsManagerMock,
            toReturn: dashboard);

        await tester.pumpWidget(localizedWidget(
            child: FeatureDiscovery(child: const DashboardView())));
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

        expect(find.byType(Dismissible, skipOffstage: false),
            findsNWidgets(numberOfCards));

        // Check that the first card is now AboutUs
        expect((text as Text).data, intl.progress_bar_title);
      });
    });

    group("golden - ", () {
      setUp(() async {
        setupInAppReviewMock();
      });

      testWidgets("Applets Card", (WidgetTester tester) async {
        RemoteConfigServiceMock.stubGetBroadcastEnabled(
            remoteConfigService as RemoteConfigServiceMock,
            toReturn: false);
        tester.binding.window.physicalSizeTestValue = const Size(800, 1410);

        final Map<PreferencesFlag, int> dashboard = {
          PreferencesFlag.broadcastCard: 0,
          PreferencesFlag.aboutUsCard: 1,
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

      testWidgets("Schedule card", (WidgetTester tester) async {
        RemoteConfigServiceMock.stubGetBroadcastEnabled(
            remoteConfigService as RemoteConfigServiceMock,
            toReturn: false);
        tester.binding.window.physicalSizeTestValue = const Size(800, 1410);

        CourseRepositoryMock.stubCoursesActivities(
            courseRepository as CourseRepositoryMock);
        CourseRepositoryMock.stubGetCoursesActivities(
            courseRepository as CourseRepositoryMock,
            fromCacheOnly: true);
        CourseRepositoryMock.stubGetCoursesActivities(
            courseRepository as CourseRepositoryMock,
            fromCacheOnly: false);

        dashboard = {
          PreferencesFlag.broadcastCard: 0,
          PreferencesFlag.scheduleCard: 1,
        };

        SettingsManagerMock.stubGetDashboard(
            settingsManager as SettingsManagerMock,
            toReturn: dashboard);

        await tester.pumpWidget(localizedWidget(
            child: FeatureDiscovery(child: const DashboardView())));
        await tester.pumpAndSettle();

        await expectLater(find.byType(DashboardView),
            matchesGoldenFile(goldenFilePath("dashboardView_scheduleCard_1")));
      });
      testWidgets("progressBar Card", (WidgetTester tester) async {
        RemoteConfigServiceMock.stubGetBroadcastEnabled(
            remoteConfigService as RemoteConfigServiceMock,
            toReturn: false);
        tester.binding.window.physicalSizeTestValue = const Size(800, 1410);

        dashboard = {
          PreferencesFlag.broadcastCard: 0,
          PreferencesFlag.progressBarCard: 1,
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
    }, skip: !Platform.isLinux);
  });
}
