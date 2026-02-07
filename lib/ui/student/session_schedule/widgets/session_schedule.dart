// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:calendar_view/calendar_view.dart';
import 'package:intl/intl.dart';

// Project imports:
import 'package:notredame/data/models/calendar_event_tile.dart';
import 'package:notredame/l10n/app_localizations.dart';
import 'package:notredame/ui/core/themes/app_theme.dart';
import 'package:notredame/ui/schedule/widgets/schedule_calendar_tile.dart';

class SessionSchedule extends StatefulWidget {
  final List<EventData> calendarEvents;
  final bool loaded;
  final bool displaySaturday;
  final bool displaySunday;

  const SessionSchedule({
    super.key,
    required this.calendarEvents,
    required this.loaded,
    required this.displaySaturday,
    required this.displaySunday,
  });

  @override
  State<SessionSchedule> createState() => _SessionScheduleState();
}

class _SessionScheduleState extends State<SessionSchedule> {
  static final List<String> weekTitles = ["L", "M", "M", "J", "V", "S", "D"];
  final GlobalKey<WeekViewState> weekViewKey = GlobalKey<WeekViewState>();

  final eventController = EventController();

  @override
  Widget build(BuildContext context) {
    if (!widget.loaded) {
      return Container();
    }
    // Check if there are no events
    if (widget.calendarEvents.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(child: Text(AppIntl.of(context)!.no_schedule_available)),
      );
    }
    final double heightPerMinute = (MediaQuery.of(context).size.height / 1200).clamp(0.45, 1.0);
    // If there are events, display the calendar
    return Scaffold(
      body: WeekView(
        maxDay: DateTime.now(),
        minDay: DateTime.now(),
        key: weekViewKey,
        safeAreaOption: const SafeAreaOption(bottom: false),
        controller: eventController..addAll(widget.calendarEvents),
        backgroundColor: context.theme.scaffoldBackgroundColor,
        startDay: WeekDays.sunday,
        weekDays: [
          if (widget.displaySunday) WeekDays.sunday,
          WeekDays.monday,
          WeekDays.tuesday,
          WeekDays.wednesday,
          WeekDays.thursday,
          WeekDays.friday,
          if (widget.displaySaturday) WeekDays.saturday,
        ],
        hourIndicatorSettings: HourIndicatorSettings(color: context.theme.appColors.scheduleLine),
        scrollOffset: heightPerMinute * 60 * 7.5,
        timeLineStringBuilder: (date, {secondaryDate}) {
          return DateFormat('H:mm').format(date);
        },
        liveTimeIndicatorSettings: LiveTimeIndicatorSettings.none(),
        weekNumberBuilder: (date) => Container(color: context.theme.appColors.appBar),
        headerStyle: HeaderStyle(
          headerTextStyle: const TextStyle(fontSize: 0),
          leftIconConfig: null,
          rightIconConfig: null,
        ),
        heightPerMinute: heightPerMinute,
        eventTileBuilder: (date, events, boundary, startDuration, endDuration) => _buildEventTile(events as List<CalendarEventData>, context),
        weekDayBuilder: (DateTime date) => Container(color: context.theme.appColors.appBar, child: _buildWeekDay(date)),
      ),
    );
  }

  Widget _buildEventTile(List<CalendarEventData> events, BuildContext context) {
    if (events.isNotEmpty) {
      return ScheduleCalendarTile(
        padding: const EdgeInsets.all(6.0),
        buildContext: context,
        event: events[0] as EventData,
      );
    } else {
      return Container();
    }
  }

  Widget _buildWeekDay(DateTime date) {
    return Center(
      child: SizedBox(
        width: 40,
        height: 80,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Text(weekTitles[date.weekday - 1])],
        ),
      ),
    );
  }
}
