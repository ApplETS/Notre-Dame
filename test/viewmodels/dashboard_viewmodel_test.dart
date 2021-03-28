// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// MANAGER
import 'package:notredame/core/managers/settings_manager.dart';

// CONSTANTS
import 'package:notredame/core/constants/preferences_flags.dart';
import 'package:notredame/core/constants/discovery_components.dart';

// VIEWMODEL
import 'package:notredame/core/viewmodels/dashboard_viewmodel.dart';

// MOCKS
import '../mock/managers/settings_manager_mock.dart';

// HELPERS
import '../helpers.dart';

// OTHER
import 'package:feature_discovery/feature_discovery.dart';

DashboardViewModel viewModel;

void main() {
  SettingsManager settingsManager;
  BuildContext context;

  group("ChooseLanguageViewModel - ", () {
    setUp(() async {
      // Setting up mocks
      settingsManager = setupSettingsManagerMock();
      context = setupBuildContextMock();
      final AppIntl intl = await setupAppIntl();

      setupLogger();

      viewModel = DashboardViewModel(intl: intl);
    });

    tearDown(() {
      unregister<SettingsManager>();
      unregister<BuildContext>();
    });

  test('should launch discovery if it is the first time the app is launch', () async {
    SettingsManagerMock.stubGetString(
          settingsManager as SettingsManagerMock, PreferencesFlag.discovery, toReturn: null);
        
    viewModel.startDiscovery(context);
    final List<String> ids = discoveryComponents(context).map((e) => e.featureId).toList();
    verify(FeatureDiscovery.discoverFeatures(context, ids));   
  });

  test('should not launch discovery if it is not the first time the app is launch', () async {
    SettingsManagerMock.stubGetString(
          settingsManager as SettingsManagerMock, PreferencesFlag.discovery, toReturn: 'true');
        
    viewModel.startDiscovery(context);
    final List<String> ids = discoveryComponents(context).map((e) => e.featureId).toList();
    verifyNever(FeatureDiscovery.discoverFeatures(context, ids));   
  });
  });
  
}
