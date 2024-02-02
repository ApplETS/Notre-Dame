// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:calendar_view/calendar_view.dart' as calendar_view;
import 'package:ets_api_clients/models.dart';
import 'package:feature_discovery/feature_discovery.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:notredame/ui/widgets/calendar_selector.dart';
import 'package:stacked/stacked.dart';
import 'package:table_calendar/table_calendar.dart';

// Project imports:
import 'package:notredame/core/constants/discovery_ids.dart';
import 'package:notredame/core/constants/preferences_flags.dart';
import 'package:notredame/core/services/analytics_service.dart';
import 'package:notredame/core/viewmodels/schedule_viewmodel.dart';
import 'package:notredame/locator.dart';
import 'package:notredame/ui/utils/app_theme.dart';
import 'package:notredame/ui/utils/discovery_components.dart';
import 'package:notredame/ui/widgets/base_scaffold.dart';
import 'package:notredame/ui/widgets/course_activity_tile.dart';
import 'package:notredame/ui/widgets/schedule_calendar_tile.dart';
import 'package:notredame/ui/widgets/schedule_settings.dart';

class ScheduleView extends StatefulWidget {
  @visibleForTesting
  final DateTime initialDay;

  const ScheduleView({Key key, this.initialDay}) : super(key: key);

  @override
  _ScheduleViewState createState() => _ScheduleViewState();
}

