// Package imports:
import 'package:calendar_view/calendar_view.dart';
import 'package:fluttertoast/fluttertoast.dart';

// Project imports:
import 'package:notredame/data/models/event_data.dart';
import 'package:notredame/ui/schedule/view_model/calendars/calendar_viewmodel.dart';
import 'package:notredame/utils/date_extensions.dart';

class MonthViewModel extends CalendarViewModel {
  DateTime monthSelected = DateTime.now().firstDayOfMonth;

  MonthViewModel({required super.intl});

  @override
  handleDateSelectedChanged(DateTime newDate) {
    // The first row in the month view can contains days from the previous month.
    monthSelected = newDate.withoutTimeUtc.add(const Duration(days: 7)).firstDayOfMonth;

    // Start with current month to avoid starting coloring with events from another session
    eventController.addAll(selectedMonthEvents());
  }

  List<EventData> selectedMonthEvents() {
    List<EventData> events = [];

    final List<DateTime> months = [
      monthSelected,
      monthSelected.withoutTimeUtc.add(const Duration(days: 31)).firstDayOfMonth,
      monthSelected.withoutTimeUtc.subtract(const Duration(days: 1)).firstDayOfMonth,
    ];

    for (final DateTime month in months) {
      for (final DateTime day in month.datesOfMonths()) {
        events.addAll(calendarEventsFromDate(day));
      }
    }

    return events;
  }

  @override
  bool returnToCurrentDate() {
    final DateTime currentMonth = DateTime.now().firstDayOfMonth;
    final bool isThisMonthSelected = currentMonth == monthSelected;

    isThisMonthSelected
        ? Fluttertoast.showToast(msg: super.intl.schedule_already_today_toast)
        : monthSelected = currentMonth;

    return !isThisMonthSelected;
  }
}
