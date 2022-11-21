// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:feature_discovery/feature_discovery.dart';

// SERVICE
import 'package:notredame/core/services/navigation_service.dart';
import 'package:notredame/core/services/analytics_service.dart';

// CONSTANT
import 'package:notredame/core/constants/router_paths.dart';
import 'package:notredame/core/constants/discovery_ids.dart';

// UTILS
import 'package:notredame/ui/utils/discovery_components.dart';
import 'package:notredame/ui/utils/app_theme.dart';

// OTHER
import 'package:notredame/locator.dart';

/// Bottom navigation bar for the application.
class BottomBar extends StatefulWidget {
  static const int dashboardView = 0;
  static const int scheduleView = 1;
  static const int studentView = 2;
  static const int etsView = 3;
  static const int moreView = 4;

  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  final NavigationService _navigationService = locator<NavigationService>();
  final AnalyticsService _analyticsService = locator<AnalyticsService>();

  int _currentView = BottomBar.dashboardView;

  @override
  Widget build(BuildContext context) {
    _currentView = _defineIndex(ModalRoute.of(context).settings.name);
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      elevation: 0,
      onTap: (value) => _onTap(value),
      items: _buildItems(context),
      currentIndex: _currentView,
    );
  }

  int _defineIndex(String routeName) {
    switch (routeName) {
      case RouterPaths.dashboard:
        _currentView = BottomBar.dashboardView;
        break;
      case RouterPaths.schedule:
        _currentView = BottomBar.scheduleView;
        break;
      case RouterPaths.student:
        _currentView = BottomBar.studentView;
        break;
      case RouterPaths.ets:
      case RouterPaths.security:
        _currentView = BottomBar.etsView;
        break;
      case RouterPaths.more:
      case RouterPaths.settings:
      case RouterPaths.about:
        _currentView = BottomBar.moreView;
        break;
    }

    return _currentView;
  }

  void _onTap(int index) {
    if (_currentView == index) {
      return;
    }

    switch (index) {
      case BottomBar.dashboardView:
        _navigationService.pushNamedAndRemoveUntil(RouterPaths.dashboard);
        _analyticsService.logEvent("BottomBar", "DashboardView clicked");
        break;
      case BottomBar.scheduleView:
        _navigationService.pushNamedAndRemoveUntil(RouterPaths.schedule);
        _analyticsService.logEvent("BottomBar", "ScheduleView clicked");
        break;
      case BottomBar.studentView:
        _navigationService.pushNamedAndRemoveUntil(RouterPaths.student);
        _analyticsService.logEvent("BottomBar", "StudentView clicked");
        break;
      case BottomBar.etsView:
        _navigationService.pushNamedAndRemoveUntil(RouterPaths.ets);
        _analyticsService.logEvent("BottomBar", "EtsView clicked");
        break;
      case BottomBar.moreView:
        _navigationService.pushNamedAndRemoveUntil(RouterPaths.more);
        _analyticsService.logEvent("BottomBar", "MoreView clicked");
        break;
    }
    _currentView = index;
  }

  List<BottomNavigationBarItem> _buildItems(BuildContext context) {
    return [
      BottomNavigationBarItem(
          icon: _buildDiscoveryFeatureDescriptionWidget(
              context, RouterPaths.dashboard, Icons.dashboard),
          label: AppIntl.of(context).title_dashboard),
      BottomNavigationBarItem(
          icon: _buildDiscoveryFeatureDescriptionWidget(
              context, RouterPaths.schedule, Icons.schedule),
          label: AppIntl.of(context).title_schedule),
      BottomNavigationBarItem(
          icon: _buildDiscoveryFeatureDescriptionWidget(
              context, RouterPaths.student, Icons.school),
          label: AppIntl.of(context).title_student),
      BottomNavigationBarItem(
          icon: _buildDiscoveryFeatureDescriptionWidget(
              context, RouterPaths.ets, Icons.account_balance),
          label: AppIntl.of(context).title_ets),
      BottomNavigationBarItem(
          icon: _buildDiscoveryFeatureDescriptionWidget(
              context, RouterPaths.more, Icons.dehaze),
          label: AppIntl.of(context).title_more),
    ];
  }

  DescribedFeatureOverlay _buildDiscoveryFeatureDescriptionWidget(
      BuildContext context, String routerPath, IconData icon) {
    final discovery =
        getDiscoveryByPath(context, DiscoveryGroupIds.bottomBar, routerPath);

    return DescribedFeatureOverlay(
      overflowMode: OverflowMode.wrapBackground,
      featureId: discovery.featureId,
      title: Text(discovery.title, textAlign: TextAlign.justify),
      description: discovery.details,
      backgroundColor: AppTheme.appletsDarkPurple,
      tapTarget: Icon(icon, color: AppTheme.etsBlack),
      pulseDuration: const Duration(seconds: 5),
      child: Icon(icon),
    );
  }
}
