// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:calendar_view/calendar_view.dart' as calendar_view;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:stacked/stacked.dart';
import 'package:table_calendar/table_calendar.dart';

// Project imports:
import 'package:notredame/data/services/signets-api/models/course_activity.dart';
import 'package:notredame/ui/core/themes/app_palette.dart';
import 'package:notredame/ui/core/themes/app_theme.dart';
import 'package:notredame/ui/dashboard/widgets/course_activity_tile.dart';
import 'package:notredame/ui/schedule/schedule_controller.dart';
import 'package:notredame/ui/schedule/view_model/calendars/day_viewmodel.dart';
import 'package:notredame/ui/schedule/widgets/schedule_calendar_tile.dart';

class DayCalendar extends StatefulWidget {
  final bool listView;
  final ScheduleController controller;

  const DayCalendar({super.key, required this.listView, required this.controller});

  @override
  State<DayCalendar> createState() => _DayCalendarState();
}

class _DayCalendarState extends State<DayCalendar> with TickerProviderStateMixin {
  late AnimationController _animationController;
  final GlobalKey<calendar_view.DayViewState> dayViewKey = GlobalKey<calendar_view.DayViewState>();

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
  Widget build(BuildContext context) {
    DayViewModel model = DayViewModel(intl: AppIntl.of(context)!);

    return ViewModelBuilder.reactive(
      viewModelBuilder: () => model,
      builder: (context, model, child) => Column(children: [
        _dayViewHeader(model),
        _buildEvents(model),
      ]),
    );
  }

  Widget _buildEvents(DayViewModel model) {
    widget.controller.returnToToday = () {
      setState(() {
        model.returnToCurrentDate();
        if (!widget.listView) {
          dayViewKey.currentState?.jumpToDate(DateTime.now());
        }
      });
    };

    return widget.listView ? _buildListView(model) : _buildCalendar(model);
  }

