// Package imports:
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart' as url_launch;

// Project imports:
import 'package:notredame/data/repositories/settings_repository.dart';
import 'package:notredame/locator.dart';
import 'package:notredame/ui/core/themes/app_palette.dart';

class LaunchUrlService {
  final SettingsRepository settingsManager = locator<SettingsRepository>();
  final browser = ChromeSafariBrowser();

  Future<void> writeEmail(String emailAddress, String subject) async {
    final uri = Uri.parse('mailto:$emailAddress?subject=$subject');
    if (await url_launch.canLaunchUrl(uri)) {
      url_launch.launchUrl(uri);
    } else {
      throw 'Could not send email to $emailAddress';
    }
  }

  Future<void> call(String phoneNumber) async {
    final uri = Uri.parse('tel:$phoneNumber');
    if (await url_launch.canLaunchUrl(uri)) {
      url_launch.launchUrl(uri);
    } else {
      throw 'Could not call $phoneNumber';
    }
  }

  void launchInBrowser(String url) {
    browser.open(
        url: WebUri(url),
        settings: ChromeSafariBrowserSettings(
          // Android
          dismissButtonStyle: DismissButtonStyle.CLOSE,
          enableUrlBarHiding: true,
          toolbarBackgroundColor: AppPalette.etsLightRed,
          navigationBarColor: AppPalette.grey.black,

          // iOS
          barCollapsingEnabled: true,
          preferredControlTintColor: AppPalette.grey.white,
          preferredBarTintColor: AppPalette.etsLightRed,
        )
    );
  }
}
