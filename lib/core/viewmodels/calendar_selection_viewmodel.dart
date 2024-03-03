import 'dart:collection';

import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:notredame/core/managers/course_repository.dart';
import 'package:notredame/core/models/news.dart';
import 'package:notredame/core/utils/calendar_utils.dart';
import 'package:notredame/locator.dart';
import 'package:notredame/ui/utils/app_theme.dart';

class CalendarSelectionViewModel {
  final AppIntl translations;
  final CourseRepository courseRepository = locator<CourseRepository>();
  late UnmodifiableListView<Calendar>? _calendars;
  String? selectedCalendarId;
  News? news;

  CalendarSelectionViewModel({required this.translations});

  Future<void> fetchCalendars() async {
    _calendars = await CalendarUtils.nativeCalendars;
  }

  List<DropdownMenuItem<String>> getDropdownItems() {
    if (_calendars == null) return [];
    return _calendars!
        .map<DropdownMenuItem<String>>(
          (Calendar value) => DropdownMenuItem<String>(
            value: value.name,
            child: Text(value.name ?? ""),
          ),
        )
        .toList();
  }

  Future<void> exportCalendar(BuildContext context) async {
    if (selectedCalendarId == null || selectedCalendarId?.isEmpty == true) {
      Fluttertoast.showToast(
        msg: translations.calendar_select,
        backgroundColor: AppTheme.etsLightRed,
        textColor: AppTheme.etsBlack,
      );
      return;
    }
    Navigator.of(context).pop();
    final result = news != null
        ? CalendarUtils.exportNews(news!, selectedCalendarId!)
        : CalendarUtils.export(
            courseRepository.coursesActivities!, selectedCalendarId!);
    result.then((value) {
      if (value) {
        Fluttertoast.showToast(
          msg: translations.calendar_export_success,
          backgroundColor: AppTheme.gradeGoodMax,
          textColor: AppTheme.etsBlack,
        );
      } else {
        Fluttertoast.showToast(
          msg: translations.calendar_export_error,
          backgroundColor: AppTheme.etsLightRed,
          textColor: AppTheme.etsBlack,
        );
      }
    });
  }
}
