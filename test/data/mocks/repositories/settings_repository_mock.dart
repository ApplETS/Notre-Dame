// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

// Project imports:
import 'package:notredame/data/repositories/settings_repository.dart';
import 'package:notredame/domain/constants/preferences_flags.dart';
import 'settings_repository_mock.mocks.dart';

@GenerateNiceMocks([MockSpec<SettingsRepository>()])
class SettingsRepositoryMock extends MockSettingsRepository {
  /// Stub the [getScheduleSettings] function of [mock], when called return [toReturn].
  static void stubGetScheduleSettings(SettingsRepositoryMock mock,
      {Map<PreferencesFlag, dynamic> toReturn = const {}}) {
    when(mock.getScheduleSettings()).thenAnswer((_) async => toReturn);
  }

  /// Stub the [getDashboard] function of [mock], when called return [toReturn].
  static void stubGetDashboard(SettingsRepositoryMock mock, {Map<PreferencesFlag, int> toReturn = const {}}) {
    when(mock.getDashboard()).thenAnswer((_) async => toReturn);
  }

  /// Stub the [setString] function of [mock], when called with [flag] return [toReturn].
  static void stubSetString(SettingsRepositoryMock mock, PreferencesFlag flag, {bool toReturn = true}) {
    when(mock.setString(flag, any)).thenAnswer((_) async => toReturn);
  }

  /// Stub the [getString] function of [mock], when called with [flag] return [toReturn].
  static void stubGetString(SettingsRepositoryMock mock, PreferencesFlag flag, {String toReturn = 'test'}) {
    when(mock.getString(flag)).thenAnswer((_) async => toReturn);
  }

  /// Stub the [getDynamicString] function of [mock], when called with [flag] return [toReturn].
  static void stubGetDynamicString(SettingsRepositoryMock mock, PreferencesFlag flag, String key,
      {String toReturn = 'test'}) {
    when(mock.getDynamicString(flag, key)).thenAnswer((_) async => toReturn);
  }

  /// Stub the [getBool] function of [mock], when called with [flag] return [toReturn].
  static void stubGetBool(SettingsRepositoryMock mock, PreferencesFlag flag, {bool toReturn = false}) {
    when(mock.getBool(flag)).thenAnswer((_) async => toReturn);
  }

  /// Stub the [setBool] function of [mock], when called with [flag] return [toReturn].
  static void stubSetBool(SettingsRepositoryMock mock, PreferencesFlag flag, {bool toReturn = true}) {
    when(mock.setBool(flag, any)).thenAnswer((_) async => toReturn);
  }

  /// Stub the [setInt] function of [mock], when called with [flag] return [toReturn].
  static void stubSetInt(SettingsRepositoryMock mock, PreferencesFlag flag, {bool toReturn = true}) {
    when(mock.setInt(flag, any)).thenAnswer((_) async => toReturn);
  }

  /// Stub the [locale] function of [mock], when called return [toReturn].
  static void stubLocale(SettingsRepositoryMock mock, {Locale toReturn = const Locale('en')}) {
    when(mock.locale).thenReturn(toReturn);
  }

  /// Stub the [themeMode] function of [mock], when called return [toReturn].
  static void stubThemeMode(SettingsRepositoryMock mock, {ThemeMode toReturn = ThemeMode.system}) {
    when(mock.themeMode).thenReturn(toReturn);
  }

  /// Stub the [dateTimeNow] function of [mock], when called return [toReturn].
  static void stubDateTimeNow(SettingsRepositoryMock mock, {required DateTime toReturn}) {
    // ignore: cast_nullable_to_non_nullable
    when(mock.dateTimeNow).thenReturn(toReturn);
  }
}
