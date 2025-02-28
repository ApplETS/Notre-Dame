// Dart imports:
import 'dart:collection';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:stacked/stacked.dart';

// Project imports:
import 'package:notredame/data/models/activity_code.dart';
import 'package:notredame/data/models/broadcast_message.dart';
import 'package:notredame/data/repositories/broadcast_message_repository.dart';
import 'package:notredame/data/repositories/course_repository.dart';
import 'package:notredame/data/repositories/settings_repository.dart';
import 'package:notredame/data/services/analytics_service.dart';
import 'package:notredame/data/services/in_app_review_service.dart';
import 'package:notredame/data/services/launch_url_service.dart';
import 'package:notredame/data/services/preferences_service.dart';
import 'package:notredame/data/services/remote_config_service.dart';
import 'package:notredame/data/services/signets-api/models/course.dart';
import 'package:notredame/data/services/signets-api/models/course_activity.dart';
import 'package:notredame/data/services/signets-api/models/session.dart';
import 'package:notredame/domain/constants/preferences_flags.dart';
import 'package:notredame/locator.dart';
import 'package:notredame/ui/dashboard/view_model/progress_bar_text_options.dart';

class DashboardViewModel extends FutureViewModel<Map<PreferencesFlag, int>> {
  static const String tag = "DashboardViewModel";

  final SettingsRepository _settingsManager = locator<SettingsRepository>();
  final CourseRepository _courseRepository = locator<CourseRepository>();
  final AnalyticsService _analyticsService = locator<AnalyticsService>();
  final RemoteConfigService remoteConfigService =
      locator<RemoteConfigService>();
  final BroadcastMessageRepository _broadcastMessageRepository =
      locator<BroadcastMessageRepository>();

  /// All dashboard displayable cards
  Map<PreferencesFlag, int>? _cards;

  /// Localization class of the application.
  final AppIntl _appIntl;

  /// Cards to display on dashboard
  List<PreferencesFlag>? _cardsToDisplay;

  /// Percentage of completed days for the session
  double _progress = 0.0;

  /// Numbers of days elapsed and total number of days of the current session
  List<int> _sessionDays = [0, 0];

  BroadcastMessage? broadcastMessage;

  /// Get progress of the session
  double get progress => _progress;

  List<int> get sessionDays => _sessionDays;

  /// Activities for today
  List<CourseActivity> _todayDateEvents = [];

  /// Get the list of activities for today
  List<CourseActivity> get todayDateEvents {
    return _todayDateEvents;
  }

  // Activities for tomorrow
  List<CourseActivity> _tomorrowDateEvents = [];

  /// Get the list of activities for tomorrow
  List<CourseActivity> get tomorrowDateEvents {
    return _tomorrowDateEvents;
  }

  /// Get the status of all displayable cards
  Map<PreferencesFlag, int>? get cards => _cards;

  /// Get cards to display
  List<PreferencesFlag>? get cardsToDisplay => _cardsToDisplay;

  ProgressBarText _currentProgressBarText =
      ProgressBarText.daysElapsedWithTotalDays;

  /// Return session progress based on today's [date]
  double getSessionProgress() {
    if (_courseRepository.activeSessions.isEmpty) {
      return -1.0;
    } else {
      return sessionDays[0] / sessionDays[1];
    }
  }

  static Future<bool> launchInAppReview() async {
    final PreferencesService preferencesService = locator<PreferencesService>();
    final InAppReviewService inAppReviewService = locator<InAppReviewService>();

    DateTime? ratingTimerFlagDate =
        await preferencesService.getDateTime(PreferencesFlag.ratingTimer);

    final hasRatingBeenRequested = await preferencesService
            .getBool(PreferencesFlag.hasRatingBeenRequested) ??
        false;

    // If the user is already logged in while doing the update containing the In_App_Review PR.
    if (ratingTimerFlagDate == null) {
      final sevenDaysLater = DateTime.now().add(const Duration(days: 7));
      preferencesService.setDateTime(
          PreferencesFlag.ratingTimer, sevenDaysLater);
      ratingTimerFlagDate = sevenDaysLater;
    }

    if (await inAppReviewService.isAvailable() &&
        !hasRatingBeenRequested &&
        DateTime.now().isAfter(ratingTimerFlagDate)) {
      await Future.delayed(const Duration(seconds: 2), () async {
        await inAppReviewService.requestReview();
        preferencesService.setBool(PreferencesFlag.hasRatingBeenRequested,
            value: true);
      });

      return true;
    }
    return false;
  }

  static Future<void> launchBroadcastUrl(String url) async {
    final LaunchUrlService launchUrlService = locator<LaunchUrlService>();
    launchUrlService.launchInBrowser(url);
  }

  void changeProgressBarText() {
    if (_currentProgressBarText.index <= 1) {
      _currentProgressBarText =
          ProgressBarText.values[_currentProgressBarText.index + 1];
    } else {
      _currentProgressBarText = ProgressBarText.values[0];
    }

    notifyListeners();
    _settingsManager.setString(
        PreferencesFlag.progressBarText, _currentProgressBarText.toString());
  }

