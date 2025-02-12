// Package imports:
import 'package:stacked/stacked.dart';

// Project imports:
import 'package:notredame/data/models/quick_link.dart';
import 'package:notredame/data/services/analytics_service.dart';
import 'package:notredame/data/services/launch_url_service.dart';
import 'package:notredame/data/services/navigation_service.dart';
import 'package:notredame/domain/constants/router_paths.dart';
import 'package:notredame/locator.dart';

class WebLinkCardViewModel extends BaseViewModel {
  /// used to redirect on the security.
  final NavigationService _navigationService = locator<NavigationService>();

  final AnalyticsService _analyticsService = locator<AnalyticsService>();

  final LaunchUrlService _launchUrlService = locator<LaunchUrlService>();

  /// used to open a website or the security view
  Future<void> onLinkClicked(QuickLink link) async {
    _analyticsService.logEvent("QuickLink", "QuickLink clicked: ${link.name}");

    if (link.link == 'security') {
      _navigationService.pushNamed(RouterPaths.security);
    } else {
      _launchUrlService.launchInBrowser(link.link);
    }
  }
}
