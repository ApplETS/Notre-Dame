// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:calendar_view/calendar_view.dart' as calendar_view;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:notredame/features/schedule/widgets/schedule_settings.dart';
import 'package:notredame/data/services/calendar_service.dart';
import 'package:stacked/stacked.dart';
import 'package:table_calendar/table_calendar.dart';

// Project imports:
import 'package:notredame/domain/constants/preferences_flags.dart';
import 'package:notredame/data/services/analytics_service.dart';
import 'package:notredame/data/services/signets-api/models/course_activity.dart';
import 'package:notredame/features/app/widgets/base_scaffold.dart';
import 'package:notredame/features/dashboard/widgets/course_activity_tile.dart';
import 'package:notredame/features/schedule/schedule_viewmodel.dart';
import 'package:notredame/features/schedule/widgets/calendar_selector.dart';
import 'package:notredame/features/schedule/widgets/schedule_calendar_tile.dart';
import 'package:notredame/utils/app_theme.dart';
import 'package:notredame/locator.dart';

class ScheduleView extends StatefulWidget {
  @visibleForTesting
  final DateTime? initialDay;

  const ScheduleView({super.key, this.initialDay});

  @override
  State<ScheduleView> createState() => _ScheduleViewState();
}

class _ScheduleViewState extends State<ScheduleView>
    with TickerProviderStateMixin {
  final GlobalKey<calendar_view.WeekViewState> weekViewKey =
      GlobalKey<calendar_view.WeekViewState>();
  final GlobalKey<calendar_view.MonthViewState> monthViewKey =
      GlobalKey<calendar_view.MonthViewState>();
  final GlobalKey<calendar_view.DayViewState> dayViewKey =
      GlobalKey<calendar_view.DayViewState>();
  final AnalyticsService _analyticsService = locator<AnalyticsService>();

  static const String tag = "ScheduleView";
  static final List<String> weekTitles = ["L", "M", "M", "J", "V", "S", "D"];
  static bool _isDayViewAnimating = false;

  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _animationController.forward();
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
            intl: AppIntl.of(context)!),
        onViewModelReady: (model) {
          if (model.settings.isEmpty) {
            model.loadSettings();
          }
        },
        builder: (context, model, child) => BaseScaffold(
            isLoading: model.busy(model.isLoadingEvents),
            isInteractionLimitedWhileLoading: false,
            appBar: AppBar(
              title: Text(AppIntl.of(context)!.title_schedule),
              centerTitle: false,
              automaticallyImplyLeading: false,
              actions: model.busy(model.settings) ? [] : _buildActionButtons(model),
            ),
            body: model.busy(model.settings)
                ? const SizedBox()
                : displaySchedule(model)),
      );

  Widget displaySchedule(ScheduleViewModel model) {
    final calendar_view.EventController eventController = calendar_view.EventController();

    final backgroundColor = Theme.of(context).brightness == Brightness.light
        ? AppTheme.lightThemeBackground
        : AppTheme.primaryDark;
    final scheduleLineColor = Theme.of(context).brightness == Brightness.light
        ? AppTheme.scheduleLineColorLight
        : AppTheme.scheduleLineColorDark;
    final chevronColor = Theme.of(context).brightness == Brightness.light
        ? AppTheme.primaryDark
        : AppTheme.lightThemeBackground;
    final textColor = Theme.of(context).brightness == Brightness.light
        ? AppTheme.primaryDark
        : AppTheme.lightThemeAccent;
    final scheduleCardsPalette = Theme.of(context).brightness == Brightness.light
        ? AppTheme.schedulePaletteLight.toList()
        : AppTheme.schedulePaletteDark.toList();

    if (model.calendarFormat == CalendarTimeFormat.month) {
      return _buildCalendarViewMonthly(model, context, eventController, backgroundColor, chevronColor, scheduleLineColor, textColor, scheduleCardsPalette);
    }
    if (model.calendarFormat == CalendarTimeFormat.week) {
      return _buildCalendarViewWeekly(model, context, eventController, backgroundColor, chevronColor, scheduleLineColor, scheduleCardsPalette);
    }
    if (!model.calendarViewSetting) {
      return _buildCalendarViewDaily(model, context, eventController, backgroundColor, chevronColor, scheduleLineColor);
    }

    return _buildListView(model, context, eventController);
  }

  Widget _buildListView(ScheduleViewModel model, BuildContext context, calendar_view.EventController eventController) {
    return Stack(children: [
      GestureDetector(
        onPanEnd: (details) {
          if (details.velocity.pixelsPerSecond.dx.abs() > 5) {
            setState(() {
              final int numberOfDays = details.velocity.pixelsPerSecond.dx.sign.toInt();
              final DateTime newFocusedDate = model.daySelected.subtract(Duration(days: numberOfDays));
              model.handleViewChanged(newFocusedDate, eventController, []);
              HapticFeedback.lightImpact();
            });
          }
        },
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            _buildTableCalendar(model, eventController),
            const SizedBox(height: 8.0),
            const Divider(indent: 8.0, endIndent: 8.0, thickness: 1),
            const SizedBox(height: 6.0),
            _buildTitleForDate(model.daySelected, model),
            const SizedBox(height: 2.0),
            if (model.selectedDateEvents(model.daySelected).isEmpty && !model.isBusy)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 64.0),
                child:
                    Center(child: Text(AppIntl.of(context)!.schedule_no_event)),
              )
            else
              _buildEventList(model.selectedDateEvents(model.daySelected)),
            const SizedBox(height: 16.0),
          ],
        ),
      ),
    ]);
  }

  Widget _buildCalendarViewDaily(
      ScheduleViewModel model,
      BuildContext context,
      calendar_view.EventController eventController,
      Color backgroundColor,
      Color chevronColor,
      Color scheduleLineColor) {
    final double heightPerMinute = (MediaQuery.of(context).size.height / 1200).clamp(0.45, 1.0);
    return Column(
      children: [
        _buildTableCalendar(model, eventController),
        Expanded(
            child: calendar_view.DayView(
                showVerticalLine: false,
                dayTitleBuilder: calendar_view.DayHeader.hidden,
                key: dayViewKey,
                controller: eventController
                  ..addAll(model.selectedDayCalendarEvents()),
                onPageChange: (date, page) => setState(() {
                  if (!_isDayViewAnimating) {
                    model.handleViewChanged(date, eventController, []);
                  }
                }),
                backgroundColor: backgroundColor,
                initialDay: model.daySelected,
                // height occupied by 1 minute time span.
                hourIndicatorSettings: calendar_view.HourIndicatorSettings(
                  color: scheduleLineColor,
                ),
                liveTimeIndicatorSettings: calendar_view.LiveTimeIndicatorSettings(
                  color: chevronColor,
                ),
                heightPerMinute: heightPerMinute,
                scrollOffset: heightPerMinute * 60 * 7.5,
                keepScrollOffset: true,
                dateStringBuilder: (date, {secondaryDate}) {
                  final locale = AppIntl.of(context)!.localeName;
                  return '${date.day} ${DateFormat.MMMM(locale).format(date)} ${date.year}';
                },
                timeStringBuilder: (date, {secondaryDate}) {
                  return DateFormat('H:mm').format(date);
                },
                eventTileBuilder:
                    (date, events, boundary, startDuration, endDuration) =>
                    _buildEventTile(events, context))
        ),
      ]);
  }

  Widget _buildCalendarViewWeekly(
      ScheduleViewModel model,
      BuildContext context,
      calendar_view.EventController eventController,
      Color backgroundColor,
      Color chevronColor,
      Color scheduleLineColor,
      List<Color> scheduleCardsPalette) {
    final double heightPerMinute =
        (MediaQuery.of(context).size.height / 1200).clamp(0.45, 1.0);

    return calendar_view.WeekView(
      key: weekViewKey,
      weekNumberBuilder: (date) => null,
      controller: eventController
        ..addAll(model.selectedWeekCalendarEvents(scheduleCardsPalette)),
      onPageChange: (date, page) => setState(() {
        model.handleViewChanged(date, eventController, []);
      }),
      backgroundColor: backgroundColor,
      weekTitleHeight:
          (MediaQuery.of(context).orientation == Orientation.portrait)
              ? 60
              : 35,
      safeAreaOption:
          const calendar_view.SafeAreaOption(top: false, bottom: false),
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
      startDay: calendar_view.WeekDays.sunday,
      weekDays: [
        if (model.displaySunday)
          calendar_view.WeekDays.sunday,
        calendar_view.WeekDays.monday,
        calendar_view.WeekDays.tuesday,
        calendar_view.WeekDays.wednesday,
        calendar_view.WeekDays.thursday,
        calendar_view.WeekDays.friday,
        if (model.displaySaturday)
          calendar_view.WeekDays.saturday
      ],
      initialDay: model.weekSelected,
      heightPerMinute: heightPerMinute,
      scrollOffset: heightPerMinute * 60 * 7.5,
      hourIndicatorSettings: calendar_view.HourIndicatorSettings(
        color: scheduleLineColor,
      ),
      liveTimeIndicatorSettings: calendar_view.LiveTimeIndicatorSettings(
        color: chevronColor,
      ),
      keepScrollOffset: true,
      timeLineStringBuilder: (date, {secondaryDate}) {
        return DateFormat('H:mm').format(date);
      },
      weekDayStringBuilder: (p0) {
        return weekTitles[p0];
      },
      headerStringBuilder: (date, {secondaryDate}) {
        final from = AppIntl.of(context)!.schedule_calendar_from;
        final to = AppIntl.of(context)!.schedule_calendar_to;
        final locale = AppIntl.of(context)!.localeName;
        return '$from ${date.day} ${DateFormat.MMMM(locale).format(date)} $to ${secondaryDate?.day ?? '00'} ${DateFormat.MMMM(locale).format(secondaryDate ?? date)}';
      },
      eventTileBuilder: (date, events, boundary, startDuration, endDuration) =>
          _buildEventTile(events, context),
      weekDayBuilder: (DateTime date) => _buildWeekDay(date, model)
    );
  }

  Widget _buildCalendarViewMonthly(
      ScheduleViewModel model,
      BuildContext context,
      calendar_view.EventController eventController,
      Color backgroundColor,
      Color chevronColor,
      Color scheduleLineColor,
      Color textColor,
      List<Color> scheduleCardsPalette) {
    return calendar_view.MonthView(
      key: monthViewKey,
      // to provide custom UI for month cells.
      cellAspectRatio: 0.8,
      borderColor: scheduleLineColor,
      controller: eventController
        ..addAll(model.selectedMonthCalendarEvents(scheduleCardsPalette)),
      safeAreaOption:
          const calendar_view.SafeAreaOption(top: false, bottom: false),
      useAvailableVerticalSpace: MediaQuery.of(context).size.height >= 500,
      onPageChange: (date, page) =>
          model.handleViewChanged(date, eventController, []),
      weekDayBuilder: (int value) => calendar_view.WeekDayTile(
          dayIndex: value,
          displayBorder: false,
          textStyle: TextStyle(color: textColor),
          backgroundColor: backgroundColor,
          weekDayStringBuilder: (p0) => weekTitles[p0]),
      headerStringBuilder: (date, {secondaryDate}) {
        final locale = AppIntl.of(context)!.localeName;
        return '${DateFormat.MMMM(locale).format(date).characters.first.toUpperCase()}${DateFormat.MMMM(locale).format(date).substring(1)} ${date.year}';
      },
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
      startDay: calendar_view.WeekDays.sunday,
      initialMonth: DateTime(DateTime.now().year, DateTime.now().month),
      cellBuilder: (date, events, _, __, ___) => calendar_view.FilledCell(
        hideDaysNotInMonth: false,
        titleColor: textColor,
        highlightColor: AppTheme.accent,
        shouldHighlight: date.getDayDifference(DateTime.now()) == 0,
        date: date,
        isInMonth: date.month == DateTime.now().month,
        events: events,
        backgroundColor: (date.month == DateTime.now().month)
            ? backgroundColor.withAlpha(128)
            : Colors.grey.withOpacity(0.1),
      ),
    );
  }

  Widget _buildEventTile(
    List<calendar_view.CalendarEventData<dynamic>> events,
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
      child: Wrap(children: <Widget>[
        Container(
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          decoration: BoxDecoration(
              color: date.withoutTime == DateTime.now().withoutTime
                  ? AppTheme.etsLightRed.withOpacity(indicatorColorOpacity)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(6.0)),
          child: Flex(
              direction:
                  (MediaQuery.of(context).orientation == Orientation.portrait)
                      ? Axis.vertical
                      : Axis.horizontal,
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(weekTitles[date.weekday - 1]),
                if (MediaQuery.of(context).orientation == Orientation.landscape)
                  const SizedBox(width: 4),
                Text(date.day.toString()),
              ]),
        ),
      ]),
    );
  }

  Widget _buildTitleForDate(DateTime date, ScheduleViewModel model) => Center(
          child: Text(
        DateFormat.MMMMEEEEd(model.locale.toString()).format(date),
        style: Theme.of(context).textTheme.headlineMedium,
      ));

  /// Build the square with the number of [events] for the [date]
  Widget? _buildEventsMarker(
      ScheduleViewModel model, DateTime date, List events, Color color) {
    if (events.isNotEmpty) {
      return Positioned(
        right: 1,
        bottom: 1,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: color
          ),
          width: 16.0,
          height: 16.0,
          child: Center(
            child: Text(
              '${events.length}',
              style: const TextStyle().copyWith(
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
  Widget _buildTableCalendar(ScheduleViewModel model, calendar_view.EventController eventController) {
    const Color selectedColor = AppTheme.etsLightRed;
    final Color todayColor = Theme.of(context).brightness == Brightness.light ? AppTheme.etsLightGrey : AppTheme.etsDarkGrey;
    final Color defaultColor = Theme.of(context).brightness == Brightness.light ? AppTheme.scheduleLineColorLight : AppTheme.scheduleLineColorDark;

    return TableCalendar(
      key: const Key("TableCalendar"),
      locale: model.locale?.toLanguageTag(),
      selectedDayPredicate: (day) {
        return isSameDay(model.daySelected, day);
      },
      weekendDays: const [],
      headerStyle: HeaderStyle(
          titleTextFormatter: (date, locale) => DateFormat.MMMMEEEEd(locale).format(model.daySelected),
          titleCentered: true, formatButtonVisible: false),
      eventLoader: model.coursesActivitiesFor,
      calendarFormat: CalendarFormat.week,
      focusedDay: model.daySelected,
      onPageChanged: (focusedDay) {
        // Used to compare
        model.listViewCalendarSelectedDate = focusedDay;
      },
      calendarBuilders: CalendarBuilders(
          defaultBuilder: (context, date, _) =>
              _buildSelectedDate(date, defaultColor, model, eventController),
          outsideBuilder: (context, date, _) =>
              _buildSelectedDate(date, defaultColor, model, eventController),
          todayBuilder: (context, date, _) =>
              _buildSelectedDate(date, todayColor, model, eventController),
          selectedBuilder: (context, date, _) => FadeTransition(
                opacity: Tween(begin: 0.0, end: 1.0)
                    .animate(_animationController),
                child: _buildSelectedDate(date, selectedColor, model, eventController),
              ),
          markerBuilder: (context, date, events) {
            final bool isSelected = isSameDay(date, model.daySelected);
            final bool isToday = isSameDay(date, DateTime.now());
            final Color color = isSelected ? selectedColor : isToday ? todayColor : defaultColor;
            return _buildEventsMarker(model, date, events, color);
          }),
      // Those are now required by the package table_calendar ^3.0.0. In the doc,
      // it is suggest to set them to values that won't affect user experience.
      // Outside the range, the date are set to disable so no event can be loaded.
      firstDay: DateTime.utc(2010, 12, 31),
      lastDay: DateTime.utc(2100, 12, 31),
    );
  }

  /// Build the visual for the selected [date]. The [color] parameter set the color for the tile.
  Widget _buildSelectedDate(DateTime date, Color color, ScheduleViewModel model, calendar_view.EventController eventController) => Container(
    margin: const EdgeInsets.all(4.0),
    decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color)
    ),
    child: InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () {
        if (dayViewKey.currentState != null) {
          _isDayViewAnimating = true;
        }

        setState(() =>
            model.handleViewChanged(date, eventController, [])
        );

        dayViewKey.currentState?.animateToDate(model.daySelected).then((value) => _isDayViewAnimating = false);
      },
      child: Container(
        padding: const EdgeInsets.only(top: 5.0, left: 6.0),
        width: 100,
        height: 100,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${date.day}',
              style: const TextStyle().copyWith(
                  fontSize: 16.0,
                  height: 1.2,
              ),
            ),
            if (date.month != DateTime.now().month || date.year != DateTime.now().year)
              Text(
                DateFormat.MMM(model.locale.toString()).format(date),
                style: const TextStyle(fontSize: 10.0)
              ),
          ],
        ),
      ),
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
      icon: const Icon(Icons.ios_share),
      onPressed: () {
        final translations = AppIntl.of(context)!;
        showDialog(
          context: context,
          builder: (_) =>
              CalendarSelectionWidget(translations: translations),
        );
      },
    ),
    if ((model.settings[PreferencesFlag.scheduleShowTodayBtn] as bool) ==
        true)
      IconButton(
          icon: const Icon(Icons.today_outlined),
          onPressed: () => setState(() {
            model.selectToday();
            _analyticsService.logEvent(tag, "Select today clicked");
            if (model.calendarFormat == CalendarTimeFormat.day && !(model.settings[PreferencesFlag.scheduleListView] as bool)) {
              dayViewKey.currentState?.animateToDate(DateTime.now());
            } else if (model.calendarFormat == CalendarTimeFormat.week) {
              weekViewKey.currentState?.animateToWeek(DateTime.now());
            } else if (model.calendarFormat == CalendarTimeFormat.month) {
              monthViewKey.currentState?.animateToMonth(DateTime(DateTime.now().year, DateTime.now().month));
            }
          })),
    IconButton(icon: const Icon(Icons.settings_outlined), onPressed: () async {
      await showModalBottomSheet(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(10),
        ),
      ),
      context: context,
      isScrollControlled: true,
      builder: (context) => const ScheduleSettings());
      model.loadSettings();
    })
  ];
}
