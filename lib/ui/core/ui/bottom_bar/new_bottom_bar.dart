import 'package:flutter/material.dart';
import 'package:notredame/ui/core/themes/app_palette.dart';
import 'package:notredame/ui/core/themes/app_theme.dart';
import 'package:notredame/ui/core/ui/bottom_bar/bottom_bar_button.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class NewBottomBar extends StatefulWidget {
  final ValueChanged<int> indexChangedCallback;

  const NewBottomBar({super.key, required this.indexChangedCallback});

  @override
  State<NewBottomBar> createState() => _NewBottomBarState();
}

class _NewBottomBarState extends State<NewBottomBar> {
  int index = 0;

  List<GlobalKey<BottomBarButtonState>> keys = [
    GlobalKey<BottomBarButtonState>(),
    GlobalKey<BottomBarButtonState>(),
    GlobalKey<BottomBarButtonState>(),
    GlobalKey<BottomBarButtonState>(),
    GlobalKey<BottomBarButtonState>()
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
          color: context.theme.appColors.appBar,
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
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            BottomBarButton(
                key: keys[0],
                label: AppIntl.of(context)!.title_dashboard,
                activeIcon: Icons.dashboard,
                inactiveIcon: Icons.dashboard_outlined,
                onPressed: () => _setIndex(0)),
            BottomBarButton(
                key: keys[1],
                label: AppIntl.of(context)!.title_schedule,
                activeIcon: Icons.access_time_filled,
                inactiveIcon: Icons.access_time,
                onPressed: () => _setIndex(1)),
            BottomBarButton(
                key: keys[2],
                label: AppIntl.of(context)!.title_student,
                activeIcon: Icons.school,
                inactiveIcon: Icons.school_outlined,
                onPressed: () => _setIndex(2)),
            BottomBarButton(
                key: keys[3],
                label: AppIntl.of(context)!.title_ets,
                activeIcon: Icons.account_balance,
                inactiveIcon: Icons.account_balance_outlined,
                onPressed: () => _setIndex(3)),
            BottomBarButton(
                key: keys[4],
                label: AppIntl.of(context)!.title_more,
                activeIcon: Icons.menu,
                inactiveIcon: Icons.menu,
                onPressed: () => _setIndex(4)),
          ]),
        ),
      ),
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
