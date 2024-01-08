// Package imports:
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:stacked/stacked.dart';

// Project imports:
import 'package:notredame/core/constants/router_paths.dart';
import 'package:notredame/core/managers/settings_manager.dart';
import 'package:notredame/core/services/navigation_service.dart';
import 'package:notredame/locator.dart';

class ChooseLanguageViewModel extends BaseViewModel {
  static const int english = 0;
  static const int french = 1;
  int languageSelectedIndex = -1;

  /// Manage the settings
  final SettingsManager _settingsManager = locator<SettingsManager>();

  /// Used to redirect on the dashboard.
  final NavigationService _navigationService = locator<NavigationService>();

  /// Localization class of the application.
  final AppIntl _appIntl;

  ChooseLanguageViewModel({required AppIntl intl}) : _appIntl = intl;

  List<String> get languages {
    return [_appIntl.settings_english, _appIntl.settings_french];
  }

  void changeLanguage(int index) {
    switch (index) {
      case english:
        _settingsManager.setLocale('en');
        languageSelectedIndex = english;
        break;
      case french:
        _settingsManager.setLocale('fr');
        languageSelectedIndex = french;
        break;
      default:
        throw Exception(
            'No valid language for the index $index passed in parameters');
    }

    _navigationService.pop();
    _navigationService.pushNamedAndRemoveUntil(RouterPaths.login);
  }
}
