// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart' as custom_tabs;
import 'package:url_launcher/url_launcher.dart' as url_launch;

// Project imports:
import 'package:notredame/features/more/settings/settings_manager.dart';
import 'package:notredame/utils/locator.dart';
import 'package:notredame/utils/app_theme.dart';

class LaunchUrlService {
  final SettingsManager settingsManager = locator<SettingsManager>();

  Future<bool> canLaunch(String url) async {
    final uri = Uri.parse(url);
    return url_launch.canLaunchUrl(uri);
  }

  Future<bool> launch(String url) async {
    final uri = Uri.parse(url);
    return url_launch.launchUrl(uri);
  }

  Future<void> launchInBrowser(String url, Brightness brightness) async {
    await custom_tabs.launchUrl(
      Uri.parse(url),
      customTabsOptions: custom_tabs.CustomTabsOptions(
          colorSchemes: custom_tabs.CustomTabsColorSchemes.defaults(
              toolbarColor: brightness == Brightness.light
                  ? AppTheme.etsLightRed
                  : AppTheme.etsDarkRed),
          shareState: custom_tabs.CustomTabsShareState.off,
          urlBarHidingEnabled: true,
          showTitle: true,
          animations: custom_tabs.CustomTabsSystemAnimations.slideIn(),
          browser: const custom_tabs.CustomTabsBrowserConfiguration(
              fallbackCustomTabs: <String>[
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
              ])),
      safariVCOptions: custom_tabs.SafariViewControllerOptions(
        preferredBarTintColor: brightness == Brightness.light
            ? AppTheme.etsLightRed
            : AppTheme.etsDarkRed,
        preferredControlTintColor: brightness == Brightness.light
            ? AppTheme.lightThemeBackground
            : AppTheme.darkThemeBackground,
        barCollapsingEnabled: true,
        entersReaderIfAvailable: false,
        dismissButtonStyle:
            custom_tabs.SafariViewControllerDismissButtonStyle.close,
      ),
    );
  }
}
