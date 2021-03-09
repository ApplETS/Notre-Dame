// FLUTTER / DART / THIRD-PARTIES
import 'package:stacked/stacked.dart';

// SERVICE
import 'package:notredame/core/services/analytics_service.dart';
import 'package:notredame/core/services/navigation_service.dart';

// OTHER
import 'package:notredame/locator.dart';
import 'package:notredame/core/constants/router_paths.dart';

class NotFoundViewModel extends BaseViewModel {
  static const String tag = "NotFoundViewModel";

  /// Used to redirect on the dashboard.
  final NavigationService _navigationService = locator<NavigationService>();
  //Used to log the event that pushedit from
  final AnalyticsService _analyticsService = locator<AnalyticsService>();
  String _pageName;

  NotFoundViewModel(String pageName) {
    _pageName = pageName;
    _analyticsService.logEvent(
        tag, "An unknown page ($pageName) has been access from the app.");
  }

  String getNotFoundPageName() {
    return _pageName;
  }

  void navigateToDashboard() {
    _navigationService.pushNamed(RouterPaths.dashboard);
  }
}
