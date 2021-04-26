// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stacked/stacked.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
import 'package:notredame/ui/utils/app_theme.dart';

class ScheduleView extends StatefulWidget {
  @visibleForTesting
  final DateTime initialDay;

  const ScheduleView({Key key, this.initialDay}) : super(key: key);

  @override
  _ScheduleViewState createState() => _ScheduleViewState();
}

class _ScheduleViewState extends State<ScheduleView>
    with TickerProviderStateMixin {
  static const Color _selectedColor = AppTheme.etsLightRed;

  static const Color _defaultColor = Color(0xff76859B);

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
          viewModelBuilder: () => ScheduleViewModel(
              intl: AppIntl.of(context),
              initialSelectedDate: widget.initialDay),
          onModelReady: (model) {
            if (model.settings.isEmpty) {
              model.loadSettings(_calendarController);
            }
          },
          builder: (context, model, child) => BaseScaffold(
                isLoading: model.busy(model.isLoadingEvents),
                isInteractionLimitedWhileLoading: false,
                appBar: AppBar(
                  title: Text(AppIntl.of(context).title_schedule),
                  centerTitle: false,
                  automaticallyImplyLeading: false,
                  actions: _buildActionButtons(model),
                ),
                body: Stack(children: [
                  Column(
                    children: [
                      _buildTableCalendar(model),
                      const SizedBox(height: 8.0),
                      const Divider(indent: 8.0, endIndent: 8.0, thickness: 1),
                      const SizedBox(height: 6.0),
                      Center(
                          child: Text(
                              DateFormat.MMMMEEEEd(model.locale.toString())
                                  .format(model.selectedDate),
                              style: Theme.of(context).textTheme.headline5)),
                      const SizedBox(height: 2.0),
                      Expanded(
                          child: model.selectedDateEvents.isEmpty
                              ? Center(
                                  child: Text(
                                      AppIntl.of(context).schedule_no_event))
                              : _buildEventList(model.selectedDateEvents))
                    ],
                  ),
                ]),
                fab: FloatingActionButton(
                  onPressed: model.refresh,
                  backgroundColor: AppTheme.etsLightRed,
                  child: const Icon(Icons.refresh),
                ),
              ));

  /// Build the square with the number of [events] for the [date]
  Widget _buildEventsMarker(DateTime date, List events) {
    return Positioned(
      right: 1,
      bottom: 1,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: _calendarController.isSelected(date)
              ? _selectedColor
              : _defaultColor,
        ),
        width: 16.0,
        height: 16.0,
        child: Center(
          child: Text(
            '${events.length}',
            style: const TextStyle().copyWith(
              color: Colors.white,
              fontSize: 12.0,
            ),
          ),
        ),
      ),
    );
  }

  /// Build the calendar
  Widget _buildTableCalendar(ScheduleViewModel model) => TableCalendar(
        //TODO uncomment when https://github.com/aleksanderwozniak/table_calendar/issues/164 is close
        // startingDayOfWeek: model.settings[PreferencesFlag.scheduleSettingsStartWeekday] as StartingDayOfWeek,
        startingDayOfWeek: StartingDayOfWeek.monday,
        locale: model.locale.toLanguageTag(),
        initialSelectedDay: widget.initialDay ?? DateTime.now(),
        weekendDays: const [],
        headerStyle: const HeaderStyle(
            centerHeaderTitle: true, formatButtonVisible: false),
        events: model.coursesActivities,
        onDaySelected: (date, events, holidays) => setState(() {
          model.selectedDate = date;
        }),
        builders: CalendarBuilders(
            todayDayBuilder: (context, date, _) =>
                _buildSelectedDate(date, _defaultColor),
            selectedDayBuilder: (context, date, _) => FadeTransition(
                  opacity:
                      Tween(begin: 0.0, end: 1.0).animate(_animationController),
                  child: _buildSelectedDate(date, _selectedColor),
                ),
            markersBuilder: (context, date, events, holidays) =>
                [_buildEventsMarker(date, events)]),
        calendarController: _calendarController,
      );

  /// Build the visual for the selected [date]. The [color] parameter set the color for the tile.
  Widget _buildSelectedDate(DateTime date, Color color) => Container(
        margin: const EdgeInsets.all(4.0),
        padding: const EdgeInsets.only(top: 5.0, left: 6.0),
        decoration: BoxDecoration(border: Border.all(color: color)),
        width: 100,
        height: 100,
        child: Text(
          '${date.day}',
          style: const TextStyle().copyWith(fontSize: 16.0),
        ),
      );

  /// Build the list of the events for the selected day.
  Widget _buildEventList(List<dynamic> events) {
    return ListView.separated(
        itemBuilder: (_, index) =>
            CourseActivityTile(events[index] as CourseActivity),
        separatorBuilder: (_, index) => (index < events.length)
            ? const Divider(thickness: 1, indent: 30, endIndent: 30)
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
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10))),
                  builder: (context) => const ScheduleSettings());
              model.loadSettings(_calendarController);
            })
      ];
}
