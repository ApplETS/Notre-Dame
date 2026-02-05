// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:calendar_view/calendar_view.dart';

@immutable
class EventData extends CalendarEventData {
  final String courseAcronym;
  final List<String>? locations;
  final String? activityName;
  final String? group;
  final String? courseName;
  final String? teacherName;

  String? get calendarDescription {
    if (locations == null) {
      return null;
    }
    // TODO should already be N/A
    final courseLocation = locations!.contains("Non assign") ? "N/A" : locations!.join("\n");
    return "$courseLocation\n$activityName";
  }

  int? get calendarDescriptionLines => calendarDescription?.split(RegExp(r'\r?\n')).length ?? 0;

  String get modalTitle => "TODO";

  EventData({
    required this.courseAcronym,
    required super.date,
    required super.startTime,
    required super.endTime,
    super.color,
    this.locations,
    this.activityName,
    this.group,
    this.courseName,
    this.teacherName,
  }) : super(title: courseAcronym);
}
