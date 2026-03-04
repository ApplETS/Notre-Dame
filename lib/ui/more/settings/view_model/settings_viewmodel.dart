// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:stacked/stacked.dart';

// Project imports:
import 'package:notredame/data/repositories/settings_repository.dart';
import 'package:notredame/locator.dart';
import 'package:notredame/domain/constants/preferences_flags.dart';

class SettingsViewModel extends FutureViewModel {
  final SettingsRepository _settingsManager = locator<SettingsRepository>();

  late Locale _locale;
  late ThemeMode _theme;
  late bool _dashboardScheduleList;

  ThemeMode? get theme => _theme;

  set theme(ThemeMode value) {
    _settingsManager.setThemeMode(value);
    _theme = value;
  }

  Locale get locale => _locale;

  set locale(Locale value) {
    _settingsManager.setLocale(value.languageCode);
    _locale = value;
  }

  bool get dashboardScheduleList => _dashboardScheduleList;

  set dashboardScheduleList(bool value) {
    _settingsManager.setBool(PreferencesFlag.dashboardScheduleList, value);
    _dashboardScheduleList = value;
  }

  @override
  Future futureToRun() async {
    _locale = _settingsManager.locale;
    _theme = _settingsManager.themeMode;
    _dashboardScheduleList = _settingsManager.getBool(PreferencesFlag.dashboardScheduleList) ?? false;
    return true;
  }
}
