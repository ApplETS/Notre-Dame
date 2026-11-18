// Flutter imports:
import 'package:material_ui/material_ui.dart';

// Package imports:
import 'package:stacked/stacked.dart';

// Project imports:
import 'package:notredame/data/repositories/settings_repository.dart';
import 'package:notredame/locator.dart';

class SettingsViewModel extends BaseViewModel {
  final SettingsRepository _settingsManager = locator<SettingsRepository>();

  ThemeMode get theme => _settingsManager.themeMode;

  set theme(ThemeMode value) => _settingsManager.themeMode = value;

  Locale get locale => _settingsManager.locale;

  set locale(Locale value) => _settingsManager.locale = value;

  bool get dashboardScheduleList => _settingsManager.dashboard.displayScheduleAsList;

  set dashboardScheduleList(bool value) => _settingsManager.dashboard.displayScheduleAsList = value;
}
