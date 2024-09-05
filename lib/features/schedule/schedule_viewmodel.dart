// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:calendar_view/calendar_view.dart';
import 'package:collection/collection.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:feature_discovery/feature_discovery.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:stacked/stacked.dart';
import 'package:table_calendar/table_calendar.dart';

// Project imports:
import 'package:notredame/constants/preferences_flags.dart';
import 'package:notredame/features/app/repository/course_repository.dart';
import 'package:notredame/features/app/signets-api/models/course.dart';
import 'package:notredame/features/app/signets-api/models/course_activity.dart';
import 'package:notredame/features/app/signets-api/models/schedule_activity.dart';
import 'package:notredame/features/more/settings/settings_manager.dart';
import 'package:notredame/features/welcome/discovery/discovery_components.dart';
import 'package:notredame/features/welcome/discovery/models/discovery_ids.dart';
import 'package:notredame/utils/activity_code.dart';
import 'package:notredame/utils/app_theme.dart';
import 'package:notredame/utils/locator.dart';
import 'package:notredame/utils/utils.dart';

class ScheduleViewModel extends FutureViewModel<List<CourseActivity>> {
  /// Load the events
  final CourseRepository _courseRepository = locator<CourseRepository>();

  /// Manage de settings
  final SettingsManager _settingsManager = locator<SettingsManager>();

  /// Localization class of the application.
  final AppIntl _appIntl;

  /// Settings of the user for the schedule
  final Map<PreferencesFlag, dynamic> settings = {};

  /// Activities sorted by day
  Map<DateTime, List<CourseActivity>> _coursesActivities = {};

  /// Courses associated to the student
  List<Course>? courses;

  /// Day currently selected
  DateTime selectedDate;

  /// Day currently focused on
  ValueNotifier<DateTime> focusedDate;

  /// List of currently loaded events
  List<CalendarEventData> calendarEvents = [];

  /// The currently selected CalendarFormat, A default value is set for test purposes.
  /// This value is then change to the cache value on load.
  CalendarFormat calendarFormat = CalendarFormat.week;

  /// This map contains the courses that has the group A or group B mark
  final Map<String, List<ScheduleActivity>> scheduleActivitiesByCourse = {};

  /// This map contains the direct settings as string for each course that are grouped
  /// (Example: (key, value) => ("ING150", "Laboratoire (Groupe A)"))
  final Map<String, String> settingsScheduleActivities = {};

  /// A map that contains a color from the AppTheme.SchedulePalette palette associated with each course.
  final Map<String, Color> courseColors = {};

  /// The color palette corresponding to the schedule courses.
  List<Color> schedulePaletteTheme = [];

  /// Get current locale
  Locale? get locale => _settingsManager.locale;

  bool displaySaturday = false;

  ScheduleViewModel({required AppIntl intl, DateTime? initialSelectedDate})
      : _appIntl = intl,
        selectedDate = initialSelectedDate ?? DateTime.now(),
        focusedDate = ValueNotifier(initialSelectedDate ?? DateTime.now());

  /// Activities for the day currently selected
  List<dynamic> selectedDateEvents(DateTime date) =>
      _coursesActivities[DateTime(date.year, date.month, date.day)] ?? [];

  Map<DateTime, List<dynamic>> selectedWeekEvents() {
    final Map<DateTime, List<dynamic>> events = {};
    final firstDayOfWeek = Utils.getFirstDayOfCurrentWeek(selectedDate,
        settings[PreferencesFlag.scheduleStartWeekday] as StartingDayOfWeek);
    for (int i = 0; i < 7; i++) {
      final date = firstDayOfWeek.add(Duration(days: i));
      final eventsForDay = selectedDateEvents(date);
      if (eventsForDay.isNotEmpty) {
        events[date] = eventsForDay;
      }
    }

    return events;
  }

  void handleViewChanged(DateTime date, EventController controller,
      List<Color> scheduleCardsPalette) {
    controller.removeWhere((event) => true);
    selectedDate = date;
    var eventsToAdd = selectedMonthCalendarEvents(scheduleCardsPalette);
    if (calendarFormat == CalendarFormat.week) {
      eventsToAdd = selectedWeekCalendarEvents(scheduleCardsPalette);
    }
    controller.addAll(eventsToAdd);
  }

