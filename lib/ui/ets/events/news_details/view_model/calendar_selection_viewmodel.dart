// Dart imports:
import 'dart:collection';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:device_calendar/device_calendar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:fluttertoast/fluttertoast.dart';

// Project imports:
import 'package:notredame/data/models/hello/news.dart';
import 'package:notredame/data/repositories/course_repository.dart';
import 'package:notredame/data/services/calendar_service.dart';
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
    _calendars = await CalendarService.nativeCalendars;
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
    CalendarService.exportNews(news, selectedCalendarId).then((value) {
      if (value) {
        _showToast(translations.news_export_success);
      } else {
        _showToast(translations.news_export_error);
      }
    });
  }

  void _exportCourses(String selectedCalendarId) {
    CalendarService.export(courseRepository.coursesActivities!, selectedCalendarId).then((value) {
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
