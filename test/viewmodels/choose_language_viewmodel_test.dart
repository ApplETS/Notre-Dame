// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// ROUTES
import 'package:notredame/core/constants/router_paths.dart';

// MANAGER
import 'package:notredame/core/managers/settings_manager.dart';
import 'package:notredame/core/services/navigation_service.dart';

// VIEWMODEL
import 'package:notredame/core/viewmodels/choose_language_viewmodel.dart';

// CONSTANTS
import 'package:notredame/core/constants/preferences_flags.dart';

// OTHERS
import '../helpers.dart';
import '../mock/managers/settings_manager_mock.dart';

ChooseLanguageViewModel viewModel;

void main() {
  NavigationService navigationService;
  SettingsManager settingsManager;

  group("ChooseLanguageViewModel - ", () {
    setUp(() async {
      // Setting up mocks
      navigationService = setupNavigationServiceMock();
      settingsManager = setupSettingsManagerMock();
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
            settingsManager as SettingsManagerMock, PreferencesFlag.theme);

        viewModel.changeLanguage(0);

        verify(settingsManager.setLocale(AppIntl.supportedLocales.first.languageCode));
        verify(navigationService.pop());
        verify(navigationService.pushNamed(RouterPaths.dashboard));
      });

      test('can set language français', () async {
        SettingsManagerMock.stubSetString(
            settingsManager as SettingsManagerMock, PreferencesFlag.theme);

        viewModel.changeLanguage(1);

        verify(settingsManager.setLocale(AppIntl.supportedLocales.last.languageCode));
        verify(navigationService.pop());
        verify(navigationService.pushNamed(RouterPaths.dashboard));
      });

      test('throws an error when index does not exist', () async {
        SettingsManagerMock.stubSetString(
            settingsManager as SettingsManagerMock, PreferencesFlag.theme);

        expect(() =>
          viewModel.changeLanguage(-1),
          throwsException,
          reason: "No valid language for the index -1 passed in paramaters");
      }); 
    }); 

    group("prop language - ", () {
      test('returns the languages successfully', () async {
        final languages = viewModel.languages;

        expect(['English', 'Français'], languages);
      });

      test('returns the languages with an exception', () async {
        const AppIntl intlNull = null;
        final ChooseLanguageViewModel viewModelWithInvalidIntl = ChooseLanguageViewModel(intl: intlNull);

        expect(() =>
          viewModelWithInvalidIntl.languages,
          throwsNoSuchMethodError,
          reason: "The getter 'settings_english' was called on null");
      });

      test('returns the languages icons successfully', () async {
        final languagesIcons = viewModel.languagesIcons;

        expect(['assets/icons/english_icon.png', 'assets/icons/french_icon.png'], languagesIcons);
      });
    });
  });
}
