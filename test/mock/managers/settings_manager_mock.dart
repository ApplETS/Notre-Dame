// Flutter imports:
import 'package:flutter/material.dart';
import 'package:mockito/annotations.dart';

// Package imports:
import 'package:mockito/mockito.dart';

// Project imports:
import 'package:notredame/core/constants/preferences_flags.dart';
import 'package:notredame/core/managers/settings_manager.dart';

import 'settings_manager_mock.mocks.dart';

@GenerateNiceMocks([MockSpec<SettingsManager>()])
class SettingsManagerMock extends MockSettingsManager {
  /// Stub the [getScheduleSettings] function of [mock], when called return [toReturn].
  static void stubGetScheduleSettings(SettingsManagerMock mock,
      {Map<PreferencesFlag, dynamic> toReturn = const {}}) {
    when(mock.getScheduleSettings()).thenAnswer((_) async => toReturn);
  }

  /// Stub the [getDashboard] function of [mock], when called return [toReturn].
  static void stubGetDashboard(SettingsManagerMock mock,
      {Map<PreferencesFlag, int> toReturn = const {}}) {
    when(mock.getDashboard()).thenAnswer((_) async => toReturn);
  }

  /// Stub the [setString] function of [mock], when called with [flag] return [toReturn].
  static void stubSetString(SettingsManagerMock mock, PreferencesFlag flag,
      {bool toReturn = true}) {
    when(mock.setString(flag, any)).thenAnswer((_) async => toReturn);
  }

  /// Stub the [getString] function of [mock], when called with [flag] return [toReturn].
  static void stubGetString(SettingsManagerMock mock, PreferencesFlag flag,
      {String toReturn = 'test'}) {
    when(mock.getString(flag)).thenAnswer((_) async => toReturn);
  }

  /// Stub the [getDynamicString] function of [mock], when called with [flag] return [toReturn].
  static void stubGetDynamicString(
      SettingsManagerMock mock, PreferencesFlag flag, String key,
      {String toReturn = 'test'}) {
    when(mock.getDynamicString(flag, key)).thenAnswer((_) async => toReturn);
  }

  /// Stub the [getBool] function of [mock], when called with [flag] return [toReturn].
  static void stubGetBool(SettingsManagerMock mock, PreferencesFlag flag,
      {bool toReturn = false}) {
    when(mock.getBool(flag)).thenAnswer((_) async => toReturn);
  }

  /// Stub the [setBool] function of [mock], when called with [flag] return [toReturn].
  static void stubSetBool(SettingsManagerMock mock, PreferencesFlag flag,
      {bool toReturn = true}) {
    when(mock.setBool(flag, any)).thenAnswer((_) async => toReturn);
  }

  /// Stub the [setInt] function of [mock], when called with [flag] return [toReturn].
  static void stubSetInt(SettingsManagerMock mock, PreferencesFlag flag,
      {bool toReturn = true}) {
    when(mock.setInt(flag, any)).thenAnswer((_) async => toReturn);
  }

  /// Stub the [locale] function of [mock], when called return [toReturn].
  static void stubLocale(SettingsManagerMock mock,
      {Locale toReturn = const Locale('en')}) {
    when(mock.locale).thenReturn(toReturn);
  }

  /// Stub the [themeMode] function of [mock], when called return [toReturn].
  static void stubThemeMode(SettingsManagerMock mock,
      {ThemeMode toReturn = ThemeMode.system}) {
    when(mock.themeMode).thenReturn(toReturn);
  }

  /// Stub the [dateTimeNow] function of [mock], when called return [toReturn].
  static void stubDateTimeNow(SettingsManagerMock mock, {required DateTime toReturn}) {
    // ignore: cast_nullable_to_non_nullable
    when(mock.dateTimeNow).thenReturn(toReturn);
  }
}
