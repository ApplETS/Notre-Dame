// Package imports:
import 'package:stacked/stacked.dart';

// Project imports:
import 'package:notredame/data/services/analytics_service.dart';
import 'package:notredame/data/services/navigation_service.dart';
import 'package:notredame/domain/constants/router_paths.dart';
import 'package:notredame/locator.dart';

class NotFoundViewModel extends BaseViewModel {
  static const String tag = "NotFoundViewModel";

  /// Used to redirect on the dashboard.
  final NavigationService _navigationService = locator<NavigationService>();

  /// Used to log the event that pushed it from
  final AnalyticsService _analyticsService = locator<AnalyticsService>();

  final String notFoundPageName;

  NotFoundViewModel({required String pageName}) : notFoundPageName = pageName {
    _analyticsService.logEvent(tag, "An unknown page ($pageName) has been access from the app.");
  }

  void navigateToDashboard() {
    _navigationService.pushNamedAndRemoveUntil(RouterPaths.dashboard);
  }
}
