// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:stacked/stacked.dart';

// Project imports:
import 'package:notredame/constants/router_paths.dart';
import 'package:notredame/features/quick-link/quick_link.dart';
import 'package:notredame/features/app/analytics/analytics_service.dart';
import 'package:notredame/features/integration/launch_url_service.dart';
import 'package:notredame/features/navigation/navigation_service.dart';
import 'package:notredame/features/navigation/locator.dart';

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
