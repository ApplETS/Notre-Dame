// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:mockito/mockito.dart';
import 'package:notredame/data/services/calendar_service.dart';

// Project imports:
import 'package:notredame/domain/constants/preferences_flags.dart';
import 'package:notredame/data/services/preferences_service.dart';
import 'package:notredame/data/repositories/settings_repository.dart';
import '../../helpers.dart';
import '../mocks/services/analytics_service_mock.dart';
import '../mocks/services/remote_config_service_mock.dart';
import '../mocks/services/preferences_service_mock.dart';

void main() {
  late AnalyticsServiceMock analyticsServiceMock;
  late RemoteConfigServiceMock remoteConfigServiceMock;
  late PreferencesServiceMock preferencesServiceMock;

  late SettingsRepository repository;

  group("SettingsRepository - ", () {
    setUp(() async {
      // Setting up mocks
      setupLogger();
      analyticsServiceMock = setupAnalyticsServiceMock();
      preferencesServiceMock = setupPreferencesServiceMock();
      remoteConfigServiceMock = setupRemoteConfigServiceMock();

      await setupAppIntl();

      repository = SettingsRepository();
    });

    tearDown(() {
      unregister<PreferencesService>();
    });

    group("getScheduleSettings - ", () {
      test("validate default behaviour", () async {
        // Stubs the answer of the preferences services
        PreferencesServiceMock.stubGetString(
            preferencesServiceMock, PreferencesFlag.scheduleCalendarFormat,
            toReturn: null);
        PreferencesServiceMock.stubGetBool(
            preferencesServiceMock, PreferencesFlag.scheduleShowTodayBtn,
            toReturn: null);
        PreferencesServiceMock.stubGetBool(
            preferencesServiceMock, PreferencesFlag.scheduleListView,
            toReturn: null);
        RemoteConfigServiceMock.stubGetCalendarViewEnabled(
            remoteConfigServiceMock);

        final expected = {
          PreferencesFlag.scheduleCalendarFormat: CalendarTimeFormat.week,
          PreferencesFlag.scheduleShowTodayBtn: true,
          PreferencesFlag.scheduleListView: getCalendarViewEnabled(),
        };

        final result = await repository.getScheduleSettings();

        expect(result, expected);

        verify(preferencesServiceMock
                .getString(PreferencesFlag.scheduleCalendarFormat))
            .called(1);
        verify(preferencesServiceMock
                .getBool(PreferencesFlag.scheduleShowTodayBtn))
            .called(1);
        verify(preferencesServiceMock.getBool(PreferencesFlag.scheduleListView))
            .called(1);

        verifyNoMoreInteractions(preferencesServiceMock);
        verifyNoMoreInteractions(analyticsServiceMock);
      });

      test("validate the loading of the settings", () async {
        // Stubs the answer of the preferences services
        PreferencesServiceMock.stubGetString(
            preferencesServiceMock, PreferencesFlag.scheduleCalendarFormat,
            toReturn: CalendarTimeFormat.month.name);
        PreferencesServiceMock.stubGetBool(
            preferencesServiceMock, PreferencesFlag.scheduleShowTodayBtn,
            toReturn: false);
        PreferencesServiceMock.stubGetBool(
            preferencesServiceMock, PreferencesFlag.scheduleListView,
            toReturn: false);

        final expected = {
          PreferencesFlag.scheduleCalendarFormat: CalendarTimeFormat.month,
          PreferencesFlag.scheduleShowTodayBtn: false,
          PreferencesFlag.scheduleListView: false,
        };

        final result = await repository.getScheduleSettings();

        expect(result, expected);

        verify(preferencesServiceMock
                .getString(PreferencesFlag.scheduleCalendarFormat))
            .called(1);
        verify(preferencesServiceMock
                .getBool(PreferencesFlag.scheduleShowTodayBtn))
            .called(1);
        verify(preferencesServiceMock.getBool(PreferencesFlag.scheduleListView))
            .called(1);

        verifyNoMoreInteractions(preferencesServiceMock);
        verifyNoMoreInteractions(analyticsServiceMock);
      });
    });

    group("ThemeMode - ", () {
      test("set light/dark/system mode", () async {
        const flag = PreferencesFlag.theme;
        repository.setThemeMode(ThemeMode.light);

        verify(preferencesServiceMock.setString(
                PreferencesFlag.theme, ThemeMode.light.toString()))
            .called(1);

        verify(analyticsServiceMock.logEvent(
                "${SettingsRepository.tag}_${flag.name}",
                any))
            .called(1);

        repository.setThemeMode(ThemeMode.dark);

        verify(preferencesServiceMock.setString(
                PreferencesFlag.theme, ThemeMode.dark.toString()))
            .called(1);

        verify(analyticsServiceMock.logEvent(
                "${SettingsRepository.tag}_${flag.name}",
                any))
            .called(1);

        repository.setThemeMode(ThemeMode.system);

        verify(preferencesServiceMock.setString(
                PreferencesFlag.theme, ThemeMode.system.toString()))
            .called(1);

        verify(analyticsServiceMock.logEvent(
                "${SettingsRepository.tag}_${flag.name}",
                any))
            .called(1);

        verifyNoMoreInteractions(preferencesServiceMock);
        verifyNoMoreInteractions(analyticsServiceMock);
      });

      test("validate default behaviour", () async {
        const flag = PreferencesFlag.theme;
        PreferencesServiceMock.stubGetString(preferencesServiceMock, flag,
            toReturn: ThemeMode.light.toString());

        repository.themeMode;
        await untilCalled(preferencesServiceMock.getString(flag));

        expect(repository.themeMode, ThemeMode.light);

        verify(preferencesServiceMock.getString(flag)).called(2);

        verifyNoMoreInteractions(preferencesServiceMock);
      });
    });

    group("Locale - ", () {
      test("validate default behaviour", () async {
        const flag = PreferencesFlag.locale;
        PreferencesServiceMock.stubGetString(
            preferencesServiceMock, PreferencesFlag.locale,
            toReturn: const Locale('fr').toString());

        repository.setLocale('fr');
        repository.locale;

        verify(preferencesServiceMock.setString(PreferencesFlag.locale, 'fr'))
            .called(1);
        verify(preferencesServiceMock.getString(PreferencesFlag.locale))
            .called(1);

        verify(analyticsServiceMock.logEvent(
                "${SettingsRepository.tag}_${flag.name}",
                any))
            .called(1);

        verifyNoMoreInteractions(preferencesServiceMock);
        verifyNoMoreInteractions(analyticsServiceMock);
      });

      test("set french/english", () async {
        const flag = PreferencesFlag.locale;
        repository.setLocale('fr');

        verify(preferencesServiceMock.setString(PreferencesFlag.locale, 'fr'))
            .called(1);

        untilCalled(analyticsServiceMock.logEvent(
            "${SettingsRepository.tag}_${flag.name}",
            any));

        verify(analyticsServiceMock.logEvent(
                "${SettingsRepository.tag}_${flag.name}",
                any))
            .called(1);

        repository.setLocale('en');

        verify(preferencesServiceMock.setString(PreferencesFlag.locale, 'en'))
            .called(1);

        untilCalled(analyticsServiceMock.logEvent(
            "${SettingsRepository.tag}_${flag.name}",
            any));

        verify(analyticsServiceMock.logEvent(
                "${SettingsRepository.tag}_${flag.name}",
                any))
            .called(1);

        verifyNoMoreInteractions(preferencesServiceMock);
        verifyNoMoreInteractions(analyticsServiceMock);
      });

      test("default locale isn't set", () {
        const flag = PreferencesFlag.locale;
        when(preferencesServiceMock.getString(flag))
            .thenAnswer((_) async => null);

        expect(repository.locale, const Locale('en'));

        verify(preferencesServiceMock.getString(PreferencesFlag.locale))
            .called(1);

        verifyNoMoreInteractions(preferencesServiceMock);
        verifyNoMoreInteractions(analyticsServiceMock);
      });
    });

    test("fetch theme and locale", () async {
      PreferencesServiceMock.stubGetString(
          preferencesServiceMock, PreferencesFlag.locale,
          toReturn: const Locale('fr').toString());
      PreferencesServiceMock.stubGetString(
          preferencesServiceMock, PreferencesFlag.theme,
          toReturn: 'ThemeMode.system');

      await repository.fetchLanguageAndThemeMode();

      verify(preferencesServiceMock.getString(PreferencesFlag.theme)).called(1);
      verify(preferencesServiceMock.getString(PreferencesFlag.locale))
          .called(1);

      verifyNoMoreInteractions(preferencesServiceMock);
      verifyNoMoreInteractions(analyticsServiceMock);
    });

    test("reset language and theme", () async {
      // Set local and theme
      PreferencesServiceMock.stubGetString(
          preferencesServiceMock, PreferencesFlag.locale,
          toReturn: const Locale('fr').toString());
      PreferencesServiceMock.stubGetString(
          preferencesServiceMock, PreferencesFlag.theme,
          toReturn: 'ThemeMode.system');

      await repository.fetchLanguageAndThemeMode();

      expect(repository.themeMode, ThemeMode.system,
          reason: "Loaded theme mode should be system");
      expect(repository.locale, const Locale('fr'),
          reason: "Loaded locale should be french");

      repository.resetLanguageAndThemeMode();

      expect(repository.themeMode, null,
          reason: "Default theme mode should be null");
      expect(repository.locale, Locale(Intl.systemLocale.split('_')[0]),
          reason: "Default locale should be system language");
    });

    test("setString", () async {
      const flag = PreferencesFlag.scheduleCalendarFormat;
      PreferencesServiceMock.stubSetString(preferencesServiceMock, flag);

      expect(await repository.setString(flag, "test"), true,
          reason:
              "setString should return true if the PreferenceService return true");

      untilCalled(analyticsServiceMock.logEvent(
          "${SettingsRepository.tag}_${flag.name}", any));

      verify(analyticsServiceMock.logEvent(
              "${SettingsRepository.tag}_${flag.name}",
              any))
          .called(1);
      verify(preferencesServiceMock.setString(flag, any));
    });

    test("setInt", () async {
      const flag = PreferencesFlag.aboutUsCard;
      PreferencesServiceMock.stubSetInt(preferencesServiceMock, flag);

      expect(await repository.setInt(flag, 0), true,
          reason:
              "setInt should return true if the PreferenceService return true");

      untilCalled(analyticsServiceMock.logEvent(
          "${SettingsRepository.tag}_${flag.name}", any));

      verify(analyticsServiceMock.logEvent(
              "${SettingsRepository.tag}_${flag.name}",
              any))
          .called(1);
      verify(preferencesServiceMock.setInt(flag, any));
    });

    test("getString", () async {
      const flag = PreferencesFlag.scheduleCalendarFormat;
      PreferencesServiceMock.stubGetString(preferencesServiceMock, flag);

      expect(await repository.getString(flag), 'test',
          reason:
              "setString should return true if the PreferenceService return true");

      untilCalled(analyticsServiceMock.logEvent(
          "${SettingsRepository.tag}_${flag.name}", any));

      verify(analyticsServiceMock.logEvent(
              "${SettingsRepository.tag}_${flag.name}",
              any))
          .called(1);
      verify(preferencesServiceMock.getString(flag));
    });

    test("setBool", () async {
      const flag = PreferencesFlag.scheduleCalendarFormat;
      PreferencesServiceMock.stubSetBool(preferencesServiceMock, flag);

      expect(await repository.setBool(flag, true), true,
          reason:
              "setString should return true if the PreferenceService return true");

      untilCalled(analyticsServiceMock.logEvent(
          "${SettingsRepository.tag}_${flag.name}", any));

      verify(analyticsServiceMock.logEvent(
              "${SettingsRepository.tag}_${flag.name}",
              any))
          .called(1);
      verify(preferencesServiceMock.setBool(flag, value: anyNamed("value")));
    });

    group("Dashboard - ", () {
      test("validate default behaviour", () async {
        PreferencesServiceMock.stubGetInt(
            preferencesServiceMock, PreferencesFlag.aboutUsCard,
            toReturn: null);
        PreferencesServiceMock.stubGetInt(
            preferencesServiceMock, PreferencesFlag.scheduleCard,
            toReturn: null);
        PreferencesServiceMock.stubGetInt(
            preferencesServiceMock, PreferencesFlag.progressBarCard,
            toReturn: null);
        PreferencesServiceMock.stubGetInt(
            preferencesServiceMock, PreferencesFlag.gradesCard,
            toReturn: null);

        // Cards
        final Map<PreferencesFlag, int> expected = {
          PreferencesFlag.aboutUsCard: 0,
          PreferencesFlag.scheduleCard: 1,
          PreferencesFlag.progressBarCard: 2,
          PreferencesFlag.gradesCard: 3
        };

        expect(
          await repository.getDashboard(),
          expected,
        );

        verify(preferencesServiceMock.getInt(PreferencesFlag.aboutUsCard))
            .called(1);
        verify(preferencesServiceMock.getInt(PreferencesFlag.scheduleCard))
            .called(1);
        verify(preferencesServiceMock.getInt(PreferencesFlag.progressBarCard))
            .called(1);
        verify(preferencesServiceMock.getInt(PreferencesFlag.gradesCard))
            .called(1);

        verifyNoMoreInteractions(preferencesServiceMock);
        verifyNoMoreInteractions(analyticsServiceMock);
      });

      test("validate the loading of the cards", () async {
        PreferencesServiceMock.stubGetInt(
            preferencesServiceMock, PreferencesFlag.aboutUsCard);
        PreferencesServiceMock.stubGetInt(
            preferencesServiceMock, PreferencesFlag.scheduleCard,
            toReturn: 2);
        PreferencesServiceMock.stubGetInt(
            preferencesServiceMock, PreferencesFlag.progressBarCard,
            // ignore: avoid_redundant_argument_values
            toReturn: 0);
        PreferencesServiceMock.stubGetInt(
            preferencesServiceMock, PreferencesFlag.gradesCard,
            toReturn: 3);

        // Cards
        final Map<PreferencesFlag, int> expected = {
          PreferencesFlag.aboutUsCard: 1,
          PreferencesFlag.scheduleCard: 2,
          PreferencesFlag.progressBarCard: 0,
          PreferencesFlag.gradesCard: 3
        };

        expect(
          await repository.getDashboard(),
          expected,
        );

        verify(preferencesServiceMock.getInt(PreferencesFlag.aboutUsCard))
            .called(1);
        verify(preferencesServiceMock.getInt(PreferencesFlag.scheduleCard))
            .called(1);
        verify(preferencesServiceMock.getInt(PreferencesFlag.progressBarCard))
            .called(1);
        verify(preferencesServiceMock.getInt(PreferencesFlag.gradesCard))
            .called(1);

        verifyNoMoreInteractions(preferencesServiceMock);
        verifyNoMoreInteractions(analyticsServiceMock);
      });
    });
  });
}
