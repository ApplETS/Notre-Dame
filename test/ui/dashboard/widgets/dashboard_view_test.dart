import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:notredame/domain/constants/preferences_flags.dart';
import 'package:notredame/ui/dashboard/widgets/dashboard_view.dart';

import '../../../data/mocks/repositories/course_repository_mock.dart';
import '../../../data/mocks/repositories/settings_repository_mock.dart';
import '../../../data/mocks/services/in_app_review_service_mock.dart';
import '../../../data/mocks/services/remote_config_service_mock.dart';
import '../../../helpers.dart';


void main() {
  late AppIntl intl;

  final dashboard = {
    PreferencesFlag.aboutUsCard: 0,
    PreferencesFlag.scheduleCard: 1,
    PreferencesFlag.progressBarCard: 2,
    PreferencesFlag.gradesCard: 3
  };

  final numberOfCards = dashboard.entries.length;

  setUp(() async {
    intl = await setupAppIntl();
    final settingsManagerMock = setupSettingsRepositoryMock();
    setupCourseRepositoryMock();
    final remoteConfigServiceMock = setupRemoteConfigServiceMock();
    setupNavigationServiceMock();
    final courseRepositoryMock = setupCourseRepositoryMock();
    setupNetworkingServiceMock();
    setupAnalyticsServiceMock();
    setupLaunchUrlServiceMock();
    setupPreferencesServiceMock();
    setupBroadcastMessageRepositoryMock();

    final inAppReviewServiceMock = setupInAppReviewServiceMock();
    InAppReviewServiceMock.stubIsAvailable(inAppReviewServiceMock,
        toReturn: false);

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

    SettingsRepositoryMock.stubGetDashboard(settingsManagerMock,
        toReturn: dashboard);
  });



  group('UI - ', () {
    testWidgets('Has view title restore button and cards, displayed',
            (WidgetTester tester) async {
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

  Future dragWidget(WidgetTester tester, String cardTitle) async {
    final finder = find.widgetWithText(Dismissible, cardTitle,
        skipOffstage: false);
    await tester.scrollUntilVisible(finder, 100);
    await tester.pumpAndSettle();
  }

  group("Dismiss and restore - ", () {
    Future swipeAndRestore(WidgetTester tester, String cardTitle, int index, {bool dragUntilVisible = false}) async {
      await tester.pumpWidget(localizedWidget(child: const DashboardView()));
      await tester.pumpAndSettle();

      if(dragUntilVisible) {
        await dragWidget(tester, cardTitle);
      }

      // Find Dismissible Cards
      expect(find.byType(Dismissible, skipOffstage: false),
          findsNWidgets(numberOfCards));
      expect(find.widgetWithText(Dismissible, cardTitle),
          findsOneWidget);

      // Swipe Dismissible schedule Card horizontally
      await tester.drag(find.byType(Dismissible, skipOffstage: false).at(index),
          const Offset(1000.0, 0.0));

      // Check that the card is now absent from the view
      await tester.pumpAndSettle();

      expect(find.byType(Dismissible, skipOffstage: false),
          findsNWidgets(numberOfCards - 1));
      expect(find.widgetWithText(Dismissible, cardTitle),
          findsNothing);

      // Tap the restoreCards button
      await tester.tap(find.byIcon(Icons.restore));

      await tester.pumpAndSettle();

      // Check that the card is now present in the view
      expect(find.byType(Dismissible, skipOffstage: false),
          findsNWidgets(numberOfCards));
      expect(find.widgetWithText(Dismissible, cardTitle),
          findsOneWidget);
    }

    testWidgets('AboutUsCard is dismissible and can be restored', (tester) async {
      await swipeAndRestore(tester, intl.card_applets_title, dashboard[PreferencesFlag.aboutUsCard]!);
    });

    testWidgets('ScheduleCard is dismissible and can be restored', (tester) async {
      await swipeAndRestore(tester, intl.title_schedule, dashboard[PreferencesFlag.scheduleCard]!);
    });

    testWidgets('ProgressBarCard is dismissible and can be restored', (tester) async {
      await swipeAndRestore(tester, intl.progress_bar_title, dashboard[PreferencesFlag.progressBarCard]!);
    });

    testWidgets('GradesCard is dismissible and can be restored', (tester) async {
      await swipeAndRestore(tester, intl.grades_title, dashboard[PreferencesFlag.gradesCard]!, dragUntilVisible: true);
    });
  });

  group("Reorder and restore - ", () {
    Future<void> longPressDrag(
        WidgetTester tester, Offset start, Offset end) async {
      final TestGesture drag = await tester.startGesture(start);
      await tester.pump(const Duration(seconds: 1));
      await drag.moveTo(end);
      await tester.pump(const Duration(seconds: 1));
      await drag.up();
    }

    Future reorderAndRestore(WidgetTester tester, {required String initialCardTitle, required String destinationCardTitle, bool dragUntilVisible = false}) async {
      await tester.pumpWidget(localizedWidget(child: const DashboardView()));
      await tester.pumpAndSettle();

      // Find Dismissible Cards
      expect(find.byType(Dismissible, skipOffstage: false),
          findsNWidgets(numberOfCards));

      if(dragUntilVisible) {
        await dragWidget(tester, initialCardTitle);
      }

      final initialCard = find.widgetWithText(Dismissible, initialCardTitle);
      final destinationCard = find.widgetWithText(Dismissible, destinationCardTitle);
      expect(initialCard, findsOneWidget);

      var text = tester.firstWidget(find.descendant(
        of: find.widgetWithText(Dismissible, initialCardTitle).first,
        matching: find.byType(Text),
      ));

      expect((text as Text).data, initialCardTitle);

      await longPressDrag(
          tester,
          tester.getCenter(initialCard),
          tester.getCenter(destinationCard) +
              const Offset(0.0, 1000));

      await tester.pumpAndSettle();

      expect(find.byType(Dismissible, skipOffstage: false),
          findsNWidgets(numberOfCards));

      final discardCard = find.widgetWithText(
          Dismissible, initialCardTitle,
          skipOffstage: false);
      await tester.ensureVisible(discardCard);
      await tester.pumpAndSettle();

      text = tester.firstWidget(find.descendant(
        of: discardCard,
        matching: find.byType(Text),
      ));
      expect(text.data, initialCardTitle);

      // Tap the restoreCards button
      await tester.tap(find.byIcon(Icons.restore));

      await tester.pumpAndSettle();

      text = tester.firstWidget(find.descendant(
        of: find.widgetWithText(Dismissible, initialCardTitle).first,
        matching: find.byType(Text),
      ));

      expect(find.byType(Dismissible, skipOffstage: false),
          findsNWidgets(numberOfCards));

      // Check that the first card is now AboutUs
      expect(text.data, initialCardTitle);
    }

    testWidgets('AboutUsCard is reorderable and can be restored', (tester) async {
      await reorderAndRestore(tester, initialCardTitle: intl.card_applets_title, destinationCardTitle: intl.progress_bar_title);
    });

    testWidgets('ScheduleCard is reorderable and can be restored', (tester) async {
      await reorderAndRestore(tester, initialCardTitle: intl.title_schedule, destinationCardTitle: intl.card_applets_title);
    });

    testWidgets('ProgressBarCard is reorderable and can be restored', (tester) async {
      await reorderAndRestore(tester, initialCardTitle: intl.progress_bar_title, destinationCardTitle: intl.title_schedule);
    });

    testWidgets('GradesCard is reorderable and can be restored', (tester) async {
      await reorderAndRestore(tester, initialCardTitle: intl.progress_bar_title, destinationCardTitle: intl.title_schedule);
    });
  });
}
