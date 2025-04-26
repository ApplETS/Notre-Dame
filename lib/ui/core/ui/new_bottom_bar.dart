import 'package:flutter/material.dart';
import 'package:notredame/ui/core/themes/app_palette.dart';
import 'package:notredame/ui/core/themes/app_theme.dart';
import 'package:notredame/ui/core/ui/bottom_bar/selected_menu_item.dart';
import 'package:notredame/ui/core/ui/bottom_bar/unselected_menu_item.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'bottom_bar/button_properties.dart';

class NewBottomBar extends StatefulWidget {
  final ValueChanged<int> indexChangedCallback;

  const NewBottomBar({
    super.key,
    required this.indexChangedCallback
  });

  @override
  State<NewBottomBar> createState() => _NewBottomBarState();
}

class _NewBottomBarState extends State<NewBottomBar> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    final intl = AppIntl.of(context)!;
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
            if (index == 0)
              SelectedMenuItem(properties: ButtonProperties(intl.title_dashboard, Icons.dashboard, () => _setIndex(0)))
            else
              UnselectedMenuItem(properties: ButtonProperties(intl.title_dashboard, Icons.dashboard_outlined, () => _setIndex(0))),
            if (index == 1)
              SelectedMenuItem(properties: ButtonProperties(intl.title_schedule, Icons.access_time_filled, () => _setIndex(1)))
            else
              UnselectedMenuItem(properties: ButtonProperties(intl.title_schedule, Icons.schedule_outlined, () => _setIndex(1))),
            if (index == 2)
              SelectedMenuItem(properties: ButtonProperties(intl.title_student, Icons.school, () => _setIndex(2)))
            else
              UnselectedMenuItem(properties: ButtonProperties(intl.title_student, Icons.school_outlined, () => _setIndex(2))),
            if (index == 3)
              SelectedMenuItem(properties: ButtonProperties(intl.title_ets, Icons.account_balance, () => _setIndex(3)))
            else
              UnselectedMenuItem(properties: ButtonProperties(intl.title_ets, Icons.account_balance_outlined, () => _setIndex(3))),
            if (index == 4)
              SelectedMenuItem(properties: ButtonProperties(intl.title_more, Icons.menu, () => _setIndex(4)))
            else
              UnselectedMenuItem(properties: ButtonProperties(intl.title_more, Icons.menu_outlined, () => _setIndex(4)))
          ]),
        ),
      ),
    ]);
  }

  _setIndex(int index) {
    setState(() {
      this.index = index;
      widget.indexChangedCallback(index);
    });
  }
}
