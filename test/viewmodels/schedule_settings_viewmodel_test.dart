// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:table_calendar/table_calendar.dart';

// MANAGER
import 'package:notredame/core/managers/settings_manager.dart';

// VIEWMODEL
import 'package:notredame/core/viewmodels/schedule_settings_viewmodel.dart';

// CONSTANTS
import 'package:notredame/core/constants/preferences_flags.dart';

// OTHER
import '../helpers.dart';
import '../mock/managers/settings_manager_mock.dart';

SettingsManager settingsManager;
ScheduleSettingsViewModel viewModel;

void main() {
  final Map<PreferencesFlag, dynamic> settings = {
    PreferencesFlag.scheduleSettingsCalendarFormat: CalendarFormat.week,
    PreferencesFlag.scheduleSettingsStartWeekday: StartingDayOfWeek.monday,
    PreferencesFlag.scheduleSettingsShowTodayBtn: true
  };

  group("ScheduleSettingsViewModel - ", () {
    setUp(() {
      settingsManager = setupSettingsManagerMock();

      viewModel = ScheduleSettingsViewModel();
    });

    group("futureToRun - ", () {
      test("The settings are correctly loaded and sets", () async {
        SettingsManagerMock.stubGetScheduleSettings(
            settingsManager as SettingsManagerMock,
            toReturn: settings);

        expect(await viewModel.futureToRun(), settings);
        expect(viewModel.calendarFormat,
            settings[PreferencesFlag.scheduleSettingsCalendarFormat]);
        expect(viewModel.startingDayOfWeek,
            settings[PreferencesFlag.scheduleSettingsStartWeekday]);
        expect(viewModel.showTodayBtn,
            settings[PreferencesFlag.scheduleSettingsShowTodayBtn]);

        verify(settingsManager.getScheduleSettings()).called(1);
        verifyNoMoreInteractions(settingsManager);
      });
    });

    group("setter calendarFormat - ", () {
      test("calendarFormat is updated on the settings", () async {
        SettingsManagerMock.stubSetString(
            settingsManager as SettingsManagerMock,
            PreferencesFlag.scheduleSettingsCalendarFormat);

        // Call the setter.
        viewModel.calendarFormat = CalendarFormat.twoWeeks;

        await untilCalled(settingsManager.setString(
            PreferencesFlag.scheduleSettingsCalendarFormat, any));

        expect(viewModel.calendarFormat, CalendarFormat.twoWeeks);
        expect(viewModel.isBusy, false);

        verify(settingsManager.setString(
                PreferencesFlag.scheduleSettingsCalendarFormat, any))
            .called(1);
        verifyNoMoreInteractions(settingsManager);
      });
    });

    group("setter startingDayOfWeek - ", () {
      test("startingDayOfWeek is updated on the settings", () async {
        SettingsManagerMock.stubSetString(
            settingsManager as SettingsManagerMock,
            PreferencesFlag.scheduleSettingsStartWeekday);

        // Call the setter.
        viewModel.startingDayOfWeek = StartingDayOfWeek.friday;

        await untilCalled(settingsManager.setString(
            PreferencesFlag.scheduleSettingsStartWeekday, any));

        expect(viewModel.startingDayOfWeek, StartingDayOfWeek.friday);
        expect(viewModel.isBusy, false);

        verify(settingsManager.setString(
                PreferencesFlag.scheduleSettingsStartWeekday, any))
            .called(1);
        verifyNoMoreInteractions(settingsManager);
      });
    });

    group("setter showTodayBtn - ", () {
      test("showTodayBtn is updated on the settings", () async {
        SettingsManagerMock.stubSetString(
            settingsManager as SettingsManagerMock,
            PreferencesFlag.scheduleSettingsStartWeekday);

        const expected = false;

        // Call the setter.
        viewModel.showTodayBtn = expected;

        await untilCalled(settingsManager.setBool(
            PreferencesFlag.scheduleSettingsShowTodayBtn, any));

        expect(viewModel.showTodayBtn, expected);
        expect(viewModel.isBusy, false);

        verify(settingsManager.setBool(
                PreferencesFlag.scheduleSettingsShowTodayBtn, any))
            .called(1);
        verifyNoMoreInteractions(settingsManager);
      });
    });
  });
}
