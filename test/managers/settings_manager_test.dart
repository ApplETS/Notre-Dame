// FLUTTER / DART / THIRD-PARTIES
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:table_calendar/table_calendar.dart';

// MANAGER
import 'package:notredame/core/managers/settings_manager.dart';
import 'package:notredame/core/services/analytics_service.dart';

// SERVICE
import 'package:notredame/core/services/preferences_service.dart';

// CONSTANTS
import 'package:notredame/core/constants/preferences_flags.dart';

// GENERATED
import 'package:notredame/generated/l10n.dart';

import '../helpers.dart';

// MOCK
import '../mock/services/preferences_service_mock.dart';

void main() {
  AnalyticsService analyticsService;
  PreferencesService preferencesService;
  SettingsManager manager;
  AppIntl appIntl;

  group("SettingsManager - ", () {
    setUp(() async {
      // Setting up mocks
      setupLogger();
      analyticsService = setupAnalyticsServiceMock();
      preferencesService = setupPreferencesServiceMock();

      appIntl = await setupAppIntl();

      manager = SettingsManager();
    });

    tearDown(() {
      unregister<PreferencesService>();
    });

    group("getScheduleSettings - ", () {
      test("validate default behaviour", () async {
        final expected = {
          PreferencesFlag.scheduleSettingsStartWeekday:
              StartingDayOfWeek.monday,
          PreferencesFlag.scheduleSettingsCalendarFormat: CalendarFormat.week,
          PreferencesFlag.scheduleSettingsShowTodayBtn: true
        };

        final result = await manager.getScheduleSettings();

        expect(result, expected);

        verify(preferencesService
                .getString(PreferencesFlag.scheduleSettingsStartWeekday))
            .called(1);
        verify(preferencesService
                .getString(PreferencesFlag.scheduleSettingsCalendarFormat))
            .called(1);
        verify(preferencesService
                .getBool(PreferencesFlag.scheduleSettingsShowTodayBtn))
            .called(1);

        verifyNoMoreInteractions(preferencesService);
        verifyNoMoreInteractions(analyticsService);
      });

      test("validate the loading of the settings", () async {
        // Stubs the answer of the preferences services
        PreferencesServiceMock.stubGetString(
            preferencesService as PreferencesServiceMock,
            PreferencesFlag.scheduleSettingsStartWeekday,
            toReturn: EnumToString.convertToString(StartingDayOfWeek.sunday));
        PreferencesServiceMock.stubGetString(
            preferencesService as PreferencesServiceMock,
            PreferencesFlag.scheduleSettingsCalendarFormat,
            toReturn: EnumToString.convertToString(CalendarFormat.month));
        PreferencesServiceMock.stubGetBool(
            preferencesService as PreferencesServiceMock,
            PreferencesFlag.scheduleSettingsShowTodayBtn,
            toReturn: false);

        final expected = {
          PreferencesFlag.scheduleSettingsStartWeekday:
              StartingDayOfWeek.sunday,
          PreferencesFlag.scheduleSettingsCalendarFormat: CalendarFormat.month,
          PreferencesFlag.scheduleSettingsShowTodayBtn: false
        };

        final result = await manager.getScheduleSettings();

        expect(result, expected);

        verify(preferencesService
                .getString(PreferencesFlag.scheduleSettingsStartWeekday))
            .called(1);
        verify(preferencesService
                .getString(PreferencesFlag.scheduleSettingsCalendarFormat))
            .called(1);
        verify(preferencesService
                .getBool(PreferencesFlag.scheduleSettingsShowTodayBtn))
            .called(1);

        verifyNoMoreInteractions(preferencesService);
        verifyNoMoreInteractions(analyticsService);
      });
    });

    group("ThemeMode - ", () {
      test("validate default behaviour", () async {

        PreferencesServiceMock.stubGetString(
            preferencesService as PreferencesServiceMock,
            PreferencesFlag.theme,
            toReturn: 'test theme');

        final result = manager.themeMode;

        verify(preferencesService
            .getString(PreferencesFlag.theme))
            .called(1);

        verifyNoMoreInteractions(preferencesService);
        verifyNoMoreInteractions(analyticsService);
      });

      test("set light/dark/system mode", () async {

        var result = manager.setLightMode();

        verify(preferencesService
            .setString(PreferencesFlag.theme, 'light'))
            .called(1);

        result = manager.setDarkMode();

        verify(preferencesService
            .setString(PreferencesFlag.theme, 'dark'))
            .called(1);

        result = manager.setSystemMode();

        verify(preferencesService
            .setString(PreferencesFlag.theme, 'system'))
            .called(1);

        verifyNoMoreInteractions(preferencesService);
        verifyNoMoreInteractions(analyticsService);
      });
    });

    group("Locale - ", () {
      test("validate default behaviour", () async {

        PreferencesServiceMock.stubGetString(
            preferencesService as PreferencesServiceMock,
            PreferencesFlag.locale,
            toReturn: 'test locale');

        final result = manager.locale;

        verify(preferencesService
            .getString(PreferencesFlag.locale))
            .called(1);

        verifyNoMoreInteractions(preferencesService);
        verifyNoMoreInteractions(analyticsService);
      });

      test("set french/english", () async {

        var result = manager.setFrench();

        verify(preferencesService
            .setString(PreferencesFlag.locale, 'Français'))
            .called(1);

        result = manager.setEnglish();

        verify(preferencesService
            .setString(PreferencesFlag.locale, 'English'))
            .called(1);

        verifyNoMoreInteractions(preferencesService);
        verifyNoMoreInteractions(analyticsService);
      });
    });

    test("setString", () async {
      const flag = PreferencesFlag.scheduleSettingsCalendarFormat;
      PreferencesServiceMock.stubSetString(
          preferencesService as PreferencesServiceMock,
          flag);

      expect(
          await manager.setString(
              flag, "test"),
          true, reason: "setString should return true if the PreferenceService return true");

      untilCalled(analyticsService.logEvent(
          "${SettingsManager.tag}-${EnumToString.convertToString(flag)}",
          any));

      verify(analyticsService.logEvent(
              "${SettingsManager.tag}-${EnumToString.convertToString(flag)}",
              any))
          .called(1);
      verify(preferencesService.setString(flag, any));
    });

    test("getString", () async {
      const flag = PreferencesFlag.scheduleSettingsCalendarFormat;
      PreferencesServiceMock.stubGetString(
          preferencesService as PreferencesServiceMock,
          flag);

      expect(
          await manager.getString(
              flag),
          'test', reason: "setString should return true if the PreferenceService return true");

      untilCalled(analyticsService.logEvent(
          "${SettingsManager.tag}-${EnumToString.convertToString(flag)}",
          any));

      verify(analyticsService.logEvent(
          "${SettingsManager.tag}-${EnumToString.convertToString(flag)}",
          any))
          .called(1);
      verify(preferencesService.getString(flag));
    });

    test("setBool", () async {
      const flag = PreferencesFlag.scheduleSettingsCalendarFormat;
      PreferencesServiceMock.stubSetBool(
          preferencesService as PreferencesServiceMock,
          flag);

      expect(
          await manager.setBool(
              flag, true),
          true, reason: "setString should return true if the PreferenceService return true");

      untilCalled(analyticsService.logEvent(
          "${SettingsManager.tag}-${EnumToString.convertToString(flag)}",
          any));

      verify(analyticsService.logEvent(
          "${SettingsManager.tag}-${EnumToString.convertToString(flag)}",
          any))
          .called(1);
      verify(preferencesService.setBool(flag, value: anyNamed("value")));
    });
  });
}
