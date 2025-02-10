import 'package:calendar_view/calendar_view.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:notredame/ui/schedule/view_model/calendar_viewmodel.dart';
import 'package:notredame/utils/utils.dart';

class DayViewModel extends CalendarViewModel {
  /// Day currently focused on
  DateTime daySelected = DateTime.now().withoutTime;
  final EventController eventController = EventController();

  DayViewModel({required super.intl});

  @override
  bool returnToCurrentDate() {
    final bool isTodaySelected = DateTime.now().withoutTime == daySelected.withoutTime;

    if (isTodaySelected) {
      Fluttertoast.showToast(msg: appIntl.schedule_already_today_toast);
    }

    daySelected = DateTime.now().withoutTime;
    return !isTodaySelected;
  }

  @override
  handleDateSelectedChanged(DateTime newDate) {
    daySelected = newDate;

    // TODO don't remove everything
    eventController.removeWhere((event) => true);

    // TODO don't store the events for 3 entire weeeks
    List<CalendarEventData> eventsToAdd = selectedWeekCalendarEvents();

    eventController.addAll(eventsToAdd);
  }

  List<CalendarEventData> selectedWeekCalendarEvents() {
    final List<CalendarEventData> events = [];

    final firstDayOfWeek = Utils.getFirstDayOfCurrentWeek(daySelected);
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

  // TODO method to get number of ovents for each day in last week, current week and next week
}