  List<CalendarEventData> selectedDateCalendarEvents(DateTime date) {
    return _coursesActivities[DateTime(date.year, date.month, date.day)]
            ?.map((eventData) => calendarEventData(eventData))
            .toList() ??
        [];
  }

  CalendarEventData<Object> calendarEventData(CourseActivity eventData) {
    final courseLocation = eventData.activityLocation == "Non assign"
        ? "N/A"
        : eventData.activityLocation;
    final associatedCourses = courses?.where(
        (element) => element.acronym == eventData.courseGroup.split('-')[0]);
    final associatedCourse =
        associatedCourses?.isNotEmpty == true ? associatedCourses?.first : null;
    return CalendarEventData(
        title:
            "${eventData.courseGroup.split('-')[0]}\n$courseLocation\n${eventData.activityName}",
        description:
            "${eventData.courseGroup};$courseLocation;${eventData.activityName};${associatedCourse?.teacherName}",
        date: eventData.startDateTime,
        startTime: eventData.startDateTime,
        endTime: eventData.endDateTime.subtract(const Duration(minutes: 1)),
        color: getCourseColor(eventData.courseGroup.split('-')[0]));
  }

  Color getCourseColor(String courseName) {
    if (!courseColors.containsKey(courseName)) {
      courseColors[courseName] = schedulePaletteTheme.removeLast();
    }
    return courseColors[courseName] ?? Colors.red;
  }

  List<CalendarEventData> selectedWeekCalendarEvents(
      List<Color> scheduleCardsPalette) {
    if (scheduleCardsPalette.isNotEmpty) {
      schedulePaletteTheme = scheduleCardsPalette;
    } else {
      schedulePaletteTheme = AppTheme.schedulePaletteLight.toList();
    }
    final List<CalendarEventData> events = [];
    final firstDayOfWeek = Utils.getFirstDayOfCurrentWeek(selectedDate,
        settings[PreferencesFlag.scheduleStartWeekday] as StartingDayOfWeek);
    // We want to put events of previous week and next week in memory to make transitions smoother
    for (int i = -7; i < 14; i++) {
      final date = firstDayOfWeek.add(Duration(days: i));
      final eventsForDay = selectedDateCalendarEvents(date);
      if (eventsForDay.isNotEmpty) {
        events.addAll(eventsForDay);
      }
    }
    return events;
  }

  List<CalendarEventData> selectedMonthCalendarEvents(
      List<Color> scheduleCardsPalette) {
    if (scheduleCardsPalette.isNotEmpty) {
      schedulePaletteTheme = scheduleCardsPalette;
    } else {
      schedulePaletteTheme = AppTheme.schedulePaletteLight.toList();
    }
    final List<CalendarEventData> events = [];

    // The reason why previous month is last is to avoid event colors to start from previous session
    final List<DateTime> months = [DateTime(selectedDate.year, selectedDate.month), DateTime(selectedDate.year, selectedDate.month + 1), DateTime(selectedDate.year, selectedDate.month - 1)];

    final List<DateTime> eventDates = [];
    for (final DateTime month in months) {
      eventDates.addAll(month.datesOfMonths());
    }

    for (int i = 0; i < eventDates.length; i++) {
      final eventsForDay = selectedDateCalendarEvents(eventDates.elementAt(i));
      if (eventsForDay.isNotEmpty) {
        events.addAll(eventsForDay);
      }
    }
    return events;
  }

  bool get showWeekEvents =>
      settings[PreferencesFlag.scheduleShowWeekEvents] as bool;

  bool isLoadingEvents = false;

  bool get calendarViewSetting {
    if (busy(settings)) {
      return false;
    }
    return settings[PreferencesFlag.scheduleListView] as bool;
  }

