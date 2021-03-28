// FLUTTER / DART / THIRD-PARTIES
import 'package:notredame/core/managers/dashboard_manager.dart';
import 'package:stacked/stacked.dart';

import '../../locator.dart';

class DashboardViewModel extends BaseViewModel {
  /// Manage the cards
  final DashboardManager _dashboardManager = locator<DashboardManager>();

  bool get showAboutUsCard {
    return _dashboardManager.showAboutUsCard;
  }

  /// Set showAboutUsCard
  set showAboutUsCard(bool value) {
    _dashboardManager.setShowAboutUsCard(value);
  }

  DashboardViewModel();
}
