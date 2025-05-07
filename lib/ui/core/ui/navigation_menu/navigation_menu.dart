// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// Project imports:
import 'package:notredame/data/models/navigation_menu_callback.dart';
import 'package:notredame/ui/core/themes/app_palette.dart';
import 'package:notredame/ui/core/themes/app_theme.dart';
import 'package:notredame/ui/core/ui/navigation_menu/navigation_menu_button.dart';

late GlobalKey<NavigationMenuButtonState> currentKey;

class NavigationMenu extends StatefulWidget {
  final int selectedIndex;
  final ValueChanged<NavigationMenuCallback> indexChangedCallback;

  const NavigationMenu({super.key, required this.selectedIndex, required this.indexChangedCallback});

  @override
  State<NavigationMenu> createState() => _NavigationMenuState();
}

class _NavigationMenuState extends State<NavigationMenu> {
  List<GlobalKey<NavigationMenuButtonState>> keys = [
    GlobalKey<NavigationMenuButtonState>(),
    GlobalKey<NavigationMenuButtonState>(),
    GlobalKey<NavigationMenuButtonState>(),
    GlobalKey<NavigationMenuButtonState>(),
    GlobalKey<NavigationMenuButtonState>()
  ];

  @override
  void initState() {
    super.initState();

    currentKey = keys[widget.selectedIndex];
    WidgetsBinding.instance.addPostFrameCallback((_) => currentKey.currentState?.restartAnimation());
  }

  @override
  Widget build(BuildContext context) {
    Widget buttons = _createButtons();

    return (MediaQuery.of(context).orientation == Orientation.portrait) ? _bottomBar(buttons) : _sideBar(buttons);
  }

  Widget _sideBar(Widget buttons) {
    return Container(
      padding: EdgeInsets.only(right: Platform.isIOS ? 12.0 : 0.0),
      color: context.theme.appColors.navBar,
      child: SafeArea(
        top: false,
        bottom: false,
        right: false,
        child: Padding(
          padding: const EdgeInsets.only(top: 12.0),
          child: buttons,
        ),
      ),
    );
  }

  Widget _bottomBar(Widget buttons) {
    return Stack(children: [
      Positioned.fill(
        child: IgnorePointer(
          child: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
              colors: [
                Colors.transparent,
                context.theme.scaffoldBackgroundColor,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            )),
          ),
        ),
      ),
      Container(
        height: 96.0,
        decoration: BoxDecoration(
          color: context.theme.appColors.navBar,
          boxShadow: [
            BoxShadow(
              color: AppPalette.etsDarkRed,
              spreadRadius: 1.0,
              blurRadius: 8.0,
            ),
          ],
        ),
      ),
      Positioned.fill(
        child: Padding(padding: const EdgeInsets.symmetric(horizontal: 20.0), child: buttons),
      ),
    ]);
  }

  Widget _createButtons() {
    return Flex(
        mainAxisAlignment: (MediaQuery.of(context).orientation == Orientation.portrait)
            ? MainAxisAlignment.spaceAround
            : MainAxisAlignment.center,
        direction: (MediaQuery.of(context).orientation == Orientation.portrait) ? Axis.horizontal : Axis.vertical,
        children: [
          NavigationMenuButton(
              key: keys[0],
              label: AppIntl.of(context)!.title_dashboard,
              activeIcon: Icons.dashboard,
              inactiveIcon: Icons.dashboard_outlined,
              onPressed: () => _setIndex(0)),
          NavigationMenuButton(
              key: keys[1],
              label: AppIntl.of(context)!.title_schedule,
              activeIcon: Icons.access_time_filled,
              inactiveIcon: Icons.access_time,
              onPressed: () => _setIndex(1)),
          NavigationMenuButton(
              key: keys[2],
              label: AppIntl.of(context)!.title_student,
              activeIcon: Icons.school,
              inactiveIcon: Icons.school_outlined,
              onPressed: () => _setIndex(2)),
          NavigationMenuButton(
              key: keys[3],
              label: AppIntl.of(context)!.title_ets,
              activeIcon: Icons.account_balance_sharp,
              inactiveIcon: Icons.account_balance_outlined,
              onPressed: () => _setIndex(3)),
          NavigationMenuButton(
              key: keys[4],
              label: AppIntl.of(context)!.title_more,
              activeIcon: Icons.menu,
              inactiveIcon: Icons.menu,
              onPressed: () => _setIndex(4)),
        ]);
  }

  _setIndex(int newIndex) {
    widget.indexChangedCallback(NavigationMenuCallback(newIndex, keys[newIndex], currentKey));
    currentKey = keys[newIndex];
  }
}
