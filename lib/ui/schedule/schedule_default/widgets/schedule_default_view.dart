// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:stacked/stacked.dart';

// Project imports:
import 'package:notredame/ui/core/ui/base_scaffold.dart';
import 'package:notredame/ui/schedule/schedule_default/view_model/schedule_default_viewmodel.dart';
import 'package:notredame/ui/schedule/schedule_default/widgets/schedule_default.dart';

class ScheduleDefaultView extends StatefulWidget {
  final String? sessionCode;

  const ScheduleDefaultView({super.key, this.sessionCode});

  @override
  State<ScheduleDefaultView> createState() => _ScheduleDefaultViewState();
}

class _ScheduleDefaultViewState extends State<ScheduleDefaultView> {
  @override
  Widget build(BuildContext context) {
    if (widget.sessionCode == null) {
      return Container();
    }

    return ViewModelBuilder<ScheduleDefaultViewModel>.reactive(
      viewModelBuilder: () =>
          ScheduleDefaultViewModel(sessionCode: widget.sessionCode),
      builder: (context, model, child) => BaseScaffold(
        showBottomBar: false,
        safeArea: false,
        isLoading: model.busy(model.isLoadingEvents),
        appBar: AppBar(
          title: Text(_sessionName(widget.sessionCode!, AppIntl.of(context)!)),
          centerTitle: false,
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
          titleSpacing: 0,
        ),
        body: RefreshIndicator(
          child: model.isBusy
              ? const Center(child: CircularProgressIndicator())
              : ScheduleDefault(
                  calendarEvents: model.calendarEvents,
                  loaded: !model.busy(model.isLoadingEvents),
                  displaySaturday: model.displaySaturday,
                  displaySunday: model.displaySunday),
          onRefresh: () => model.refresh(),
        ),
      ),
    );
  }

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