  Widget _buildCalendar(DayViewModel model) {
    final double heightPerMinute = (MediaQuery.of(context).size.height / 1200).clamp(0.45, 1.0);

    return Expanded(
        child: calendar_view.DayView(
            showVerticalLine: false,
            dayTitleBuilder: calendar_view.DayHeader.hidden,
            key: dayViewKey,
            controller: model.eventController..addAll(model.selectedDayCalendarEvents()),
            onPageChange: (date, _) => ({
                  setState(() {
                    model.handleDateSelectedChanged(date);
                  })
                }),
            backgroundColor: context.theme.scaffoldBackgroundColor,
            initialDay: model.daySelected,
            hourIndicatorSettings: calendar_view.HourIndicatorSettings(
              color: context.theme.appColors.scheduleLine,
            ),
            liveTimeIndicatorSettings: calendar_view.LiveTimeIndicatorSettings(
              color: context.theme.textTheme.bodyMedium!.color!,
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
            eventTileBuilder: (date, events, boundary, startDuration, endDuration) => _buildEventTile(events)));
  }

  Widget _buildListView(DayViewModel model) {
    final int pageBufferSize = 10;
    PageController pageController = PageController(initialPage: pageBufferSize);

    pageController.addListener(() {
      final page = pageController.page;
      int daysToAdd = page!.floor() - pageBufferSize;

      // Checks if the page has completely finished the animation.
      // Otherwise, the experience will be choppy
      if (page == page.floorToDouble() && daysToAdd != 0) {
        setState(() {
          model.handleDateSelectedChanged(model.daySelected.add(Duration(days: daysToAdd)));
        });
        // Same principle as a recycler view; displayed elements of the list are reused to reduce ressource usage
        // For each page change, we move the elements in the page we were previously on and go back to that page
        pageController.jumpToPage(pageBufferSize);
        HapticFeedback.lightImpact();
      }
    });
    return Expanded(
      child: PageView(
        physics: const BouncingScrollPhysics(),
        controller: pageController,
        children: [
          // When swiping fast, this prevents from having to wait for animation completion to go to the next page
          for (int i = pageBufferSize * -1; i <= pageBufferSize + 1; i++)
            _buildDayList(model.daySelected.add(Duration(days: i)), model)
        ],
      ),
    );
  }

  Widget _buildDayList(DateTime date, DayViewModel model) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        const SizedBox(height: 8.0),
        if (model.coursesActivitiesFor(date).isEmpty && !model.isBusy)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 64.0),
            child: Center(child: Text(AppIntl.of(context)!.schedule_no_event)),
          )
        else
          _buildEventList(model.coursesActivitiesFor(date)),
        const SizedBox(height: 16.0),
      ],
    );
  }

  Widget _buildEventTile(List<calendar_view.CalendarEventData<dynamic>> events) {
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

  /// Build the list of the events for the selected day.
  Widget _buildEventList(List<dynamic> events) {
    return ListView.separated(
        physics: const ScrollPhysics(),
        shrinkWrap: true,
        itemBuilder: (_, index) => CourseActivityTile(events[index] as CourseActivity),
        separatorBuilder: (_, index) =>
            (index < events.length) ? const Divider(thickness: 1, indent: 30, endIndent: 30) : const SizedBox(),
        itemCount: events.length);
  }

  Widget _dayViewHeader(DayViewModel model) {
    const Color selectedColor = AppPalette.etsLightRed;
    final Color todayColor = context.theme.appColors.dayIndicatorWeekView;
    final Color defaultColor = context.theme.appColors.scheduleLine;

    return Container(
      padding: EdgeInsets.only(bottom: 4),
      color: context.theme.appColors.appBar,
      child: TableCalendar(
        key: const Key("TableCalendar"),
        locale: AppIntl.of(context)!.localeName,
        selectedDayPredicate: (day) {
          return isSameDay(model.daySelected, day);
        },
        headerStyle: HeaderStyle(
            titleTextFormatter: (_, locale) => DateFormat.MMMMEEEEd(locale).format(model.daySelected),
            titleCentered: true,
            formatButtonVisible: false),
        eventLoader: model.coursesActivitiesFor,
        calendarFormat: CalendarFormat.week,
        focusedDay: model.daySelected,
        calendarBuilders: CalendarBuilders(
            defaultBuilder: (_, date, __) => _buildHeaderDay(date, defaultColor, model, dayViewKey),
            outsideBuilder: (_, date, __) => _buildHeaderDay(date, defaultColor, model, dayViewKey),
            todayBuilder: (_, date, __) => _buildHeaderDay(date, todayColor, model, dayViewKey),
            selectedBuilder: (_, date, __) => FadeTransition(
                  opacity: Tween(begin: 0.0, end: 1.0).animate(_animationController),
                  child: _buildHeaderDay(date, selectedColor, model, dayViewKey),
                ),
            markerBuilder: (_, date, events) {
              final bool isSelected = isSameDay(date, model.daySelected);
              final bool isToday = isSameDay(date, DateTime.now());
              Color color = selectedColor;

              if (!isSelected) {
                if (isToday) {
                  color = todayColor;
                } else {
                  color = defaultColor;
                }
              }

              return _buildEventsMarker(events, color);
            }),
        // Those are now required by the package table_calendar ^3.0.0. In the doc,
        // it is suggest to set them to values that won't affect user experience.
        // Outside the range, the date are set to disable so no event can be loaded.
        firstDay: DateTime.utc(2010, 12, 31),
        lastDay: DateTime.utc(2100, 12, 31),
      ),
    );
  }

  Widget _buildHeaderDay(
          DateTime date, Color color, DayViewModel model, GlobalKey<calendar_view.DayViewState> dayViewKey) =>
      Container(
        margin: const EdgeInsets.all(4.0),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), border: Border.all(color: color)),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () {
              DateTime startingDate = model.daySelected;
              setState(() {
                model.handleDateSelectedChanged(date);
              });

              if (model.daySelected.difference(startingDate).inDays.abs() == 1) {
                dayViewKey.currentState?.animateToDate(model.daySelected);
              } else {
                dayViewKey.currentState?.jumpToDate(model.daySelected);
              }
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
                    Text(DateFormat.MMM(AppIntl.of(context)!.localeName).format(date),
                        style: const TextStyle(fontSize: 10.0)),
                ],
              ),
            ),
          ),
        ),
      );

  Widget? _buildEventsMarker(List events, Color color) {
    if (events.isNotEmpty) {
      return Positioned(
        right: 1,
        bottom: 1,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(5), color: color),
          width: 16.0,
          height: 16.0,
          child: Text(
            '${events.length}',
            textAlign: TextAlign.center,
            style: const TextStyle().copyWith(
              fontSize: 12.0,
            ),
          ),
        ),
      );
    }
    return null;
  }
}
