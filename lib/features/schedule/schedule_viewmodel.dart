// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:calendar_view/calendar_view.dart';
import 'package:collection/collection.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:notredame/theme/app_palette.dart';
import 'package:stacked/stacked.dart';
import 'package:table_calendar/table_calendar.dart';

// Project imports:
import 'package:notredame/constants/preferences_flags.dart';
import 'package:notredame/features/app/repository/course_repository.dart';
import 'package:notredame/features/app/signets-api/models/course.dart';
import 'package:notredame/features/app/signets-api/models/course_activity.dart';
import 'package:notredame/features/app/signets-api/models/schedule_activity.dart';
import 'package:notredame/features/more/settings/settings_manager.dart';
import 'package:notredame/utils/activity_code.dart';
import 'package:notredame/utils/locator.dart';
import 'package:notredame/utils/utils.dart';
import 'package:notredame/utils/calendar_utils.dart';

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

  /// Day currently selected (in week or month view)
  DateTime weekSelected = Utils.getFirstDayOfCurrentWeek(DateTime.now());

  /// Day currently focused on (day view only)
  DateTime daySelected = DateTime.now().withoutTime;
  // Allows to check if table calendar on top of the screen displays current week
  DateTime listViewCalendarSelectedDate = DateTime.now().withoutTime;

  /// List of currently loaded events
  List<CalendarEventData> calendarEvents = [];

  /// The currently selected CalendarTimeFormat, A default value is set for test purposes.
  /// This value is then change to the cache value on load.
  CalendarTimeFormat calendarFormat = CalendarTimeFormat.week;

  /// This map contains the courses that has the group A or group B mark
  final Map<String, List<ScheduleActivity>> scheduleActivitiesByCourse = {};

  /// This map contains the direct settings as string for each course that are grouped
  /// (Example: (key, value) => ("ING150", "Laboratoire (Groupe A)"))
  final Map<String, String> settingsScheduleActivities = {};

  /// A map that contains a color from the AppTheme.SchedulePalette palette associated with each course.
  final Map<String, Color> courseColors = {};

  /// The color palette corresponding to the schedule courses.
  List<Color> schedulePaletteTheme = AppPalette.schedule.toList();

  /// In calendar view (week), display weekend days if there are events in them
  bool displaySunday = false;
  bool displaySaturday = false;

  /// Get current locale
  Locale? get locale => _settingsManager.locale;

  ScheduleViewModel({required AppIntl intl})
      : _appIntl = intl;

  /// Activities for the day currently selected
  List<dynamic> selectedDateEvents(DateTime date) =>
      _coursesActivities[DateTime(date.year, date.month, date.day)] ?? [];

  Map<DateTime, List<dynamic>> selectedWeekEvents() {
    final Map<DateTime, List<dynamic>> events = {};
    final firstDayOfWeek = Utils.getFirstDayOfCurrentWeek(weekSelected);
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
    if (calendarFormat != CalendarTimeFormat.day) {
      // As a student, if I open my schedule a saturday (and I have no course today), I want to see next week's shedule
      if (date.weekday == DateTime.saturday && selectedDateEvents(date).isEmpty) {
        // Add extra hour to fix a bug related to daylight saving time changes
        weekSelected = weekSelected.add(const Duration(days: 7, hours: 1)).withoutTime;
      } else {
        weekSelected = Utils.getFirstDayOfCurrentWeek(date);
      }
      displaySunday = selectedDateEvents(weekSelected).isNotEmpty;
      displaySaturday = selectedDateEvents(weekSelected.add(const Duration(days: 6, hours: 1))).isNotEmpty;
    }
    else {
      daySelected = date;
    }

    controller.removeWhere((event) => true);

    List<CalendarEventData> eventsToAdd = [];
    if (calendarFormat == CalendarTimeFormat.month) {
      eventsToAdd = selectedMonthCalendarEvents();
    }
    else {
      eventsToAdd = selectedWeekCalendarEvents();
    }
    controller.addAll(eventsToAdd);
  }

  List<CalendarEventData> selectedDateCalendarEvents(DateTime date) {
    return _coursesActivities[date.withoutTime]
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
    return courseColors[courseName] ?? AppPalette.etsLightRed;
  }

  List<CalendarEventData> selectedWeekCalendarEvents() {
    final List<CalendarEventData> events = [];

    final firstDayOfWeek = Utils.getFirstDayOfCurrentWeek(weekSelected);
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

  List<CalendarEventData> selectedDayCalendarEvents() {
    final List<CalendarEventData> events = [];
    for (int i = -1; i <= 1; i++) {
      events.addAll(selectedDateCalendarEvents(daySelected.add(Duration(days: i))));
    }
    return events;
  }

  List<CalendarEventData> selectedMonthCalendarEvents() {

    final List<CalendarEventData> events = [];

    // Month view displays last week of last month, this accounts for that (additionnal hour is for the edge case of time changes)
    final dateInSelectedMonth = weekSelected.add(const Duration(days: 7, hours: 1));
    final selectedMonth = DateTime(dateInSelectedMonth.year, dateInSelectedMonth.month);

    // The reason why previous month is last is to avoid event colors to start from previous session
    final List<DateTime> months = [selectedMonth, DateTime(selectedMonth.year, selectedMonth.month + 1), DateTime(selectedMonth.year, selectedMonth.month - 1)];

    // For each day in each month, add events
    for (final DateTime month in months) {
      for (final DateTime day in month.datesOfMonths()) {
        final eventsForDay = selectedDateCalendarEvents(day);
        if (eventsForDay.isNotEmpty) {
          events.addAll(eventsForDay);
        }
      }
    }
    return events;
  }

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
          if (calendarFormat == CalendarTimeFormat.week) {
            calendarEvents = selectedWeekCalendarEvents();
          } else {
            calendarEvents = selectedMonthCalendarEvents();
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
            element.activityCode == ActivityCode.labGroupB)) {
      return;
    }

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
        settings[PreferencesFlag.scheduleCalendarFormat] as CalendarTimeFormat;

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

  Future setCalendarFormat(CalendarTimeFormat format) async {
    calendarFormat = format;
    settings[PreferencesFlag.scheduleCalendarFormat] = calendarFormat;
    _settingsManager.setString(PreferencesFlag.scheduleCalendarFormat,
        calendarFormat.name);
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
    if (calendarFormat == CalendarTimeFormat.day) {
      return selectTodayDayView();
    }
    if (calendarFormat == CalendarTimeFormat.month) {
      return selectTodayMonthView();
    }
    return selectTodayWeekView();
  }

  bool selectTodayDayView() {
    final bool isTodaySelected = listViewCalendarSelectedDate.withoutTime == DateTime.now().withoutTime &&
        DateTime.now().withoutTime == daySelected.withoutTime;

    isTodaySelected
        ? Fluttertoast.showToast(msg: _appIntl.schedule_already_today_toast)
        : daySelected = listViewCalendarSelectedDate = DateTime.now().withoutTime;

    return !isTodaySelected;
  }

  bool selectTodayWeekView() {
    final bool isThisWeekSelected = weekSelected == Utils.getFirstDayOfCurrentWeek(DateTime.now());

    isThisWeekSelected
        ? Fluttertoast.showToast(msg: _appIntl.schedule_already_today_toast)
        : weekSelected = Utils.getFirstDayOfCurrentWeek(DateTime.now());

    return !isThisWeekSelected;
  }

  bool selectTodayMonthView() {
    final DateTime currentMonth = DateTime(DateTime.now().year, DateTime.now().month);
    final bool isThisMonthSelected = weekSelected.month == currentMonth.month && weekSelected.year == currentMonth.year;

    isThisMonthSelected
        ? Fluttertoast.showToast(msg: _appIntl.schedule_already_today_toast)
        : weekSelected = currentMonth;

    return !isThisMonthSelected;
  }
}
