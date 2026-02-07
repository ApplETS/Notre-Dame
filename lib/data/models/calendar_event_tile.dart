// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:calendar_view/calendar_view.dart';

@immutable
class EventData extends CalendarEventData {
  final String courseAcronym;
  final String courseName;
  final List<String>? locations;
  final String? activityName;
  final String? group;
  final String? teacherName;

  String? calendarDescription(bool mutliline) {
    if (locations == null) {
      return null;
    }
    // TODO should already be N/A
    List<String> withoutBreakableSpaces = locations!.map((str) {
      return str.replaceAll(" ", "\u{00A0}");
    }).toList();

    final courseLocation = locations!.contains("Non assign") ? "N/A" : withoutBreakableSpaces.join(mutliline ? "\n" : ", ");

    final name = activityName?.replaceAll(" ", "\u{00A0}");
    return "$courseLocation\n$name";
  }

  EventData({
    required this.courseAcronym,
    required this.courseName,
    required super.date,
    required super.startTime,
    required super.endTime,
    super.color,
    this.locations,
    this.activityName,
    this.group,
    this.teacherName,
  }) : super(title: courseAcronym);
}
