// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stacked/stacked.dart';
import 'package:table_calendar/table_calendar.dart';

// VIEWMODEL
import 'package:notredame/core/viewmodels/schedule_viewmodel.dart';

// MODELS
import 'package:notredame/core/models/course_activity.dart';

// WIDGET
import 'package:notredame/ui/widgets/base_scaffold.dart';
import 'package:notredame/ui/widgets/course_activity_tile.dart';
import 'package:notredame/ui/widgets/schedule_settings.dart';

// CONSTANTS
import 'package:notredame/core/constants/preferences_flags.dart';

// OTHER
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:notredame/ui/utils/app_theme.dart';

class DashboardView extends StatefulWidget {
  @visibleForTesting
  final DateTime initialDay;

  const DashboardView({Key key, this.initialDay}) : super(key: key);

  @override
  _DashboardViewState createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView>
    with TickerProviderStateMixin {
  static const Color _selectedColor = AppTheme.etsLightRed;

  static const Color _defaultColor = Color(0xff76859B);

  final DateFormat _dateFormat = DateFormat.MMMMEEEEd();

  CalendarController _calendarController;

  AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _calendarController = CalendarController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _calendarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      ViewModelBuilder<ScheduleViewModel>.reactive(
          viewModelBuilder: () => ScheduleViewModel(initialSelectedDate: widget.initialDay),
          onModelReady: (model) {
            if (model.settings.isEmpty) {
              model.loadSettings(_calendarController);
            }
          },
          builder: (context, model, child) => BaseScaffold(
            isLoading: model.busy(model.isLoadingEvents),
            isInteractionLimitedWhileLoading: false,
            appBar: AppBar(
              title: Text(AppIntl.of(context).title_dashboard),
              centerTitle: false,
              automaticallyImplyLeading: false,
              actions: _buildActionButtons(model),
            ),
            body: Column(
              children: [
                const SizedBox(height: 6.0),
                Flexible(
                  flex: 10,
                  fit: FlexFit.tight,
                  child: Dismissible(
                    key: UniqueKey(),
                    child: Card(
                      elevation: 1,
                      child:
                      Column(

                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Align(
                                alignment: Alignment.centerLeft,
                                child: Container(padding: const EdgeInsets.fromLTRB(10, 10, 0, 0),
                                  child: Text(AppIntl.of(context).title_schedule,  style: Theme.of(context).textTheme.headline6),)),
                            Flexible(
                                fit: FlexFit.tight,
                                child: model.selectedDateEvents.isEmpty
                                    ? Center(
                                    child: Text(
                                        AppIntl.of(context).schedule_no_event))
                                    : _buildEventList(model.selectedDateEvents))
                          ]),

                    ),

                  ),
                ),
                Flexible(
                  flex: 10,
                  fit: FlexFit.tight,
                  child: Dismissible(
                    key: UniqueKey(),
                    child: Card(
                      elevation: 1,
                      child:
                      Column(

                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Align(
                                alignment: Alignment.centerLeft,
                                child: Container(padding: const EdgeInsets.fromLTRB(10, 10, 0, 0),
                                  child: Text(AppIntl.of(context).title_schedule,  style: Theme.of(context).textTheme.headline6),)),
                            Flexible(
                                fit: FlexFit.tight,
                                child: model.selectedDateEvents.isEmpty
                                    ? Center(
                                    child: Text(
                                        AppIntl.of(context).schedule_no_event))
                                    : _buildEventList(model.selectedDateEvents))
                          ]),

                    ),

                  ),
                ),

                Flexible(
                  flex: 10,
                  fit: FlexFit.tight,
                  child: Dismissible(
                    key: UniqueKey(),
                    child: Card(
                      elevation: 1,
                      child:
                      Column(

                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Align(
                                alignment: Alignment.centerLeft,
                                child: Container(padding: const EdgeInsets.fromLTRB(10, 10, 0, 0),
                                  child: Text(AppIntl.of(context).title_schedule,  style: Theme.of(context).textTheme.headline6),)),
                            Flexible(
                                fit: FlexFit.tight,
                                child: model.selectedDateEvents.isEmpty
                                    ? Center(
                                    child: Text(
                                        AppIntl.of(context).schedule_no_event))
                                    : _buildEventList(model.selectedDateEvents))
                          ]),

                    ),

                  ),
                ),
                Flexible(
                  flex: 10,
                  fit: FlexFit.tight,
                  child: Dismissible(
                    key: UniqueKey(),
                    child: Card(
                      elevation: 1,
                      child:
                      Column(

                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Align(
                                alignment: Alignment.centerLeft,
                                child: Container(padding: const EdgeInsets.fromLTRB(10, 10, 0, 0),
                                  child: Text(AppIntl.of(context).title_schedule,  style: Theme.of(context).textTheme.headline6),)),
                            Flexible(
                                fit: FlexFit.tight,
                                child: model.selectedDateEvents.isEmpty
                                    ? Center(
                                    child: Text(
                                        AppIntl.of(context).schedule_no_event))
                                    : _buildEventList(model.selectedDateEvents))
                          ]),

                    ),

                  ),
                ),
              ],
            ),
          )
      );


  /// Build the list of the events for the selected day.
  Widget _buildEventList(List<dynamic> events) {
    return ListView.separated(
        itemBuilder: (_, index) =>
            CourseActivityTile(events[index] as CourseActivity),
        separatorBuilder: (_, index) => (index < events.length)
            ? const Divider(thickness: 2, indent: 30, endIndent: 30)
            : const SizedBox(),
        itemCount: events.length);
  }

  List<Widget> _buildActionButtons(ScheduleViewModel model) => [
    if ((model.settings[PreferencesFlag.scheduleSettingsShowTodayBtn]
    as bool) ==
        true)
      IconButton(
          icon: const Icon(Icons.today),
          onPressed: () => setState(() {
            _calendarController.setSelectedDay(DateTime.now());
            model.selectedDate = DateTime.now();
          })),
    IconButton(
        icon: const Icon(Icons.settings),
        onPressed: () async {
          await showModalBottomSheet(
              isDismissible: true,
              enableDrag: true,
              isScrollControlled: true,
              context: context,
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(110),
                      topRight: Radius.circular(10))),
              builder: (context) => const ScheduleSettings());
          model.loadSettings(_calendarController);
        })
  ];
}
