// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';
import 'package:notredame/locator.dart';
import 'package:stacked/stacked.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// MANAGERS
import 'package:notredame/core/managers/settings_manager.dart';

// SERVICES
import 'package:notredame/core/services/launch_url_service.dart';
import 'package:notredame/core/services/analytics_service.dart';

// CONSTANTS
import 'package:notredame/core/constants/app_info.dart';

class FaqViewModel extends BaseViewModel {
  final SettingsManager _settingsManager = locator<SettingsManager>();

  final LaunchUrlService _launchUrlService = locator<LaunchUrlService>();

  Locale get locale => _settingsManager.locale;

  String mailtoStr(String email, String subject) {
    return 'mailto:$email?subject=$subject';
  }

  Future<void> launchWebsite(String link, Brightness brightness) async {
    await _launchUrlService.launchInBrowser(link, brightness);
  }

  Future<void> openMail(String addressEmail, BuildContext context) async {
    var email = "";
    if (addressEmail == AppInfo.email) {
      email = mailtoStr(addressEmail, AppIntl.of(context).email_subject);
    } else {
      email = mailtoStr(addressEmail, "");
    }

    final urlLaunchable = await _launchUrlService.canLaunch(email);

    if (urlLaunchable) {
      await _launchUrlService.launch(email);
    } else {
      locator<AnalyticsService>().logError("login_view", "Cannot send email.");
    }
  }
}
