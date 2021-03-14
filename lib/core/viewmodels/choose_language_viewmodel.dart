// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:notredame/core/managers/settings_manager.dart';
import 'package:stacked/stacked.dart';

import '../../locator.dart';

class ChooseLanguageViewModel extends BaseViewModel {
  /// Manage the settings
  final SettingsManager _settingsManager = locator<SettingsManager>();

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
}
