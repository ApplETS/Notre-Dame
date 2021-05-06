// FLUTTER / DART / THIRD-PARTIES
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:package_info/package_info.dart';

// CONSTANT
import 'package:notredame/core/constants/router_paths.dart';

// MODEL
import 'package:notredame/core/models/quick_link.dart';
import 'package:notredame/core/services/analytics_service.dart';

// SERVICE
import 'package:notredame/core/services/navigation_service.dart';

// OTHER
import 'package:notredame/locator.dart';
import 'package:notredame/ui/utils/app_theme.dart';

class WebLinkCard extends StatelessWidget {
  final QuickLink _links;

  /// used to redirect on the security.
  final NavigationService _navigationService = locator<NavigationService>();

  final AnalyticsService _analyticsService = locator<AnalyticsService>();

  WebLinkCard(this._links);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width / 3.1,
      height: 130,
      child: Card(
        elevation: 4.0,
        child: InkWell(
          onTap: () => _onLinkClicked(_links.link, context),
          splashColor: AppTheme.etsLightRed.withAlpha(50),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Expanded(
                  flex: 40,
                  child: Image.asset(_links.image, color: AppTheme.etsLightRed),
                ),
                FittedBox(
                  fit: BoxFit.fitWidth,
                  child: Text(
                    _links.name,
                    style: const TextStyle(color: Colors.red, fontSize: 18.0),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// used to open a website or the security view
  Future<void> _onLinkClicked(String link, BuildContext context) async {
    if (link == 'security') {
      _navigationService.pushNamed(RouterPaths.security);
    } else {
      try {
        await _launchInBrowser(link);
      } catch(e) {        
        final PackageInfo packageInfo = await PackageInfo.fromPlatform();

        final errorMessage = "**Error message : ${e.toString()}\n**Device Infos** \n"
                "- **Version:** ${packageInfo.version} \n"
                "- **Build number:** ${packageInfo.buildNumber} \n"
                "- **Platform operating system:** ${Platform.operatingSystem} \n"
                "- **Platform operating system version:** ${Platform.operatingSystemVersion} \n";

        _analyticsService.logError("web_link_card", errorMessage);
        _navigationService.pushNamed(RouterPaths.webView, arguments: _links);
      }
    }
  }

  /// used to open a website inside AndroidChromeCustomTabs or SFSafariViewController
  Future<void> _launchInBrowser(String url) async {
    final ChromeSafariBrowser browser = ChromeSafariBrowser();
    await browser.open(
        url: Uri.parse(url),
        options: ChromeSafariBrowserClassOptions(
            android: AndroidChromeCustomTabsOptions(
                addDefaultShareMenuItem: false,
                enableUrlBarHiding: true,
                toolbarBackgroundColor: Colors.red),
            ios: IOSSafariOptions(
                barCollapsingEnabled: true,
                preferredBarTintColor: Colors.red)));
  }
}
