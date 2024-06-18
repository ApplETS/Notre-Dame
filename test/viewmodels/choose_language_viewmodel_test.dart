// Package imports:
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

// Project imports:
import 'package:notredame/core/constants/preferences_flags.dart';
import 'package:notredame/core/constants/router_paths.dart';
import 'package:notredame/features/more/settings/settings_manager.dart';
import 'package:notredame/features/app/navigation/navigation_service.dart';
import 'package:notredame/features/more/settings/choose_language_viewmodel.dart';
import '../helpers.dart';
import '../mock/managers/settings_manager_mock.dart';
import '../mock/services/navigation_service_mock.dart';

late ChooseLanguageViewModel viewModel;

void main() {
  late NavigationServiceMock navigationServiceMock;
  late SettingsManagerMock settingsManagerMock;

  group("ChooseLanguageViewModel - ", () {
    setUp(() async {
      // Setting up mocks
      navigationServiceMock = setupNavigationServiceMock();
      settingsManagerMock = setupSettingsManagerMock();
      final AppIntl intl = await setupAppIntl();

      viewModel = ChooseLanguageViewModel(intl: intl);
    });

    tearDown(() {
      unregister<NavigationService>();
      unregister<SettingsManager>();
    });

    group("changeLanguage - ", () {
      test('can set language english', () async {
        SettingsManagerMock.stubSetString(
            settingsManagerMock, PreferencesFlag.theme);

        viewModel.changeLanguage(0);

        verify(settingsManagerMock
            .setLocale(AppIntl.supportedLocales.first.languageCode));
        verify(navigationServiceMock.pop());
        verify(
            navigationServiceMock.pushNamedAndRemoveUntil(RouterPaths.login));
      });

      test('can set language français', () async {
        SettingsManagerMock.stubSetString(
            settingsManagerMock, PreferencesFlag.theme);

        viewModel.changeLanguage(1);

        verify(settingsManagerMock
            .setLocale(AppIntl.supportedLocales.last.languageCode));
        verify(navigationServiceMock.pop());
        verify(
            navigationServiceMock.pushNamedAndRemoveUntil(RouterPaths.login));
      });

      test('throws an error when index does not exist', () async {
        SettingsManagerMock.stubSetString(
            settingsManagerMock, PreferencesFlag.theme);

        expect(() => viewModel.changeLanguage(-1), throwsException,
            reason: "No valid language for the index -1 passed in parameters");
      });
    });

    group("prop language - ", () {
      test('returns the languages successfully', () async {
        final languages = viewModel.languages;

        expect(['English', 'Français'], languages);
      });
    });
  });
}
