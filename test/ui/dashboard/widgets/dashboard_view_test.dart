import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:notredame/data/models/broadcast_message.dart';
import 'package:notredame/domain/broadcast_icon_type.dart';
import 'package:notredame/domain/constants/preferences_flags.dart';
import 'package:notredame/ui/dashboard/widgets/broadcast_message_card.dart';
import 'package:notredame/ui/dashboard/widgets/dashboard_view.dart';

import '../../../data/mocks/repositories/broadcast_message_repository_mock.dart';
import '../../../data/mocks/repositories/course_repository_mock.dart';
import '../../../data/mocks/repositories/settings_repository_mock.dart';
import '../../../data/mocks/services/in_app_review_service_mock.dart';
import '../../../data/mocks/services/remote_config_service_mock.dart';
import '../../../helpers.dart';


void main() {
  late AppIntl intl;
  late BroadcastMessageRepositoryMock broadcastMessageRepositoryMock;
  late RemoteConfigServiceMock remoteConfigServiceMock;

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
    remoteConfigServiceMock = setupRemoteConfigServiceMock();
    final courseRepositoryMock = setupCourseRepositoryMock();

    setupCourseRepositoryMock();
    setupNavigationServiceMock();
    setupNetworkingServiceMock();
    setupAnalyticsServiceMock();
    setupLaunchUrlServiceMock();
    setupPreferencesServiceMock();
    broadcastMessageRepositoryMock = setupBroadcastMessageRepositoryMock();

    final inAppReviewServiceMock = setupInAppReviewServiceMock();
    InAppReviewServiceMock.stubIsAvailable(inAppReviewServiceMock, toReturn: false);

    CourseRepositoryMock.stubCourses(courseRepositoryMock);
    CourseRepositoryMock.stubGetCourses(courseRepositoryMock, fromCacheOnly: true);
    CourseRepositoryMock.stubGetCourses(courseRepositoryMock);
    CourseRepositoryMock.stubCoursesActivities(courseRepositoryMock);
    CourseRepositoryMock.stubGetCoursesActivities(courseRepositoryMock, fromCacheOnly: true);

    RemoteConfigServiceMock.stubGetBroadcastEnabled(remoteConfigServiceMock, toReturn: false);

    for (var flag in [
      PreferencesFlag.aboutUsCard,
      PreferencesFlag.scheduleCard,
      PreferencesFlag.progressBarCard,
      PreferencesFlag.gradesCard
    ]) {
      SettingsRepositoryMock.stubSetInt(settingsManagerMock, flag);
    }

    SettingsRepositoryMock.stubDateTimeNow(settingsManagerMock, toReturn: DateTime.now());
    SettingsRepositoryMock.stubGetDashboard(settingsManagerMock, toReturn: dashboard);
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
    void expectTextMatches(WidgetTester tester, Finder cardFinder, String expectedText) {
      final textWidget = tester.firstWidget<Text>(find.descendant(
        of: cardFinder.first,
        matching: find.byType(Text),
      ));
      expect(textWidget.data, expectedText);
    }

    Future reorderAndRestore(
        WidgetTester tester, {
          required String initialCardTitle,
          required String destinationCardTitle,
          bool dragUntilVisible = false,
        }) async {
      await tester.pumpWidget(localizedWidget(child: const DashboardView()));
      await tester.pumpAndSettle();

      expect(find.byType(Dismissible, skipOffstage: false), findsNWidgets(numberOfCards));

      if (dragUntilVisible) {
        await dragWidget(tester, initialCardTitle);
      }

      final initialCard = find.widgetWithText(Dismissible, initialCardTitle);
      final destinationCard = find.widgetWithText(Dismissible, destinationCardTitle);

      expect(initialCard, findsOneWidget);
      expectTextMatches(tester, initialCard, initialCardTitle);

      await longPressDrag(
        tester,
        tester.getCenter(initialCard),
        tester.getCenter(destinationCard) + const Offset(0.0, 1000),
      );
      await tester.pumpAndSettle();

      expect(find.byType(Dismissible, skipOffstage: false), findsNWidgets(numberOfCards));

      final discardCard = find.widgetWithText(Dismissible, initialCardTitle, skipOffstage: false);
      await tester.ensureVisible(discardCard);
      await tester.pumpAndSettle();
      expectTextMatches(tester, discardCard, initialCardTitle);

      await tester.tap(find.byIcon(Icons.restore));
      await tester.pumpAndSettle();

      expect(find.byType(Dismissible, skipOffstage: false), findsNWidgets(numberOfCards));
      expectTextMatches(tester, find.widgetWithText(Dismissible, initialCardTitle), initialCardTitle);
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
  
  testWidgets("Test BroadcastMessage not empty displays BroadcastMesssageCard", (tester) async {
    RemoteConfigServiceMock.stubGetBroadcastEnabled(remoteConfigServiceMock, toReturn: true);
    BroadcastMessageRepositoryMock.stubGetBroadcastMessage(broadcastMessageRepositoryMock, "en", BroadcastMessage(message: "Test", title: "Test title", color: Color(0xFFFF9000), url: "https://example.com", type: BroadcastIconType.alert));

    await tester.pumpWidget(localizedWidget(child: const DashboardView()));
    await tester.pumpAndSettle();

    expect(find.byType(BroadcastMessageCard), findsOneWidget);
  });
}
