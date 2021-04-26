// FLUTTER / DART / THIRD-PARTIES
import 'dart:collection';

import 'package:feature_discovery/feature_discovery.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:notredame/core/constants/preferences_flags.dart';
import 'package:notredame/core/managers/settings_manager.dart';
import 'package:notredame/ui/utils/discovery_components.dart';
import 'package:stacked/stacked.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../locator.dart';

// CONSTANTS
import 'package:notredame/core/constants/preferences_flags.dart';

class DashboardViewModel extends FutureViewModel<Map<PreferencesFlag, int>> {
  /// Localization class of the application.
  final AppIntl _appIntl;

  /// Manage the cards
  final SettingsManager _settingsManager = locator<SettingsManager>();

  List<PreferencesFlag> _cards;

  List<PreferencesFlag> get cards => _cards;

  /// Current aboutUsCard
  int _aboutUsCard;

  int get aboutUsCard => _aboutUsCard;

  /// Current aboutUsCard
  int _scheduleCard;

  int get scheduleCard => _scheduleCard;

  /// Current aboutUsCard
  int _progressBarCard;

  int get progressBarCard => _progressBarCard;

  DashboardViewModel({@required AppIntl intl}) : _appIntl = intl;

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
  void setOrder(PreferencesFlag flag, int index) {
    _settingsManager.setInt(flag, index).then((value) {
      if (!value) {
        Fluttertoast.showToast(msg: "Failed");
      }
    });

    _cards.remove(flag);
    _cards.insert(index, flag);

    notifyListeners();
  }

  @override
  Future<Map<PreferencesFlag, int>> futureToRun() async {
    final dashboard = await _settingsManager.getDashboard();

    _cards = SplayTreeMap<PreferencesFlag, int>.from(dashboard,
            (key1, key2) => dashboard[key1].compareTo(dashboard[key2]))
        .keys
        .toList();

    _aboutUsCard = dashboard[PreferencesFlag.aboutUsCard];
    _scheduleCard = dashboard[PreferencesFlag.scheduleCard];
    _progressBarCard = dashboard[PreferencesFlag.progressBarCard];

    return dashboard;
  }

  Future<void> startDiscovery(BuildContext context) async {
    if (await _settingsManager.getString(PreferencesFlag.discovery) == null) {
      final List<String> ids = discoveryComponents(context).map((e) => e.featureId).toList();
      FeatureDiscovery.discoverFeatures(context, ids);
      _settingsManager.setString(PreferencesFlag.discovery, 'true');
    }
  }
}
