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
class BottomBar extends StatelessWidget {
  static const int dashboardView = 0;
  static const int scheduleView = 1;
  static const int studentView = 2;
  static const int etsView = 3;
  static const int moreView = 4;

  final NavigationService _navigationService = locator<NavigationService>();
  final AnalyticsService _analyticsService = locator<AnalyticsService>();

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      elevation: 0,
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
        _navigationService.pushNamedAndRemoveUntil(RouterPaths.dashboard);
        _analyticsService.logEvent("BottomBar", "DashboardView clicked");
        break;
      case scheduleView:
        _navigationService.pushNamedAndRemoveUntil(RouterPaths.schedule);
        _analyticsService.logEvent("BottomBar", "ScheduleView clicked");
        break;
      case studentView:
        _navigationService.pushNamedAndRemoveUntil(RouterPaths.student);
        _analyticsService.logEvent("BottomBar", "StudentView clicked");
        break;
      case etsView:
        _navigationService.pushNamedAndRemoveUntil(RouterPaths.ets);
        _analyticsService.logEvent("BottomBar", "EtsView clicked");
        break;
      case moreView:
        _navigationService.pushNamedAndRemoveUntil(RouterPaths.more);
        _analyticsService.logEvent("BottomBar", "MoreView clicked");
        break;
    }
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
