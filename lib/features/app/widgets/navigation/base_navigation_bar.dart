import 'package:flutter/material.dart';

import '../../../../utils/locator.dart';
import '../../analytics/analytics_service.dart';
import '../../navigation/navigation_service.dart';
import '../../navigation/router_paths.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

abstract class BaseNavigationBar extends StatefulWidget {
  final List<int> viewIndices = const [
    0, // Dashboard
    1, // Schedule
    2, // Student
    3, // ETS
    4  // More
  ];

  const BaseNavigationBar({super.key});

  @override
  BaseNavigationBarState createState();

  Widget buildNavigationBar(
      BuildContext context, int currentIndex, Function(int) onTap);

  List<NavigationRailDestination> buildRailItems(BuildContext context) => _buildItems(
    context, (icon, selectedIcon, label) =>
      NavigationRailDestination(
        icon: Icon(icon),
        selectedIcon: Icon(selectedIcon),
        label: Text(label),
    ),
  );

  List<BottomNavigationBarItem> buildBottomBarItems(BuildContext context) =>
      _buildItems(context, (icon, selectedIcon, label) =>
          BottomNavigationBarItem(
            icon: Icon(icon),
            activeIcon: Icon(selectedIcon),
            label: label,
    ),
  );

  List<T> _buildItems<T>(
      BuildContext context,
      T Function(IconData, IconData?, String) builder,
      ) {
    final intl = AppIntl.of(context)!;

    return [
      builder(Icons.dashboard_outlined, Icons.dashboard, intl.title_dashboard),
      builder(Icons.schedule_outlined, Icons.access_time_filled, intl.title_schedule),
      builder(Icons.school_outlined, Icons.school, intl.title_student),
      builder(Icons.account_balance_outlined, Icons.account_balance, intl.title_ets),
      builder(Icons.menu_outlined, Icons.menu, intl.title_more),
    ];
  }
}

abstract class BaseNavigationBarState<T extends BaseNavigationBar>
    extends State<T> {
  final NavigationService _navigationService = locator<NavigationService>();
  final AnalyticsService _analyticsService = locator<AnalyticsService>();

  int _currentView = 0;

  @override
  Widget build(BuildContext context) {
    _currentView = _defineIndex(ModalRoute.of(context)!.settings.name!);
    return widget.buildNavigationBar(context, _currentView, _onTap);
  }

  int _defineIndex(String routeName) {
    switch (routeName) {
      case RouterPaths.dashboard:
        return widget.viewIndices[0];
      case RouterPaths.schedule:
        return widget.viewIndices[1];
      case RouterPaths.student:
        return widget.viewIndices[2];
      case RouterPaths.ets:
      case RouterPaths.security:
        return widget.viewIndices[3];
      case RouterPaths.more:
      case RouterPaths.settings:
      case RouterPaths.about:
        return widget.viewIndices[4];
      default:
        return _currentView;
    }
  }

  void _onTap(int index) {
    if (_currentView == index) return;

    final routeNames = [
      RouterPaths.dashboard,
      RouterPaths.schedule,
      RouterPaths.student,
      RouterPaths.ets,
      RouterPaths.more
    ];
    final events = [
      "DashboardView clicked",
      "ScheduleView clicked",
      "StudentView clicked",
      "EtsView clicked",
      "MoreView clicked"
    ];

    _navigationService.pushNamedAndRemoveDuplicates(routeNames[index]);
    _analyticsService.logEvent("NavigationBar", events[index]);
    setState(() => _currentView = index);
  }
}
