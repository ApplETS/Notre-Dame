// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:notredame/data/services/remote_config_service.dart';
import 'package:stacked/stacked.dart';

// Project imports:
import 'package:notredame/data/repositories/settings_repository.dart';
import 'package:notredame/data/services/launch_url_service.dart';
import 'package:notredame/domain/constants/app_info.dart';
import 'package:notredame/locator.dart';

class FaqViewModel extends BaseViewModel {
  final SettingsRepository _settingsManager = locator<SettingsRepository>();

  final LaunchUrlService _launchUrlService = locator<LaunchUrlService>();
  final RemoteConfigService _remoteConfigService = locator<RemoteConfigService>();

  Locale? get locale => _settingsManager.locale;

  void launchWebsite(String link) {
    _launchUrlService.launchInBrowser(link);
  }
  
  void launchPasswordReset() {
    _launchUrlService.launchInBrowser(_remoteConfigService.signetsPasswordResetUrl);
  }

  Future<void> openMail(String addressEmail, BuildContext context) async {
    String subject = "";

    if (addressEmail == AppInfo.email) {
      subject = AppIntl.of(context)!.email_subject;
    }

    _launchUrlService.writeEmail(addressEmail, subject);
  }
}
