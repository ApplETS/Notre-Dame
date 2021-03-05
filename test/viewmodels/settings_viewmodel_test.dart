// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

// MANAGER
import 'package:notredame/core/managers/settings_manager.dart';

// VIEWMODEL
import 'package:notredame/core/viewmodels/settings_viewmodel.dart';

// CONSTANTS
import 'package:notredame/core/constants/preferences_flags.dart';

// OTHERS
import '../helpers.dart';
import '../mock/managers/settings_manager_mock.dart';

SettingsViewModel viewModel;

void main() {
  SettingsManager settingsManager;

  group("SettingsViewModel - ", () {
    setUp(() async {
      // Setting up mocks
      settingsManager = setupSettingsManagerMock();
      await setupAppIntl();

      viewModel = SettingsViewModel();
    });

    tearDown(() {
      unregister<SettingsManager>();
    });

    group("futureToRun - ", () {
      test("The settings are correctly loaded and sets", () async {
        SettingsManagerMock.stubGetString(
            settingsManager as SettingsManagerMock, PreferencesFlag.locale,
            toReturn: 'test locale');

        SettingsManagerMock.stubGetString(
            settingsManager as SettingsManagerMock, PreferencesFlag.theme,
            toReturn: 'test theme');

        expect(await viewModel.futureToRun(), true);
        expect(viewModel.currentLocale, 'test locale');
        expect(viewModel.selectedTheme, 'System');

        verify(settingsManager.getString(any)).called(2);
        verifyNoMoreInteractions(settingsManager);
      });
    });

    group("setter theme - ", () {
      test("can set system theme option", () async {
        SettingsManagerMock.stubSetString(
            settingsManager as SettingsManagerMock, PreferencesFlag.theme);

        // Call the setter.
        viewModel.selectedTheme = ThemeMode.system.toString();

        await untilCalled(
            settingsManager.setThemeMode(ThemeMode.system.toString()));

        expect(viewModel.selectedTheme.toLowerCase(),
            ThemeMode.system.toString().replaceFirst('ThemeMode.', ''));
        expect(viewModel.isBusy, false);

        verify(settingsManager.setThemeMode(ThemeMode.system.toString()))
            .called(1);
        verifyNoMoreInteractions(settingsManager);
      });

      test("can set dark theme option", () async {
        SettingsManagerMock.stubSetString(
            settingsManager as SettingsManagerMock, PreferencesFlag.theme);

        // Call the setter.
        viewModel.selectedTheme = ThemeMode.dark.toString();

        await untilCalled(
            settingsManager.setThemeMode(ThemeMode.dark.toString()));

        expect(viewModel.selectedTheme.toLowerCase(),
            ThemeMode.dark.toString().replaceFirst('ThemeMode.', ''));
        expect(viewModel.isBusy, false);

        verify(settingsManager.setThemeMode(ThemeMode.dark.toString()))
            .called(1);
        verifyNoMoreInteractions(settingsManager);
      });

      test("can set light theme option", () async {
        SettingsManagerMock.stubSetString(
            settingsManager as SettingsManagerMock, PreferencesFlag.theme);

        // Call the setter.
        viewModel.selectedTheme = ThemeMode.light.toString();

        await untilCalled(
            settingsManager.setThemeMode(ThemeMode.light.toString()));

        expect(viewModel.selectedTheme.toLowerCase(),
            ThemeMode.light.toString().replaceFirst('ThemeMode.', ''));
        expect(viewModel.isBusy, false);

        verify(settingsManager.setThemeMode(ThemeMode.light.toString()))
            .called(1);
        verifyNoMoreInteractions(settingsManager);
      });
    });
  });
}
