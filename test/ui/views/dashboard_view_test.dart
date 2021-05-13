// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// MANAGERS
import 'package:notredame/core/managers/settings_manager.dart';

// VIEW
import 'package:notredame/ui/views/dashboard_view.dart';

// CONSTANTS
import 'package:notredame/core/constants/preferences_flags.dart';

// OTHERS
import '../../helpers.dart';

// MOCKS
import '../../mock/managers/settings_manager_mock.dart';

void main() {
  SettingsManager settingsManager;
  AppIntl intl;

  // Cards
  final Map<PreferencesFlag, int> dashboard = {
    PreferencesFlag.aboutUsCard: 0,
    PreferencesFlag.scheduleCard: 1,
    PreferencesFlag.progressBarCard: 2
  };

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
    });

    tearDown(() {});

    group('UI - ', () {
      testWidgets('Has view title and restore button, displayed',
          (WidgetTester tester) async {
        SettingsManagerMock.stubGetDashboard(
            settingsManager as SettingsManagerMock,
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
      });

      testWidgets('Has card aboutUs displayed', (WidgetTester tester) async {
        SettingsManagerMock.stubGetDashboard(
            settingsManager as SettingsManagerMock,
            toReturn: dashboard);

        await tester.pumpWidget(localizedWidget(child: const DashboardView()));
        await tester.pumpAndSettle();

        // Find aboutUs card
        final aboutUsCard = find.byType(Card);
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

        await tester.pumpWidget(localizedWidget(child: const DashboardView()));
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
        final String progressBarCard =
            PreferencesFlag.progressBarCard.toString();

        SettingsManagerMock.stubGetDashboard(
            settingsManager as SettingsManagerMock,
            toReturn: dashboard);

        SettingsManagerMock.stubSetInt(settingsManager as SettingsManagerMock,
            PreferencesFlag.aboutUsCard);

        SettingsManagerMock.stubSetInt(settingsManager as SettingsManagerMock,
            PreferencesFlag.scheduleCard);

        SettingsManagerMock.stubSetInt(settingsManager as SettingsManagerMock,
            PreferencesFlag.progressBarCard);

        await tester.pumpWidget(localizedWidget(child: const DashboardView()));
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
            tester.getCenter(find.text(progressBarCard)) +
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

    group("golden - ", () {
      testWidgets("default view", (WidgetTester tester) async {
        tester.binding.window.physicalSizeTestValue = const Size(800, 1410);

        SettingsManagerMock.stubGetDashboard(
            settingsManager as SettingsManagerMock,
            toReturn: dashboard);

        await tester.pumpWidget(localizedWidget(child: const DashboardView()));
        await tester.pumpAndSettle();

        await expectLater(find.byType(DashboardView),
            matchesGoldenFile(goldenFilePath("dashboardView_1")));
      });
    });
  });
}
