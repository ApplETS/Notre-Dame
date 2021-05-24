// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// MANAGERS
import 'package:notredame/core/managers/settings_manager.dart';

// CONSTANTS
import 'package:notredame/core/constants/preferences_flags.dart';

// WIDGET
import 'package:notredame/ui/widgets/schedule_settings.dart';

import '../../helpers.dart';

// MOCK
import '../../mock/managers/settings_manager_mock.dart';

void main() {
  SettingsManager settingsManager;
  AppIntl intl;

  // Some settings
  final Map<PreferencesFlag, dynamic> settings = {
    PreferencesFlag.scheduleSettingsCalendarFormat: CalendarFormat.week,
    PreferencesFlag.scheduleSettingsStartWeekday: StartingDayOfWeek.monday,
    PreferencesFlag.scheduleSettingsShowTodayBtn: true
  };

  group("ScheduleSettings - ", () {
    setUp(() async {
      settingsManager = setupSettingsManagerMock();
      intl = await setupAppIntl();
    });

    group("ui - ", () {
      testWidgets("With handle", (WidgetTester tester) async {
        SettingsManagerMock.stubGetScheduleSettings(
            settingsManager as SettingsManagerMock,
            toReturn: settings);

        await tester
            .pumpWidget(localizedWidget(child: const ScheduleSettings()));
        await tester.pumpAndSettle();

        // Check the handle
        expect(
            find.byWidgetPredicate((widget) =>
                widget is Container &&
                (widget.decoration as BoxDecoration).color == Colors.grey),
            findsOneWidget,
            reason: "The handle should be grey");

        // Check the title
        expect(find.text(intl.schedule_settings_title), findsOneWidget);

        // Check calendar format section
        expect(find.text(intl.schedule_settings_calendar_format_pref),
            findsOneWidget);
        expect(
            find.widgetWithText(
                ListTile, intl.schedule_settings_calendar_format_2_weeks),
            findsOneWidget);
        expect(
            find.widgetWithText(
                ListTile, intl.schedule_settings_calendar_format_month),
            findsOneWidget);

        final weekFormatTile = find.widgetWithText(
            ListTile, intl.schedule_settings_calendar_format_week);
        expect(weekFormatTile, findsOneWidget);
        expect(
            tester.widget(weekFormatTile),
            isA<ListTile>()
                .having((source) => source.selected, 'selected', isTrue),
            reason:
                'The settings says week format is the current format, the UI should reflet that.');

        // Check starting day of week section
        expect(find.text(intl.schedule_settings_starting_weekday_pref),
            findsOneWidget);
        expect(
            find.widgetWithText(
                ListTile, intl.schedule_settings_starting_weekday_saturday,
                skipOffstage: false),
            findsOneWidget);
        expect(
            find.widgetWithText(
                ListTile, intl.schedule_settings_starting_weekday_sunday,
                skipOffstage: false),
            findsOneWidget);

        final startingDayTile = find.widgetWithText(
            ListTile, intl.schedule_settings_starting_weekday_monday,
            skipOffstage: false);
        expect(startingDayTile, findsOneWidget);
        expect(
            tester.widget(startingDayTile),
            isA<ListTile>()
                .having((source) => source.selected, 'selected', isTrue),
            reason:
                'The settings says starting day of week is monday, the UI should reflet that.');

        // Check showTodayButton section
        final showTodayBtnFinder = find.widgetWithText(
            ListTile, intl.schedule_settings_show_today_btn_pref,
            skipOffstage: false);
        expect(showTodayBtnFinder, findsOneWidget);
        expect(
            tester.widget(showTodayBtnFinder),
            isA<ListTile>().having(
                (source) => source.trailing, 'trailing', isA<Switch>()));

        expect(
            tester.widget(find.descendant(
                of: showTodayBtnFinder,
                matching: find.byType(Switch, skipOffstage: false))),
            isA<Switch>().having((source) => source.value, 'value', isTrue),
            reason:
                "the settings says that the showTodayBtn is enabled, the UI should reflet that.");
      });

      testWidgets("Without handle", (WidgetTester tester) async {
        SettingsManagerMock.stubGetScheduleSettings(
            settingsManager as SettingsManagerMock,
            toReturn: settings);

        await tester.pumpWidget(
            localizedWidget(child: const ScheduleSettings(showHandle: false)));
        await tester.pumpAndSettle();

        expect(
            find.byWidgetPredicate((widget) =>
                widget is Container &&
                (widget.decoration as BoxDecoration).color == Colors.grey),
            findsNothing,
            reason: "There should not have a handle.");

        expect(find.text(intl.schedule_settings_title), findsOneWidget);

        // Check calendar format section
        expect(find.text(intl.schedule_settings_calendar_format_pref),
            findsOneWidget);
        expect(
            find.widgetWithText(
                ListTile, intl.schedule_settings_calendar_format_2_weeks),
            findsOneWidget);
        expect(
            find.widgetWithText(
                ListTile, intl.schedule_settings_calendar_format_month),
            findsOneWidget);

        final weekFormatTile = find.widgetWithText(
            ListTile, intl.schedule_settings_calendar_format_week);
        expect(weekFormatTile, findsOneWidget);
        expect(
            tester.widget(weekFormatTile),
            isA<ListTile>()
                .having((source) => source.selected, 'selected', isTrue),
            reason:
                'The settings says week format is the current format, the UI should reflet that.');

        // Check starting day of week section
        expect(find.text(intl.schedule_settings_starting_weekday_pref),
            findsOneWidget);

        expect(
            find.widgetWithText(
                ListTile, intl.schedule_settings_starting_weekday_saturday,
                skipOffstage: false),
            findsOneWidget);
        expect(
            find.widgetWithText(
                ListTile, intl.schedule_settings_starting_weekday_sunday,
                skipOffstage: false),
            findsOneWidget);

        final startingDayTile = find.widgetWithText(
            ListTile, intl.schedule_settings_starting_weekday_monday,
            skipOffstage: false);
        expect(startingDayTile, findsOneWidget);
        expect(
            tester.widget(startingDayTile),
            isA<ListTile>()
                .having((source) => source.selected, 'selected', isTrue),
            reason:
                'The settings says starting day of week is monday, the UI should reflet that.');

        // Check showTodayButton section
        final showTodayBtnFinder = find.widgetWithText(
            ListTile, intl.schedule_settings_show_today_btn_pref,
            skipOffstage: false);
        expect(showTodayBtnFinder, findsOneWidget);
        expect(
            tester.widget(showTodayBtnFinder),
            isA<ListTile>().having(
                (source) => source.trailing, 'trailing', isA<Switch>()));
        expect(
            tester.widget(find.descendant(
                of: showTodayBtnFinder,
                matching: find.byType(Switch, skipOffstage: false))),
            isA<Switch>().having((source) => source.value, 'value', isTrue),
            reason:
                "the settings says that the showTodayBtn is enabled, the UI should reflet that.");
      });
    });

    group("interactions - ", () {
      testWidgets("onChange calendarFormat", (WidgetTester tester) async {
        SettingsManagerMock.stubGetScheduleSettings(
            settingsManager as SettingsManagerMock,
            toReturn: settings);
        SettingsManagerMock.stubSetString(
            settingsManager as SettingsManagerMock,
            PreferencesFlag.scheduleSettingsCalendarFormat);

        await tester.pumpWidget(
            localizedWidget(child: const ScheduleSettings(showHandle: false)));
        await tester.pumpAndSettle();

        await tester.tap(find.widgetWithText(
            ListTile, intl.schedule_settings_calendar_format_2_weeks));
        await tester.pump();

        await untilCalled(settingsManager.setString(
            PreferencesFlag.scheduleSettingsCalendarFormat, any));

        final formatTile = find.widgetWithText(
            ListTile, intl.schedule_settings_calendar_format_2_weeks);
        expect(
            tester.widget(formatTile),
            isA<ListTile>()
                .having((source) => source.selected, 'selected', isTrue),
            reason:
                'The settings says 2 week format now, the UI should reflet that.');
      });

      testWidgets("onChange showTodayBtn", (WidgetTester tester) async {
        SettingsManagerMock.stubGetScheduleSettings(
            settingsManager as SettingsManagerMock,
            toReturn: settings);
        SettingsManagerMock.stubSetBool(settingsManager as SettingsManagerMock,
            PreferencesFlag.scheduleSettingsShowTodayBtn);

        await tester.pumpWidget(
            localizedWidget(child: const ScheduleSettings(showHandle: false)));
        await tester.pumpAndSettle();

        final showTodayBtnFinder = find.widgetWithText(
            ListTile, intl.schedule_settings_show_today_btn_pref,
            skipOffstage: false);

        expect(find.byType(Switch, skipOffstage: false), findsOneWidget);
        // Currently the await tester.tap on a switch in a tile isn't working. Workaround:
        (find.byType(Switch, skipOffstage: false).evaluate().single.widget
                as Switch)
            .onChanged(false);

        await tester.pumpAndSettle();

        await untilCalled(settingsManager.setBool(
            PreferencesFlag.scheduleSettingsShowTodayBtn, any));

        expect(
            tester.widget(find.descendant(
                of: showTodayBtnFinder,
                matching: find.byType(Switch, skipOffstage: false))),
            isA<Switch>().having((source) => source.value, 'value', isFalse),
            reason:
                "the settings says that the showTodayBtn is enabled, the UI should reflet that.");
      });
    });
  });
}