  @override
  Future<List<CourseActivity>> futureToRun() async {
    loadSettings();
    List<CourseActivity>? activities =
        await _courseRepository.getCoursesActivities(fromCacheOnly: true);
    try {
      setBusyForObject(isLoadingEvents, true);

      final fetchedCourseActivities =
          await _courseRepository.getCoursesActivities();
      if (fetchedCourseActivities != null) {
        activities = fetchedCourseActivities;
        // Reload the list of activities
        coursesActivities;

        courses = await _courseRepository.getCourses(fromCacheOnly: true);

        if (_coursesActivities.isNotEmpty) {
          if (calendarFormat == CalendarFormat.week) {
            calendarEvents = selectedWeekCalendarEvents([]);
          } else {
            calendarEvents = selectedMonthCalendarEvents([]);
          }
        }
      }
      final scheduleActivities =
          await _courseRepository.getScheduleActivities();
      await assignScheduleActivities(scheduleActivities);
    } catch (e) {
      onError(e);
    } finally {
      setBusyForObject(isLoadingEvents, false);
    }
    return activities ?? [];
  }

  Future assignScheduleActivities(
      List<ScheduleActivity> listOfSchedules) async {
    if (listOfSchedules.isEmpty ||
        !listOfSchedules.any((element) =>
            element.activityCode == ActivityCode.labGroupA ||
            element.activityCode == ActivityCode.labGroupB)) return;

    setBusy(true);
    scheduleActivitiesByCourse.clear();
    for (final activity in listOfSchedules) {
      if (activity.activityCode == ActivityCode.labGroupA ||
          activity.activityCode == ActivityCode.labGroupB) {
        // Create the list with the new activity inside or add the activity to an existing group
        if (!scheduleActivitiesByCourse.containsKey(activity.courseAcronym)) {
          scheduleActivitiesByCourse[activity.courseAcronym] = [activity];
        } else {
          scheduleActivitiesByCourse[activity.courseAcronym]?.add(activity);
        }
      }
    }

    await loadSettingsScheduleActivities();
  }

  @override
  // ignore: type_annotate_public_apis
  void onError(error) {
    Fluttertoast.showToast(msg: _appIntl.error);
  }

  Future loadSettings() async {
    setBusyForObject(settings, true);
    settings.clear();
    settings.addAll(await _settingsManager.getScheduleSettings());
    calendarFormat =
        settings[PreferencesFlag.scheduleCalendarFormat] as CalendarFormat;

    await loadSettingsScheduleActivities();

    setBusyForObject(settings, false);
  }

  Future loadSettingsScheduleActivities() async {
    for (final courseAcronym in scheduleActivitiesByCourse.keys) {
      final String? activityCodeToUse = await _settingsManager.getDynamicString(
          PreferencesFlag.scheduleLaboratoryGroup, courseAcronym);
      final scheduleActivityToSet = scheduleActivitiesByCourse[courseAcronym]
          ?.firstWhereOrNull(
              (element) => element.activityCode == activityCodeToUse);
      if (scheduleActivityToSet != null) {
        settingsScheduleActivities[courseAcronym] = scheduleActivityToSet.name;
      } else {
        // All group selected
        settingsScheduleActivities
            .removeWhere((key, value) => key == courseAcronym);
      }

      coursesActivities;
    }
  }

  /// Return the list of all the courses activities arranged by date.
  Map<DateTime, List<CourseActivity>> get coursesActivities {
    _coursesActivities = {};

    // Build the map
    if (_courseRepository.coursesActivities != null) {
      for (final CourseActivity course
          in _courseRepository.coursesActivities!) {
        final DateTime dateOnly = course.startDateTime.subtract(Duration(
            hours: course.startDateTime.hour,
            minutes: course.startDateTime.minute));

        if (!_coursesActivities.containsKey(dateOnly)) {
          _coursesActivities[dateOnly] = [];
        }

        _coursesActivities.update(dateOnly, (value) {
          final scheduleActivitiesContainsGroup = settingsScheduleActivities
              .containsKey(course.courseGroup.split("-").first);

          if (scheduleActivitiesContainsGroup) {
            if (scheduleActivityIsSelected(course)) {
              value.add(course);
            }
          } else {
            value.add(course);
          }

          return value;
        }, ifAbsent: () => [course]);
      }
    }

    _coursesActivities.updateAll((key, value) {
      value.sort((a, b) => a.startDateTime.compareTo(b.startDateTime));

      return value;
    });

    return _coursesActivities;
  }

