// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart' as custom_tabs;
import 'package:url_launcher/url_launcher.dart' as url_launch;

// UTILS
import 'package:notredame/ui/utils/app_theme.dart';

class LaunchUrlService {
  Future<bool> canLaunch(String url) async {
    final uri = Uri.parse(url);
    return url_launch.canLaunchUrl(uri);
  }

  Future<bool> launch(String url) async {
    final uri = Uri.parse(url);
    return url_launch.launchUrl(uri);
  }

  Future<void> launchInBrowser(String url) async {
    await custom_tabs.launch(
      url,
      customTabsOption: custom_tabs.CustomTabsOption(
        toolbarColor: AppTheme.etsLightRed,
        enableDefaultShare: false,
        enableUrlBarHiding: true,
        showPageTitle: true,
        animation: custom_tabs.CustomTabsSystemAnimation.slideIn(),
        extraCustomTabs: const <String>[
          // ref. https://play.google.com/store/apps/details?id=org.mozilla.firefox
          'org.mozilla.firefox',
          // https://play.google.com/store/apps/details?id=com.brave.browser
          'com.brave.browser',
          // https://play.google.com/store/apps/details?id=com.opera.browser
          'com.opera.browser',
          'com.opera.mini.native',
          'com.opera.gx',
          // https://play.google.com/store/apps/details?id=com.sec.android.app.sbrowser
          'com.sec.android.app.sbrowser',
          // ref. https://play.google.com/store/apps/details?id=com.microsoft.emmx
          'com.microsoft.emmx',
          // https://play.google.com/store/apps/details?id=com.UCMobile.intl
          'com.UCMobile.intl',
        ],
      ),
      safariVCOption: const custom_tabs.SafariViewControllerOption(
        preferredBarTintColor: AppTheme.etsLightRed,
        preferredControlTintColor: AppTheme.lightThemeBackground,
        barCollapsingEnabled: true,
        entersReaderIfAvailable: false,
        dismissButtonStyle:
            custom_tabs.SafariViewControllerDismissButtonStyle.close,
      ),
    );
  }
}