class _ScheduleViewState extends State<ScheduleView>
    with TickerProviderStateMixin {
  final GlobalKey<calendar_view.WeekViewState> weekViewKey =
      GlobalKey<calendar_view.WeekViewState>();
  final GlobalKey<calendar_view.MonthViewState> monthViewKey =
      GlobalKey<calendar_view.MonthViewState>();
  final AnalyticsService _analyticsService = locator<AnalyticsService>();

  static const String tag = "ScheduleView";
  static const Color _selectedColor = AppTheme.etsLightRed;
  static const Color _defaultColor = Color(0xff76859B);
  static final List<String> weekTitles = ["L", "M", "M", "J", "V", "S", "D"];

  AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _animationController.forward();

    SchedulerBinding.instance.addPostFrameCallback((Duration duration) {
      ScheduleViewModel.startDiscovery(context);
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      ViewModelBuilder<ScheduleViewModel>.reactive(
        viewModelBuilder: () => ScheduleViewModel(
            intl: AppIntl.of(context), initialSelectedDate: widget.initialDay),
        onModelReady: (model) {
          if (model.settings.isEmpty) {
            model.loadSettings();
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
            body: RefreshIndicator(
              child: !model.calendarViewSetting
                  ? _buildCalendarView(model, context)
                  : _buildListView(model, context),
              onRefresh: () => model.refresh(),
            )),
      );

  Widget _buildListView(ScheduleViewModel model, BuildContext context) {
    return Stack(children: [
      GestureDetector(
        onPanEnd: (details) {
          if (details.velocity.pixelsPerSecond.dx > 0) {
            setState(() {
              if (!model.showWeekEvents) {
                model.focusedDate.value =
                    model.focusedDate.value.subtract(const Duration(days: 1));
              } else {
                model.focusedDate.value =
                    model.focusedDate.value.subtract(const Duration(days: 7));
              }
              model.selectedDate = model.focusedDate.value;
              HapticFeedback.lightImpact();
            });
          } else if (details.velocity.pixelsPerSecond.dx < -5) {
            setState(() {
              if (!model.showWeekEvents) {
                model.focusedDate.value =
                    model.focusedDate.value.add(const Duration(days: 1));
              } else {
                model.focusedDate.value =
                    model.focusedDate.value.add(const Duration(days: 7));
              }
              model.selectedDate = model.focusedDate.value;
              HapticFeedback.lightImpact();
            });
          }
        },
        child: ListView(
          children: [
            _buildTableCalendar(model),
            const SizedBox(height: 8.0),
            const Divider(indent: 8.0, endIndent: 8.0, thickness: 1),
            const SizedBox(height: 6.0),
            if (model.showWeekEvents)
              for (Widget widget in _buildWeekEvents(model, context)) widget
            else
              _buildTitleForDate(model.selectedDate, model),
            const SizedBox(height: 2.0),
            if (!model.showWeekEvents &&
                model.selectedDateEvents(model.selectedDate).isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 64.0),
                child:
                    Center(child: Text(AppIntl.of(context).schedule_no_event)),
              )
            else if (!model.showWeekEvents)
              _buildEventList(model.selectedDateEvents(model.selectedDate)),
            const SizedBox(height: 16.0),
          ],
        ),
      ),
    ]);
  }

  Widget _buildCalendarView(ScheduleViewModel model, BuildContext context) {
    final calendar_view.EventController eventController =
        calendar_view.EventController();

    final backgroundColor = Theme.of(context).brightness == Brightness.light
        ? AppTheme.lightThemeBackground
        : AppTheme.primaryDark;
    final scheduleLineColor = Theme.of(context).brightness == Brightness.light
        ? AppTheme.scheduleLineColorLight
        : AppTheme.scheduleLineColorDark;
    final chevronColor = Theme.of(context).brightness == Brightness.light
        ? AppTheme.primaryDark
        : AppTheme.lightThemeBackground;

    model.handleViewChanged(DateTime.now(), eventController);

    if (model.calendarFormat == CalendarFormat.month) {
      return _buildCalendarViewMonthly(
          model, context, eventController, backgroundColor, chevronColor);
    }
    return _buildCalendarViewWeekly(model, context, eventController,
        backgroundColor, chevronColor, scheduleLineColor);
  }

  Widget _buildCalendarViewWeekly(
      ScheduleViewModel model,
      BuildContext context,
      calendar_view.EventController eventController,
      Color backgroundColor,
      Color chevronColor,
      Color scheduleLineColor) {
    return Scaffold(
      body: calendar_view.WeekView(
        key: weekViewKey,
        controller: eventController..addAll(model.selectedWeekCalendarEvents()),
        onPageChange: (date, page) =>
            model.handleViewChanged(date, eventController),
        backgroundColor: backgroundColor,
        headerStyle: calendar_view.HeaderStyle(
            decoration: BoxDecoration(
              color: backgroundColor,
            ),
            leftIcon: Icon(
              Icons.chevron_left,
              size: 30,
              color: chevronColor,
            ),
            rightIcon: Icon(
              Icons.chevron_right,
              size: 30,
              color: chevronColor,
            )),
        weekDays: [
          calendar_view.WeekDays.monday,
          calendar_view.WeekDays.tuesday,
          calendar_view.WeekDays.wednesday,
          calendar_view.WeekDays.thursday,
          calendar_view.WeekDays.friday,
          if (model.settings[PreferencesFlag.scheduleOtherWeekday] ==
              calendar_view.WeekDays.saturday)
            calendar_view.WeekDays.saturday,
          if (model.settings[PreferencesFlag.scheduleOtherWeekday] ==
              calendar_view.WeekDays.sunday)
            calendar_view.WeekDays.sunday,
        ],
        initialDay: DateTime.now(),
        heightPerMinute: 0.65, // height occupied by 1 minute time span.
        hourIndicatorSettings: calendar_view.HourIndicatorSettings(
          color: scheduleLineColor,
        ),
        liveTimeIndicatorSettings: calendar_view.HourIndicatorSettings(
          color: chevronColor,
        ),
        scrollOffset: 305,
        timeLineStringBuilder: (date, {secondaryDate}) {
          return DateFormat('HH:mm').format(date);
        },
        weekDayStringBuilder: (p0) {
          return weekTitles[p0];
        },
        headerStringBuilder: (date, {secondaryDate}) {
          final from = AppIntl.of(context).schedule_calendar_from;
          final to = AppIntl.of(context).schedule_calendar_to;
          final locale = AppIntl.of(context).localeName;
          return '$from ${date.day} ${DateFormat.MMMM(locale).format(date)} $to ${secondaryDate.day} ${DateFormat.MMMM(locale).format(secondaryDate)}';
        },
        eventTileBuilder: (date, events, boundary, startDuration,
                endDuration) =>
            _buildEventTile(
                date, events, boundary, startDuration, endDuration, context),
        weekDayBuilder: (DateTime date) => _buildWeekDay(date, model),
      ),
    );
  }

  Widget _buildCalendarViewMonthly(
      ScheduleViewModel model,
      BuildContext context,
      calendar_view.EventController eventController,
      Color backgroundColor,
      Color chevronColor) {
    return Scaffold(
        body: calendar_view.MonthView(
      key: monthViewKey,
      controller: eventController..addAll(model.selectedMonthCalendarEvents()),
      // to provide custom UI for month cells.
      cellAspectRatio: 0.78,
      onPageChange: (date, page) =>
          model.handleViewChanged(date, eventController),
      headerStyle: calendar_view.HeaderStyle(
          decoration: BoxDecoration(
            color: backgroundColor,
          ),
          leftIcon: Icon(
            Icons.chevron_left,
            size: 30,
            color: chevronColor,
          ),
          rightIcon: Icon(
            Icons.chevron_right,
            size: 30,
            color: chevronColor,
          )),
      weekDayStringBuilder: (p0) {
        return weekTitles[p0];
      },
      headerStringBuilder: (date, {secondaryDate}) {
        final locale = AppIntl.of(context).localeName;
        return '${DateFormat.MMMM(locale).format(date).characters.first.toUpperCase()}${DateFormat.MMMM(locale).format(date).substring(1)} ${date.year}';
      },
      startDay: calendar_view.WeekDays.sunday,
      initialMonth: DateTime(DateTime.now().year, DateTime.now().month),
    ));
  }

  Widget _buildEventTile(
    DateTime date,
    List<calendar_view.CalendarEventData<dynamic>> events,
    Rect boundary,
    DateTime startDuration,
    DateTime endDuration,
    BuildContext context,
  ) {
    if (events.isNotEmpty) {
      return ScheduleCalendarTile(
        title: events[0].title,
        description: events[0].description,
        start: events[0].startTime,
        end: events[0].endTime,
        titleStyle: TextStyle(
          fontSize: 14,
          color: events[0].color.accent,
        ),
        totalEvents: events.length,
        padding: const EdgeInsets.all(7.0),
        backgroundColor: events[0].color,
        borderRadius: BorderRadius.circular(6.0),
        buildContext: context,
      );
    } else {
      return Container();
    }
  }

  Widget _buildWeekDay(DateTime date, ScheduleViewModel model) {
    final indicatorColorOpacity =
        Theme.of(context).brightness == Brightness.light ? 0.2 : 0.8;
    return Center(
      child: Container(
        width: 40,
        height: 80,
        decoration: BoxDecoration(
            color: model.compareDates(date, DateTime.now())
                ? AppTheme.etsLightRed.withOpacity(indicatorColorOpacity)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(6.0)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(weekTitles[date.weekday - 1]),
            Text(date.day.toString()),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleForDate(DateTime date, ScheduleViewModel model) => Center(
          child: Text(
        DateFormat.MMMMEEEEd(model.locale.toString()).format(date),
        style: Theme.of(context).textTheme.headline5,
      ));

  List<Widget> _buildWeekEvents(ScheduleViewModel model, BuildContext context) {
    final List<Widget> widgets = [];
    final eventsByDate = model.selectedWeekEvents();
    for (final events in eventsByDate.entries) {
      widgets.add(_buildTitleForDate(events.key, model));
      widgets.add(_buildEventList(events.value));
      widgets.add(const SizedBox(height: 20.0));
    }
    return widgets;
  }

  /// Build the square with the number of [events] for the [date]
  Widget _buildEventsMarker(
      ScheduleViewModel model, DateTime date, List events) {
    if (events.isNotEmpty) {
      return Positioned(
        right: 1,
        bottom: 1,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isSameDay(date, model.selectedDate)
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
    return null;
  }

  /// Build the calendar
  Widget _buildTableCalendar(ScheduleViewModel model) {
    return ValueListenableBuilder<DateTime>(
        valueListenable: model.focusedDate,
        builder: (context, value, _) {
          return TableCalendar(
            startingDayOfWeek:
                model.settings[PreferencesFlag.scheduleStartWeekday]
                    as StartingDayOfWeek,
            locale: model.locale.toLanguageTag(),
            selectedDayPredicate: (day) {
              return isSameDay(model.selectedDate, day);
            },
            weekendDays: const [],
            headerStyle: const HeaderStyle(
                titleCentered: true, formatButtonVisible: false),
            eventLoader: model.coursesActivitiesFor,
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                model.selectedDate = selectedDay;
                model.focusedDate.value = focusedDay;
              });
            },
            calendarFormat: model.calendarFormat,
            onFormatChanged: (format) {
              setState(() {
                model.setCalendarFormat(format);
              });
            },
            focusedDay: model.focusedDate.value,
            onPageChanged: (focusedDay) {
              model.focusedDate.value = focusedDay;
            },
            calendarBuilders: CalendarBuilders(
                todayBuilder: (context, date, _) =>
                    _buildSelectedDate(date, _defaultColor),
                selectedBuilder: (context, date, _) => FadeTransition(
                      opacity: Tween(begin: 0.0, end: 1.0)
                          .animate(_animationController),
                      child: _buildSelectedDate(date, _selectedColor),
                    ),
                markerBuilder: (context, date, events) =>
                    _buildEventsMarker(model, date, events)),
            // Those are now required by the package table_calendar ^3.0.0. In the doc,
            // it is suggest to set them to values that won't affect user experience.
            // Outside the range, the date are set to disable so no event can be loaded.
            firstDay: DateTime.utc(2010, 12, 31),
            lastDay: DateTime.utc(2100, 12, 31),
          );
        });
  }

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
        physics: const ScrollPhysics(),
        shrinkWrap: true,
        itemBuilder: (_, index) =>
            CourseActivityTile(events[index] as CourseActivity),
        separatorBuilder: (_, index) => (index < events.length)
            ? const Divider(thickness: 1, indent: 30, endIndent: 30)
            : const SizedBox(),
        itemCount: events.length);
  }

  List<Widget> _buildActionButtons(ScheduleViewModel model) => [
        IconButton(
          icon: const Icon(Icons.today),
          onPressed: () {
            showDialog(
              context: context,
              builder: (_) => const CalendarSelectionWidget(),
            );
          },
        ),
        if ((model.settings[PreferencesFlag.scheduleShowTodayBtn] as bool) ==
            true)
          IconButton(
              icon: const Icon(Icons.today),
              onPressed: () => setState(() {
                    if (!(model.settings[PreferencesFlag.scheduleListView]
                        as bool)) {
                      weekViewKey.currentState?.animateToWeek(DateTime.now());
                      if (model.calendarFormat == CalendarFormat.month) {
                        monthViewKey.currentState?.animateToMonth(DateTime(
                            DateTime.now().year, DateTime.now().month));
                      }
                    }
                    model.selectToday();
                    if (model.calendarFormat == CalendarFormat.month) {
                      model.selectTodayMonth();
                    }
                    _analyticsService.logEvent(tag, "Select today clicked");
                  })),
        _buildDiscoveryFeatureDescriptionWidget(
          context,
          Icons.settings,
          model,
        ),
      ];

  DescribedFeatureOverlay _buildDiscoveryFeatureDescriptionWidget(
      BuildContext context, IconData icon, ScheduleViewModel model) {
    final discovery = getDiscoveryByFeatureId(
      context,
      DiscoveryGroupIds.pageSchedule,
      DiscoveryIds.detailsScheduleSettings,
    );

    return DescribedFeatureOverlay(
      overflowMode: OverflowMode.wrapBackground,
      contentLocation: ContentLocation.below,
      featureId: discovery.featureId,
      title: Text(discovery.title, textAlign: TextAlign.justify),
      description: discovery.details,
      backgroundColor: AppTheme.appletsDarkPurple,
      tapTarget: Icon(icon, color: AppTheme.etsBlack),
      pulseDuration: const Duration(seconds: 5),
      onComplete: () => model.discoveryCompleted(),
      child: IconButton(
        icon: const Icon(Icons.settings),
        onPressed: () async {
          _analyticsService.logEvent(tag, "Settings clicked");
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
          model.loadSettings();
        },
      ),
    );
  }
}
