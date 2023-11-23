// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:stacked/stacked.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// Project imports:
import 'package:notredame/core/viewmodels/schedule_default_viewmodel.dart';
import 'package:notredame/ui/utils/app_theme.dart';
import 'package:notredame/ui/widgets/base_scaffold.dart';
import 'package:notredame/ui/widgets/schedule_default.dart';

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
        viewModelBuilder: () =>
            ScheduleDefaultViewModel(sessionCode: widget.sessionCode),
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
                    title: Text(_sessionName(widget.sessionCode, AppIntl.of(context))),)
              ],
              body: SafeArea(
                child: model.isBusy 
                  ? const Center(child: CircularProgressIndicator()) 
                  : ScheduleDefault(calendarEvents: model.calendarEvents),
              ),
            ),
          ),
        ),
      );

  String _sessionName(String shortName, AppIntl intl) {
    switch (shortName[0]) {
      case 'H':
        return "${intl.session_winter} ${shortName.substring(1)}";
      case 'A':
        return "${intl.session_fall} ${shortName.substring(1)}";
      case 'É':
        return "${intl.session_summer} ${shortName.substring(1)}";
      default:
        return intl.session_without;
    }
  }
}
