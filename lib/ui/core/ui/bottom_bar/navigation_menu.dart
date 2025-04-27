import 'package:flutter/material.dart';
import 'package:notredame/ui/core/themes/app_theme.dart';
import 'package:notredame/ui/core/ui/bottom_bar/navigation_menu_button.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:notredame/ui/core/themes/app_palette.dart';

int index = 0;

class NavigationMenu extends StatefulWidget {
  final ValueChanged<int> indexChangedCallback;

  const NavigationMenu({super.key, required this.indexChangedCallback});

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      keys[index].currentState?.restartAnimation();
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget buttons = _createButtons();

    if (MediaQuery.of(context).orientation == Orientation.portrait) {
      return _bottomBar(buttons);
    }

    return _sideBar(buttons);
  }

  Widget _sideBar(Widget buttons) {
    return Container(
      width: 80,
      color: context.theme.appColors.navBar,
      child: Padding(
        padding: const EdgeInsets.only(top: 12.0),
        child: buttons,
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
                    context.theme.scaffoldBackgroundColor.withAlpha(64),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                )),
          ),
        ),
      ),
      Container(
        height: 96,
        margin: const EdgeInsets.only(top: 40),
        padding: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: context.theme.appColors.navBar,
          boxShadow: [
            BoxShadow(
              color: AppPalette.etsDarkRed,
              spreadRadius: 1,
              blurRadius: 8,
            ),
          ],
        ),
      ),
      Positioned.fill(
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: buttons
        ),
      ),
    ]);
  }

  Widget _createButtons() {
    return Flex(
        mainAxisAlignment: (MediaQuery.of(context).orientation == Orientation.portrait) ? MainAxisAlignment.spaceAround : MainAxisAlignment.center,
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
    widget.indexChangedCallback(newIndex);

    if (newIndex == index) return;
    keys[index].currentState?.reverseAnimation();
    index = newIndex;
    keys[index].currentState?.restartAnimation();
  }
}
