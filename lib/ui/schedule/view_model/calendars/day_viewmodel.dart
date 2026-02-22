// Dart imports:
import 'dart:math';

// Package imports:
import 'package:calendar_view/calendar_view.dart';
import 'package:fluttertoast/fluttertoast.dart';

// Project imports:
import 'package:notredame/data/models/event_data.dart';
import 'package:notredame/ui/schedule/view_model/calendars/calendar_viewmodel.dart';

class DayViewModel extends CalendarViewModel {
  DateTime daySelected = DateTime.now().withoutTime;

  DayViewModel({required super.intl});

  @override
  bool returnToCurrentDate() {
    final bool isTodaySelected = DateTime.now().withoutTime == daySelected;

    if (isTodaySelected) {
      Fluttertoast.showToast(msg: intl.schedule_already_today_toast);
    }

    daySelected = DateTime.now().withoutTime;
    return !isTodaySelected;
  }

  @override
  handleDateSelectedChanged(DateTime newDate) {
    daySelected = newDate.withoutTime;
    eventController.removeWhere((event) => true);
  }

  List<EventData> selectedDayCalendarEvents() {
    final List<EventData> events = [];

    // We want to put events of previous and next day in memory to make transitions smoother
    for (int i = -1; i <= 1; i++) {
      final date = daySelected.add(Duration(days: i));
      events.addAll(calendarEventsFromDate(date));
    }
    return events;
  }

  int getStartHour() {
    List<EventData> eventsFromDay = calendarEventsFromDate(daySelected);
    int defaultStartHour = 8;

    if (eventsFromDay.isEmpty) {
      return defaultStartHour;
    }

    int firstEventHour = calendarEventsFromDate(daySelected).first.startTime.hour - 1;
    return min(defaultStartHour, firstEventHour);
  }

  int getEndHour() {
    List<EventData> eventsFromDay = calendarEventsFromDate(daySelected);
    int defaultEndHour = 18;

    if (eventsFromDay.isEmpty) {
      return defaultEndHour;
    }

    int lastEventHour = calendarEventsFromDate(daySelected).last.endTime.hour + 1;
    return max(defaultEndHour, lastEventHour);
  }
}
