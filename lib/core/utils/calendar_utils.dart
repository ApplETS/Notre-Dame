import 'dart:collection';
import 'package:device_calendar/device_calendar.dart';

import 'package:ets_api_clients/models.dart';

mixin CalendarUtils {
  static Future<bool> checkPermissions() async {
    final deviceCalendarPluginPermissionsResponse =
        await deviceCalendarPlugin.hasPermissions();
    // if we were able to check for permissions without error
    if (deviceCalendarPluginPermissionsResponse.isSuccess) {
      // if the user has not yet allowed permission
      if (!deviceCalendarPluginPermissionsResponse.data) {
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

  static Future<UnmodifiableListView<Calendar>> get nativeCalendars async {
    final Result<UnmodifiableListView<Calendar>> calendarFetchResult =
        await DeviceCalendarPlugin().retrieveCalendars();
    // TODO handle errors
    return calendarFetchResult.data;
  }

  /// Fetches a calendar by name from the native calendar app
  static Future<Calendar> fetchNativeCalendar(String calendarName) async {
    return (await nativeCalendars).firstWhere(
      (element) => element.name == calendarName,
      orElse: () => null,
    );
  }

  /// Fetches events from a calendar by id from the native calendar app
  static Future<UnmodifiableListView<Event>> fetchNativeCalendarEvents(
      String calendarId, RetrieveEventsParams retrievalParams) async {
    final output =
        await deviceCalendarPlugin.retrieveEvents(calendarId, retrievalParams);

    // TODO handle errors
    return output.data;
  }

  static Future<void> export(List<CourseActivity> courses) async {
    final DeviceCalendarPlugin localDeviceCalendarPlugin =
        DeviceCalendarPlugin();

    // TODO make this cleaner
    const calendarName = "ÉTS";

    // Request permissions
    final bool calendarPermission = await checkPermissions();

    if (!calendarPermission) {
      // TODO warn user
      return;
    }

    // Fetch calendar
    Calendar calendar = await fetchNativeCalendar(calendarName);

    // Create calendar if it doesn't exist
    if (calendar == null) {
      await deviceCalendarPlugin.createCalendar(
        calendarName,
      );
      calendar = await fetchNativeCalendar(calendarName);
    }

    // Fetch events from calendar to avoid duplicates
    final events = await fetchNativeCalendarEvents(
        calendar.id,
        RetrieveEventsParams(
          startDate: DateTime.now().subtract(const Duration(days: 120)),
          endDate: DateTime.now().add(const Duration(days: 120)),
        ));

    // Order by date
    courses.sort((a, b) => a.startDateTime.compareTo(b.startDateTime));

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

      // add event to calendar if it doesn't already exist
      if (events
          .where((element) =>
              element.description.contains(course.hashCode.toString()))
          .isEmpty) {
        final result = await localDeviceCalendarPlugin.createOrUpdateEvent(
          event,
        );
        // TODO handle errors
        print("even created successfully:");
        print(result.isSuccess);
        print("event id:");
        print(result.data);
      } else {
        print("already exist");
      }
    }
  }
}
