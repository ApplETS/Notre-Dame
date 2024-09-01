// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

// Project imports:
import 'package:notredame/constants/preferences_flags.dart';
import 'package:notredame/features/more/settings/settings_manager.dart';
import 'package:notredame/features/more/settings/settings_viewmodel.dart';
import '../../../common/helpers.dart';
import 'mocks/settings_manager_mock.dart';

late SettingsViewModel viewModel;

void main() {
  late SettingsManagerMock settingsManagerMock;

  group("SettingsViewModel - ", () {
    setUp(() async {
      // Setting up mocks
      settingsManagerMock = setupSettingsManagerMock();
      final AppIntl intl = await setupAppIntl();

      viewModel = SettingsViewModel(intl: intl);
    });

    tearDown(() {
      unregister<SettingsManager>();
    });

    group("futureToRun - ", () {
      test("The settings are correctly loaded and sets", () async {
        SettingsManagerMock.stubLocale(settingsManagerMock);

        SettingsManagerMock.stubThemeMode(settingsManagerMock);

        await viewModel.futureToRun();
        expect(viewModel.currentLocale, 'English');
        expect(viewModel.selectedTheme, ThemeMode.system);

        verifyInOrder([
          settingsManagerMock.fetchLanguageAndThemeMode(),
          settingsManagerMock.locale,
          settingsManagerMock.themeMode
        ]);
        verifyNoMoreInteractions(settingsManagerMock);
      });
    });

    group("setter theme - ", () {
      test("can set system theme option", () async {
        SettingsManagerMock.stubSetString(
            settingsManagerMock, PreferencesFlag.theme);

        // Call the setter.
        viewModel.selectedTheme = ThemeMode.system;

        await untilCalled(settingsManagerMock.setThemeMode(ThemeMode.system));

        expect(viewModel.selectedTheme, ThemeMode.system);
        expect(viewModel.isBusy, false);

        verify(settingsManagerMock.setThemeMode(ThemeMode.system)).called(1);
        verifyNoMoreInteractions(settingsManagerMock);
      });

      test("can set dark theme option", () async {
        SettingsManagerMock.stubSetString(
            settingsManagerMock, PreferencesFlag.theme);

        // Call the setter.
        viewModel.selectedTheme = ThemeMode.dark;

        await untilCalled(settingsManagerMock.setThemeMode(ThemeMode.dark));

        expect(viewModel.selectedTheme, ThemeMode.dark);
        expect(viewModel.isBusy, false);

        verify(settingsManagerMock.setThemeMode(ThemeMode.dark)).called(1);
        verifyNoMoreInteractions(settingsManagerMock);
      });

      test("can set light theme option", () async {
        SettingsManagerMock.stubSetString(
            settingsManagerMock, PreferencesFlag.theme);

        // Call the setter.
        viewModel.selectedTheme = ThemeMode.light;

        await untilCalled(settingsManagerMock.setThemeMode(ThemeMode.light));

        expect(viewModel.selectedTheme, ThemeMode.light);
        expect(viewModel.isBusy, false);

        verify(settingsManagerMock.setThemeMode(ThemeMode.light)).called(1);
        verifyNoMoreInteractions(settingsManagerMock);
      });
    });
  });
}
