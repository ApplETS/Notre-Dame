// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:notredame/ui/dashboard/widgets/dashboard_view.dart';
import 'package:notredame/ui/ets/widgets/ets_view.dart';
import 'package:notredame/ui/core/ui/new_bottom_bar.dart';
import 'package:notredame/ui/more/widgets/more_view.dart';
import 'package:notredame/ui/schedule/schedule_controller.dart';
import 'package:notredame/ui/schedule/widgets/schedule_view.dart';
import 'package:notredame/ui/student/widgets/student_view.dart';

class RootView extends StatefulWidget {
  RootView({super.key});

  final ScheduleController _scheduleController = ScheduleController();

  @override
  State<RootView> createState() => _RootViewState();
}

class _RootViewState extends State<RootView> {
  Widget currentView = DashboardView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: NewBottomBar(indexChangedCallback: _updateView),
      body: currentView,
    );
  }

  _updateView(int index) {
    setState(() {
      currentView = _getViewByIndex(index);
    });
  }

  Widget _getViewByIndex(int index) {
    switch (index) {
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