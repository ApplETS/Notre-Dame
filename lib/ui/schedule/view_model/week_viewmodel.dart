import 'package:calendar_view/calendar_view.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:notredame/utils/utils.dart';
import 'calendar_viewmodel.dart';

class WeekViewModel extends CalendarViewModel {
  // Sunday of current week
  DateTime weekSelected = Utils.getFirstDayOfCurrentWeek(DateTime.now());
  // Display weekend days if there are events in them
  bool displaySunday = false;
  bool displaySaturday = false;

  final EventController eventController = EventController();

  WeekViewModel({required super.intl});

  @override
  handleDateSelectedChanged(DateTime newDate) {
    if (newDate.weekday == DateTime.saturday && calendarEventsFromDate(newDate).isEmpty) {
      // Add extra hour to fix a bug related to daylight saving time changes
      weekSelected = weekSelected.add(const Duration(days: 7, hours: 1)).withoutTime;
    } else {
      weekSelected = Utils.getFirstDayOfCurrentWeek(newDate);
    }
    displaySunday = calendarEventsFromDate(weekSelected).isNotEmpty;
    displaySaturday = calendarEventsFromDate(weekSelected.add(const Duration(days: 6, hours: 1))).isNotEmpty;

    eventController.removeWhere((event) => true);
    eventController.addAll(selectedWeekCalendarEvents());
  }

  @override
  bool returnToCurrentDate() {
    final bool isThisWeekSelected = weekSelected == Utils.getFirstDayOfCurrentWeek(DateTime.now());

    isThisWeekSelected
        ? Fluttertoast.showToast(msg: super.appIntl.schedule_already_today_toast)
        : weekSelected = Utils.getFirstDayOfCurrentWeek(DateTime.now());

    return !isThisWeekSelected;
  }

  List<CalendarEventData> selectedWeekCalendarEvents() {
    final List<CalendarEventData> events = [];

    final firstDayOfWeek = Utils.getFirstDayOfCurrentWeek(weekSelected);
    // We want to put events of previous week and next week in memory to make transitions smoother
    for (int i = -7; i < 14; i++) {
      final date = firstDayOfWeek.add(Duration(days: i));
      final eventsForDay = calendarEventsFromDate(date);
      if (eventsForDay.isNotEmpty) {
        events.addAll(eventsForDay);
      }
    }
    return events;
  }
}