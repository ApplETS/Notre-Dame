// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:calendar_view/calendar_view.dart';

@immutable
class CalendarEventTile<T extends Object?> extends CalendarEventData {
  final int? nbLines;
  final String? cardDescription;

  CalendarEventTile({
    required super.title,
    required super.date,
    super.color,
    super.description,
    super.descriptionStyle,
    super.endDate,
    super.endTime,
    super.event,
    super.recurrenceSettings,
    super.startTime,
    super.titleStyle,
    this.nbLines,
    this.cardDescription,
  });
}
