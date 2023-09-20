// FLUTTER / DART / THIRD-PARTIES
import 'dart:ui';
import 'package:notredame/locator.dart';
import 'package:stacked/stacked.dart';

// MANAGERS
import 'package:notredame/core/managers/settings_manager.dart';

// SERVICES
import 'package:notredame/core/services/launch_url_service.dart';

class FaqViewModel extends BaseViewModel {
  final SettingsManager _settingsManager = locator<SettingsManager>();

  final LaunchUrlService _launchUrlService = locator<LaunchUrlService>();

  Locale get locale => _settingsManager.locale;

  String mailtoStr(String email, String subject) {
    return 'mailto:$email?subject=$subject';
  }

  /// used to open a website or the security view
  Future<void> launchWebsite(String link, Brightness brightness) async {
    await _launchUrlService.launchInBrowser(link, brightness);
  }
}
