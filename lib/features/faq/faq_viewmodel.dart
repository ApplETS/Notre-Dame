// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:stacked/stacked.dart';

// Project imports:
import 'package:notredame/constants/app_info.dart';
import 'package:notredame/features/settings/settings_manager.dart';
import 'package:notredame/features/app/analytics/analytics_service.dart';
import 'package:notredame/features/integration/launch_url_service.dart';
import 'package:notredame/features/navigation/locator.dart';

class FaqViewModel extends BaseViewModel {
  final SettingsManager _settingsManager = locator<SettingsManager>();

  final LaunchUrlService _launchUrlService = locator<LaunchUrlService>();

  Locale? get locale => _settingsManager.locale;

  String mailtoStr(String email, String subject) {
    return 'mailto:$email?subject=$subject';
  }

  Future<void> launchWebsite(String link, Brightness brightness) async {
    await _launchUrlService.launchInBrowser(link, brightness);
  }

  Future<void> openMail(String addressEmail, BuildContext context) async {
    var email = "";
    if (addressEmail == AppInfo.email) {
      email = mailtoStr(addressEmail, AppIntl.of(context)!.email_subject);
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
