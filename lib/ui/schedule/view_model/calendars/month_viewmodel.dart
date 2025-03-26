// Package imports:
import 'package:calendar_view/calendar_view.dart';
import 'package:fluttertoast/fluttertoast.dart';

// Project imports:
import 'package:notredame/ui/schedule/view_model/calendars/calendar_viewmodel.dart';
import 'package:notredame/utils/utils.dart';

class MonthViewModel extends CalendarViewModel {
  DateTime monthSelected = Utils.getFirstDayOfMonth(DateTime.now());
  final EventController eventController = EventController();

  MonthViewModel({required super.intl});

  @override
  handleDateSelectedChanged(DateTime newDate) {
    // The first row in the month view can contains day from the previous month. One extra hour for daylight savings.
    final dateInSelectedMonth = newDate.add(const Duration(days: 7, hours: 1));
    monthSelected = Utils.getFirstDayOfMonth(dateInSelectedMonth);

    // Start with current month to avoid starting coloring with events from another session
    eventController.addAll(selectedMonthEvents());
  }

  List<CalendarEventData> selectedMonthEvents() {
    List<CalendarEventData> events = [];

    final List<DateTime> months = [
      monthSelected,
      Utils.getFirstDayOfMonth(monthSelected.add(Duration(days: 31))),
      Utils.getFirstDayOfMonth(monthSelected.subtract(Duration(days: 1)))
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
    final DateTime currentMonth = Utils.getFirstDayOfMonth(DateTime.now());
    final bool isThisMonthSelected = currentMonth == monthSelected;

    isThisMonthSelected
        ? Fluttertoast.showToast(msg: super.appIntl.schedule_already_today_toast)
        : monthSelected = currentMonth;

    return !isThisMonthSelected;
  }
}
