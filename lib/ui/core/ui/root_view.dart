// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:animations/animations.dart';

// Project imports:
import 'package:notredame/data/services/analytics_service.dart';
import 'package:notredame/locator.dart';
import 'package:notredame/ui/core/ui/navigation_menu/navigation_menu.dart';
import 'package:notredame/ui/dashboard/widgets/dashboard_view.dart';
import 'package:notredame/ui/ets/widgets/ets_view.dart';
import 'package:notredame/ui/more/widgets/more_view.dart';
import 'package:notredame/ui/schedule/schedule_controller.dart';
import 'package:notredame/ui/schedule/widgets/schedule_view.dart';
import 'package:notredame/ui/student/widgets/student_view.dart';

int currentIndex = 0;
int oldIndex = 0;

enum NavigationView {
  dashboard,
  schedule,
  student,
  ets,
  more,
}

class RootView extends StatefulWidget {
  RootView({super.key});

  final ScheduleController _scheduleController = ScheduleController();

  @override
  State<RootView> createState() => _RootViewState();
}

class _RootViewState extends State<RootView> {
  Widget? currentView;
  final AnalyticsService _analyticsService = locator<AnalyticsService>();

  @override
  Widget build(BuildContext context) {
    currentView ??= _getViewByIndex();
    Widget menu = NavigationMenu(indexChangedCallback: _updateView);

    return Scaffold(
      extendBody: true,
      bottomNavigationBar: (MediaQuery.of(context).orientation == Orientation.portrait) ? menu : null,
      body: Column(children: [
        Expanded(
            child: Row(
          children: [
            if (MediaQuery.of(context).orientation == Orientation.landscape) menu,
            Expanded(
              child: PageTransitionSwitcher(
                  reverse: currentIndex < oldIndex,
                  duration: Duration(milliseconds: 350),
                  transitionBuilder: (child, primaryAnimation, secondaryAnimation) {
                    oldIndex = currentIndex;
                    return SharedAxisTransition(
                      animation: primaryAnimation,
                      secondaryAnimation: secondaryAnimation,
                      transitionType: (MediaQuery.of(context).orientation == Orientation.portrait)
                          ? SharedAxisTransitionType.horizontal
                          : SharedAxisTransitionType.vertical,
                      child: child,
                    );
                  },
                  child: currentView!),
            ),
          ],
        )),
        if (MediaQuery.of(context).orientation == Orientation.portrait)
          SizedBox(height: 96) // The same height as the menu bar
      ]),
    );
  }

  _updateView(int index) {
    if (index == currentIndex) {
      if (index == 1) widget._scheduleController.returnToToday();
      return;
    }

    oldIndex = currentIndex;
    currentIndex = index;
    _analyticsService.logEvent("RootView", "${NavigationView.values[index].name} clicked");

    setState(() => currentView = _getViewByIndex());
  }

  Widget _getViewByIndex() {
    switch (currentIndex) {
      case 0:
        return DashboardView();
      case 1:
        return ScheduleView(controller: widget._scheduleController);
      case 2:
        return StudentView();
      case 3:
        return ETSView();
      case 4:
        return MoreView();
      default:
        return DashboardView();
    }
  }
}