  bool scheduleActivityIsSelected(CourseActivity course) {
    if (course.activityDescription != ActivityDescriptionName.labA &&
        course.activityDescription != ActivityDescriptionName.labB) {
      return true;
    }

    final activityNameSelected =
        settingsScheduleActivities[course.courseGroup.split("-").first];

    return activityNameSelected == course.activityDescription;
  }

  /// Get the activities for a specific [date], return empty if there is no activity for this [date]
  List<CourseActivity> coursesActivitiesFor(DateTime date) {
    // Populate the _coursesActivities
    if (_coursesActivities.isEmpty) {
      coursesActivities;
    }

    // TODO: maybe use containsKey and put the _courseActivities key to a string...
    DateTime? dateInArray;
    final courseActivitiesContains = _coursesActivities.keys.any((element) {
      dateInArray = element;
      return isSameDay(element, date);
    });
    if (courseActivitiesContains) {
      return _coursesActivities[dateInArray] ?? [];
    }
    return [];

    // List<CourseActivity> activities = [];
    // if (_coursesActivities.containsKey(date)) {
    //   activities = _coursesActivities[date] ?? [];
    // }
    // return activities;
  }

  Future setCalendarFormat(CalendarFormat format) async {
    calendarFormat = format;
    settings[PreferencesFlag.scheduleCalendarFormat] = calendarFormat;
    _settingsManager.setString(PreferencesFlag.scheduleCalendarFormat,
        EnumToString.convertToString(calendarFormat));
  }

  Future<void> refresh() async {
    try {
      setBusyForObject(isLoadingEvents, true);
      await _courseRepository.getCoursesActivities();
      notifyListeners();
    } on Exception catch (error) {
      onError(error);
    } finally {
      setBusyForObject(isLoadingEvents, false);
    }
  }

  /// Set current selected date to today (used by the today button in the view).
  /// Show a toaster instead if the selected date is already today.
  ///
  /// Return true if switched selected date to today (= today was not selected),
  /// return false otherwise (today was already selected, show toast for
  /// visual feedback).
  bool selectToday() {
    if (compareDates(selectedDate, DateTime.now()) &&
        compareDates(focusedDate.value, DateTime.now())) {
      Fluttertoast.showToast(msg: _appIntl.schedule_already_today_toast);
      return false;
    } else {
      selectedDate = DateTime.now();
      focusedDate.value = DateTime.now();
      return true;
    }
  }

  bool selectTodayMonth() {
    if (compareDates(
        selectedDate, DateTime(DateTime.now().year, DateTime.now().month))) {
      Fluttertoast.showToast(msg: _appIntl.schedule_already_today_toast);
      return false;
    } else {
      selectedDate = DateTime(DateTime.now().year, DateTime.now().month);
      focusedDate.value = DateTime(DateTime.now().year, DateTime.now().month);
      return true;
    }
  }

  /// This function is used to compare two dates without taking
  /// into account the time.
  ///
  /// Return true if the dates are the same, false otherwise.
  bool compareDates(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  /// Start Discovery if needed.
  static Future<void> startDiscovery(BuildContext context) async {
    final SettingsManager settingsManager = locator<SettingsManager>();

    if (await settingsManager.getBool(PreferencesFlag.discoverySchedule) ==
        null) {
      if (!context.mounted) return;
      final List<String> ids =
          findDiscoveriesByGroupName(context, DiscoveryGroupIds.pageSchedule)
              .map((e) => e.featureId)
              .toList();

      Future.delayed(const Duration(milliseconds: 700),
          () => FeatureDiscovery.discoverFeatures(context, ids));
    }
  }

  /// Mark the discovery of this view completed
  Future<bool> discoveryCompleted() async {
    await _settingsManager.setBool(PreferencesFlag.discoverySchedule, true);

    return true;
  }
}
