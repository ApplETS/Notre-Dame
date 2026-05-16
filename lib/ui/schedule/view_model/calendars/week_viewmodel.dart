// Dart imports:
import 'dart:async';

// Package imports:
import 'package:calendar_view/calendar_view.dart';
import 'package:fluttertoast/fluttertoast.dart';

// Project imports:
import 'package:notredame/data/models/event_data.dart';
import 'package:notredame/ui/schedule/view_model/calendars/calendar_viewmodel.dart';
import 'package:notredame/utils/date_utils.dart';

class WeekViewModel extends CalendarViewModel {
  // Sunday of current week
  DateTime weekSelected = DateUtils.getFirstdayOfWeek(DateTime.now());

  // Display weekend days only if they contain events
  bool displaySunday = false;
  bool displaySaturday = false;

  /// If today is saturday, I have no course today and the shedule just loaded, then this value will be true
  bool displayNextWeek = false;

  bool _firstLoad = true;

  DateTime? _eventsLoadedStart;
  DateTime? _eventsLoadedEnd;

  WeekViewModel({required super.intl});

  @override
  Future<void> futureToRun() async {
    setBusy(true);
    final currentWeekStart = DateUtils.getFirstdayOfWeek(DateTime.now());
    await _loadWeekEvents(currentWeekStart);
    setBusy(false);
  }

  @override
  Future<void> refreshEvents() async {
    setBusy(true);
    final currentWeekStart = DateUtils.getFirstdayOfWeek(DateTime.now());
    await _loadWeekEvents(currentWeekStart, forceUpdate: true);
    setBusy(false);
  }

  Future<void> _loadWeekEvents(DateTime referenceWeek, {bool forceUpdate = false}) async {
    final DateTime rangeStart = referenceWeek.subtract(const Duration(days: 21));
    final DateTime rangeEnd = referenceWeek.add(const Duration(days: 28));

    await loadEvents(rangeStart, rangeEnd, forceUpdate: forceUpdate);

    _eventsLoadedStart = rangeStart;
    _eventsLoadedEnd = rangeEnd;
  }

  @override
  void handleDateSelectedChanged(DateTime newDate) {
    weekSelected = DateUtils.getFirstdayOfWeek(newDate);
    final DateTime selectedWeekEnd = weekSelected.add(const Duration(days: 6));

    if (_eventsLoadedStart == null ||
        _eventsLoadedEnd == null ||
        weekSelected.isBefore(_eventsLoadedStart!) ||
        selectedWeekEnd.isAfter(_eventsLoadedEnd!.subtract(const Duration(days: 1)))) {
      Future<void>.microtask(() async {
        await _loadWeekEvents(weekSelected);
        eventController.removeWhere((event) => true);
        eventController.addAll(selectedWeekCalendarEvents());
      });
    }

    if (!isBusy && _firstLoad) {
      _firstLoad = false;
      if (DateTime.now().weekday == DateTime.saturday &&
          DateUtils.getFirstdayOfWeek(DateTime.now()) == weekSelected &&
          calendarEventsFromDate(DateTime.now()).isEmpty) {
        handleDateSelectedChanged(weekSelected.add(const Duration(days: 7, hours: 1)));
        displayNextWeek = true;
      }
    }

    displaySunday = calendarEventsFromDate(weekSelected).isNotEmpty;
    displaySaturday = calendarEventsFromDate(weekSelected.add(const Duration(days: 6, hours: 1))).isNotEmpty;

    eventController.removeWhere((event) => true);
    eventController.addAll(selectedWeekCalendarEvents());
  }

  @override
  bool returnToCurrentDate() {
    DateTime dateToReturnTo = DateUtils.getFirstdayOfWeek(DateTime.now());
    if (DateTime.now().weekday == DateTime.saturday &&
        calendarEventsFromDate(dateToReturnTo.add(const Duration(days: 6, hours: 1))).isEmpty) {
      dateToReturnTo = dateToReturnTo.add(const Duration(days: 7, hours: 1)).withoutTime;
    }

    final bool isThisWeekSelected = dateToReturnTo == weekSelected;

    if (isThisWeekSelected) {
      Fluttertoast.showToast(msg: super.intl.schedule_already_today_toast);
    } else {
      handleDateSelectedChanged(dateToReturnTo);
    }

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
