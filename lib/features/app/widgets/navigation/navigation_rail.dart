// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:notredame/features/app/widgets/navigation/base_navigation_bar.dart';

class NavRail extends BaseNavigationBar {
  const NavRail({super.key});

  @override
  Widget buildNavigationBar(BuildContext context, int currentIndex, Function(int) onTap) {
    return NavigationRail(
      destinations: buildRailItems(context),
      selectedIndex: currentIndex,
      onDestinationSelected: (value) => onTap(value),
      labelType: MediaQuery.of(context).size.height > 350
          ? NavigationRailLabelType.all
          : NavigationRailLabelType.selected,
    );
  }

  @override
  BaseNavigationBarState<BaseNavigationBar> createState() => _NavigationRailState();
}

class _NavigationRailState extends BaseNavigationBarState<BaseNavigationBar> {}
