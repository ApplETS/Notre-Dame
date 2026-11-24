// Dart imports:
import 'dart:collection';

// Package imports:
import 'package:device_calendar_plus/device_calendar_plus.dart';

// Project imports:
import 'package:notredame/data/models/hello/news.dart';
import 'package:notredame/data/services/signets-api/models/course_activity.dart';

/// Formats that the calendar can display.
enum CalendarTimeFormat { month, week, day }

mixin CalendarService {
  static DeviceCalendar get deviceCalendarPlugin => DeviceCalendar.instance;

  static Future<bool> checkPermissions() async {
    try {
      final status = await deviceCalendarPlugin.hasPermissions();
      if (status == CalendarPermissionStatus.granted) {
        return true;
      }
      // Request permission (or upgrade write-only access to full access)
      return await deviceCalendarPlugin.requestPermissions() == CalendarPermissionStatus.granted;
    } on DeviceCalendarException {
      return false;
    }
  }

  static Future<UnmodifiableListView<Calendar>> get nativeCalendars async {
    if (await checkPermissions()) {
      return UnmodifiableListView(await deviceCalendarPlugin.listCalendars());
    }
    // User denied calendar access
    throw Error();
  }

  /// Fetches a calendar by name from the native calendar app
  static Future<Calendar?> fetchNativeCalendar(String calendarName) async {
    final nativeCalendarList = await nativeCalendars;
    for (final calendar in nativeCalendarList) {
      if (calendar.name == calendarName) {
        return calendar;
      }
    }
    return null;
  }

  /// Fetches the calendar with the given name, creating it if it doesn't exist.
  /// Returns its id.
  static Future<String> _fetchOrCreateNativeCalendarId(String calendarName) async {
    final calendar = await fetchNativeCalendar(calendarName);
    return calendar?.id ?? await deviceCalendarPlugin.createCalendar(name: calendarName);
  }

  /// Fetches events from a calendar by id from the native calendar app
  static Future<UnmodifiableListView<Event>> fetchNativeCalendarEvents(
    String calendarId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final events = await deviceCalendarPlugin.listEvents(startDate, endDate, calendarIds: [calendarId]);
    return UnmodifiableListView(events);
  }

  static Future<bool> export(List<CourseActivity> courses, String calendarName) async {
    // Request permissions
    final bool calendarPermission = await checkPermissions();

    if (!calendarPermission) {
      return false;
    }

    courses.sort((a, b) => a.startDateTime.compareTo(b.startDateTime));

    final DateTime startDate = courses.first.startDateTime;
    final DateTime endDate = courses.last.endDateTime;

    bool hasErrors = false;
    try {
      final calendarId = await _fetchOrCreateNativeCalendarId(calendarName);

      // Fetch events from calendar to avoid duplicates
      final events = await fetchNativeCalendarEvents(calendarId, startDate, endDate);

      // Add events to calendar
      for (final course in courses) {
        final title = course.courseName;
        final location = course.activityLocation.join(", ");
        final description =
            "${course.courseGroup} \n${course.activityDescription}\n N'EFFACEZ PAS CETTE LIGNE: ${course.hashCode}";

        final existingEvents = events.where(
          (element) => element.description != null && element.description!.contains(course.hashCode.toString()),
        );

        try {
          if (existingEvents.isNotEmpty) {
            // If already exists, update it
            await deviceCalendarPlugin.updateEvent(
              instanceId: existingEvents.first.instanceId,
              title: title,
              startDate: course.startDateTime,
              endDate: course.endDateTime,
              location: Patch.set(location),
              description: Patch.set(description),
            );
          } else {
            await deviceCalendarPlugin.createEvent(
              calendarId: calendarId,
              title: title,
              startDate: course.startDateTime,
              endDate: course.endDateTime,
              location: location,
              description: description,
            );
          }
        } on DeviceCalendarException {
          hasErrors = true;
        }
      }
    } on DeviceCalendarException {
      return false;
    }
    return !hasErrors;
  }

  static Future<bool> exportNews(News news, String calendarName) async {
    // Request permissions
    final bool calendarPermission = await checkPermissions();

    if (!calendarPermission) {
      return false;
    }

    try {
      final calendarId = await _fetchOrCreateNativeCalendarId(calendarName);

      await deviceCalendarPlugin.createEvent(
        calendarId: calendarId,
        title: news.title,
        startDate: news.eventStartDate,
        endDate: news.eventEndDate,
        description: news.content,
      );
    } on DeviceCalendarException {
      return false;
    }
    return true;
  }
}
