// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:notredame/ui/schedule/calendar_controller.dart';

// Project imports:
import '../../../data/services/analytics_service.dart';
import '../../../data/services/navigation_service.dart';
import '../../../domain/constants/router_paths.dart';
import '../../../locator.dart';

enum NavigationView {
  dashboard,
  schedule,
  student,
  ets,
  more,
}

CalendarController _scheduleController = CalendarController();

abstract class BaseNavigationBar extends StatefulWidget {
  const BaseNavigationBar({super.key});

  @override
  BaseNavigationBarState createState();

  Widget buildNavigationBar(BuildContext context, NavigationView currentView,
      Function(NavigationView) onTap);

  List<NavigationRailDestination> buildRailItems(BuildContext context) =>
      _buildItems(
        context,
        (icon, selectedIcon, label) => NavigationRailDestination(
          icon: Icon(icon),
          selectedIcon: Icon(selectedIcon),
          label: Text(label),
        ),
      );

  List<BottomNavigationBarItem> buildBottomBarItems(BuildContext context) =>
      _buildItems(
        context,
        (icon, selectedIcon, label) => BottomNavigationBarItem(
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
      builder(Icons.schedule_outlined, Icons.access_time_filled,
          intl.title_schedule),
      builder(Icons.school_outlined, Icons.school, intl.title_student),
      builder(Icons.account_balance_outlined, Icons.account_balance,
          intl.title_ets),
      builder(Icons.menu_outlined, Icons.menu, intl.title_more),
    ];
  }
}

abstract class BaseNavigationBarState<T extends BaseNavigationBar>
    extends State<T> {
  final NavigationService _navigationService = locator<NavigationService>();
  final AnalyticsService _analyticsService = locator<AnalyticsService>();

  NavigationView _currentView = NavigationView.dashboard;

  @override
  Widget build(BuildContext context) {
    _currentView = _defineView(ModalRoute.of(context)!.settings.name!);
    return widget.buildNavigationBar(context, _currentView, _onTap);
  }

  NavigationView _defineView(String routeName) {
    switch (routeName) {
      case RouterPaths.dashboard:
        return NavigationView.dashboard;
      case RouterPaths.schedule:
        return NavigationView.schedule;
      case RouterPaths.student:
        return NavigationView.student;
      case RouterPaths.ets:
      case RouterPaths.security:
        return NavigationView.ets;
      case RouterPaths.more:
      case RouterPaths.settings:
      case RouterPaths.about:
        return NavigationView.more;
      default:
        return _currentView;
    }
  }

  void _onTap(NavigationView view) {
    if (view == NavigationView.schedule && _currentView == view) {
      _scheduleController.returnToToday();
    }

    if (_currentView == view) return;

    final routeNames = {
      NavigationView.dashboard: RouterPaths.dashboard,
      NavigationView.schedule: RouterPaths.schedule,
      NavigationView.student: RouterPaths.student,
      NavigationView.ets: RouterPaths.ets,
      NavigationView.more: RouterPaths.more
    };
    final events = {
      NavigationView.dashboard: "DashboardView clicked",
      NavigationView.schedule: "ScheduleView clicked",
      NavigationView.student: "StudentView clicked",
      NavigationView.ets: "EtsView clicked",
      NavigationView.more: "MoreView clicked"
    };

    if (view == NavigationView.schedule) {
      _navigationService.pushNamedAndRemoveDuplicates(routeNames[view]!, arguments: _scheduleController);
    } else {
      _navigationService.pushNamedAndRemoveDuplicates(routeNames[view]!);
    }
    _analyticsService.logEvent("NavigationBar", events[view]!);
    setState(() => _currentView = view);
  }
}
