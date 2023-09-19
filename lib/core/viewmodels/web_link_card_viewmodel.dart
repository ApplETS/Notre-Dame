// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:notredame/core/models/quick_link.dart';
import 'package:stacked/stacked.dart';

// CONSTANTS
import 'package:notredame/core/constants/router_paths.dart';

// SERVICES
import 'package:notredame/core/services/analytics_service.dart';
import 'package:notredame/core/services/navigation_service.dart';
import 'package:notredame/core/services/launch_url_service.dart';

// OTHER
import 'package:notredame/locator.dart';

class WebLinkCardViewModel extends BaseViewModel {
  /// used to redirect on the security.
  final NavigationService _navigationService = locator<NavigationService>();

  final AnalyticsService _analyticsService = locator<AnalyticsService>();

  final LaunchUrlService _launchUrlService = locator<LaunchUrlService>();

  /// used to open a website or the security view
  Future<void> onLinkClicked(QuickLink link, Brightness brightness) async {
    _analyticsService.logEvent("QuickLink", "QuickLink clicked: ${link.name}");

    if (link.link == 'security') {
      _navigationService.pushNamed(RouterPaths.security);
    } else {
      try {
        await _launchUrlService.launchInBrowser(link.link, brightness);
      } catch (error) {
        // An exception is thrown if browser app is not installed on Android device.
        await launchWebView(link);
      }
    }
  }

  Future<void> launchWebView(QuickLink link) async {
    _navigationService.pushNamed(RouterPaths.webView, arguments: link);
  }
}
