// FLUTTER / DART / THIRD-PARTIES
import 'package:notredame/core/models/quick_link.dart';
import 'package:stacked/stacked.dart';

// MODELS
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

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
        await launchWebView(link);
      }
    }
  }

  /// used to open a website inside AndroidChromeCustomTabs or SFSafariViewController
  Future<void> launchInBrowser(String url) async {
    final ChromeSafariBrowser browser = ChromeSafariBrowser();
    await browser.open(
        url: Uri.parse(url),
        options: ChromeSafariBrowserClassOptions(
            android: AndroidChromeCustomTabsOptions(
                addDefaultShareMenuItem: false,
                enableUrlBarHiding: true,
                toolbarBackgroundColor: AppTheme.etsLightRed),
            ios: IOSSafariOptions(
                barCollapsingEnabled: true,
                preferredBarTintColor: AppTheme.etsLightRed)));
  }

  Future<void> launchWebView(QuickLink link) async {
    _navigationService.pushNamed(RouterPaths.webView, arguments: link);
  }
}