  /// Returns a list containing the number of elapsed days in the active session
  /// and the total number of days in the session
  List<int> getSessionDays() {
    if (_courseRepository.activeSessions.isEmpty) {
      return [0, 0];
    } else {
      int dayCompleted = _settingsManager.dateTimeNow
          .difference(_courseRepository.activeSessions.first.startDate)
          .inDays;
      final dayInTheSession = _courseRepository.activeSessions.first.endDate
          .difference(_courseRepository.activeSessions.first.startDate)
          .inDays;

      if (dayCompleted > dayInTheSession) {
        dayCompleted = dayInTheSession;
      } else if (dayCompleted < 0) {
        dayCompleted = 0;
      }

      return [dayCompleted, dayInTheSession];
    }
  }

  /// List of courses for the current session
  List<Course> courses = [];

  DashboardViewModel({required AppIntl intl}) : _appIntl = intl;

  @override
  Future<Map<PreferencesFlag, int>> futureToRun() async {
    _cards = await _settingsManager.getDashboard();

    getCardsToDisplay();

    await loadDataAndUpdateWidget();

    return _cards!;
  }

  Future loadDataAndUpdateWidget() async {
    return Future.wait([
      futureToRunBroadcast(),
      futureToRunGrades(),
      futureToRunSessionProgressBar(),
      futureToRunSchedule()
    ]);
  }

  @override
  // ignore: type_annotate_public_apis
  void onError(error) {
    Fluttertoast.showToast(msg: _appIntl.error);
  }

  /// Change the order of [flag] card from [oldIndex] to [newIndex].
  void setOrder(PreferencesFlag flag, int newIndex) {
    _cardsToDisplay?.remove(flag);
    _cardsToDisplay?.insert(newIndex, flag);

    updatePreferences();

    notifyListeners();

    _analyticsService.logEvent(tag, "Reordoring ${flag.name}");
  }

  /// Hide [flag] card from dashboard by setting int value -1
  void hideCard(PreferencesFlag flag) {
    _cards?.update(flag, (value) => -1);

    _cardsToDisplay?.remove(flag);

    updatePreferences();

    notifyListeners();

    _analyticsService.logEvent(tag, "Deleting ${flag.name}");
  }

  /// Reset all card indexes to their default values
  void setAllCardsVisible() {
    _cards?.updateAll((key, value) {
      _settingsManager
          .setInt(key, key.index - PreferencesFlag.aboutUsCard.index)
          .then((value) {
        if (!value) {
          Fluttertoast.showToast(msg: _appIntl.error);
        }
      });
      return key.index - PreferencesFlag.aboutUsCard.index;
    });

    getCardsToDisplay();

    loadDataAndUpdateWidget();

    notifyListeners();
  }

  /// Populate list of cards used in view
  void getCardsToDisplay() {
    _cardsToDisplay = [];

    if (_cards != null) {
      final orderedCards = SplayTreeMap<PreferencesFlag, int>.from(
          _cards!, (a, b) => _cards![a]!.compareTo(_cards![b]!));

      orderedCards.forEach((key, value) {
        if (value >= 0) {
          _cardsToDisplay?.insert(value, key);
        }
      });
    }

    _analyticsService.logEvent(tag, "Restoring cards");
  }

  Future<List<Session>> futureToRunSessionProgressBar() async {
    try {
      final progressBarText =
          await _settingsManager.getString(PreferencesFlag.progressBarText) ??
              ProgressBarText.daysElapsedWithTotalDays.toString();

      _currentProgressBarText = ProgressBarText.values
          .firstWhere((e) => e.toString() == progressBarText);

      setBusyForObject(progress, true);
      final sessions = await _courseRepository.getSessions();
      _sessionDays = getSessionDays();
      _progress = getSessionProgress();
      return sessions;
    } catch (error) {
      onError(error);
    } finally {
      setBusyForObject(progress, false);
    }
    return [];
  }

  Future<List<CourseActivity>> futureToRunSchedule() async {
    setBusyForObject(_todayDateEvents, true);
    setBusyForObject(_tomorrowDateEvents, true);
    try {
      var courseActivities =
          await _courseRepository.getCoursesActivities(fromCacheOnly: true);
      _todayDateEvents.clear();
      _tomorrowDateEvents.clear();
      final todayDate = _settingsManager.dateTimeNow;
      courseActivities = await _courseRepository.getCoursesActivities();

      if (_courseRepository.coursesActivities != null) {
        final DateTime tomorrowDate = todayDate.add(const Duration(days: 1));
        // Build the list
        for (final CourseActivity course
            in _courseRepository.coursesActivities!) {
          final DateTime dateOnly = course.startDateTime;
          if (isSameDay(todayDate, dateOnly) &&
              todayDate.compareTo(course.endDateTime) < 0) {
            _todayDateEvents.add(course);
          } else if (isSameDay(tomorrowDate, dateOnly)) {
            _tomorrowDateEvents.add(course);
          }
        }
      }

      _todayDateEvents
          .sort((a, b) => a.startDateTime.compareTo(b.startDateTime));
      _tomorrowDateEvents
          .sort((a, b) => a.startDateTime.compareTo(b.startDateTime));

      _todayDateEvents = await removeLaboratoryGroup(_todayDateEvents);
      _tomorrowDateEvents = await removeLaboratoryGroup(_tomorrowDateEvents);
      return courseActivities ?? [];
    } catch (error) {
      onError(error);
    } finally {
      setBusyForObject(_todayDateEvents, false);
      setBusyForObject(_tomorrowDateEvents, false);
    }
    return [];
  }

