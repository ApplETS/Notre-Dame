// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:calendar_view/calendar_view.dart';
import 'package:collection/collection.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:notredame/data/repositories/course_activity_repository.dart';
import 'package:notredame/data/repositories/course_repository.dart';
import 'package:notredame/data/repositories/list_sessions_repository.dart';
import 'package:notredame/data/repositories/settings_repository.dart';
import 'package:notredame/domain/models/signets-api/course_activity.dart';
import 'package:notredame/domain/models/signets-api/session.dart';
import 'package:notredame/ui/core/themes/app_palette.dart';
import 'package:stacked/stacked.dart';

// Project imports:
import 'package:notredame/data/models/activity_code.dart';
import 'package:notredame/data/models/event_data.dart';
import 'package:notredame/l10n/app_localizations.dart';
import 'package:notredame/locator.dart';

abstract class CalendarViewModel extends FutureViewModel {
  @protected
  final AppIntl intl;

  final CourseActivityRepository _courseActivityRepository;
  final ListSessionsRepository _listSessionsRepository;
  final CourseRepository _courseRepository;
  final SettingsRepository _settingsRepository;

  final EventController eventController = EventController();

  final Map<String, Color> _courseColors = {};
  final List<Color> _schedulePaletteTheme = AppPalette.schedule.toList();

  Map<DateTime, List<EventData>> _events = {};

  CalendarViewModel({
    required this.intl,
    CourseActivityRepository? courseActivityRepository,
    ListSessionsRepository? listSessionsRepository,
    CourseRepository? courseRepository,
    SettingsRepository? settingsRepository,
  })  : _courseActivityRepository = courseActivityRepository ?? locator<CourseActivityRepository>(),
        _listSessionsRepository = listSessionsRepository ?? locator<ListSessionsRepository>(),
        _courseRepository = courseRepository ?? locator<CourseRepository>(),
        _settingsRepository = settingsRepository ?? locator<SettingsRepository>();

  @protected
  Future<void> loadEvents(DateTime startDate, DateTime endDate, {bool forceUpdate = false}) async {
    final Session? session = await _findSessionForDateRange(startDate, endDate);
    if (session == null) {
      _events = {};
      return;
    }

    final DateTime clampedStartDate = startDate.isBefore(session.startDate) ? session.startDate : startDate;
    final DateTime clampedEndDate = endDate.isAfter(session.endDate.add(const Duration(days: 1)))
        ? session.endDate.add(const Duration(days: 1))
        : endDate;

    final courseActivities = await getCourseActivities(
      startDate: clampedStartDate,
      endDate: clampedEndDate,
      forceUpdate: forceUpdate,
      sessionShortName: session.shortName,
    );

    _events = _groupAndBuildEvents(courseActivities);
  }

  Future<Session?> _findSessionForDateRange(DateTime startDate, DateTime endDate) async {
    await _ensureActiveSession();
    return _listSessionsRepository.getSessionForRange(startDate, endDate) ?? _listSessionsRepository.getActiveSession();
  }

  Future<void> refreshEvents();

  Future<Session?> _ensureActiveSession() async {
    Session? activeSession = _listSessionsRepository.getActiveSession();
    if (activeSession != null) {
      return activeSession;
    }

    await _listSessionsRepository.getSessions();
    return _listSessionsRepository.getActiveSession();
  }

  Map<DateTime, List<EventData>> _groupAndBuildEvents(List<CourseActivity> activities) {
    final Map<DateTime, List<CourseActivity>> grouped = {};
    for (final course in activities) {
      final date = course.startDate.withoutTime;
      grouped.update(date, (current) {
        current.add(course);
        return current;
      }, ifAbsent: () => [course]);
    }

    grouped.updateAll((key, value) => value..sort((a, b) => a.startDate.compareTo(b.startDate)));

    return grouped.map((key, value) => MapEntry(key, _calendarEventTile(value)));
  }

  List<CourseActivity> _filterActivities(List<CourseActivity> activities) {
    return activities.where((course) {
      final courseAcronym = course.courseGroup.split('-').first;
      final isLabAorB = course.activityName == ActivityName.labA || course.activityName == ActivityName.labB;
      final activitySelected = _settingsRepository.schedule.getLaboratoryGroup(courseAcronym);

      if (isLabAorB &&
          ((activitySelected == ActivityCode.labGroupA && course.activityName != ActivityName.labA) ||
              (activitySelected == ActivityCode.labGroupB && course.activityName != ActivityName.labB))) {
        return false;
      }

      return true;
    }).toList();
  }

  Color _getCourseColor(String courseName) {
    if (!_courseColors.containsKey(courseName)) {
      _courseColors[courseName] = _schedulePaletteTheme.removeLast();
    }
    return _courseColors[courseName] ?? AppPalette.etsLightRed;
  }

  List<EventData> _calendarEventTile(List<CourseActivity> courses) {
    final allCourses = _courseRepository.courses ?? [];

    return courses.map((course) {
      final courseAcronym = course.courseGroup.split('-').first;
      final associatedCourse = allCourses.firstWhereOrNull((c) => c.acronym == courseAcronym);

      return EventData(
        courseAcronym: courseAcronym,
        group: course.courseGroup,
        locations: [course.location],
        activityName: course.activityName,
        courseName: course.courseLabel,
        teacherName: associatedCourse?.teacherName,
        date: course.startDate,
        startTime: course.startDate,
        endTime: course.endDate,
        color: _getCourseColor(courseAcronym),
      );
    }).toList();
  }

  Future<List<CourseActivity>> getCourseActivities({
    required DateTime startDate,
    required DateTime endDate,
    bool forceUpdate = false,
    String? sessionShortName,
  }) async {
    if (sessionShortName == null) {
      return [];
    }

    try {
      await _courseActivityRepository.getCourseActivities(
        sessionShortName,
        startDate: startDate,
        endDate: endDate,
        forceUpdate: forceUpdate,
      );

      final activities = _filterActivities(_courseActivityRepository.activities ?? []);
      activities.sort((a, b) => a.startDate.compareTo(b.startDate));
      return activities;
    } catch (e) {
      onError(e, StackTrace.current);
      return [];
    }
  }

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
