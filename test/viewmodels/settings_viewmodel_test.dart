// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

// Project imports:
import 'package:notredame/core/constants/preferences_flags.dart';
import 'package:notredame/core/managers/settings_manager.dart';
import 'package:notredame/core/viewmodels/settings_viewmodel.dart';
import '../helpers.dart';
import '../mock/managers/settings_manager_mock.dart';

late SettingsViewModel viewModel;

void main() {
  late SettingsManager settingsManager;

  group("SettingsViewModel - ", () {
    setUp(() async {
      // Setting up mocks
      settingsManager = setupSettingsManagerMock();
      final AppIntl intl = await setupAppIntl();

      viewModel = SettingsViewModel(intl: intl);
    });

    tearDown(() {
      unregister<SettingsManager>();
    });

    group("futureToRun - ", () {
      test("The settings are correctly loaded and sets", () async {
        SettingsManagerMock.stubLocale(settingsManager as SettingsManagerMock);

        SettingsManagerMock.stubThemeMode(
            settingsManager as SettingsManagerMock);

        await viewModel.futureToRun();
        expect(viewModel.currentLocale, 'English');
        expect(viewModel.selectedTheme, ThemeMode.system);

        verifyInOrder([
          settingsManager.fetchLanguageAndThemeMode(),
          settingsManager.locale,
          settingsManager.themeMode
        ]);
        verifyNoMoreInteractions(settingsManager);
      });
    });

    group("setter theme - ", () {
      test("can set system theme option", () async {
        SettingsManagerMock.stubSetString(
            settingsManager as SettingsManagerMock, PreferencesFlag.theme);

        // Call the setter.
        viewModel.selectedTheme = ThemeMode.system;

        await untilCalled(settingsManager.setThemeMode(ThemeMode.system));

        expect(viewModel.selectedTheme, ThemeMode.system);
        expect(viewModel.isBusy, false);

        verify(settingsManager.setThemeMode(ThemeMode.system)).called(1);
        verifyNoMoreInteractions(settingsManager);
      });

      test("can set dark theme option", () async {
        SettingsManagerMock.stubSetString(
            settingsManager as SettingsManagerMock, PreferencesFlag.theme);

        // Call the setter.
        viewModel.selectedTheme = ThemeMode.dark;

        await untilCalled(settingsManager.setThemeMode(ThemeMode.dark));

        expect(viewModel.selectedTheme, ThemeMode.dark);
        expect(viewModel.isBusy, false);

        verify(settingsManager.setThemeMode(ThemeMode.dark)).called(1);
        verifyNoMoreInteractions(settingsManager);
      });

      test("can set light theme option", () async {
        SettingsManagerMock.stubSetString(
            settingsManager as SettingsManagerMock, PreferencesFlag.theme);

        // Call the setter.
        viewModel.selectedTheme = ThemeMode.light;

        await untilCalled(settingsManager.setThemeMode(ThemeMode.light));

        expect(viewModel.selectedTheme, ThemeMode.light);
        expect(viewModel.isBusy, false);

        verify(settingsManager.setThemeMode(ThemeMode.light)).called(1);
        verifyNoMoreInteractions(settingsManager);
      });
    });
  });
}
