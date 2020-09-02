// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';
import 'package:notredame/generated/l10n.dart';

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

  final int _currentView;

  BottomBar(int index) : _currentView = index;

  @override
  Widget build(BuildContext context) => BottomNavigationBar(
        onTap: _onTap,
        items: _buildItems(context),
        currentIndex: _currentView,
      );

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
          title: Text(AppIntl.of(context).title_dashboard)),
      BottomNavigationBarItem(
          icon: const Icon(Icons.schedule),
          title: Text(AppIntl.of(context).title_schedule)),
      BottomNavigationBarItem(
          icon: const Icon(Icons.school),
          title: Text(AppIntl.of(context).title_student)),
      BottomNavigationBarItem(
          icon: const Icon(Icons.account_balance),
          title: Text(AppIntl.of(context).title_ets)),
      BottomNavigationBarItem(
          icon: const Icon(Icons.dehaze),
          title: Text(AppIntl.of(context).title_more)),
    ];
  }
}
