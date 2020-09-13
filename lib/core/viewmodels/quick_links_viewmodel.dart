// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:stacked/stacked.dart';

// VIEW
import 'package:notredame/ui/views/security_view.dart';

// MODEL
import 'package:notredame/core/models/quick_link.dart';

// CONSTANT
import 'package:notredame/core/constants/quick_links.dart';

class QuickLinksViewModel extends BaseViewModel {
  final int numberOfLinks = quickLinks.length;

  List<QuickLink> quickLinkList = quickLinks;

  void onLinkClicked(BuildContext context, QuickLink links) {
    if (links.link == 'security') {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => SecurityView()));
    } else {
      _launchInBrowser(links.link);
    }
  }

  Future<void> _launchInBrowser(String url) async {
    final ChromeSafariBrowser browser = ChromeSafariBrowser();
    await browser.open(
        url: url,
        options: ChromeSafariBrowserClassOptions(
            android: AndroidChromeCustomTabsOptions(
                addDefaultShareMenuItem: false, toolbarBackgroundColor: "Red"),
            ios: IOSSafariOptions(
                barCollapsingEnabled: true, preferredBarTintColor: "Red")));
  }
}
