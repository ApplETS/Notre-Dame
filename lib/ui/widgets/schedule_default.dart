// Flutter imports:
import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:calendar_view/calendar_view.dart' as calendar_view;
import 'package:github/github.dart';

// Project imports:
import 'package:notredame/ui/utils/app_theme.dart';
import 'package:notredame/ui/widgets/schedule_calendar_tile.dart';

class ScheduleDefault extends StatefulWidget {
  // final ScheduleDefaultViewModel model;

  const ScheduleDefault(
      {Key key,})
      : super(key: key);

  @override
  _ScheduleDefaultState createState() => _ScheduleDefaultState();
}

class _ScheduleDefaultState extends State<ScheduleDefault> {
  static final List<String> weekTitles = ["L", "M", "M", "J", "V", "S", "D"];
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: calendar_view.WeekView(
        backgroundColor: AppTheme.darkThemeBackground,
        weekDays: const [
          calendar_view.WeekDays.monday,
          calendar_view.WeekDays.tuesday,
          calendar_view.WeekDays.wednesday,
          calendar_view.WeekDays.thursday,
          calendar_view.WeekDays.friday,
          calendar_view.WeekDays.saturday
        ],
        scrollOffset: 305,
        headerStyle: const calendar_view.HeaderStyle(
          headerTextStyle: TextStyle(
            color: Colors.transparent,
            fontSize: 0,
          ),
          decoration: BoxDecoration(
            color: Colors.transparent,
          ),
          leftIconVisible: false,
          rightIconVisible: false
        ),
        eventTileBuilder: (date, events, boundary, startDuration,
                endDuration) =>
            _buildEventTile(_events, context),
        weekDayBuilder: (DateTime date) => _buildWeekDay(date),
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

  Widget _buildWeekDay(DateTime date) {
    return Center(
      child: Container(
        width: 40,
        height: 80,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(weekTitles[date.weekday - 1]),
          ],
        ),
      ),
    );
  }

  final List<CalendarEventData<Event>> _events = [
    CalendarEventData(
      date: DateTime.now(),
      title: "Project meeting",
      description: "Today is project meeting.",
      startTime: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 18, 30),
      endTime: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 22),
    ),
    CalendarEventData(
      date: DateTime.now().add(const Duration(days: 1)),
      startTime: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 18),
      endTime: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 19),
      title: "Wedding anniversary",
      description: "Attend uncle's wedding anniversary.",
    ),
    CalendarEventData(
      date: DateTime.now(),
      startTime: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 14),
      endTime: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 17),
      title: "Football Tournament",
      description: "Go to football tournament.",
    ),
  ];
}
