// Dart imports:
import 'dart:async';
import 'dart:math';

// Package imports:
import 'package:calendar_view/calendar_view.dart';
import 'package:fluttertoast/fluttertoast.dart';

// Project imports:
import 'package:notredame/data/models/event_data.dart';
import 'package:notredame/domain/models/signets-api/course_activity.dart';
import 'package:notredame/ui/schedule/view_model/calendars/calendar_viewmodel.dart';
import 'package:notredame/utils/date_utils.dart';

class DayViewModel extends CalendarViewModel {
  DateTime daySelected = DateTime.now().withoutTime;

  DateTime? _eventsLoadedStart;
  DateTime? _eventsLoadedEnd;

  DayViewModel({required super.intl});

  @override
  Future<void> futureToRun() async {
    setBusy(true);
    await _loadSurroundingDays(DateTime.now().withoutTime);
    setBusy(false);
  }

  @override
  Future<void> refreshEvents() async {
    setBusy(true);
    await _loadSurroundingDays(DateTime.now().withoutTime, forceUpdate: true);
    setBusy(false);
  }

  Future<void> _loadSurroundingDays(DateTime referenceDate, {bool forceUpdate = false}) async {
    final DateTime currentWeekStart = DateUtils.getFirstdayOfWeek(referenceDate);
    final DateTime rangeStart = currentWeekStart.subtract(const Duration(days: 7));
    final DateTime rangeEnd = currentWeekStart.add(const Duration(days: 21));

    await loadEvents(rangeStart, rangeEnd, forceUpdate: forceUpdate);

    _eventsLoadedStart = rangeStart;
    _eventsLoadedEnd = rangeEnd;
  }

  @override
  bool returnToCurrentDate() {
    final DateTime today = DateTime.now().withoutTime;
    final bool isTodaySelected = today == daySelected;

    if (isTodaySelected) {
      Fluttertoast.showToast(msg: intl.schedule_already_today_toast);
    } else {
      handleDateSelectedChanged(today);
    }

    return !isTodaySelected;
  }

  @override
  void handleDateSelectedChanged(DateTime newDate) {
    daySelected = newDate.withoutTime;

    if (_eventsLoadedStart == null ||
        _eventsLoadedEnd == null ||
        daySelected.isBefore(_eventsLoadedStart!) ||
        daySelected.isAfter(_eventsLoadedEnd!.subtract(const Duration(days: 1)))) {
      Future<void>.microtask(() async {
        await _loadSurroundingDays(daySelected);
        eventController.removeWhere((event) => true);
        eventController.addAll(selectedDayCalendarEvents());
      });
    }

    eventController.removeWhere((event) => true);
    eventController.addAll(selectedDayCalendarEvents());
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

  Future<List<CourseActivity>> getTodayActivities() {
    final today = DateTime.now().subtract(Duration(days: 1)).withoutTime;
    final tomorrow = DateTime.now().withoutTime.add(const Duration(days: 1));
    return getCourseActivities(startDate: today, endDate: tomorrow);
  }
}

