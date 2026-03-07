// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

// Project imports:
import 'package:notredame/data/repositories/settings_repository.dart';
import 'package:notredame/ui/more/settings/view_model/settings_viewmodel.dart';
import '../../../../data/mocks/repositories/settings_repository_mock.dart';
import '../../../../helpers.dart';

late SettingsViewModel viewModel;

void main() {
  late SettingsRepositoryMock settingsManagerMock;

  group("SettingsViewModel - ", () {
    setUp(() async {
      settingsManagerMock = setupSettingsRepositoryMock();

      viewModel = SettingsViewModel();
    });

    tearDown(() {
      unregister<SettingsRepository>();
    });

    group("futureToRun - ", () {
      test("The settings are correctly loaded and sets", () async {
        SettingsRepositoryMock.stubLocale(settingsManagerMock);
        SettingsRepositoryMock.stubThemeMode(settingsManagerMock);
        SettingsRepositoryMock.stubDashboardScheduleAsList(settingsManagerMock);

        expect(viewModel.locale, Locale('fr'));
        expect(viewModel.theme, ThemeMode.system);
        expect(viewModel.dashboardScheduleList, false);

        verifyInOrder([
          settingsManagerMock.locale,
          settingsManagerMock.themeMode,
          settingsManagerMock.dashboard.displayScheduleAsList
        ]);
        verifyNoMoreInteractions(settingsManagerMock);
      });
    });

    group("setter theme - ", () {
      test("can set system theme option", () async {
        SettingsRepositoryMock.stubThemeMode(settingsManagerMock);

        viewModel.theme = ThemeMode.system;

        verify(settingsManagerMock.themeMode = ThemeMode.system).called(1);
        verifyNoMoreInteractions(settingsManagerMock);
      });

      test("can set dark theme option", () async {
        SettingsRepositoryMock.stubThemeMode(settingsManagerMock);

        viewModel.theme = ThemeMode.dark;

        verify(settingsManagerMock.themeMode = ThemeMode.dark).called(1);
        verifyNoMoreInteractions(settingsManagerMock);
      });

      test("can set light theme option", () async {
        SettingsRepositoryMock.stubThemeMode(settingsManagerMock);

        viewModel.theme = ThemeMode.light;

        verify(settingsManagerMock.themeMode = ThemeMode.light).called(1);
        verifyNoMoreInteractions(settingsManagerMock);
      });
    });
  });
}
