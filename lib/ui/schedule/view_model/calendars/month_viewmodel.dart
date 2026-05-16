// Dart imports:
import 'dart:async';

// Package imports:
import 'package:calendar_view/calendar_view.dart';
import 'package:fluttertoast/fluttertoast.dart';

// Project imports:
import 'package:notredame/data/models/event_data.dart';
import 'package:notredame/ui/schedule/view_model/calendars/calendar_viewmodel.dart';
import 'package:notredame/utils/date_utils.dart';

class MonthViewModel extends CalendarViewModel {
  DateTime monthSelected = DateUtils.getFirstDayOfMonth(DateTime.now());

  DateTime? _eventsLoadedStart;
  DateTime? _eventsLoadedEnd;

  MonthViewModel({required super.intl});

  @override
  Future<void> futureToRun() async {
    setBusy(true);
    final month = DateUtils.getFirstDayOfMonth(DateTime.now());
    await _loadMonthEvents(month);
    setBusy(false);
  }

  @override
  Future<void> refreshEvents() async {
    setBusy(true);
    final month = DateUtils.getFirstDayOfMonth(DateTime.now());
    await _loadMonthEvents(month, forceUpdate: true);
    setBusy(false);
  }

  Future<void> _loadMonthEvents(DateTime referenceMonth, {bool forceUpdate = false}) async {
    final DateTime rangeStart = DateTime(referenceMonth.year, referenceMonth.month - 1);
    final DateTime rangeEnd = DateTime(referenceMonth.year, referenceMonth.month + 3);

    await loadEvents(rangeStart, rangeEnd, forceUpdate: forceUpdate);

    _eventsLoadedStart = rangeStart;
    _eventsLoadedEnd = rangeEnd;
  }

  @override
  void handleDateSelectedChanged(DateTime newDate) {
    // The first row in the month view can contain day from the previous month.
    // One extra hour for daylight savings.
    final dateInSelectedMonth = newDate.add(const Duration(days: 7, hours: 1));
    monthSelected = DateUtils.getFirstDayOfMonth(dateInSelectedMonth);

    if (_eventsLoadedStart == null ||
        _eventsLoadedEnd == null ||
        monthSelected.isBefore(_eventsLoadedStart!) ||
        monthSelected.isAfter(_eventsLoadedEnd!.subtract(const Duration(days: 1)))) {
      Future<void>.microtask(() async {
        await _loadMonthEvents(monthSelected);
        eventController.removeWhere((event) => true);
        eventController.addAll(selectedMonthEvents());
      });
    }

    eventController.removeWhere((event) => true);
    eventController.addAll(selectedMonthEvents());
  }

  List<EventData> selectedMonthEvents() {
    final List<EventData> events = [];

    final List<DateTime> months = [
      monthSelected,
      DateUtils.getFirstDayOfMonth(monthSelected.add(const Duration(days: 31))),
      DateUtils.getFirstDayOfMonth(monthSelected.subtract(const Duration(days: 1))),
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

    if (isThisMonthSelected) {
      Fluttertoast.showToast(msg: super.intl.schedule_already_today_toast);
    } else {
      handleDateSelectedChanged(currentMonth);
    }

    return !isThisMonthSelected;
  }
}
