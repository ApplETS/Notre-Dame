// FLUTTER / DART / THIRD-PARTIES
import 'package:notredame/core/models/quick_link.dart';
import 'package:stacked/stacked.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart';

// CONSTANTS
import 'package:notredame/core/constants/router_paths.dart';

// SERVICES
import 'package:notredame/core/services/analytics_service.dart';
import 'package:notredame/core/services/navigation_service.dart';

// UTILS
import 'package:notredame/ui/utils/app_theme.dart';

// OTHER
import 'package:notredame/locator.dart';

class WebLinkCardViewModel extends BaseViewModel {
  /// used to redirect on the security.
  final NavigationService _navigationService = locator<NavigationService>();

  final AnalyticsService _analyticsService = locator<AnalyticsService>();

  /// used to open a website or the security view
  Future<void> onLinkClicked(QuickLink link) async {
    _analyticsService.logEvent("QuickLink", "QuickLink clicked: ${link.name}");

    if (link.link == 'security') {
      _navigationService.pushNamed(RouterPaths.security);
    } else {
      try {
        await launchInBrowser(link.link);
      } catch (error) {
        // An exception is thrown if browser app is not installed on Android device.
        await launchWebView(link);
      }
    }
  }

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

  Future<void> launchWebView(QuickLink link) async {
    _navigationService.pushNamed(RouterPaths.webView, arguments: link);
  }
}
