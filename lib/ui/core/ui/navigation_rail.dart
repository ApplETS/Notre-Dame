// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:notredame/ui/core/ui/base_navigation_bar.dart';

class NavRail extends BaseNavigationBar {
  const NavRail({super.key});

  @override
  Widget buildNavigationBar(BuildContext context, NavigationView currentView, Function(NavigationView) onTap) {
    return NavigationRail(
      destinations: buildRailItems(context),
      selectedIndex: currentView.index,
      onDestinationSelected: (value) => onTap(NavigationView.values[value]),
      labelType: MediaQuery.of(context).size.height > 350
          ? NavigationRailLabelType.all
          : NavigationRailLabelType.selected,
    );
  }

  @override
  BaseNavigationBarState<BaseNavigationBar> createState() => _NavigationRailState();
}

class _NavigationRailState extends BaseNavigationBarState<BaseNavigationBar> {}
