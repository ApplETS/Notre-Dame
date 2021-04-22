// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

// CONSTANT
import 'package:notredame/core/constants/router_paths.dart';

// MODEL
import 'package:notredame/core/models/quick_link.dart';

// SERVICE
import 'package:notredame/core/services/navigation_service.dart';

// OTHER
import 'package:notredame/locator.dart';
import 'package:notredame/ui/utils/app_theme.dart';

class WebLinkCard extends StatelessWidget {
  final QuickLink _links;

  /// used to redirect on the security.
  final NavigationService _navigationService = locator<NavigationService>();

  WebLinkCard(this._links);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 130,
      height: 130,
      child: Card(
        elevation: 4.0,
        child: InkWell(
          onTap: () => _onLinkClicked(_links.link),
          splashColor: AppTheme.etsLightRed.withAlpha(50),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Expanded(
                  flex: 40,
                  child: Image.asset(_links.image, color: AppTheme.etsLightRed),
                ),
                Text(
                  _links.name,
                  style: const TextStyle(color: AppTheme.etsLightRed, fontSize: 18.0),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// used to open a website or the security view
  void _onLinkClicked(String link) {
    if (link == 'security') {
      _navigationService.pushNamed(RouterPaths.security);
    } else {
      _launchInBrowser(link);
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
