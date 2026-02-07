// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:calendar_view/calendar_view.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:stacked/stacked.dart';

// Project imports:
import 'package:notredame/data/models/calendar_event_tile.dart';
import 'package:notredame/l10n/app_localizations.dart';
import 'package:notredame/locator.dart';
import 'package:notredame/data/services/schedule_service.dart';

abstract class CalendarViewModel extends FutureViewModel<Map<DateTime, List<EventData>>> {
  @protected
  final AppIntl intl;

  final ScheduleService _scheduleService = locator<ScheduleService>();

  Map<DateTime, List<EventData>> _events = {};

  CalendarViewModel({required this.intl});

  @override
  Future<Map<DateTime, List<EventData>>> futureToRun() async {
    _events = await _scheduleService.events;
    return _events;
  }

  @protected
  List<EventData> calendarEventsFromDate(DateTime date) {
    return _events[date.withoutTime] ?? [];
  }

  bool returnToCurrentDate();

  void handleDateSelectedChanged(DateTime newDate);

  @override
  void onError(error, StackTrace? stackTrace) {
    Fluttertoast.showToast(msg: intl.error);
  }
}
