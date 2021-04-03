// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// SERVICE
import 'package:notredame/core/managers/settings_manager.dart';

// OTHER
import 'package:notredame/locator.dart';
import 'package:notredame/core/constants/preferences_flags.dart';
import 'package:feature_discovery/feature_discovery.dart';
import 'package:notredame/ui/utils/discovery_components.dart';

class DashboardViewModel extends BaseViewModel {
  /// Localization class of the application.
  final AppIntl _appIntl;

  /// Manage the settings
  final SettingsManager _settingsManager = locator<SettingsManager>();

  DashboardViewModel({@required AppIntl intl}) : _appIntl = intl;

  Future<void> startDiscovery(BuildContext context) async {
    if (await _settingsManager.getString(PreferencesFlag.discovery) == null) {
      final List<String> ids =
          discoveryComponents(context).map((e) => e.featureId).toList();
      FeatureDiscovery.discoverFeatures(context, ids);
      _settingsManager.setString(PreferencesFlag.discovery, 'true');
    }
  }
}
