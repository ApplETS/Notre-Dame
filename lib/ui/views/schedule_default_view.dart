// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:notredame/ui/widgets/schedule_default.dart';
import 'package:stacked/stacked.dart';

// Project imports:
import 'package:notredame/ui/utils/app_theme.dart';
import 'package:notredame/ui/widgets/base_scaffold.dart';
import 'package:notredame/core/viewmodels/schedule_default_viewmodel.dart';

class ScheduleDefaultView extends StatefulWidget {
  final String sessionCode;

  const ScheduleDefaultView({this.sessionCode});

  @override
  _ScheduleDefaultViewState createState() => _ScheduleDefaultViewState();
}

class _ScheduleDefaultViewState extends State<ScheduleDefaultView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) =>
    ViewModelBuilder<ScheduleDefaultViewModel>.reactive(
      viewModelBuilder: () => ScheduleDefaultViewModel(
          sessionCode: widget.sessionCode),
      builder: (context, model, child) => BaseScaffold(
        showBottomBar: false,
        body: Material(
          child: NestedScrollView(
            headerSliverBuilder: (context, innerBoxScrolled) => [
              SliverAppBar(
                backgroundColor:
                    Theme.of(context).brightness == Brightness.light
                        ? AppTheme.etsLightRed
                        : Theme.of(context).bottomAppBarColor,
                pinned: true,
                onStretchTrigger: () {
                  return Future<void>.value();
                },
                titleSpacing: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                title: Text(widget.sessionCode)
              ),
            ],
            body: const SafeArea(
              child: ScheduleDefault(),
            ),
          ),
        ),
      ),
    );
}
