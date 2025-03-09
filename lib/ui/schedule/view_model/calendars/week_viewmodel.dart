// Package imports:
import 'package:calendar_view/calendar_view.dart';
import 'package:fluttertoast/fluttertoast.dart';

// Project imports:
import 'package:notredame/ui/schedule/view_model/calendars/calendar_viewmodel.dart';
import 'package:notredame/utils/utils.dart';

class WeekViewModel extends CalendarViewModel {
  // Sunday of current week
  DateTime weekSelected = Utils.getFirstdayOfWeek(DateTime.now());

  // Display weekend days only if they contain events
  bool displaySunday = false;
  bool displaySaturday = false;

  bool _firstLoad = true;

  final EventController eventController = EventController();

  WeekViewModel({required super.intl});

  @override
  handleDateSelectedChanged(DateTime newDate) {
    weekSelected = Utils.getFirstdayOfWeek(newDate);

    if (!isBusy && _firstLoad) {
      _firstLoad = false;
      if (DateTime.now().weekday == DateTime.saturday &&
          Utils.getFirstdayOfWeek(DateTime.now()) == weekSelected &&
          calendarEventsFromDate(DateTime.now()).isEmpty) {
        handleDateSelectedChanged(
            weekSelected.add(Duration(days: 7, hours: 1)));
      }
    }

    displaySunday = calendarEventsFromDate(weekSelected).isNotEmpty;
    displaySaturday = calendarEventsFromDate(
            weekSelected.add(const Duration(days: 6, hours: 1)))
        .isNotEmpty;

    eventController.removeWhere((event) => true);
    eventController.addAll(selectedWeekCalendarEvents());
  }

  @override
  bool returnToCurrentDate() {
    DateTime dateToReturnTo = Utils.getFirstdayOfWeek(DateTime.now());
    if (DateTime.now().weekday == DateTime.saturday &&
        calendarEventsFromDate(dateToReturnTo.add(Duration(days: 6, hours: 1)))
            .isEmpty) {
      dateToReturnTo = dateToReturnTo.add(Duration(days: 7, hours: 1)).withoutTime;
    }

    final bool isThisWeekSelected = dateToReturnTo == weekSelected;

    isThisWeekSelected
        ? Fluttertoast.showToast(
            msg: super.appIntl.schedule_already_today_toast)
        : handleDateSelectedChanged(dateToReturnTo);

    return !isThisWeekSelected;
  }

  List<CalendarEventData> selectedWeekCalendarEvents() {
    final List<CalendarEventData> events = [];

    // We want to put events of previous week and next week in memory to make transitions smoother
    for (int i = -7; i < 14; i++) {
      final date = weekSelected.add(Duration(days: i));
      final eventsForDay = calendarEventsFromDate(date);
      if (eventsForDay.isNotEmpty) {
        events.addAll(eventsForDay);
      }
    }
    return events;
  }
}
