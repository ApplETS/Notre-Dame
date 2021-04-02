// FLUTTER / DART / THIRD-PARTIES
import 'dart:collection';

import 'package:notredame/core/constants/preferences_flags.dart';
import 'package:notredame/core/managers/settings_manager.dart';
import 'package:stacked/stacked.dart';

import '../../locator.dart';

class DashboardViewModel extends FutureViewModel<Map<PreferencesFlag, int>> {
  /// Manage the cards
  final SettingsManager _settingsManager = locator<SettingsManager>();

  SplayTreeMap _dashboard;

  SplayTreeMap get cards => _dashboard;

  /// Current aboutUsCard
  int _aboutUsCard;

  int get aboutUsCard => _aboutUsCard;

  /// Current aboutUsCard
  int _scheduleCard;

  int get scheduleCard => _scheduleCard;

  /// Current aboutUsCard
  int _progressBarCard;

  int get progressBarCard => _progressBarCard;

  /// Set aboutUsCard
  set aboutUsCard(int value) {
    setBusy(true);
    _settingsManager.setInt(PreferencesFlag.aboutUsCard, value);
    _aboutUsCard = value;
    setBusy(false);
  }

  /// Set scheduleCard
  set scheduleCard(int value) {
    setBusy(true);
    _settingsManager.setInt(PreferencesFlag.scheduleCard, value);
    _scheduleCard = value;
    setBusy(false);
  }

  /// Set progressBarCard
  set progressBarCard(int value) {
    setBusy(true);
    _settingsManager.setInt(PreferencesFlag.progressBarCard, value);
    _progressBarCard = value;
    setBusy(false);
  }

  /// Set progressBarCard
  set setOrder(PreferencesFlag flag, int index) {
    _settingsManager.setInt(flag, index);
    _dashboard
  }

  List<PreferencesFlag> convertDashboard(Map<PreferencesFlag, int> dashboard) {
    return SplayTreeMap.from(
        dashboard, (key1, key2) => dashboard[key1].compareTo(dashboard[key2])).entries.toList();
  }

  @override
  Future<Map<PreferencesFlag, int>> futureToRun() async {
    final dashboard = await _settingsManager.getDashboard();

    _dashboard = convertDashboard(dashboard);

    print(_dashboard);

    _aboutUsCard = dashboard[PreferencesFlag.aboutUsCard];
    _scheduleCard = dashboard[PreferencesFlag.scheduleCard];
    _progressBarCard = dashboard[PreferencesFlag.progressBarCard];

    return dashboard;
  }
}
