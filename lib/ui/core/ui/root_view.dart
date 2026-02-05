// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:animations/animations.dart';

// Project imports:
import 'package:notredame/data/models/navigation_menu_callback.dart';
import 'package:notredame/data/services/analytics_service.dart';
import 'package:notredame/locator.dart';
import 'package:notredame/ui/core/ui/navigation_menu/navigation_menu.dart';
import 'package:notredame/ui/dashboard/widgets/dashboard_view.dart';
import 'package:notredame/ui/ets/widgets/ets_view.dart';
import 'package:notredame/ui/more/widgets/more_view.dart';
import 'package:notredame/ui/schedule/schedule_controller.dart';
import 'package:notredame/ui/schedule/widgets/schedule_view.dart';
import 'package:notredame/ui/student/widgets/student_view.dart';

enum NavigationView {
  dashboard(0),
  schedule(1),
  student(2),
  ets(3),
  more(4);

  final int buttonIndex;

  const NavigationView(this.buttonIndex);
}

NavigationView _selected = NavigationView.dashboard;
NavigationView _previous = _selected;
final ScheduleController _scheduleController = ScheduleController();

class RootView extends StatefulWidget {
  const RootView({super.key});

  @override
  State<RootView> createState() => _RootViewState();
}

class _RootViewState extends State<RootView> {
  Widget? currentView;
  final AnalyticsService _analyticsService = locator<AnalyticsService>();

  @override
  Widget build(BuildContext context) {
    currentView ??= _getViewByIndex();
    Widget menu = NavigationMenu(selectedIndex: _selected.buttonIndex, indexChangedCallback: _updateView);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      // primary: false,
      extendBody: true,
      bottomNavigationBar: (MediaQuery.of(context).orientation == Orientation.portrait) ? menu : null,
      body: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                if (MediaQuery.of(context).orientation == Orientation.landscape) menu,
                Expanded(
                  child: PageTransitionSwitcher(
                    reverse: _selected.buttonIndex < _previous.buttonIndex,
                    duration: Duration(milliseconds: 350),
                    transitionBuilder: (child, primaryAnimation, secondaryAnimation) {
                      _previous = _selected;
                      return SharedAxisTransition(
                        animation: primaryAnimation,
                        secondaryAnimation: secondaryAnimation,
                        transitionType: (MediaQuery.of(context).orientation == Orientation.portrait)
                            ? SharedAxisTransitionType.horizontal
                            : SharedAxisTransitionType.vertical,
                        child: child,
                      );
                    },
                    child: currentView!,
                  ),
                ),
              ],
            ),
          ),
          if (MediaQuery.of(context).orientation == Orientation.portrait)
            SizedBox(height: 80.0), // The same height as the menu bar
        ],
      ),
    );
  }

  void _updateView(NavigationMenuCallback callback) {
    if (callback.index == _selected.buttonIndex) {
      if (callback.index == NavigationView.schedule.buttonIndex) _scheduleController.returnToToday();
      return;
    }

    // Animate navigation menu icons
    callback.oldKey.currentState?.reverseAnimation();
    callback.newKey.currentState?.restartAnimation();

    _previous = _selected;
    _selected = NavigationView.values[callback.index];

    _analyticsService.logEvent("RootView", "${_selected.name} clicked");
    setState(() => currentView = _getViewByIndex());
  }

  Widget _getViewByIndex() {
    return switch (_selected) {
      NavigationView.dashboard => DashboardView(),
      NavigationView.schedule => ScheduleView(controller: _scheduleController),
      NavigationView.student => StudentView(),
      NavigationView.ets => ETSView(),
      NavigationView.more => MoreView(),
    };
  }
}
