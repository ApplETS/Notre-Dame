// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

// SERVICE
import 'package:notredame/core/services/navigation_service.dart';

// OTHER
import 'package:notredame/locator.dart';
import 'package:notredame/core/constants/router_paths.dart';

class NotFoundViewModel extends BaseViewModel {
  /// Used to redirect on the dashboard.
  final NavigationService _navigationService = locator<NavigationService>();

  NotFoundViewModel();

  void navigateToDashboard() {
    _navigationService.pushNamed(RouterPaths.dashboard);
  }
}
