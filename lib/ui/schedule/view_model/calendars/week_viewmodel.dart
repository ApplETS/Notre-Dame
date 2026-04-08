// Package imports:
import 'package:calendar_view/calendar_view.dart';
import 'package:fluttertoast/fluttertoast.dart';

// Project imports:
import 'package:notredame/data/models/event_data.dart';
import 'package:notredame/ui/schedule/view_model/calendars/calendar_viewmodel.dart';
import 'package:notredame/utils/date_extensions.dart';

class WeekViewModel extends CalendarViewModel {
  // Sunday of current week
  DateTime weekSelected = DateTime.now().startOfWeek(start: WeekDays.sunday);

  // Display weekend days only if they contain events
  bool displaySunday = false;
  bool displaySaturday = false;

  /// If today is saturday, I have no course today and the shedule just loaded, then this value will be true
  bool displayNextWeek = false;

  bool _firstLoad = true;

  WeekViewModel({required super.intl});

  @override
  handleDateSelectedChanged(DateTime newDate) {
    weekSelected = newDate.startOfWeek(start: WeekDays.sunday);
    if (!isBusy && _firstLoad) {
      _firstLoad = false;
      if (DateTime.now().weekday == DateTime.saturday &&
          DateTime.now().startOfWeek(start: WeekDays.sunday) == weekSelected &&
          calendarEventsFromDate(DateTime.now()).isEmpty) {
        handleDateSelectedChanged(weekSelected.withoutTimeUtc.add(Duration(days: 7)).withoutTime);
        displayNextWeek = true;
      }
    }

    displaySunday = calendarEventsFromDate(weekSelected).isNotEmpty;
    displaySaturday = calendarEventsFromDate(
      weekSelected.withoutTimeUtc.add(const Duration(days: 6)).withoutTime,
    ).isNotEmpty;

    eventController.removeWhere((event) => true);
    eventController.addAll(selectedWeekCalendarEvents());
  }

  @override
  bool returnToCurrentDate() {
    DateTime dateToReturnTo = DateTime.now().startOfWeek(start: WeekDays.sunday);
    if (DateTime.now().weekday == DateTime.saturday &&
        calendarEventsFromDate(dateToReturnTo.withoutTimeUtc.add(Duration(days: 6)).withoutTime).isEmpty) {
      dateToReturnTo = dateToReturnTo.withoutTimeUtc.add(Duration(days: 7)).withoutTime;
    }

    final bool isThisWeekSelected = dateToReturnTo == weekSelected;

    isThisWeekSelected
        ? Fluttertoast.showToast(msg: super.intl.schedule_already_today_toast)
        : handleDateSelectedChanged(dateToReturnTo);

    return !isThisWeekSelected;
  }

  List<EventData> selectedWeekCalendarEvents() {
    final List<EventData> events = [];

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
