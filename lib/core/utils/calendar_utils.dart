import 'dart:collection';
import 'package:device_calendar/device_calendar.dart';
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

  static Event newsToEvent(News news) {
    return Event(
      null,
      title: news.title,
      start:
          TZDateTime.from(news.eventStartDate, getLocation('America/Toronto')),
      end: TZDateTime.from(news.eventEndDate ?? news.eventStartDate,
          getLocation('America/Toronto')),
      description: news.description,
    );
  }

  static Future<bool> exportEvent(
    Event? event,
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

    if (calendar != null && calendar.id != null) {
      // create event
      final finalEvent = Event(
        calendar.id,
        /*title: event.title,
        start: event.start,
        end: event.end,
        description: event.description,*/
      );

      // Create or update event
      final result = await localDeviceCalendarPlugin.createOrUpdateEvent(
        finalEvent,
      );

      if (result?.isSuccess == false) {
        hasErrors = true;
      }
    }
    return !hasErrors;
  }
}
