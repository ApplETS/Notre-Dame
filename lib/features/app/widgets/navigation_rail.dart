// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// Project imports:
import 'package:notredame/features/app/analytics/analytics_service.dart';
import 'package:notredame/features/app/navigation/navigation_service.dart';
import 'package:notredame/features/app/navigation/router_paths.dart';
import 'package:notredame/utils/locator.dart';

/// Bottom navigation bar for the application.
class NavRail extends StatefulWidget {
  static const int dashboardView = 0;
  static const int scheduleView = 1;
  static const int studentView = 2;
  static const int etsView = 3;
  static const int moreView = 4;

  @override
  State<NavRail> createState() => _NavRailState();
}

class _NavRailState extends State<NavRail> {
  final NavigationService _navigationService = locator<NavigationService>();
  final AnalyticsService _analyticsService = locator<AnalyticsService>();

  int _currentView = NavRail.dashboardView;

  @override
  Widget build(BuildContext context) {
    _currentView = _defineIndex(ModalRoute.of(context)!.settings.name!);
    return NavigationRail(
      destinations: _buildItems(context),
      selectedIndex: _currentView,
      onDestinationSelected: (value) => _onTap(value),
      labelType: MediaQuery.of(context).size.height > 350
          ? NavigationRailLabelType.all
          : NavigationRailLabelType.selected,
    );
  }

  int _defineIndex(String routeName) {
    switch (routeName) {
      case RouterPaths.dashboard:
        _currentView = NavRail.dashboardView;
      case RouterPaths.schedule:
        _currentView = NavRail.scheduleView;
      case RouterPaths.student:
        _currentView = NavRail.studentView;
      case RouterPaths.ets:
      case RouterPaths.security:
        _currentView = NavRail.etsView;
      case RouterPaths.more:
      case RouterPaths.settings:
      case RouterPaths.about:
        _currentView = NavRail.moreView;
    }

    return _currentView;
  }

  void _onTap(int index) {
    if (_currentView == index) {
      return;
    }

    switch (index) {
      case NavRail.dashboardView:
        _navigationService.pushNamedAndRemoveDuplicates(RouterPaths.dashboard);
        _analyticsService.logEvent("BottomBar", "DashboardView clicked");
      case NavRail.scheduleView:
        _navigationService.pushNamedAndRemoveDuplicates(RouterPaths.schedule);
        _analyticsService.logEvent("BottomBar", "ScheduleView clicked");
      case NavRail.studentView:
        _navigationService.pushNamedAndRemoveDuplicates(RouterPaths.student);
        _analyticsService.logEvent("BottomBar", "StudentView clicked");
      case NavRail.etsView:
        _navigationService.pushNamedAndRemoveDuplicates(RouterPaths.ets);
        _analyticsService.logEvent("BottomBar", "EtsView clicked");
      case NavRail.moreView:
        _navigationService.pushNamedAndRemoveDuplicates(RouterPaths.more);
        _analyticsService.logEvent("BottomBar", "MoreView clicked");
    }
    _currentView = index;
  }

  List<NavigationRailDestination> _buildItems(BuildContext context) {
    return [
      NavigationRailDestination(
          icon: const Icon(Icons.dashboard_outlined),
          label: Text(AppIntl.of(context)!.title_dashboard)),
      NavigationRailDestination(
          icon: const Icon(Icons.schedule_outlined),
          label: Text(AppIntl.of(context)!.title_schedule)),
      NavigationRailDestination(
          icon: const Icon(Icons.school_outlined),
          label: Text(AppIntl.of(context)!.title_student)),
      NavigationRailDestination(
          icon: const Icon(Icons.account_balance_outlined),
          label: Text(AppIntl.of(context)!.title_ets)),
      NavigationRailDestination(
          icon: const Icon(Icons.menu_outlined),
          label: Text(AppIntl.of(context)!.title_more)),
    ];
  }
}
