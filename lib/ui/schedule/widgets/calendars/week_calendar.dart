import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:notredame/ui/core/themes/app_theme.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:notredame/ui/schedule/view_model/calendars/week_viewmodel.dart';
import 'package:notredame/ui/schedule/widgets/schedule_calendar_tile.dart';
import 'package:stacked/stacked.dart';

class WeekCalendar extends StatelessWidget {
  final GlobalKey weekViewKey;
  static final List<String> weekTitles = ["L", "M", "M", "J", "V", "S", "D"];

  const WeekCalendar({
    super.key,
    required this.weekViewKey
  });

  @override
  Widget build(BuildContext context) {
    final double heightPerMinute =
    (MediaQuery.of(context).size.height / 1200).clamp(0.45, 1.0);

    return ViewModelBuilder.reactive(
      viewModelBuilder: () => WeekViewModel(intl: AppIntl.of(context)!),
      builder:(context, model, child) => WeekView(
          key: weekViewKey,
          weekNumberBuilder: (date) => null,
          // TODO check if add all is required
          controller: model.eventController..addAll(model.selectedWeekCalendarEvents()),
          onPageChange: (date, page) => model.handleDateSelectedChanged(date),
          backgroundColor: context.theme.scaffoldBackgroundColor,
          weekTitleHeight:
          (MediaQuery.of(context).orientation == Orientation.portrait)
              ? 60
              : 35,
          safeAreaOption:
          const SafeAreaOption(top: false, bottom: false),
          headerStyle: HeaderStyle(
              decoration: BoxDecoration(
                color: context.theme.scaffoldBackgroundColor,
              ),
              leftIcon: Icon(
                Icons.chevron_left,
                size: 30,
                color: context.theme.textTheme.bodyMedium!.color,
              ),
              rightIcon: Icon(
                Icons.chevron_right,
                size: 30,
                color: context.theme.textTheme.bodyMedium!.color,
              )),
          startDay: WeekDays.sunday,
          weekDays: [
            if (model.displaySunday) WeekDays.sunday,
            WeekDays.monday,
            WeekDays.tuesday,
            WeekDays.wednesday,
            WeekDays.thursday,
            WeekDays.friday,
            if (model.displaySaturday) WeekDays.saturday
          ],
          initialDay: model.weekSelected,
          heightPerMinute: heightPerMinute,
          scrollOffset: heightPerMinute * 60 * 7.5,
          hourIndicatorSettings: HourIndicatorSettings(
            color: context.theme.appColors.scheduleLine,
          ),
          liveTimeIndicatorSettings: LiveTimeIndicatorSettings(
            color: context.theme.textTheme.bodyMedium!.color!,
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
          eventTileBuilder:
              (date, events, boundary, startDuration, endDuration) =>
              _buildEventTile(events, context),
          weekDayBuilder: (DateTime date) => _buildWeekDay(date, model, context)),
    );
  }

  Widget _buildWeekDay(DateTime date, WeekViewModel model, BuildContext context) {
    return Center(
      child: Wrap(children: <Widget>[
        Container(
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          decoration: BoxDecoration(
              color: date.withoutTime == DateTime.now().withoutTime
                  ? context.theme.appColors.dayIndicatorWeekView
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

  Widget _buildEventTile(
      List<CalendarEventData<dynamic>> events,
      BuildContext context) {
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
}