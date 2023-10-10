import 'dart:collection';
import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:ets_api_clients/models.dart';

mixin CalendarUtils {

  static MethodChannel _channel = MethodChannel('native_calendar');
  static Future<void> checkPermissions() async {
    if (!(await deviceCalendarPlugin.hasPermissions()).isSuccess) {
      await deviceCalendarPlugin.requestPermissions();
    }
  }

  static final DeviceCalendarPlugin deviceCalendarPlugin =
      DeviceCalendarPlugin();

  static Future<UnmodifiableListView<Calendar>> get nativeCalendars async {
    final Result<UnmodifiableListView<Calendar>> calendarFetchResult =
        await DeviceCalendarPlugin().retrieveCalendars();
    // TODO handle errors
    return calendarFetchResult.data;
  }

  static Future<Calendar> fetchNativeCalendar(String calendarName) async {
    return (await nativeCalendars).firstWhere(
      (element) => element.name == calendarName,
      orElse: () => null,
    );
  }

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
    const calendarName = "ÉTS";

    await checkPermissions();
    Calendar calendar = await fetchNativeCalendar(calendarName);

    if (calendar == null) {
      await deviceCalendarPlugin.createCalendar(
        calendarName,
      );
      calendar = await fetchNativeCalendar(calendarName);
    }
    final events = await fetchNativeCalendarEvents(
        calendar.id,
        RetrieveEventsParams(
          startDate: DateTime.now().subtract(const Duration(days: 5)),
          endDate: DateTime.now().add(const Duration(days: 365)),
        ));

    print(events);

    for (final course in courses) {
      // add prof
      final result = await localDeviceCalendarPlugin.createOrUpdateEvent(
        Event(
          calendar.id,
          eventId: course.hashCode.toString(),
          start: TZDateTime.from(
              course.startDateTime, getLocation('America/Toronto')),
          end: TZDateTime.from(
              course.endDateTime, getLocation('America/Toronto')),
          location: course.activityLocation,
          description: "${course.courseGroup} \n ${course.courseGroup}",
          title: course.courseName,
        ),
      );
      // TODO handle errors
      print(result);
      print(result.isSuccess);
      await Future.delayed(const Duration(milliseconds: 1000));
    }
  }

  // static Future<void> exportRaw(List<CourseActivity> courses) async {
  //   const calendarName = "ÉTS";

  //   final DeviceCalendarPlugin deviceCalendarPlugin = DeviceCalendarPlugin();

  //   if (!(await deviceCalendarPlugin.hasPermissions()).isSuccess) {
  //     await deviceCalendarPlugin.requestPermissions();
  //   }

  //   final Result<UnmodifiableListView<Calendar>> calendarFetchResult =
  //       await DeviceCalendarPlugin().retrieveCalendars();
  //   // TODO handle errors
  //   Calendar calendar = calendarFetchResult.data.firstWhere(
  //     (element) => element.name == calendarName,
  //     orElse: () => null,
  //   );

  //   if (calendar == null) {
  //     await deviceCalendarPlugin.createCalendar(
  //       calendarName,
  //     );
  //     calendar = calendarFetchResult.data.firstWhere(
  //       (element) => element.name == calendarName,
  //       orElse: () => null,
  //     );
  //   }

  //   final output = await deviceCalendarPlugin.retrieveEvents(
  //     calendar.id,
  //     RetrieveEventsParams(
  //       startDate: DateTime.now().subtract(const Duration(days: 365)),
  //       endDate: DateTime.now().add(const Duration(days: 365)),
  //     ),
  //   );

  //   print(output.data.length);

  //   for (final course in courses) {
  //     final event = add2cal.Event(
  //       title: course.courseName,
  //       description: course.courseGroup,
  //       location: course.activityLocation,
  //       startDate: course.startDateTime,
  //       endDate: course.endDateTime,
  //     );
  //     final result = await add2cal.Add2Calendar.addEvent2Cal(event);
  //     await Future.delayed(const Duration(milliseconds: 1000));
  //   }
  // }
}
