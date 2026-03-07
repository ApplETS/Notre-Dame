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
