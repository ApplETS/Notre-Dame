// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// SERVICE
import 'package:notredame/core/services/navigation_service.dart';

// CONSTANT
import 'package:notredame/core/constants/router_paths.dart';
import 'package:notredame/locator.dart';

/// Bottom navigation bar for the application.
class BottomBar extends StatelessWidget {
  static const int dashboardView = 0;
  static const int scheduleView = 1;
  static const int studentView = 2;
  static const int etsView = 3;
  static const int moreView = 4;

  final NavigationService _navigationService = locator<NavigationService>();

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      onTap: (value) => _onTap(value),
      items: _buildItems(context),
      currentIndex: _defineIndex(ModalRoute.of(context).settings.name),
    );
  }

  int _defineIndex(String routeName) {
    int currentView = dashboardView;

    switch (routeName) {
      case RouterPaths.dashboard:
        currentView = dashboardView;
        break;
      case RouterPaths.schedule:
        currentView = scheduleView;
        break;
      case RouterPaths.student:
        currentView = studentView;
        break;
      case RouterPaths.ets:
      case RouterPaths.security:
        currentView = etsView;
        break;
      case RouterPaths.more:
      case RouterPaths.settings:
      case RouterPaths.about:
        currentView = moreView;
        break;
    }

    return currentView;
  }

  void _onTap(int index) {
    switch (index) {
      case dashboardView:
        _navigationService.pushNamed(RouterPaths.dashboard);
        break;
      case scheduleView:
        _navigationService.pushNamed(RouterPaths.schedule);
        break;
      case studentView:
        _navigationService.pushNamed(RouterPaths.student);
        break;
      case etsView:
        _navigationService.pushNamed(RouterPaths.ets);
        break;
      case moreView:
        _navigationService.pushNamed(RouterPaths.more);
        break;
    }
  }

  List<BottomNavigationBarItem> _buildItems(BuildContext context) {
    return [
      BottomNavigationBarItem(
          icon: const Icon(Icons.dashboard),
          label: AppIntl.of(context).title_dashboard),
      BottomNavigationBarItem(
          icon: const Icon(Icons.schedule),
          label: AppIntl.of(context).title_schedule),
      BottomNavigationBarItem(
          icon: const Icon(Icons.school),
          label: AppIntl.of(context).title_student),
      BottomNavigationBarItem(
          icon: const Icon(Icons.account_balance),
          label: AppIntl.of(context).title_ets),
      BottomNavigationBarItem(
          icon: const Icon(Icons.dehaze),
          label: AppIntl.of(context).title_more),
    ];
  }
}
