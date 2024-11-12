// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:notredame/features/app/widgets/navigation/base_navigation_bar.dart';

class BottomBar extends BaseNavigationBar {
  const BottomBar({super.key});

  @override
  Widget buildNavigationBar(BuildContext context, int currentIndex, Function(int) onTap) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      elevation: 0,
      onTap: onTap,
      items: buildBottomBarItems(context),
      currentIndex: currentIndex,
    );
  }

  @override
  BaseNavigationBarState<BaseNavigationBar> createState() => _BottomBarState();
}

class _BottomBarState extends BaseNavigationBarState<BaseNavigationBar> {}
