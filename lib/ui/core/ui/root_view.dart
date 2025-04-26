// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:notredame/ui/dashboard/widgets/dashboard_view.dart';
import 'package:notredame/ui/ets/widgets/ets_view.dart';
import 'package:notredame/ui/core/ui/bottom_bar/new_bottom_bar.dart';
import 'package:notredame/ui/more/widgets/more_view.dart';
import 'package:notredame/ui/schedule/schedule_controller.dart';
import 'package:notredame/ui/schedule/widgets/schedule_view.dart';
import 'package:notredame/ui/student/widgets/student_view.dart';

int currentIndex = 0;

class RootView extends StatefulWidget {
  RootView({super.key});

  final ScheduleController _scheduleController = ScheduleController();

  @override
  State<RootView> createState() => _RootViewState();
}

class _RootViewState extends State<RootView> {
  Widget? currentView;

  @override
  Widget build(BuildContext context) {
    currentView ??= _getViewByIndex(currentIndex);

    return Scaffold(
      extendBody: true,
      bottomNavigationBar: NewBottomBar(indexChangedCallback: _updateView),
      body: Column(children: [
        Expanded(child: currentView!),
        SizedBox(height: 100) // The same height as the menu bar
      ]),
    );
  }

  _updateView(int index) {
    if (index == currentIndex) {
      if (index == 1) widget._scheduleController.returnToToday();
      return;
    }

    setState(() {
      currentView = _getViewByIndex(index);
    });
  }

  Widget _getViewByIndex(int index) {
    currentIndex = index;

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
