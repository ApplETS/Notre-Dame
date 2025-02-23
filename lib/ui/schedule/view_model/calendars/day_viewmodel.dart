import 'package:calendar_view/calendar_view.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:notredame/ui/schedule/view_model/calendar_viewmodel.dart';
import 'package:notredame/data/services/signets-api/models/course_activity.dart';

class DayViewModel extends CalendarViewModel {
  DateTime daySelected = DateTime.now().withoutTime;
  final EventController eventController = EventController();

  DayViewModel({required super.intl});

  @override
  bool returnToCurrentDate() {
    final bool isTodaySelected = DateTime.now().withoutTime == daySelected.withoutTime;

    if (isTodaySelected) {
      Fluttertoast.showToast(msg: appIntl.schedule_already_today_toast);
    }

    daySelected = DateTime.now().withoutTime;
    return !isTodaySelected;
  }

  @override
  handleDateSelectedChanged(DateTime newDate) {
    daySelected = newDate;

    eventController.removeWhere((event) =>
      event.date.withoutTime.difference(newDate.withoutTime).inDays.abs() > 1
    );

    List<CalendarEventData> eventsToAdd = selectedDayCalendarEvents();

    eventController.addAll(eventsToAdd);
  }

  List<CalendarEventData> selectedDayCalendarEvents() {
    final List<CalendarEventData> events = [];

    // We want to put events of previous and next day in memory to make transitions smoother
    for (int i = -1; i <= 1; i++) {
      final date = daySelected.add(Duration(days: i));
      final eventsForDay = calendarEventsFromDate(date);
      if (eventsForDay.isNotEmpty) {
        events.addAll(eventsForDay);
      }
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
}
