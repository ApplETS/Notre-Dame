// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

// Project imports:
import 'package:notredame/data/services/networking_service.dart';
import 'package:notredame/l10n/app_localizations.dart';
import 'package:notredame/ui/core/ui/titled_card.dart';
import 'package:notredame/ui/more/settings/widgets/settings_view.dart';
import '../../../../data/mocks/repositories/settings_repository_mock.dart';
import '../../../../data/mocks/services/analytics_service_mock.dart';
import '../../../../helpers.dart';

void main() {
  late AppIntl intl;
  late SettingsRepositoryMock settingsManagerMock;

  group('SettingsView - ', () {
    setUp(() async {
      intl = await setupAppIntl();
      setupNavigationServiceMock();
      setupNetworkingServiceMock();
      setupCacheManagerMock();
      settingsManagerMock = setupSettingsRepositoryMock();
      setupAnalyticsServiceMock();
    });

    tearDown(() {
      unregister<NetworkingService>();
      unregister<AnalyticsServiceMock>();
    });

    group('UI - ', () {
      testWidgets('contains two TitledCards with correct titles', (WidgetTester tester) async {
        await tester.pumpWidget(localizedWidget(child: SettingsView()));
        await tester.pumpAndSettle();

        // Check that there are two TitledCards
        expect(find.byType(TitledCard), findsNWidgets(2));

        // Verify the titles of the cards (using localized strings)
        expect(find.text(intl.settings_display_pref_category), findsOneWidget);
        expect(find.text(intl.settings_language_pref), findsOneWidget);
      });

      testWidgets('contains three SegmentedButtons (theme, dashboard format, language)', (WidgetTester tester) async {
        await tester.pumpWidget(localizedWidget(child: SettingsView()));
        await tester.pumpAndSettle();

        // There should be three SegmentedButton widgets
        expect(find.byType(SegmentedButton<ThemeMode>), findsOneWidget);
        expect(find.byType(SegmentedButton<bool>), findsOneWidget);
        expect(find.byType(SegmentedButton<Locale>), findsOneWidget);
      });
    });

    group('Theme selection - ', () {
      testWidgets('changing theme to light updates the selected segment', (WidgetTester tester) async {
        SettingsRepositoryMock.stubThemeMode(settingsManagerMock, toReturn: ThemeMode.system);
        await tester.pumpWidget(localizedWidget(child: SettingsView()));
        await tester.pumpAndSettle();

        // Find the theme SegmentedButton
        final themeButton = tester.widget<SegmentedButton<ThemeMode>>(find.byType(SegmentedButton<ThemeMode>).first);
        final initialSelected = themeButton.selected;

        // Tap on the light theme segment
        await tester.tap(find.text(intl.light_theme).first);

        // We simulate that the tap changed the setting in the repository
        SettingsRepositoryMock.stubThemeMode(settingsManagerMock, toReturn: ThemeMode.light);
        await tester.pump();

        verify(settingsManagerMock.themeMode = ThemeMode.light).called(1);

        // Verify the selected now selects light mode
        final updatedButton = tester.widget<SegmentedButton<ThemeMode>>(find.byType(SegmentedButton<ThemeMode>).first);
        expect(updatedButton.selected, contains(ThemeMode.light));
        expect(updatedButton.selected, isNot(equals(initialSelected)));
      });

      testWidgets('changing theme to dark updates the selected segment', (WidgetTester tester) async {
        SettingsRepositoryMock.stubThemeMode(settingsManagerMock, toReturn: ThemeMode.system);
        await tester.pumpWidget(localizedWidget(child: SettingsView()));
        await tester.pumpAndSettle();

        // Find the theme SegmentedButton
        final themeButton = tester.widget<SegmentedButton<ThemeMode>>(find.byType(SegmentedButton<ThemeMode>).first);
        final initialSelected = themeButton.selected;

        // Tap on the light theme segment
        await tester.tap(find.text(intl.dark_theme).first);

        // We simulate that the tap changed the setting in the repository
        SettingsRepositoryMock.stubThemeMode(settingsManagerMock, toReturn: ThemeMode.dark);
        await tester.pump();

        verify(settingsManagerMock.themeMode = ThemeMode.dark).called(1);

        // Verify the selected now selects light mode
        final updatedButton = tester.widget<SegmentedButton<ThemeMode>>(find.byType(SegmentedButton<ThemeMode>).first);
        expect(updatedButton.selected, contains(ThemeMode.dark));
        expect(updatedButton.selected, isNot(equals(initialSelected)));
      });

      testWidgets('changing theme to system updates the selected segment', (WidgetTester tester) async {
        SettingsRepositoryMock.stubThemeMode(settingsManagerMock, toReturn: ThemeMode.light);
        await tester.pumpWidget(localizedWidget(child: SettingsView()));
        await tester.pumpAndSettle();

        // Find the theme SegmentedButton
        final themeButton = tester.widget<SegmentedButton<ThemeMode>>(find.byType(SegmentedButton<ThemeMode>).first);
        final initialSelected = themeButton.selected;

        // Tap on the light theme segment
        await tester.tap(find.text(intl.system_theme).first);

        // We simulate that the tap changed the setting in the repository
        SettingsRepositoryMock.stubThemeMode(settingsManagerMock, toReturn: ThemeMode.system);
        await tester.pump();

        verify(settingsManagerMock.themeMode = ThemeMode.system).called(1);

        // Verify the selected now selects light mode
        final updatedButton = tester.widget<SegmentedButton<ThemeMode>>(find.byType(SegmentedButton<ThemeMode>).first);
        expect(updatedButton.selected, contains(ThemeMode.system));
        expect(updatedButton.selected, isNot(equals(initialSelected)));
      });
    });

    group('Dashboard schedule format selection - ', () {
      testWidgets('list view', (WidgetTester tester) async {
        SettingsRepositoryMock.stubDashboardScheduleAsList(settingsManagerMock, toReturn: false);
        await tester.pumpWidget(localizedWidget(child: SettingsView()));
        await tester.pumpAndSettle();

        // Find the theme SegmentedButton
        final themeButton = tester.widget<SegmentedButton<bool>>(find.byType(SegmentedButton<bool>).first);
        final initialSelected = themeButton.selected;

        // Tap on the list segment
        await tester.tap(find.text(intl.settings_dashboard_schedule_format_list).first);

        // We simulate that the tap changed the setting in the repository
        SettingsRepositoryMock.stubDashboardScheduleAsList(settingsManagerMock, toReturn: true);
        await tester.pump();

        verify(settingsManagerMock.dashboard.displayScheduleAsList = true).called(1);

        // Verify the selected now selects light mode
        final updatedButton = tester.widget<SegmentedButton<bool>>(find.byType(SegmentedButton<bool>).first);
        expect(updatedButton.selected, contains(true));
        expect(updatedButton.selected, isNot(equals(initialSelected)));
      });

      testWidgets('calendar view', (WidgetTester tester) async {
        SettingsRepositoryMock.stubDashboardScheduleAsList(settingsManagerMock, toReturn: true);
        await tester.pumpWidget(localizedWidget(child: SettingsView()));
        await tester.pumpAndSettle();

        // Find the theme SegmentedButton
        final themeButton = tester.widget<SegmentedButton<bool>>(find.byType(SegmentedButton<bool>).first);
        final initialSelected = themeButton.selected;

        // Tap on the list segment
        await tester.tap(find.text(intl.settings_dashboard_schedule_format_calendar).first);

        // We simulate that the tap changed the setting in the repository
        SettingsRepositoryMock.stubDashboardScheduleAsList(settingsManagerMock, toReturn: false);
        await tester.pump();

        verify(settingsManagerMock.dashboard.displayScheduleAsList = false).called(1);

        // Verify the selected now selects light mode
        final updatedButton = tester.widget<SegmentedButton<bool>>(find.byType(SegmentedButton<bool>).first);
        expect(updatedButton.selected, contains(false));
        expect(updatedButton.selected, isNot(equals(initialSelected)));
      });
    });

    group('Language selection - ', () {
      testWidgets('english', (WidgetTester tester) async {
        SettingsRepositoryMock.stubLocale(settingsManagerMock, toReturn: Locale('fr'));
        await tester.pumpWidget(localizedWidget(child: SettingsView()));
        await tester.pumpAndSettle();

        // Find the locale SegmentedButton
        final themeButton = tester.widget<SegmentedButton<Locale>>(find.byType(SegmentedButton<Locale>).first);
        final initialSelected = themeButton.selected;

        // Tap on the list segment
        await tester.tap(find.text(intl.settings_english).first);

        // We simulate that the tap changed the setting in the repository
        SettingsRepositoryMock.stubLocale(settingsManagerMock, toReturn: Locale('en'));
        await tester.pump();

        verify(settingsManagerMock.locale = Locale('en')).called(1);

        // Verify the selected now selects light mode
        final updatedButton = tester.widget<SegmentedButton<Locale>>(find.byType(SegmentedButton<Locale>).first);
        expect(updatedButton.selected, contains(Locale('en')));
        expect(updatedButton.selected, isNot(equals(initialSelected)));
      });

      testWidgets('french', (WidgetTester tester) async {
        SettingsRepositoryMock.stubLocale(settingsManagerMock, toReturn: Locale('en'));
        await tester.pumpWidget(localizedWidget(child: SettingsView()));
        await tester.pumpAndSettle();

        // Find the locale SegmentedButton
        final themeButton = tester.widget<SegmentedButton<Locale>>(find.byType(SegmentedButton<Locale>).first);
        final initialSelected = themeButton.selected;

        // Tap on the list segment
        await tester.tap(find.text(intl.settings_french).first);

        // We simulate that the tap changed the setting in the repository
        SettingsRepositoryMock.stubLocale(settingsManagerMock, toReturn: Locale('fr'));
        await tester.pump();

        verify(settingsManagerMock.locale = Locale('fr')).called(1);

        // Verify the selected now selects light mode
        final updatedButton = tester.widget<SegmentedButton<Locale>>(find.byType(SegmentedButton<Locale>).first);
        expect(updatedButton.selected, contains(Locale('fr')));
        expect(updatedButton.selected, isNot(equals(initialSelected)));
      });
    });
  });
}
