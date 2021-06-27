// FLUTTER / DART / THIRD-PARTIES
import 'package:feature_discovery/feature_discovery.dart';
import 'package:flutter/material.dart';
import 'package:notredame/core/constants/preferences_flags.dart';
import 'package:notredame/core/managers/settings_manager.dart';
import 'package:notredame/locator.dart';
import 'package:stacked/stacked.dart';

class StudentViewModel extends BaseViewModel {
  /// Settings manager
  final SettingsManager _settingsManager = locator<SettingsManager>();

  StudentViewModel();

  Future<void> startDiscovery(BuildContext context) async {
    if (await _settingsManager
            .getString(PreferencesFlag.discoveryStudentProfile) ==
        null) {
      FeatureDiscovery.discoverFeatures(context, ['page_student_page_profile']);
      _settingsManager.setString(
          PreferencesFlag.discoveryStudentProfile, 'true');
    }
  }
}
