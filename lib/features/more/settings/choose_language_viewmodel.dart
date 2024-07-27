// Package imports:
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:stacked/stacked.dart';

// Project imports:
import 'package:notredame/features/app/navigation/navigation_service.dart';
import 'package:notredame/features/app/navigation/router_paths.dart';
import 'package:notredame/features/more/settings/settings_manager.dart';
import 'package:notredame/utils/locator.dart';

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
      case french:
        _settingsManager.setLocale('fr');
        languageSelectedIndex = french;
      default:
        throw Exception(
            'No valid language for the index $index passed in parameters');
    }

    _navigationService.pop();
    _navigationService.pushNamedAndRemoveUntil(RouterPaths.login);
  }
}
