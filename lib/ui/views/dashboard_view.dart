// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stacked/stacked.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


import 'package:flutter/src/widgets/dismissible.dart';

// VIEWMODEL
import 'package:notredame/core/viewmodels/dashboard_viewmodel.dart';

// MODELS
import 'package:notredame/core/models/course_activity.dart';

// WIDGET
import 'package:notredame/ui/widgets/base_scaffold.dart';
import 'package:notredame/ui/widgets/course_activity_tile.dart';
import 'package:notredame/ui/widgets/schedule_settings.dart';

// CONSTANTS
import 'package:notredame/core/constants/preferences_flags.dart';

// OTHER
import 'package:notredame/ui/utils/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';

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

  bool scheduleVisible = true;

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
      ViewModelBuilder<DashboardViewModel>.reactive(
          viewModelBuilder: () =>
              DashboardViewModel(initialSelectedDate: widget.initialDay),
          builder: (context, model, child) => BaseScaffold(
            isLoading: model.busy(model.isLoadingEvents),
            isInteractionLimitedWhileLoading: false,
            appBar: AppBar(
              title: Text(AppIntl.of(context).title_dashboard),
              centerTitle: false,
              automaticallyImplyLeading: false,
              actions: _buildActionButtons(model),
            ),
            body: Column(mainAxisSize: MainAxisSize.min, children: [
              Dismissible(
                key: UniqueKey(),
                child: _buildAboutUsCard(model),
              ),
              const SizedBox(height: 6.0),
              Dismissible(
                key: UniqueKey(),
                child: _buildProgress(model),
              ),
              const SizedBox(height: 6.0),
              if (scheduleVisible)
                IntrinsicHeight(
                  child: Dismissible(
                    key: UniqueKey(),
                    child: _buildTodayScheduleCard(model),
                  ),
                )
              else
                const SizedBox(),
              const SizedBox(height: 6.0),
              Dismissible(
                key: UniqueKey(),
                //child: _buildGradesCard(model),
              ),
            ]),
          ));

  /// Build the list of the events for the selected day.
  Widget _buildEventList(List<dynamic> events) {
    return ListView.separated(
        shrinkWrap: true,
        itemBuilder: (_, index) =>
            CourseActivityTile(events[index] as CourseActivity),
        separatorBuilder: (_, index) => (index < events.length)
            ? const Divider(thickness: 1, indent: 30, endIndent: 30)
            : const SizedBox(),
        itemCount: events.length);
  }

  Widget _buildTodayScheduleCard(DashboardViewModel model) {
    return Card(
      elevation: 1,

      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.fromLTRB(10, 10, 0, 0),
              child: Text(AppIntl.of(context).title_schedule,
                  style: Theme.of(context).textTheme.headline6),
            )),
        if (model.todayDateEvents.isEmpty)
          SizedBox(
              height: 100,
              child: Center(child: Text(AppIntl.of(context).schedule_no_event)))
        else
          Container(
              height: 200.0,
              child: _buildEventList(model.todayDateEvents))
      ]),
    );
  }

  Widget _buildGradesCard(DashboardViewModel model) {
    return Card(
      elevation: 1,

      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.fromLTRB(10, 10, 0, 0),
              child: Text(AppIntl.of(context).title_schedule,
                  style: Theme.of(context).textTheme.headline6),
            )),
        if (model.todayDateEvents.isEmpty)
          SizedBox(
              height: 100,
              child: Center(child: Text(AppIntl.of(context).schedule_no_event)))
        else
          Container(
              height: 200.0,
              child: _buildEventList(model.todayDateEvents))
      ]),
    );
  }




  Widget _buildAboutUsCard(DashboardViewModel model) {
    return Card(
      elevation: 1,
      color: AppTheme.appletsPurple,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.fromLTRB(17, 10, 0, 0),
              child: Text(AppIntl.of(context).card_applets_title,
                  style: Theme.of(context).primaryTextTheme.headline6),
            )),
        Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(17, 10, 15, 10),
              child: Text(AppIntl.of(context).card_applets_text,
                  style: Theme.of(context).primaryTextTheme.bodyText2),
            ),
            Row(children: [
              const SizedBox(width: 2),
              FlatButton(
                onPressed: () {
                  launch('https://www.facebook.com/ClubApplETS');
                },
                child: Text(AppIntl.of(context).facebook.toUpperCase(),
                    style: Theme.of(context).primaryTextTheme.bodyText2),
              ),
              const SizedBox(width: 10),
              FlatButton(
                onPressed: () {
                  launch('https://github.com/ApplETS/Notre-Dame');
                },
                child: Text(AppIntl.of(context).github.toUpperCase(),
                    style: Theme.of(context).primaryTextTheme.button),
              ),
              const SizedBox(width: 10),
              FlatButton(
                onPressed: () {
                  launch('mailto:info@clubapplets.ca');
                },
                child: Text(AppIntl.of(context).email.toUpperCase(),
                    style: Theme.of(context).primaryTextTheme.button),
              ),
            ]),
          ],
        ),
      ]),
    );
  }

  Widget _buildProgress(DashboardViewModel model) {
    return Card(
      elevation: 1,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.fromLTRB(17, 10, 0, 0),
              child: Text("Progression de la session",
                  style: Theme.of(context).textTheme.headline6),
            )),
        Stack(children: [
          Container(
            padding: const EdgeInsets.fromLTRB(17, 10, 15, 20),
            child: ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              child: LinearProgressIndicator(
                value: model.getSessionProgress,
                minHeight: 30,
                valueColor:
                const AlwaysStoppedAnimation<Color>(AppTheme.gradeGoodMax),
                backgroundColor: AppTheme.etsDarkGrey,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.only(top: 16),
            child: Center(
              child: Text(
                  "${model.getSessionDays[0]} jours écoulés/${model.getSessionDays[1]} jours"),
            ),
          ),
        ]),
      ]),
    );
  }

  List<Widget> _buildActionButtons(DashboardViewModel model) => [
    IconButton(
        icon: const Icon(Icons.restore),
        onPressed: () => setState(() {
          scheduleVisible:
          true;
        }))
  ];
}