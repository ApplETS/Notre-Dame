// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:feature_discovery/feature_discovery.dart';

// SERVICE
import 'package:notredame/core/services/navigation_service.dart';

// CONSTANT
import 'package:notredame/core/constants/router_paths.dart';
import 'package:notredame/locator.dart';

// UTILS
import 'package:notredame/ui/utils/discovery_components.dart';
import 'package:notredame/ui/utils/app_theme.dart';

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
    final discovery = getDiscoveryByPath(context, routerPath);

    return DescribedFeatureOverlay(
      overflowMode: OverflowMode.wrapBackground,
      featureId: discovery.featureId,
      title: Text(discovery.title, textAlign: TextAlign.justify),
      description: discovery.details,
      backgroundColor: AppTheme.appletsPurple,
      tapTarget: Icon(icon, color: AppTheme.etsBlack),
      pulseDuration: const Duration(seconds: 5),
      child: Icon(icon),
    );
  }
}
