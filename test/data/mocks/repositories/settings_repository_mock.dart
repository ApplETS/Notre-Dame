// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

// Project imports:
import 'package:notredame/data/repositories/settings_repository.dart';
import 'package:notredame/domain/constants/preferences_flags.dart';
import 'settings_repository_mock.mocks.dart';

@GenerateNiceMocks([
  MockSpec<SettingsRepository>(),
  MockSpec<DashboardSettings>(),
  MockSpec<ScheduleSettings>(),
  MockSpec<RatingSettings>(),
])
class SettingsRepositoryMock extends MockSettingsRepository {
  /// Stub the [locale] getter
  static void stubLocale(SettingsRepositoryMock mock, {Locale toReturn = const Locale('fr')}) {
    when(mock.locale).thenReturn(toReturn);
  }

  /// Stub the [isLocaleDefined] getter
  static void stubIsLocaleDefined(SettingsRepositoryMock mock, {bool toReturn = true}) {
    when(mock.isLocaleDefined).thenReturn(toReturn);
  }

  /// Stub the [themeMode] getter
  static void stubThemeMode(SettingsRepositoryMock mock, {ThemeMode toReturn = ThemeMode.system}) {
    when(mock.themeMode).thenReturn(toReturn);
  }

  /// Stub the [dateTimeNow] getter
  static void stubDateTimeNow(SettingsRepositoryMock mock, {required DateTime toReturn}) {
    when(mock.dateTimeNow).thenReturn(toReturn);
  }

  /// Stub the [isLoggedIn] getter
  static void stubIsLoggedIn(SettingsRepositoryMock mock, {bool toReturn = false}) {
    when(mock.isLoggedIn).thenReturn(toReturn);
  }
}