  Future<List<CourseActivity>> removeLaboratoryGroup(
      List<CourseActivity> todayDateEvents) async {
    final List<CourseActivity> todayDateEventsCopy = List.from(todayDateEvents);

    for (final courseAcronym in todayDateEvents) {
      final courseKey = courseAcronym.courseGroup.split('-')[0];

      final String? activityCodeToUse = await _settingsManager.getDynamicString(
          PreferencesFlag.scheduleLaboratoryGroup, courseKey);

      if (activityCodeToUse == ActivityCode.labGroupA) {
        todayDateEventsCopy.removeWhere((element) =>
            element.activityDescription == ActivityDescriptionName.labB &&
            element.courseGroup == courseAcronym.courseGroup);
      } else if (activityCodeToUse == ActivityCode.labGroupB) {
        todayDateEventsCopy.removeWhere((element) =>
            element.activityDescription == ActivityDescriptionName.labA &&
            element.courseGroup == courseAcronym.courseGroup);
      }
    }

    return todayDateEventsCopy;
  }

  /// Update cards order and display status in preferences
  void updatePreferences() {
    if (_cards == null || _cardsToDisplay == null) {
      return;
    }
    for (final MapEntry<PreferencesFlag, int> element in _cards!.entries) {
      _cards![element.key] = _cardsToDisplay!.indexOf(element.key);
      _settingsManager
          .setInt(element.key, _cardsToDisplay!.indexOf(element.key))
          .then((value) {
        if (!value) {
          Fluttertoast.showToast(msg: _appIntl.error);
        }
      });
    }
  }

  /// Returns true if dates [a] and [b] are on the same day
  bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  /// Get the list of courses for the Grades card.
  Future<List<Course>> futureToRunGrades() async {
    if (!busy(courses)) {
      try {
        setBusyForObject(courses, true);
        if (_courseRepository.sessions == null ||
            _courseRepository.sessions!.isEmpty) {
          await _courseRepository.getSessions();
        }

        // Determine current sessions
        if (_courseRepository.activeSessions.isEmpty) {
          return [];
        }
        final currentSession = _courseRepository.activeSessions.first;

        final coursesCached =
            await _courseRepository.getCourses(fromCacheOnly: true);
        courses.clear();
        for (final Course course in coursesCached) {
          if (course.session == currentSession.shortName) {
            courses.add(course);
          }
        }
        notifyListeners();

        final fetchedCourses = await _courseRepository.getCourses();
        // Update the courses list
        courses.clear();
        for (final Course course in fetchedCourses) {
          if (course.session == currentSession.shortName) {
            courses.add(course);
          }
        }
        // Will remove duplicated courses in the list
        courses = courses.toSet().toList();
      } catch (error) {
        onError(error);
      } finally {
        setBusyForObject(courses, false);
      }
    }
    return courses;
  }

  Future<void> futureToRunBroadcast() async {
    setBusyForObject(broadcastMessage, true);

    try {
      broadcastMessage =
          _broadcastMessageRepository.getBroadcastMessage(_appIntl.localeName);
    } catch (error) {
      onError(error);
    } finally {
      setBusyForObject(broadcastMessage, false);
    }
  }

  void onCardReorder(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      // ignore: parameter_assignments
      newIndex -= 1;
    }

    // Should not happen becase dismiss card will not be called if the card is null.
    if (cards == null) {
      _analyticsService.logError("DashboardView", "Cards list is null");
      throw Exception("Cards is null");
    }

    final PreferencesFlag elementMoved =
        cards!.keys.firstWhere((element) => cards![element] == oldIndex);

    setOrder(elementMoved, newIndex);
  }

  String setProgressBarText(BuildContext context) {
    switch (_currentProgressBarText) {
      case ProgressBarText.daysElapsedWithTotalDays:
        _currentProgressBarText = ProgressBarText.daysElapsedWithTotalDays;
        return AppIntl.of(context)!
            .progress_bar_message(sessionDays[0], sessionDays[1]);
      case ProgressBarText.percentage:
        _currentProgressBarText = ProgressBarText.percentage;
        final percentage = sessionDays[1] == 0
            ? 0
            : ((sessionDays[0] / sessionDays[1]) * 100).round();
        return AppIntl.of(context)!.progress_bar_message_percentage(percentage);
      default:
        _currentProgressBarText = ProgressBarText.remainingDays;
        return AppIntl.of(context)!.progress_bar_message_remaining_days(
            sessionDays[1] - sessionDays[0]);
    }
  }
}
