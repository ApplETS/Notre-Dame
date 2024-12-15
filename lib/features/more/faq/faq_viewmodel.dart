// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:stacked/stacked.dart';

// Project imports:
import 'package:notredame/domain/constants/app_info.dart';
import 'package:notredame/data/services/analytics_service.dart';
import 'package:notredame/data/services/launch_url_service.dart';
import 'package:notredame/features/more/settings/settings_manager.dart';
import 'package:notredame/locator.dart';

class FaqViewModel extends BaseViewModel {
  final SettingsManager _settingsManager = locator<SettingsManager>();

  final LaunchUrlService _launchUrlService = locator<LaunchUrlService>();

  Locale? get locale => _settingsManager.locale;

  void launchWebsite(String link) {
    _launchUrlService.launchInBrowser(link);
  }

  Future<void> openMail(String addressEmail, BuildContext context) async {
    String subject = "";

    if (addressEmail == AppInfo.email) {
      subject = AppIntl.of(context)!.email_subject;
    }

    try {
      _launchUrlService.writeEmail(addressEmail, subject);
    } catch (e) {
      locator<AnalyticsService>().logError("login_view", "Cannot send email.");
    }
  }
}
