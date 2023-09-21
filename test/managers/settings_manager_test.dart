// FLUTTER / DART / THIRD-PARTIES
import 'package:calendar_view/calendar_view.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:mockito/mockito.dart';
import 'package:table_calendar/table_calendar.dart';

// MANAGER
import 'package:notredame/core/managers/settings_manager.dart';
import 'package:notredame/core/services/analytics_service.dart';

// SERVICE
import 'package:notredame/core/services/preferences_service.dart';
import 'package:notredame/core/services/remote_config_service.dart';

// CONSTANTS
import 'package:notredame/core/constants/preferences_flags.dart';

import '../helpers.dart';

// MOCK
import '../mock/services/preferences_service_mock.dart';
import '../mock/services/remote_config_service_mock.dart';

void main() {
  AnalyticsService analyticsService;
  RemoteConfigService remoteConfigService;
  PreferencesService preferencesService;
  SettingsManager manager;

  group("SettingsManager - ", () {
    setUp(() async {
      // Setting up mocks
      setupLogger();
      analyticsService = setupAnalyticsServiceMock();
      preferencesService = setupPreferencesServiceMock();
      remoteConfigService = setupRemoteConfigServiceMock();

      await setupAppIntl();

      manager = SettingsManager();
    });

    tearDown(() {
      unregister<PreferencesService>();
    });

    group("getScheduleSettings - ", () {
      test("validate default behaviour", () async {
        // Stubs the answer of the preferences services
        PreferencesServiceMock.stubGetString(
            preferencesService as PreferencesServiceMock,
            PreferencesFlag.scheduleStartWeekday,
            toReturn: null);
        PreferencesServiceMock.stubGetString(
            preferencesService as PreferencesServiceMock,
            PreferencesFlag.scheduleOtherWeekday,
            toReturn: null);
        PreferencesServiceMock.stubGetString(
            preferencesService as PreferencesServiceMock,
            PreferencesFlag.scheduleCalendarFormat,
            toReturn: null);
        PreferencesServiceMock.stubGetBool(
            preferencesService as PreferencesServiceMock,
            PreferencesFlag.scheduleShowTodayBtn,
            toReturn: null);
        PreferencesServiceMock.stubGetBool(
            preferencesService as PreferencesServiceMock,
            PreferencesFlag.scheduleListView,
            toReturn: null);
        PreferencesServiceMock.stubGetBool(
            preferencesService as PreferencesServiceMock,
            PreferencesFlag.scheduleShowWeekEvents,
            toReturn: null);
        RemoteConfigServiceMock.stubGetCalendarViewEnabled(
            remoteConfigService as RemoteConfigServiceMock);

        final expected = {
          PreferencesFlag.scheduleOtherWeekday: WeekDays.monday,
          PreferencesFlag.scheduleStartWeekday: StartingDayOfWeek.monday,
          PreferencesFlag.scheduleCalendarFormat: CalendarFormat.week,
          PreferencesFlag.scheduleShowTodayBtn: true,
          PreferencesFlag.scheduleListView: getCalendarViewEnabled(),
          PreferencesFlag.scheduleShowWeekEvents: true,
        };

        final result = await manager.getScheduleSettings();

        expect(result, expected);

        verify(preferencesService
                .getString(PreferencesFlag.scheduleStartWeekday))
            .called(1);
        verify(preferencesService
                .getString(PreferencesFlag.scheduleOtherWeekday))
            .called(1);
        verify(preferencesService
                .getString(PreferencesFlag.scheduleCalendarFormat))
            .called(1);
        verify(preferencesService.getBool(PreferencesFlag.scheduleShowTodayBtn))
            .called(1);
        verify(preferencesService.getBool(PreferencesFlag.scheduleListView))
            .called(1);
        verify(preferencesService
                .getBool(PreferencesFlag.scheduleShowWeekEvents))
            .called(1);

        verifyNoMoreInteractions(preferencesService);
        verifyNoMoreInteractions(analyticsService);
      });

      test("validate the loading of the settings", () async {
        // Stubs the answer of the preferences services
        PreferencesServiceMock.stubGetString(
            preferencesService as PreferencesServiceMock,
            PreferencesFlag.scheduleStartWeekday,
            toReturn: EnumToString.convertToString(StartingDayOfWeek.sunday));
        PreferencesServiceMock.stubGetString(
            preferencesService as PreferencesServiceMock,
            PreferencesFlag.scheduleOtherWeekday,
            toReturn: EnumToString.convertToString(WeekDays.monday));
        PreferencesServiceMock.stubGetString(
            preferencesService as PreferencesServiceMock,
            PreferencesFlag.scheduleCalendarFormat,
            toReturn: EnumToString.convertToString(CalendarFormat.month));
        PreferencesServiceMock.stubGetBool(
            preferencesService as PreferencesServiceMock,
            PreferencesFlag.scheduleShowTodayBtn,
            toReturn: false);
        PreferencesServiceMock.stubGetBool(
            preferencesService as PreferencesServiceMock,
            PreferencesFlag.scheduleListView,
            toReturn: false);
        PreferencesServiceMock.stubGetBool(
            preferencesService as PreferencesServiceMock,
            PreferencesFlag.scheduleShowWeekEvents,
            toReturn: false);

        final expected = {
          PreferencesFlag.scheduleOtherWeekday: WeekDays.monday,
          PreferencesFlag.scheduleStartWeekday: StartingDayOfWeek.sunday,
          PreferencesFlag.scheduleCalendarFormat: CalendarFormat.month,
          PreferencesFlag.scheduleShowTodayBtn: false,
          PreferencesFlag.scheduleListView: false,
          PreferencesFlag.scheduleShowWeekEvents: false,
        };

        final result = await manager.getScheduleSettings();

        expect(result, expected);

        verify(preferencesService
                .getString(PreferencesFlag.scheduleOtherWeekday))
            .called(1);
        verify(preferencesService
                .getString(PreferencesFlag.scheduleStartWeekday))
            .called(1);
        verify(preferencesService
                .getString(PreferencesFlag.scheduleCalendarFormat))
            .called(1);
        verify(preferencesService.getBool(PreferencesFlag.scheduleShowTodayBtn))
            .called(1);
        verify(preferencesService.getBool(PreferencesFlag.scheduleListView))
            .called(1);
        verify(preferencesService
                .getBool(PreferencesFlag.scheduleShowWeekEvents))
            .called(1);

        verifyNoMoreInteractions(preferencesService);
        verifyNoMoreInteractions(analyticsService);
      });
    });

    group("ThemeMode - ", () {
      test("set light/dark/system mode", () async {
        const flag = PreferencesFlag.theme;
        manager.setThemeMode(ThemeMode.light);

        verify(preferencesService.setString(
                PreferencesFlag.theme, ThemeMode.light.toString()))
            .called(1);

        verify(analyticsService.logEvent(
                "${SettingsManager.tag}_${EnumToString.convertToString(flag)}",
                any))
            .called(1);

        manager.setThemeMode(ThemeMode.dark);

        verify(preferencesService.setString(
                PreferencesFlag.theme, ThemeMode.dark.toString()))
            .called(1);

        verify(analyticsService.logEvent(
                "${SettingsManager.tag}_${EnumToString.convertToString(flag)}",
                any))
            .called(1);

        manager.setThemeMode(ThemeMode.system);

        verify(preferencesService.setString(
                PreferencesFlag.theme, ThemeMode.system.toString()))
            .called(1);

        verify(analyticsService.logEvent(
                "${SettingsManager.tag}_${EnumToString.convertToString(flag)}",
                any))
            .called(1);

        verifyNoMoreInteractions(preferencesService);
        verifyNoMoreInteractions(analyticsService);
      });

      test("validate default behaviour", () async {
        const flag = PreferencesFlag.theme;
        PreferencesServiceMock.stubGetString(
            preferencesService as PreferencesServiceMock, flag,
            toReturn: ThemeMode.light.toString());

        manager.themeMode;
        await untilCalled(preferencesService.getString(flag));

        expect(manager.themeMode, ThemeMode.light);

        verify(preferencesService.getString(flag)).called(2);

        verifyNoMoreInteractions(preferencesService);
      });
    });

    group("Locale - ", () {
      test("validate default behaviour", () async {
        const flag = PreferencesFlag.locale;
        PreferencesServiceMock.stubGetString(
            preferencesService as PreferencesServiceMock,
            PreferencesFlag.locale,
            toReturn: const Locale('fr').toString());

        manager.setLocale('fr');
        manager.locale;

        verify(preferencesService.setString(PreferencesFlag.locale, 'fr'))
            .called(1);
        verify(preferencesService.getString(PreferencesFlag.locale)).called(1);

        verify(analyticsService.logEvent(
                "${SettingsManager.tag}_${EnumToString.convertToString(flag)}",
                any))
            .called(1);

        verifyNoMoreInteractions(preferencesService);
        verifyNoMoreInteractions(analyticsService);
      });

      test("set french/english", () async {
        const flag = PreferencesFlag.locale;
        manager.setLocale('fr');

        verify(preferencesService.setString(PreferencesFlag.locale, 'fr'))
            .called(1);

        untilCalled(analyticsService.logEvent(
            "${SettingsManager.tag}_${EnumToString.convertToString(flag)}",
            any));

        verify(analyticsService.logEvent(
                "${SettingsManager.tag}_${EnumToString.convertToString(flag)}",
                any))
            .called(1);

        manager.setLocale('en');

        verify(preferencesService.setString(PreferencesFlag.locale, 'en'))
            .called(1);

        untilCalled(analyticsService.logEvent(
            "${SettingsManager.tag}_${EnumToString.convertToString(flag)}",
            any));

        verify(analyticsService.logEvent(
                "${SettingsManager.tag}_${EnumToString.convertToString(flag)}",
                any))
            .called(1);

        verifyNoMoreInteractions(preferencesService);
        verifyNoMoreInteractions(analyticsService);
      });

      test("default locale isn't set", () {
        const flag = PreferencesFlag.locale;
        when((preferencesService as PreferencesServiceMock).getString(flag))
            .thenAnswer((_) async => null);

        expect(manager.locale, const Locale('en'));

        verify(preferencesService.getString(PreferencesFlag.locale)).called(1);

        verifyNoMoreInteractions(preferencesService);
        verifyNoMoreInteractions(analyticsService);
      });
    });

    test("fetch theme and locale", () async {
      PreferencesServiceMock.stubGetString(
          preferencesService as PreferencesServiceMock, PreferencesFlag.locale,
          toReturn: const Locale('fr').toString());
      PreferencesServiceMock.stubGetString(
          preferencesService as PreferencesServiceMock, PreferencesFlag.theme,
          toReturn: 'ThemeMode.system');

      await manager.fetchLanguageAndThemeMode();

      verify(preferencesService.getString(PreferencesFlag.theme)).called(1);
      verify(preferencesService.getString(PreferencesFlag.locale)).called(1);

      verifyNoMoreInteractions(preferencesService);
      verifyNoMoreInteractions(analyticsService);
    });

    test("reset language and theme", () async {
      // Set local and theme
      PreferencesServiceMock.stubGetString(
          preferencesService as PreferencesServiceMock, PreferencesFlag.locale,
          toReturn: const Locale('fr').toString());
      PreferencesServiceMock.stubGetString(
          preferencesService as PreferencesServiceMock, PreferencesFlag.theme,
          toReturn: 'ThemeMode.system');

      await manager.fetchLanguageAndThemeMode();

      expect(manager.themeMode, ThemeMode.system,
          reason: "Loaded theme mode should be system");
      expect(manager.locale, const Locale('fr'),
          reason: "Loaded locale should be french");

      manager.resetLanguageAndThemeMode();

      expect(manager.themeMode, null,
          reason: "Default theme mode should be null");
      expect(manager.locale, Locale(Intl.systemLocale.split('_')[0]),
          reason: "Default locale should be system language");
    });

    test("setString", () async {
      const flag = PreferencesFlag.scheduleCalendarFormat;
      PreferencesServiceMock.stubSetString(
          preferencesService as PreferencesServiceMock, flag);

      expect(await manager.setString(flag, "test"), true,
          reason:
              "setString should return true if the PreferenceService return true");

      untilCalled(analyticsService.logEvent(
          "${SettingsManager.tag}_${EnumToString.convertToString(flag)}", any));

      verify(analyticsService.logEvent(
              "${SettingsManager.tag}_${EnumToString.convertToString(flag)}",
              any))
          .called(1);
      verify(preferencesService.setString(flag, any));
    });

    test("setInt", () async {
      const flag = PreferencesFlag.aboutUsCard;
      PreferencesServiceMock.stubSetInt(
          preferencesService as PreferencesServiceMock, flag);

      expect(await manager.setInt(flag, 0), true,
          reason:
              "setInt should return true if the PreferenceService return true");

      untilCalled(analyticsService.logEvent(
          "${SettingsManager.tag}_${EnumToString.convertToString(flag)}", any));

      verify(analyticsService.logEvent(
              "${SettingsManager.tag}_${EnumToString.convertToString(flag)}",
              any))
          .called(1);
      verify(preferencesService.setInt(flag, any));
    });

    test("getString", () async {
      const flag = PreferencesFlag.scheduleCalendarFormat;
      PreferencesServiceMock.stubGetString(
          preferencesService as PreferencesServiceMock, flag);

      expect(await manager.getString(flag), 'test',
          reason:
              "setString should return true if the PreferenceService return true");

      untilCalled(analyticsService.logEvent(
          "${SettingsManager.tag}_${EnumToString.convertToString(flag)}", any));

      verify(analyticsService.logEvent(
              "${SettingsManager.tag}_${EnumToString.convertToString(flag)}",
              any))
          .called(1);
      verify(preferencesService.getString(flag));
    });

    test("setBool", () async {
      const flag = PreferencesFlag.scheduleCalendarFormat;
      PreferencesServiceMock.stubSetBool(
          preferencesService as PreferencesServiceMock, flag);

      expect(await manager.setBool(flag, true), true,
          reason:
              "setString should return true if the PreferenceService return true");

      untilCalled(analyticsService.logEvent(
          "${SettingsManager.tag}_${EnumToString.convertToString(flag)}", any));

      verify(analyticsService.logEvent(
              "${SettingsManager.tag}_${EnumToString.convertToString(flag)}",
              any))
          .called(1);
      verify(preferencesService.setBool(flag, value: anyNamed("value")));
    });

    group("Dashboard - ", () {
      test("validate default behaviour", () async {
        PreferencesServiceMock.stubGetInt(
            preferencesService as PreferencesServiceMock,
            PreferencesFlag.aboutUsCard,
            toReturn: null);
        PreferencesServiceMock.stubGetInt(
            preferencesService as PreferencesServiceMock,
            PreferencesFlag.scheduleCard,
            toReturn: null);
        PreferencesServiceMock.stubGetInt(
            preferencesService as PreferencesServiceMock,
            PreferencesFlag.progressBarCard,
            toReturn: null);
        PreferencesServiceMock.stubGetInt(
            preferencesService as PreferencesServiceMock,
            PreferencesFlag.gradesCard,
            toReturn: null);

        // Cards
        final Map<PreferencesFlag, int> expected = {
          PreferencesFlag.broadcastCard: 0,
          PreferencesFlag.aboutUsCard: 1,
          PreferencesFlag.scheduleCard: 2,
          PreferencesFlag.progressBarCard: 3,
          PreferencesFlag.gradesCard: 4
        };

        expect(
          await manager.getDashboard(),
          expected,
        );

        verify(preferencesService.getInt(PreferencesFlag.broadcastCard))
            .called(1);
        verify(preferencesService.getInt(PreferencesFlag.aboutUsCard))
            .called(1);
        verify(preferencesService.getInt(PreferencesFlag.scheduleCard))
            .called(1);
        verify(preferencesService.getInt(PreferencesFlag.progressBarCard))
            .called(1);
        verify(preferencesService.getInt(PreferencesFlag.gradesCard)).called(1);

        verifyNoMoreInteractions(preferencesService);
        verifyNoMoreInteractions(analyticsService);
      });

      test("validate the loading of the cards", () async {
        PreferencesServiceMock.stubGetInt(
            preferencesService as PreferencesServiceMock,
            PreferencesFlag.broadcastCard,
            toReturn: 0);
        PreferencesServiceMock.stubGetInt(
            preferencesService as PreferencesServiceMock,
            PreferencesFlag.aboutUsCard,
            toReturn: 2);
        PreferencesServiceMock.stubGetInt(
            preferencesService as PreferencesServiceMock,
            PreferencesFlag.scheduleCard,
            toReturn: 3);
        PreferencesServiceMock.stubGetInt(
            preferencesService as PreferencesServiceMock,
            PreferencesFlag.progressBarCard,
            // ignore: avoid_redundant_argument_values
            toReturn: 1);
        PreferencesServiceMock.stubGetInt(
            preferencesService as PreferencesServiceMock,
            PreferencesFlag.gradesCard,
            toReturn: 4);

        // Cards
        final Map<PreferencesFlag, int> expected = {
          PreferencesFlag.broadcastCard: 0,
          PreferencesFlag.aboutUsCard: 2,
          PreferencesFlag.scheduleCard: 3,
          PreferencesFlag.progressBarCard: 1,
          PreferencesFlag.gradesCard: 4
        };

        expect(
          await manager.getDashboard(),
          expected,
        );

        verify(preferencesService.getInt(PreferencesFlag.broadcastCard))
            .called(1);
        verify(preferencesService.getInt(PreferencesFlag.aboutUsCard))
            .called(1);
        verify(preferencesService.getInt(PreferencesFlag.scheduleCard))
            .called(1);
        verify(preferencesService.getInt(PreferencesFlag.progressBarCard))
            .called(1);
        verify(preferencesService.getInt(PreferencesFlag.gradesCard)).called(1);

        verifyNoMoreInteractions(preferencesService);
        verifyNoMoreInteractions(analyticsService);
      });
    });
  });
}
