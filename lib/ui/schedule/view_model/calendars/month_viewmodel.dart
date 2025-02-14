import 'package:calendar_view/calendar_view.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:notredame/ui/schedule/view_model/calendar_viewmodel.dart';

class MonthViewModel extends CalendarViewModel {
  DateTime monthSelected = _getFirstDayOfMonth(DateTime.now());
  final EventController eventController = EventController();

  MonthViewModel({required super.intl});

  @override
  handleDateSelectedChanged(DateTime newDate) {
    // The first row in the month view can contains day from the previous month. One extra hour for daylight savings.
    final dateInSelectedMonth = newDate.add(const Duration(days: 7, hours: 1));
    monthSelected = _getFirstDayOfMonth(dateInSelectedMonth);

    // Start with current month to avoid starting coloring with events from another session
    final List<DateTime> months = [
      monthSelected,
      _getFirstDayOfMonth(monthSelected.add(Duration(days: 31))),
      _getFirstDayOfMonth(monthSelected.subtract(Duration(days: 31)))
    ];

    for (final DateTime month in months) {
      for (final DateTime day in month.datesOfMonths()) {
        final eventsForDay = calendarEventsFromDate(day);
        if (eventsForDay.isNotEmpty) {
          eventController.addAll(eventsForDay);
        }
      }
    }
  }

  @override
  bool returnToCurrentDate() {
    final DateTime currentMonth = _getFirstDayOfMonth(DateTime.now());
    final bool isThisMonthSelected = currentMonth == monthSelected;

    isThisMonthSelected
        ? Fluttertoast.showToast(msg: super.appIntl.schedule_already_today_toast)
        : monthSelected = currentMonth;

    return !isThisMonthSelected;

  }

  static DateTime _getFirstDayOfMonth(DateTime date) {
    return DateTime(date.year, date.month);
  }
}