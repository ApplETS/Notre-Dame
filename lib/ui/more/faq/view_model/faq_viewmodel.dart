// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:stacked/stacked.dart';

// Project imports:
import 'package:notredame/domain/constants/urls.dart';
import 'package:notredame/data/services/launch_url_service.dart';
import 'package:notredame/data/services/remote_config_service.dart';
import 'package:notredame/l10n/app_localizations.dart';
import 'package:notredame/locator.dart';

class FaqViewModel extends BaseViewModel {
  final LaunchUrlService _launchUrlService = locator<LaunchUrlService>();
  final RemoteConfigService _remoteConfigService = locator<RemoteConfigService>();

  void launchWebsite(String link) {
    _launchUrlService.launchInBrowser(link);
  }

  void launchPasswordReset() {
    _launchUrlService.launchInBrowser(_remoteConfigService.signetsPasswordResetUrl);
  }

  Future<void> openMail(String addressEmail, BuildContext context) async {
    String subject = "";

    if (addressEmail == Urls.clubEmail) {
      subject = AppIntl.of(context)!.email_subject;
    }

    _launchUrlService.writeEmail(addressEmail, subject);
  }
}
