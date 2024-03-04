import 'dart:collection';

import 'package:device_calendar/device_calendar.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:notredame/core/managers/course_repository.dart';
import 'package:notredame/core/models/news.dart';
import 'package:notredame/core/utils/calendar_utils.dart';
import 'package:notredame/locator.dart';

class CalendarSelectionViewModel {
  final AppIntl translations;
  late UnmodifiableListView<Calendar>? _calendars;
  final CourseRepository courseRepository = locator<CourseRepository>();
  String? selectedCalendarId;
  News? news;

  CalendarSelectionViewModel({
    required this.translations,
    this.news,
  });

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
      _showToast(translations.calendar_select);
      return;
    }
    Navigator.of(context).pop();

    if (news != null) {
      _exportNews(news!, selectedCalendarId!);
    } else {
      _exportCourses(selectedCalendarId!);
    }
  }

  void _exportNews(News news, String selectedCalendarId) {
    CalendarUtils.exportNews(news, selectedCalendarId).then((value) {
      if (value) {
        _showToast(translations.news_export_success);
      } else {
        _showToast(translations.news_export_error);
      }
    });
  }

  void _exportCourses(String selectedCalendarId) {
    CalendarUtils.export(
            courseRepository.coursesActivities!, selectedCalendarId)
        .then((value) {
      if (value) {
        _showToast(translations.calendar_export_success);
      } else {
        _showToast(translations.calendar_export_error);
      }
    });
  }

  void _showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
    );
  }
}
