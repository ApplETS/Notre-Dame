// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// SERVICE
import 'package:notredame/core/services/navigation_service.dart';

// MANAGERS
import 'package:notredame/core/managers/settings_manager.dart';

// OTHER
import 'package:notredame/locator.dart';
import 'package:notredame/core/constants/router_paths.dart';

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

  ChooseLanguageViewModel({@required AppIntl intl}) : _appIntl = intl;

  List<String> get languages {
    return [_appIntl.settings_english, _appIntl.settings_french];
  }

  void changeLanguage(int index) {
    switch (index) {
      case english:
        _settingsManager.setLocale(AppIntl.supportedLocales.first.languageCode);
        languageSelectedIndex = english;
        break;

      case french:
        _settingsManager.setLocale(AppIntl.supportedLocales.last.languageCode);
        languageSelectedIndex = french;
        break;

      default:
        throw Exception(
            'No valid language for the index $index passed in parameters');
        break;
    }

    _navigationService.pop();
    _navigationService.pushNamed(RouterPaths.login);
  }
}
