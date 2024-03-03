import 'dart:collection';
import 'package:device_calendar/device_calendar.dart';

import 'package:ets_api_clients/models.dart';
import 'package:notredame/core/models/news.dart';

mixin CalendarUtils {
  static Future<bool?> checkPermissions() async {
    final deviceCalendarPluginPermissionsResponse =
        await deviceCalendarPlugin.hasPermissions();
    // if we were able to check for permissions without error
    if (deviceCalendarPluginPermissionsResponse.isSuccess) {
      // if the user has not yet allowed permission
      if (deviceCalendarPluginPermissionsResponse.data == false) {
        // request permission
        final deviceCalendarPluginRequestPermissionsResponse =
            await deviceCalendarPlugin.requestPermissions();
        // if permission request was successfully executed
        if (deviceCalendarPluginRequestPermissionsResponse.isSuccess) {
          // return the result of the permission request (accepted or refused)
          return deviceCalendarPluginRequestPermissionsResponse.data;
        } else {
          // Handle requesting permissions failure
        }
      } else {
        // if user has allowed permission
        return true;
      }
    } else {
      // error requesting permissions
    }
    return false;
  }

  static final DeviceCalendarPlugin deviceCalendarPlugin =
      DeviceCalendarPlugin();

  static Future<UnmodifiableListView<Calendar>?> get nativeCalendars async {
    final Result<UnmodifiableListView<Calendar>> calendarFetchResult =
        await DeviceCalendarPlugin().retrieveCalendars();
    return calendarFetchResult.data;
  }

  /// Fetches a calendar by name from the native calendar app
  static Future<Calendar?> fetchNativeCalendar(String calendarName) async {
    return (await nativeCalendars)?.firstWhere(
      (element) => element.name == calendarName,
      orElse: () => Calendar(),
    );
  }

  /// Fetches events from a calendar by id from the native calendar app
  static Future<UnmodifiableListView<Event>?> fetchNativeCalendarEvents(
      String calendarId, RetrieveEventsParams retrievalParams) async {
    final output =
        await deviceCalendarPlugin.retrieveEvents(calendarId, retrievalParams);
    return output.data;
  }

  static Future<bool> export(
    List<CourseActivity> courses,
    String calendarName,
  ) async {
    final DeviceCalendarPlugin localDeviceCalendarPlugin =
        DeviceCalendarPlugin();

    // Request permissions
    final bool? calendarPermission = await checkPermissions();

    if (calendarPermission == false) {
      return false;
    }

    // Fetch calendar
    Calendar? calendar = await fetchNativeCalendar(calendarName);

    // Create calendar if it doesn't exist
    if (calendar == null) {
      await deviceCalendarPlugin.createCalendar(calendarName);
      calendar = await fetchNativeCalendar(calendarName);
    }

    // Fetch events from calendar to avoid duplicates
    final events = await fetchNativeCalendarEvents(
        calendar!.id!,
        RetrieveEventsParams(
          startDate: DateTime.now().subtract(const Duration(days: 120)),
          endDate: DateTime.now().add(const Duration(days: 120)),
        ));

    // Order by date
    courses.sort((a, b) => a.startDateTime.compareTo(b.startDateTime));

    bool hasErrors = false;
    // Add events to calendar
    for (final course in courses) {
      // create event
      final event = Event(
        calendar.id,
        title: course.courseName,
        start: TZDateTime.from(
            course.startDateTime, getLocation('America/Toronto')),
        end:
            TZDateTime.from(course.endDateTime, getLocation('America/Toronto')),
        location: course.activityLocation,
        description:
            "${course.courseGroup} \n${course.activityDescription}\nN'EFFACEZ PAS CETTE LIGNE: ${course.hashCode}",
      );

      final existingEvents = events?.where(
        (element) =>
            element.description?.contains(course.hashCode.toString()) ?? false,
      );
      if (existingEvents?.isNotEmpty == true) {
        final existingEvent = existingEvents?.first;

        // If already exists prepare for update
        if (existingEvent != null) {
          event.eventId = existingEvent.eventId;
        }
      }
      // Create or update event
      final result = await localDeviceCalendarPlugin.createOrUpdateEvent(
        event,
      );

      if (result?.isSuccess == false) {
        hasErrors = true;
      }
    }
    return !hasErrors;
  }

  static Future<bool> exportNews(
    News news,
    String calendarName,
  ) async {
    final DeviceCalendarPlugin localDeviceCalendarPlugin =
        DeviceCalendarPlugin();

    // Request permissions
    final bool? calendarPermission = await checkPermissions();

    if (calendarPermission == false) {
      return false;
    }

    // Fetch calendar
    Calendar? calendar = await fetchNativeCalendar(calendarName);

    // Create calendar if it doesn't exist
    if (calendar == null) {
      await deviceCalendarPlugin.createCalendar(calendarName);
      calendar = await fetchNativeCalendar(calendarName);
    }

    bool hasErrors = false;
    final event = Event(
      calendar?.id,
      title: news.title,
      start:
          TZDateTime.from(news.eventStartDate, getLocation('America/Toronto')),
      end: TZDateTime.from(news.eventEndDate ?? news.eventStartDate,
          getLocation('America/Toronto')),
      description: news.description,
    );

    // Create or update event
    final result = await localDeviceCalendarPlugin.createOrUpdateEvent(
      event,
    );

    if (result?.isSuccess == false) {
      hasErrors = true;
    }
    return !hasErrors;
  }
}
