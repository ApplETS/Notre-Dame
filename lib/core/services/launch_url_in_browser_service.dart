// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart';

// UTILS
import 'package:notredame/ui/utils/app_theme.dart';

/// used to open a website inside AndroidChromeCustomTabs or SFSafariViewController
Future<void> launchInBrowser(String url) async {
  await launch(
    url,
    customTabsOption: CustomTabsOption(
      toolbarColor: AppTheme.etsLightRed,
      enableDefaultShare: false,
      enableUrlBarHiding: true,
      showPageTitle: true,
      animation: CustomTabsSystemAnimation.slideIn(),
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
    safariVCOption: const SafariViewControllerOption(
      preferredBarTintColor: AppTheme.etsLightRed,
      preferredControlTintColor: AppTheme.lightThemeBackground,
      barCollapsingEnabled: true,
      entersReaderIfAvailable: false,
      dismissButtonStyle: SafariViewControllerDismissButtonStyle.close,
    ),
  );
}
