// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

// Project imports:
import 'package:notredame/data/repositories/settings_repository.dart';
import 'settings_repository_mock.mocks.dart';

final _dashboard = DashboardSettingsMock();
final _schedule = ScheduleSettingsMock();
final _rating = RatingSettingsMock();

@GenerateNiceMocks([
  MockSpec<SettingsRepository>(),
  MockSpec<ScheduleSettings>(),
  MockSpec<DashboardSettings>(),
  MockSpec<RatingSettings>(),
])
class SettingsRepositoryMock extends MockSettingsRepository {

  @override
  DashboardSettings get dashboard => _dashboard;

  @override
  ScheduleSettings get schedule => _schedule;

  @override
  RatingSettings get rating => _rating;

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

  /// Stub the [displayScheduleAsList] getter
  static void stubDashboardScheduleAsList(SettingsRepositoryMock mock, {bool toReturn = false}) {
    when(_dashboard.displayScheduleAsList).thenReturn(toReturn);
  }

  /// Stub the [hasBeenRequested] getter
  static void stubRatingHasBeenRequested(SettingsRepositoryMock mock, {bool toReturn = false}) {
    when(mock.rating.hasBeenRequested).thenReturn(toReturn);
  }

  /// Stub the [timer] getter
  static void stubRatingTimer(SettingsRepositoryMock mock, {DateTime? toReturn}) {
    when(mock.rating.timer).thenReturn(toReturn);
  }
}

class DashboardSettingsMock extends MockDashboardSettings {}

class ScheduleSettingsMock extends MockScheduleSettings {}

class RatingSettingsMock extends MockRatingSettings {}
