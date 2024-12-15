// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:notredame/ui/core/ui/base_navigation_bar.dart';

class BottomBar extends BaseNavigationBar {
  const BottomBar({super.key});

  @override
  Widget buildNavigationBar(BuildContext context, NavigationView currentView, Function(NavigationView) onTap) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      elevation: 0,
      onTap: (value) => onTap(NavigationView.values[value]),
      items: buildBottomBarItems(context),
      currentIndex: currentView.index,
    );
  }

  @override
  BaseNavigationBarState<BaseNavigationBar> createState() => _BottomBarState();
}

class _BottomBarState extends BaseNavigationBarState<BaseNavigationBar> {}
