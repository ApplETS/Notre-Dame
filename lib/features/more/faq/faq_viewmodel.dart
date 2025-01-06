// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:stacked/stacked.dart';

// Project imports:
import 'package:notredame/constants/app_info.dart';
import 'package:notredame/features/app/analytics/analytics_service.dart';
import 'package:notredame/features/app/integration/launch_url_service.dart';
import 'package:notredame/features/more/settings/settings_manager.dart';
import 'package:notredame/utils/locator.dart';

class FaqViewModel extends BaseViewModel {
  static const String tag = "FaqViewModel";
  final AnalyticsService _analyticsService = locator<AnalyticsService>();

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

    _launchUrlService.writeEmail(addressEmail, subject);
  }
}
