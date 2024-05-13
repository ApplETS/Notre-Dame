// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:feature_discovery/feature_discovery.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// Project imports:
import 'package:notredame/core/constants/discovery_ids.dart';
import 'package:notredame/core/constants/router_paths.dart';
import 'package:notredame/core/services/analytics_service.dart';
import 'package:notredame/core/services/navigation_service.dart';
import 'package:notredame/locator.dart';
import 'package:notredame/ui/utils/app_theme.dart';
import 'package:notredame/ui/utils/discovery_components.dart';

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
        break;
      case RouterPaths.schedule:
        _currentView = NavRail.scheduleView;
        break;
      case RouterPaths.student:
        _currentView = NavRail.studentView;
        break;
      case RouterPaths.ets:
      case RouterPaths.security:
        _currentView = NavRail.etsView;
        break;
      case RouterPaths.more:
      case RouterPaths.settings:
      case RouterPaths.about:
        _currentView = NavRail.moreView;
        break;
    }

    return _currentView;
  }

  void _onTap(int index) {
    if (_currentView == index) {
      return;
    }

    switch (index) {
      case NavRail.dashboardView:
        _navigationService.pushNamedAndRemoveUntil(RouterPaths.dashboard);
        _analyticsService.logEvent("BottomBar", "DashboardView clicked");
      case NavRail.scheduleView:
        _navigationService.pushNamedAndRemoveUntil(RouterPaths.schedule);
        _analyticsService.logEvent("BottomBar", "ScheduleView clicked");
      case NavRail.studentView:
        _navigationService.pushNamedAndRemoveUntil(RouterPaths.student);
        _analyticsService.logEvent("BottomBar", "StudentView clicked");
      case NavRail.etsView:
        _navigationService.pushNamedAndRemoveUntil(RouterPaths.ets);
        _analyticsService.logEvent("BottomBar", "EtsView clicked");
      case NavRail.moreView:
        _navigationService.pushNamedAndRemoveUntil(RouterPaths.more);
        _analyticsService.logEvent("BottomBar", "MoreView clicked");
    }
    _currentView = index;
  }

  List<NavigationRailDestination> _buildItems(BuildContext context) {
    return [
      NavigationRailDestination(
          icon: _buildDiscoveryFeatureDescriptionWidget(
              context, RouterPaths.dashboard, Icons.dashboard),
          label: Text(AppIntl.of(context)!.title_dashboard)),
      NavigationRailDestination(
          icon: _buildDiscoveryFeatureDescriptionWidget(
              context, RouterPaths.schedule, Icons.schedule),
          label: Text(AppIntl.of(context)!.title_schedule)),
      NavigationRailDestination(
          icon: _buildDiscoveryFeatureDescriptionWidget(
              context, RouterPaths.student, Icons.school),
          label: Text(AppIntl.of(context)!.title_student)),
      NavigationRailDestination(
          icon: _buildDiscoveryFeatureDescriptionWidget(
              context, RouterPaths.ets, Icons.account_balance),
          label: Text(AppIntl.of(context)!.title_ets)),
      NavigationRailDestination(
          icon: _buildDiscoveryFeatureDescriptionWidget(
              context, RouterPaths.more, Icons.dehaze),
          label: Text(AppIntl.of(context)!.title_more)),
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
