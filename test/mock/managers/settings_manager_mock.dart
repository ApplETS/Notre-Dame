// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';
import 'package:mockito/mockito.dart';

// MANAGER
import 'package:notredame/core/managers/settings_manager.dart';

// MODEL
import 'package:notredame/core/constants/preferences_flags.dart';

class SettingsManagerMock extends Mock implements SettingsManager {
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
}
