// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:feature_discovery/feature_discovery.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:notredame/constants/preferences_flags.dart';
import 'package:notredame/constants/update_code.dart';
import 'package:notredame/features/app/signets-api/models/course.dart';
import 'package:notredame/features/app/signets-api/models/course_activity.dart';
import 'package:notredame/features/app/signets-api/models/session.dart';
import 'package:notredame/features/app/widgets/dismissible_card.dart';
import 'package:notredame/features/dashboard/dashboard_view.dart';
import 'package:notredame/features/dashboard/widgets/course_activity_tile.dart';
import 'package:notredame/features/student/grades/widgets/grade_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../helpers.dart';
import '../../mock/managers/course_repository_mock.dart';
import '../../mock/managers/settings_manager_mock.dart';
import '../../mock/services/in_app_review_service_mock.dart';
import '../../mock/services/remote_config_service_mock.dart';

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
  Map<PreferencesFlag, int> dashboard = {
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
    CourseRepositoryMock.stubCoursesActivities(courseRepositoryMock,
        toReturn: courses);

    CourseRepositoryMock.stubGetCoursesActivities(courseRepositoryMock,
        fromCacheOnly: true);
    CourseRepositoryMock.stubGetCoursesActivities(courseRepositoryMock);

    SettingsManagerMock.stubGetDashboard(settingsManagerMock,
        toReturn: dashboard);

    SettingsManagerMock.stubDateTimeNow(settingsManagerMock, toReturn: now);

    await tester.pumpWidget(localizedWidget(
        child: FeatureDiscovery(
            child: const DashboardView(updateCode: UpdateCode.none))));
    await tester.pumpAndSettle();

    // Find schedule card in second position by its title
    return tester.firstWidget(find.descendant(
      of: find.byType(Dismissible, skipOffstage: false).at(1),
      matching: find.byType(Text),
    ));
  }

  group('DashboardView - ', () {
    setUp(() async {
      intl = await setupAppIntl();
      settingsManagerMock = setupSettingsManagerMock();
      courseRepositoryMock = setupCourseRepositoryMock();
      remoteConfigServiceMock = setupRemoteConfigServiceMock();
      setupNavigationServiceMock();
      courseRepositoryMock = setupCourseRepositoryMock();
      setupNetworkingServiceMock();
      setupAnalyticsServiceMock();
      setupPreferencesServiceMock();
      // TODO: Remove when 4.51.0 is released
      SharedPreferences.setMockInitialValues({});
      // End TODO: Remove when 4.51.0 is released

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
            findsNWidgets(2));
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

      group('UI - gradesCard', () {
        testWidgets('Has card grades displayed - with no courses',
            (WidgetTester tester) async {
          SettingsManagerMock.stubGetDashboard(settingsManagerMock,
              toReturn: dashboard);

          await tester.pumpWidget(localizedWidget(
              child: FeatureDiscovery(
                  child: const DashboardView(updateCode: UpdateCode.none))));
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
          CourseRepositoryMock.stubCourses(courseRepositoryMock,
              toReturn: courses);
          CourseRepositoryMock.stubGetCourses(courseRepositoryMock,
              fromCacheOnly: true, toReturn: courses);
          CourseRepositoryMock.stubGetCourses(courseRepositoryMock,
              toReturn: courses);

          SettingsManagerMock.stubGetDashboard(settingsManagerMock,
              toReturn: dashboard);

          await tester.pumpWidget(localizedWidget(
              child: FeatureDiscovery(
                  child: const DashboardView(updateCode: UpdateCode.none))));
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
          SettingsManagerMock.stubSetInt(
              settingsManagerMock, PreferencesFlag.aboutUsCard);

          SettingsManagerMock.stubSetInt(
              settingsManagerMock, PreferencesFlag.scheduleCard);

          SettingsManagerMock.stubSetInt(
              settingsManagerMock, PreferencesFlag.progressBarCard);

          SettingsManagerMock.stubSetInt(
              settingsManagerMock, PreferencesFlag.gradesCard);
          SettingsManagerMock.stubGetDashboard(settingsManagerMock,
              toReturn: dashboard);

          await tester.pumpWidget(localizedWidget(
              child: FeatureDiscovery(
                  child: const DashboardView(updateCode: UpdateCode.none))));
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
        SettingsManagerMock.stubGetDashboard(settingsManagerMock,
            toReturn: dashboard);

        await tester.pumpWidget(localizedWidget(
            child: FeatureDiscovery(
                child: const DashboardView(updateCode: UpdateCode.none))));
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
        SettingsManagerMock.stubGetDashboard(settingsManagerMock,
            toReturn: dashboard);

        await tester.pumpWidget(localizedWidget(
            child: FeatureDiscovery(
                child: const DashboardView(updateCode: UpdateCode.none))));
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
        SettingsManagerMock.stubGetDashboard(settingsManagerMock,
            toReturn: dashboard);

        await tester.pumpWidget(localizedWidget(
            child: FeatureDiscovery(
                child: const DashboardView(updateCode: UpdateCode.none))));
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

    group("golden - ", () {
      setUp(() async {
        setupInAppReviewMock();
      });

      testWidgets("Applets Card", (WidgetTester tester) async {
        RemoteConfigServiceMock.stubGetBroadcastEnabled(remoteConfigServiceMock,
            toReturn: false);
        tester.view.physicalSize = const Size(800, 1410);

        final Map<PreferencesFlag, int> dashboard = {
          PreferencesFlag.gradesCard: 0,
          PreferencesFlag.aboutUsCard: 1,
        };

        SettingsManagerMock.stubGetDashboard(settingsManagerMock,
            toReturn: dashboard);

        await tester.pumpWidget(localizedWidget(
            child: FeatureDiscovery(
                child: const DashboardView(updateCode: UpdateCode.none))));
        await tester.pumpAndSettle();

        await expectLater(find.byType(DashboardView),
            matchesGoldenFile(goldenFilePath("dashboardView_appletsCard_1")));
      });

      testWidgets("Schedule card", (WidgetTester tester) async {
        RemoteConfigServiceMock.stubGetBroadcastEnabled(remoteConfigServiceMock,
            toReturn: false);
        tester.view.physicalSize = const Size(800, 1410);

        CourseRepositoryMock.stubCoursesActivities(courseRepositoryMock);
        CourseRepositoryMock.stubGetCoursesActivities(courseRepositoryMock,
            fromCacheOnly: true);
        CourseRepositoryMock.stubGetCoursesActivities(courseRepositoryMock);

        dashboard = {
          PreferencesFlag.gradesCard: 0,
          PreferencesFlag.scheduleCard: 1,
        };

        SettingsManagerMock.stubGetDashboard(settingsManagerMock,
            toReturn: dashboard);

        await tester.pumpWidget(localizedWidget(
            child: FeatureDiscovery(
                child: const DashboardView(updateCode: UpdateCode.none))));
        await tester.pumpAndSettle();

        await expectLater(find.byType(DashboardView),
            matchesGoldenFile(goldenFilePath("dashboardView_scheduleCard_1")));
      });
      testWidgets("progressBar Card", (WidgetTester tester) async {
        RemoteConfigServiceMock.stubGetBroadcastEnabled(remoteConfigServiceMock,
            toReturn: false);
        tester.view.physicalSize = const Size(800, 1410);

        dashboard = {
          PreferencesFlag.gradesCard: 0,
          PreferencesFlag.progressBarCard: 1,
        };

        SettingsManagerMock.stubGetDashboard(settingsManagerMock,
            toReturn: dashboard);

        await tester.pumpWidget(localizedWidget(
            child: FeatureDiscovery(
                child: const DashboardView(updateCode: UpdateCode.none))));
        await tester.pumpAndSettle();

        await expectLater(
            find.byType(DashboardView),
            matchesGoldenFile(
                goldenFilePath("dashboardView_progressBarCard_1")));
      });
    }, skip: !Platform.isLinux);
  });
}
