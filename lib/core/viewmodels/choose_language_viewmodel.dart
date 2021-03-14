// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:notredame/core/constants/router_paths.dart';
import 'package:notredame/core/managers/settings_manager.dart';
import 'package:notredame/core/services/navigation_service.dart';
import 'package:stacked/stacked.dart';

import '../../locator.dart';

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

  List<String> get languagesIcons {
    return [
      'assets/icons/english_icon.png',
      'assets/icons/french_icon.png',
    ];
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
    }

    _navigationService.pop();
    _navigationService.pushNamed(RouterPaths.dashboard);
  }
}
