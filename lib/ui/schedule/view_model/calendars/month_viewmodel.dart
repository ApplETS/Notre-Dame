// Package imports:
import 'package:calendar_view/calendar_view.dart';
import 'package:fluttertoast/fluttertoast.dart';

// Project imports:
import 'package:notredame/data/models/event_data.dart';
import 'package:notredame/ui/schedule/view_model/calendars/calendar_viewmodel.dart';
import 'package:notredame/utils/date_utils.dart';

class MonthViewModel extends CalendarViewModel {
  DateTime monthSelected = DateUtils.getFirstDayOfMonth(DateTime.now());

  MonthViewModel({required super.intl});

  @override
  handleDateSelectedChanged(DateTime newDate) {
    // The first row in the month view can contains day from the previous month. One extra hour for daylight savings.
    final dateInSelectedMonth = newDate.add(const Duration(days: 7, hours: 1));
    monthSelected = DateUtils.getFirstDayOfMonth(dateInSelectedMonth);

    // Start with current month to avoid starting coloring with events from another session
    eventController.addAll(selectedMonthEvents());
  }

  List<EventData> selectedMonthEvents() {
    List<EventData> events = [];

    final List<DateTime> months = [
      monthSelected,
      DateUtils.getFirstDayOfMonth(monthSelected.add(Duration(days: 31))),
      DateUtils.getFirstDayOfMonth(monthSelected.subtract(Duration(days: 1))),
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
    final DateTime currentMonth = DateUtils.getFirstDayOfMonth(DateTime.now());
    final bool isThisMonthSelected = currentMonth == monthSelected;

    isThisMonthSelected
        ? Fluttertoast.showToast(msg: super.intl.schedule_already_today_toast)
        : monthSelected = currentMonth;

    return !isThisMonthSelected;
  }
}
