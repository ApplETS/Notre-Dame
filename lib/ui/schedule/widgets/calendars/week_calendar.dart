// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:calendar_view/calendar_view.dart';
import 'package:intl/intl.dart';
import 'package:stacked/stacked.dart';

// Project imports:
import 'package:notredame/l10n/app_localizations.dart';
import 'package:notredame/ui/core/themes/app_theme.dart';
import 'package:notredame/ui/schedule/schedule_controller.dart';
import 'package:notredame/ui/schedule/view_model/calendars/week_viewmodel.dart';
import 'package:notredame/ui/schedule/widgets/schedule_calendar_tile.dart';

bool isAnimating = false;

class WeekCalendar extends StatefulWidget {
  static final List<String> weekTitles = ["L", "M", "M", "J", "V", "S", "D"];
  final ScheduleController controller;
  const WeekCalendar({super.key, required this.controller});

  @override
  State<WeekCalendar> createState() => _WeekCalendarState();
}

class _WeekCalendarState extends State<WeekCalendar> {
  final GlobalKey<WeekViewState> weekViewKey = GlobalKey<WeekViewState>();

  @override
  Widget build(BuildContext context) {
    final double heightPerMinute = (MediaQuery.of(context).size.height / 1200).clamp(0.45, 1.0);

    return ViewModelBuilder.reactive(
      viewModelBuilder: () => WeekViewModel(intl: AppIntl.of(context)!),
      builder: (context, model, child) => _buildWeekView(model, context, heightPerMinute),
    );
  }

  WeekView<Object?> _buildWeekView(WeekViewModel model, BuildContext context, double heightPerMinute) {
    model.handleDateSelectedChanged(model.weekSelected);

    if (!isAnimating && model.displayNextWeek) {
      weekViewKey.currentState?.animateToWeek(model.weekSelected);
      model.displayNextWeek = false;
    }

    widget.controller.returnToToday = () {
      model.returnToCurrentDate();
      isAnimating = true;
      weekViewKey.currentState?.animateToWeek(model.weekSelected).then((_) => isAnimating = false);
    };

    return WeekView(
      key: weekViewKey,
      weekNumberBuilder: (date) => Container(color: context.theme.appColors.appBar),
      controller: model.eventController..addAll(model.selectedWeekCalendarEvents()),
      onPageChange: (date, page) => setState(() {
        model.weekSelected = date;
      }),
      backgroundColor: context.theme.scaffoldBackgroundColor,
      weekTitleHeight: (MediaQuery.of(context).orientation == Orientation.portrait) ? 60 : 35,
      safeAreaOption: const SafeAreaOption(top: false, bottom: false),
      headerStyle: HeaderStyle(
        decoration: BoxDecoration(color: context.theme.appColors.appBar),
        leftIconConfig: IconDataConfig(color: context.theme.textTheme.bodyMedium!.color!, size: 30),
        rightIconConfig: IconDataConfig(color: context.theme.textTheme.bodyMedium!.color!, size: 30),
      ),
      startDay: WeekDays.sunday,
      weekDays: [
        if (model.displaySunday) WeekDays.sunday,
        WeekDays.monday,
        WeekDays.tuesday,
        WeekDays.wednesday,
        WeekDays.thursday,
        WeekDays.friday,
        if (model.displaySaturday) WeekDays.saturday,
      ],
      initialDay: model.weekSelected,
      heightPerMinute: heightPerMinute,
      scrollOffset: heightPerMinute * 60 * 7.5,
      hourIndicatorSettings: HourIndicatorSettings(color: context.theme.appColors.scheduleLine),
      liveTimeIndicatorSettings: LiveTimeIndicatorSettings(color: context.theme.textTheme.bodyMedium!.color!),
      keepScrollOffset: true,
      timeLineStringBuilder: (date, {secondaryDate}) {
        return DateFormat('H:mm').format(date);
      },
      headerStringBuilder: (date, {secondaryDate}) {
        final from = AppIntl.of(context)!.schedule_calendar_from;
        final to = AppIntl.of(context)!.schedule_calendar_to;
        final locale = AppIntl.of(context)!.localeName;
        return '$from ${date.day} ${DateFormat.MMMM(locale).format(date)} $to ${secondaryDate?.day} ${DateFormat.MMMM(locale).format(secondaryDate ?? date)}';
      },
      eventTileBuilder: (date, events, boundary, startDuration, endDuration) => _buildEventTile(events, context),
      weekDayBuilder: (DateTime date) =>
          Container(color: context.theme.appColors.appBar, child: _buildWeekDay(date, model, context)),
    );
  }

  Widget _buildWeekDay(DateTime date, WeekViewModel model, BuildContext context) {
    return Center(
      child: Wrap(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            decoration: BoxDecoration(
              color: date.withoutTime == DateTime.now().withoutTime
                  ? context.theme.appColors.dayIndicatorWeekView
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(6.0),
            ),
            child: Flex(
              direction: (MediaQuery.of(context).orientation == Orientation.portrait) ? Axis.vertical : Axis.horizontal,
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(WeekCalendar.weekTitles[date.weekday - 1]),
                if (MediaQuery.of(context).orientation == Orientation.landscape) const SizedBox(width: 4),
                Text(date.day.toString()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventTile(List<CalendarEventData<dynamic>> events, BuildContext context) {
    if (events.isNotEmpty) {
      return ScheduleCalendarTile(
        title: events[0].title,
        description: events[0].description,
        start: events[0].startTime,
        end: events[0].endTime,
        titleStyle: TextStyle(fontSize: 14, color: events[0].color.accent),
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
}
