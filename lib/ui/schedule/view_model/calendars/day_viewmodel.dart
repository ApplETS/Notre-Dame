// Package imports:
import 'package:calendar_view/calendar_view.dart';
import 'package:fluttertoast/fluttertoast.dart';

// Project imports:
import 'package:notredame/data/services/signets-api/models/course_activity.dart';
import 'package:notredame/ui/schedule/view_model/calendars/calendar_viewmodel.dart';
import 'package:notredame/data/models/calendar_event_tile.dart';

class DayViewModel extends CalendarViewModel {
  DateTime daySelected = DateTime.now().withoutTime;
  final EventController eventController = EventController();

  DayViewModel({required super.intl});

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
    eventController.removeWhere((event) => true);
  }

  List<CalendarEventTile> selectedDayCalendarEvents() {
    final List<CalendarEventTile> events = [];

    // We want to put events of previous and next day in memory to make transitions smoother
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
}
