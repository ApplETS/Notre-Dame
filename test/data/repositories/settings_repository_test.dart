// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

// Project imports:
import 'package:notredame/data/repositories/settings_repository.dart';
import 'package:notredame/data/services/calendar_service.dart';
import 'package:notredame/domain/constants/preferences_flags.dart';
import '../../helpers.dart';
import '../mocks/services/preferences_service_mock.dart';

void main() {
  late PreferencesServiceMock preferencesServiceMock;
  late SettingsRepository repository;

  group("SettingsRepository - ", () {
    setUp(() {
      preferencesServiceMock = setupPreferencesServiceMock();
      repository = SettingsRepository();
    });

    group("ThemeMode - ", () {
      test("set light/dark/system mode", () {
        repository.themeMode = ThemeMode.light;

        verify(preferencesServiceMock.setString(PreferencesFlag.theme, ThemeMode.light.toString())).called(1);

        repository.themeMode = ThemeMode.dark;

        verify(preferencesServiceMock.setString(PreferencesFlag.theme, ThemeMode.dark.toString())).called(1);

        repository.themeMode = ThemeMode.system;

        verify(preferencesServiceMock.setString(PreferencesFlag.theme, ThemeMode.system.toString())).called(1);

        verifyNoMoreInteractions(preferencesServiceMock);
      });

      test("get", () {
        PreferencesServiceMock.stubGetString(
          preferencesServiceMock,
          PreferencesFlag.theme,
          toReturn: ThemeMode.light.toString(),
        );

        ThemeMode result = repository.themeMode;

        expect(result, ThemeMode.light);

        verify(preferencesServiceMock.getString(PreferencesFlag.theme)).called(1);

        verifyNoMoreInteractions(preferencesServiceMock);
      });
    });

    group("Locale - ", () {
      test("validate default behaviour", () {
        PreferencesServiceMock.stubGetString(preferencesServiceMock, PreferencesFlag.locale, toReturn: 'fr');

        repository.locale = const Locale('fr');

        verify(preferencesServiceMock.setString(PreferencesFlag.locale, 'fr')).called(1);

        repository.locale;

        verify(preferencesServiceMock.getString(PreferencesFlag.locale)).called(1);

        verifyNoMoreInteractions(preferencesServiceMock);
      });

      test("set french/english", () {
        repository.locale = const Locale('fr');

        verify(preferencesServiceMock.setString(PreferencesFlag.locale, 'fr')).called(1);

        repository.locale = const Locale('en');

        verify(preferencesServiceMock.setString(PreferencesFlag.locale, 'en')).called(1);

        verifyNoMoreInteractions(preferencesServiceMock);
      });

      test("default locale isn't set", () {
        const flag = PreferencesFlag.locale;
        when(preferencesServiceMock.getString(flag)).thenAnswer((_) => null);

        expect(repository.locale, const Locale('fr'));

        verify(preferencesServiceMock.getString(PreferencesFlag.locale)).called(1);

        verifyNoMoreInteractions(preferencesServiceMock);
      });
    });

    group("DateTimeNow - ", () {
      test("dateTimeNow returns current time", () {
        final now = repository.dateTimeNow;

        expect(now, isA<DateTime>());
      });
    });

    group("isLocaleDefined - ", () {
      test("isLocaleDefined true", () {
        PreferencesServiceMock.stubGetString(preferencesServiceMock, PreferencesFlag.locale, toReturn: 'fr');

        expect(repository.isLocaleDefined, true);

        verify(preferencesServiceMock.getString(PreferencesFlag.locale)).called(1);
      });

      test("isLocaleDefined false", () {
        when(preferencesServiceMock.getString(PreferencesFlag.locale)).thenReturn(null);

        expect(repository.isLocaleDefined, false);

        verify(preferencesServiceMock.getString(PreferencesFlag.locale)).called(1);
      });
    });

    group("replacedDaysCacheTimestamp - ", () {
      test("set timestamp", () {
        final date = DateTime(2025, 1, 1, 12, 30, 45);

        repository.replacedDaysCacheExpiration = date;

        verify(
          preferencesServiceMock.setString(PreferencesFlag.replacedDaysCacheExpiration, date.toIso8601String()),
        ).called(1);

        verifyNoMoreInteractions(preferencesServiceMock);
      });

      test("get timestamp parses DateTime", () {
        final date = DateTime(2025, 1, 1, 12, 30, 45);

        PreferencesServiceMock.stubGetString(
          preferencesServiceMock,
          PreferencesFlag.replacedDaysCacheExpiration,
          toReturn: date.toIso8601String(),
        );

        final result = repository.replacedDaysCacheExpiration;

        expect(result, date);

        verify(preferencesServiceMock.getString(PreferencesFlag.replacedDaysCacheExpiration)).called(1);

        verifyNoMoreInteractions(preferencesServiceMock);
      });

      test("get timestamp returns null when not set", () {
        when(preferencesServiceMock.getString(PreferencesFlag.replacedDaysCacheExpiration)).thenReturn(null);

        final result = repository.replacedDaysCacheExpiration;

        expect(result, null);

        verify(preferencesServiceMock.getString(PreferencesFlag.replacedDaysCacheExpiration)).called(1);

        verifyNoMoreInteractions(preferencesServiceMock);
      });
    });

    group("Login - ", () {
      test("get isLoggedIn true", () {
        PreferencesServiceMock.stubGetBool(preferencesServiceMock, PreferencesFlag.isLoggedIn, toReturn: true);

        expect(repository.isLoggedIn, true);

        verify(preferencesServiceMock.getBool(PreferencesFlag.isLoggedIn)).called(1);
      });

      test("get isLoggedIn default false", () {
        when(preferencesServiceMock.getBool(PreferencesFlag.isLoggedIn)).thenReturn(null);

        expect(repository.isLoggedIn, false);

        verify(preferencesServiceMock.getBool(PreferencesFlag.isLoggedIn)).called(1);
      });

      test("set isLoggedIn", () {
        repository.isLoggedIn = true;

        verify(preferencesServiceMock.setBool(PreferencesFlag.isLoggedIn, true)).called(1);
      });
    });

    group("DashboardSettings - ", () {
      test("displayScheduleAsList getter", () {
        PreferencesServiceMock.stubGetBool(
          preferencesServiceMock,
          PreferencesFlag.dashboardScheduleList,
          toReturn: true,
        );

        expect(repository.dashboard.displayScheduleAsList, true);

        verify(preferencesServiceMock.getBool(PreferencesFlag.dashboardScheduleList)).called(1);
      });

      test("displayScheduleAsList setter", () {
        repository.dashboard.displayScheduleAsList = true;

        verify(preferencesServiceMock.setBool(PreferencesFlag.dashboardScheduleList, true)).called(1);
      });
    });

    group("ScheduleSettings - ", () {
      test("calendarFormat getter", () {
        PreferencesServiceMock.stubGetString(
          preferencesServiceMock,
          PreferencesFlag.scheduleCalendarFormat,
          toReturn: CalendarTimeFormat.day.name,
        );

        final result = repository.schedule.calendarFormat;

        expect(result, CalendarTimeFormat.day);

        verify(preferencesServiceMock.getString(PreferencesFlag.scheduleCalendarFormat)).called(1);
      });

      test("calendarFormat default", () {
        when(preferencesServiceMock.getString(PreferencesFlag.scheduleCalendarFormat)).thenReturn(null);

        final result = repository.schedule.calendarFormat;

        expect(result, CalendarTimeFormat.week);

        verify(preferencesServiceMock.getString(PreferencesFlag.scheduleCalendarFormat)).called(1);
      });

      test("calendarFormat setter", () {
        repository.schedule.calendarFormat = CalendarTimeFormat.month;

        verify(
          preferencesServiceMock.setString(PreferencesFlag.scheduleCalendarFormat, CalendarTimeFormat.month.name),
        ).called(1);
      });

      test("listView getter", () {
        PreferencesServiceMock.stubGetBool(preferencesServiceMock, PreferencesFlag.scheduleListView, toReturn: true);

        expect(repository.schedule.listView, true);

        verify(preferencesServiceMock.getBool(PreferencesFlag.scheduleListView)).called(1);
      });

      test("listView setter", () {
        repository.schedule.listView = true;

        verify(preferencesServiceMock.setBool(PreferencesFlag.scheduleListView, true)).called(1);
      });

      test("todayButton getter", () {
        PreferencesServiceMock.stubGetBool(
          preferencesServiceMock,
          PreferencesFlag.scheduleShowTodayBtn,
          toReturn: false,
        );

        expect(repository.schedule.todayButton, false);

        verify(preferencesServiceMock.getBool(PreferencesFlag.scheduleShowTodayBtn)).called(1);
      });

      test("todayButton default true", () {
        when(preferencesServiceMock.getBool(PreferencesFlag.scheduleShowTodayBtn)).thenReturn(null);

        expect(repository.schedule.todayButton, true);

        verify(preferencesServiceMock.getBool(PreferencesFlag.scheduleShowTodayBtn)).called(1);
      });

      test("todayButton setter", () {
        repository.schedule.todayButton = false;

        verify(preferencesServiceMock.setBool(PreferencesFlag.scheduleShowTodayBtn, false)).called(1);
      });

      test("getLaboratoryGroup", () {
        PreferencesServiceMock.stubGetDynamicString(
          preferencesServiceMock,
          PreferencesFlag.scheduleLaboratoryGroup,
          'LOG121',
          toReturn: 'A01',
        );

        final result = repository.schedule.getLaboratoryGroup('LOG121');

        expect(result, 'A01');

        verify(preferencesServiceMock.getDynamicString(PreferencesFlag.scheduleLaboratoryGroup, 'LOG121')).called(1);
      });

      test("setLaboratoryGroup", () async {
        await repository.schedule.setLaboratoryGroup('LOG121', 'A02');

        verify(
          preferencesServiceMock.setDynamicString(PreferencesFlag.scheduleLaboratoryGroup, 'LOG121', 'A02'),
        ).called(1);
      });
    });

    group("RatingSettings - ", () {
      test("timer getter returns date", () {
        final now = DateTime.now();

        PreferencesServiceMock.stubGetString(
          preferencesServiceMock,
          PreferencesFlag.ratingTimer,
          toReturn: now.toIso8601String(),
        );

        final result = repository.rating.timer;

        expect(result, now);

        verify(preferencesServiceMock.getString(PreferencesFlag.ratingTimer)).called(1);
      });

      test("timer getter null", () {
        when(preferencesServiceMock.getString(PreferencesFlag.ratingTimer)).thenReturn(null);

        expect(repository.rating.timer, null);

        verify(preferencesServiceMock.getString(PreferencesFlag.ratingTimer)).called(1);
      });

      test("timer setter", () {
        final now = DateTime.now();

        repository.rating.timer = now;

        verify(preferencesServiceMock.setString(PreferencesFlag.ratingTimer, now.toIso8601String())).called(1);
      });

      test("hasBeenRequested getter", () {
        PreferencesServiceMock.stubGetBool(
          preferencesServiceMock,
          PreferencesFlag.hasRatingBeenRequested,
          toReturn: true,
        );

        expect(repository.rating.hasBeenRequested, true);

        verify(preferencesServiceMock.getBool(PreferencesFlag.hasRatingBeenRequested)).called(1);
      });

      test("hasBeenRequested setter", () {
        repository.rating.hasBeenRequested = true;

        verify(preferencesServiceMock.setBool(PreferencesFlag.hasRatingBeenRequested, true)).called(1);
      });
    });
  });
}
