// Flutter imports:
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

// Package imports:
import 'package:url_launcher/url_launcher.dart' as url_launch;

// Project imports:
import 'package:notredame/data/repositories/settings_repository.dart';
import 'package:notredame/ui/core/themes/app_theme.dart';
import 'package:notredame/locator.dart';

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
          toolbarBackgroundColor: AppTheme.accent,
          navigationBarColor: AppTheme.primaryDark,

          // iOS
          barCollapsingEnabled: true,
          preferredControlTintColor: AppTheme.lightThemeBackground,
          preferredBarTintColor: AppTheme.accent,
        )
    );
  }
}
