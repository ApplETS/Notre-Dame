// Package imports:
import 'package:calendar_view/calendar_view.dart';
import 'package:fluttertoast/fluttertoast.dart';

// Project imports:
import 'package:notredame/data/services/signets-api/models/course_activity.dart';
import 'package:notredame/ui/schedule/view_model/calendars/calendar_viewmodel.dart';

class DayViewModel extends CalendarViewModel {
  DateTime daySelected;
  final EventController eventController = EventController();

  DayViewModel({required super.intl, DateTime? selectedDate})
      : daySelected = selectedDate?.withoutTime ?? DateTime.now().withoutTime;

  @override
  bool returnToCurrentDate() {
    final bool isTodaySelected = DateTime.now().withoutTime == daySelected;

    if (isTodaySelected) {
      Fluttertoast.showToast(msg: appIntl.schedule_already_today_toast);
    }

    daySelected = DateTime.now().withoutTime;
    return !isTodaySelected;
  }

  @override
  handleDateSelectedChanged(DateTime newDate) {
    daySelected = newDate.withoutTime;

    eventController.removeWhere((event) => event.date.withoutTime.difference(daySelected).inDays.abs() > 1);

    List<CalendarEventData> eventsToAdd = selectedDayCalendarEvents();

    eventController.addAll(eventsToAdd);
  }

  List<CalendarEventData> selectedDayCalendarEvents() {
    final List<CalendarEventData> events = [];

    // We want to put events of previous and next day in memory to make transitions smoother
    // TODO fix duplicate events
    for (int i = -1; i <= 1; i++) {
      final date = daySelected.add(Duration(days: i));
      events.addAll(calendarEventsFromDate(date));
    }
    return events;
  }

  /// Get the activities for a specific [date], return empty if there is no activity for this [date]
  List<CourseActivity> coursesActivitiesFor(DateTime date) {
    // Populate the _coursesActivities
    if (coursesActivities.isEmpty) {
      coursesActivities;
    }

    return coursesActivities[date.withoutTime] ?? [];
  }

  void loadEventsForSelectedDay() {
    eventController.removeWhere((event) => event.date.withoutTime.difference(daySelected).inDays.abs() > 1);
    eventController.addAll(selectedDayCalendarEvents());
  }
}
