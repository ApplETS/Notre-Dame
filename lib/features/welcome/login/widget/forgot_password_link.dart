// widgets/ForgotPasswordLink.dart

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:fluttertoast/fluttertoast.dart';

// Project imports:
import 'package:notredame/features/app/analytics/remote_config_service.dart';
import 'package:notredame/features/app/integration/launch_url_service.dart';
import 'package:notredame/utils/locator.dart';

class ForgotPasswordLink extends StatelessWidget {
  final LaunchUrlService _launchUrlService = locator<LaunchUrlService>();
  final RemoteConfigService _remoteConfigService =
      locator<RemoteConfigService>();

  ForgotPasswordLink({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topRight,
      child: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: InkWell(
          child: Text(
            AppIntl.of(context)!.forgot_password,
            style: const TextStyle(
                decoration: TextDecoration.underline, color: Colors.white),
          ),
          onTap: () {
            final signetsPasswordResetUrl =
                _remoteConfigService.signetsPasswordResetUrl;
            if (signetsPasswordResetUrl != "") {
              _launchUrlService.launchInBrowser(
                  _remoteConfigService.signetsPasswordResetUrl,
                  Theme.of(context).brightness);
            } else {
              Fluttertoast.showToast(msg: AppIntl.of(context)!.error);
            }
          },
        ),
      ),
    );
  }
}
