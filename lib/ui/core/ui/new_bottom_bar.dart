import 'package:flutter/material.dart';
import 'package:notredame/ui/core/themes/app_palette.dart';
import 'package:notredame/ui/core/themes/app_theme.dart';
import 'package:notredame/ui/core/ui/bottom_bar/selected_menu_item.dart';
import 'package:notredame/ui/core/ui/bottom_bar/unselected_menu_item.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:notredame/data/services/navigation_service.dart';
import 'package:notredame/domain/constants/router_paths.dart';
import 'package:notredame/locator.dart';
import 'base_navigation_bar.dart';

class NewBottomBar extends StatelessWidget {
  const NewBottomBar({
    super.key,
  });

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
                    const Color(0xFF1A1A1D).withValues(alpha: 0.8),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                )),
          ),
        ),
      ),
      Container(
        height: 48,
        margin: const EdgeInsets.all(40),
        padding: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: context.theme.appColors.appBar,
          borderRadius: BorderRadius.circular(16),
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
          padding: const EdgeInsets.symmetric(horizontal: 50.0),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            if (_defineView(ModalRoute.of(context)!.settings.name!) == NavigationView.dashboard)
              SelectedMenuItem(label: intl.title_dashboard, icon: Icons.dashboard, route: RouterPaths.dashboard)
            else
              UnselectedMenuItem(label: intl.title_dashboard, icon: Icons.dashboard_outlined, route: RouterPaths.dashboard),

            if (_defineView(ModalRoute.of(context)!.settings.name!) == NavigationView.schedule)
              SelectedMenuItem(label: intl.title_schedule, icon: Icons.access_time_filled, route: RouterPaths.schedule)
            else
              UnselectedMenuItem(label: intl.title_schedule, icon: Icons.schedule_outlined, route: RouterPaths.schedule),

            if (_defineView(ModalRoute.of(context)!.settings.name!) == NavigationView.student)
              SelectedMenuItem(label: intl.title_student, icon: Icons.school, route: RouterPaths.student)
            else
              UnselectedMenuItem(label: intl.title_student, icon: Icons.school_outlined, route: RouterPaths.student),

            if (_defineView(ModalRoute.of(context)!.settings.name!) == NavigationView.ets)
              SelectedMenuItem(label: intl.title_ets, icon: Icons.account_balance, route: RouterPaths.ets)
            else
              UnselectedMenuItem(label: intl.title_ets, icon: Icons.account_balance_outlined, route: RouterPaths.ets),

            if (_defineView(ModalRoute.of(context)!.settings.name!) == NavigationView.more)
              SelectedMenuItem(label: intl.title_more, icon: Icons.menu, route: RouterPaths.more)
            else
              UnselectedMenuItem(label: intl.title_more, icon: Icons.menu_outlined, route: RouterPaths.more),
          ]),
        ),
      ),
    ]);
  }
}

NavigationView _defineView(String routeName) {
  switch (routeName) {
    case RouterPaths.dashboard:
      return NavigationView.dashboard;
    case RouterPaths.schedule:
      return NavigationView.schedule;
    case RouterPaths.student:
      return NavigationView.student;
    case RouterPaths.ets:
    case RouterPaths.security:
      return NavigationView.ets;
    case RouterPaths.more:
    case RouterPaths.settings:
    case RouterPaths.about:
      return NavigationView.more;
    default:
      return NavigationView.dashboard;
  }
}