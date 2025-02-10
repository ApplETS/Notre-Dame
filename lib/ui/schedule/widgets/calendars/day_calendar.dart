import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:notredame/ui/core/themes/app_theme.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:notredame/ui/schedule/view_model/day_viewmodel.dart';
import 'package:notredame/ui/schedule/widgets/day_view_header.dart';
import 'package:notredame/ui/schedule/widgets/schedule_calendar_tile.dart';
import 'package:stacked/stacked.dart';

class DayCalendar extends StatefulWidget {
  final GlobalKey<DayViewState> dayViewKey;
  static final List<String> weekTitles = ["L", "M", "M", "J", "V", "S", "D"];

  const DayCalendar({
    super.key,
    required this.dayViewKey
  });

  @override
  State<DayCalendar> createState() => _DayCalendarState();
}

class _DayCalendarState extends State<DayCalendar> {
  @override
  Widget build(BuildContext context) {
    final double heightPerMinute =
    (MediaQuery.of(context).size.height / 1200).clamp(0.45, 1.0);
    return ViewModelBuilder.reactive(
      viewModelBuilder: () => DayViewModel(intl: AppIntl.of(context)!),
      builder: (context, model, child) => Column(children: [
        DayViewHeader(m: model, dayViewKey: widget.dayViewKey),
        Expanded(
            child: DayView(
                showVerticalLine: false,
                dayTitleBuilder: DayHeader.hidden,
                key: widget.dayViewKey,
                controller: model.eventController,
                  // ..addAll(model.selectedDayCalendarEvents()),
                onPageChange: (date, page) => ({
                  setState(() {
                    model.handleDateSelectedChanged(date);
                  })
                }),
                backgroundColor: context.theme.scaffoldBackgroundColor,
                initialDay: model.daySelected,
                // height occupied by 1 minute time span.
                hourIndicatorSettings: HourIndicatorSettings(
                  color: context.theme.appColors.scheduleLine,
                ),
                liveTimeIndicatorSettings:
                LiveTimeIndicatorSettings(
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
                eventTileBuilder:
                    (date, events, boundary, startDuration, endDuration) =>
                    _buildEventTile(events, context))),
      ]),
    );
  }
}

Widget _buildEventTile(
    List<CalendarEventData<dynamic>> events,
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