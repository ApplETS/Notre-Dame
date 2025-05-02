// Dart imports:
import 'dart:collection';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:calendar_view/calendar_view.dart';
import 'package:collection/collection.dart';
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
import 'package:notredame/domain/models/progress_bar_text_options.dart';

class DashboardViewModel extends FutureViewModel<Map<PreferencesFlag, int>> {
  static const String tag = "DashboardViewModel";
  static const String abandonedGradeCode = "XX";

  final SettingsRepository _settingsManager = locator<SettingsRepository>();
  final CourseRepository _courseRepository = locator<CourseRepository>();
  final AnalyticsService _analyticsService = locator<AnalyticsService>();
  final RemoteConfigService remoteConfigService = locator<RemoteConfigService>();
  final BroadcastMessageRepository _broadcastMessageRepository = locator<BroadcastMessageRepository>();

  /// All dashboard displayable cards
  Map<PreferencesFlag, int>? _cards;

  /// Localization class of the application.
  final AppIntl _appIntl;

  /// Cards to display on dashboard
  List<PreferencesFlag>? _cardsToDisplay;

  BroadcastMessage? broadcastMessage;

  /// Get progress of the session
  double get progress => _progress;

  List<int> get sessionDays => _sessionDays;

  /// Activities for today
  final List<CourseActivity> _scheduleEvents = [];

  /// Get the list of activities for today
  List<CourseActivity> get scheduleEvents {
    return _scheduleEvents;
  }

  /// Get the status of all displayable cards
  Map<PreferencesFlag, int>? get cards => _cards;

  /// Get cards to display
  List<PreferencesFlag>? get cardsToDisplay => _cardsToDisplay;

  static Future<bool> launchInAppReview() async {
    final PreferencesService preferencesService = locator<PreferencesService>();
    final InAppReviewService inAppReviewService = locator<InAppReviewService>();

    DateTime? ratingTimerFlagDate = await preferencesService.getDateTime(PreferencesFlag.ratingTimer);

    final hasRatingBeenRequested = await preferencesService.getBool(PreferencesFlag.hasRatingBeenRequested) ?? false;

    // If the user is already logged in while doing the update containing the In_App_Review PR.
    if (ratingTimerFlagDate == null) {
      final sevenDaysLater = DateTime.now().add(const Duration(days: 7));
      preferencesService.setDateTime(PreferencesFlag.ratingTimer, sevenDaysLater);
      ratingTimerFlagDate = sevenDaysLater;
    }

    if (await inAppReviewService.isAvailable() &&
        !hasRatingBeenRequested &&
        DateTime.now().isAfter(ratingTimerFlagDate)) {
      await Future.delayed(const Duration(seconds: 2), () async {
        await inAppReviewService.requestReview();
        preferencesService.setBool(PreferencesFlag.hasRatingBeenRequested, value: true);
      });

      return true;
    }
    return false;
  }

  static Future<void> launchBroadcastUrl(String url) async {
    final LaunchUrlService launchUrlService = locator<LaunchUrlService>();
    launchUrlService.launchInBrowser(url);
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
    return Future.wait(
        [futureToRunBroadcast(), futureToRunGrades(), futureToRunSessionProgressBar(), futureToRunSchedule()]);
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
      _settingsManager.setInt(key, key.index - PreferencesFlag.aboutUsCard.index).then((value) {
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
      final orderedCards =
          SplayTreeMap<PreferencesFlag, int>.from(_cards!, (a, b) => _cards![a]!.compareTo(_cards![b]!));

      orderedCards.forEach((key, value) {
        if (value >= 0) {
          _cardsToDisplay?.insert(value, key);
        }
      });
    }

    _analyticsService.logEvent(tag, "Restoring cards");
  }

  Future<List<CourseActivity>> futureToRunSchedule() async {
    try {
      setBusyForObject(scheduleEvents, true);
      scheduleEvents.clear();
      await _courseRepository.getCoursesActivities();

      final now = _settingsManager.dateTimeNow;
      final tomorrow = now.add(const Duration(days: 1)).withoutTime;
      final twoDaysFromNow = now.add(const Duration(days: 2)).withoutTime;

      final courseActivities = _courseRepository.coursesActivities
              ?.where((activity) => activity.endDateTime.isAfter(now) && activity.endDateTime.isBefore(twoDaysFromNow))
              .sorted((a, b) => a.startDateTime.compareTo(b.startDateTime))
              .toList() ??
          [];

      for (final activity in courseActivities) {
        final isToday = now.compareWithoutTime(activity.startDateTime);
        final isTomorrow = activity.startDateTime.withoutTime == tomorrow;

        if ((isToday || isTomorrow) && await _isLaboratoryGroupToAdd(activity)) {
          if (isTomorrow && scheduleEvents.isNotEmpty && scheduleEvents.first.startDateTime.compareWithoutTime(now)) {
            return scheduleEvents;
          }
          scheduleEvents.add(activity);
        }
      }
      return scheduleEvents;
    } catch (error) {
      onError(error);
    } finally {
      setBusyForObject(scheduleEvents, false);
    }
    return [];
  }

  Future<bool> _isLaboratoryGroupToAdd(CourseActivity courseActivity) async {
    final courseKey = courseActivity.courseGroup.split('-').first;

    final activityCodeToUse =
        await _settingsManager.getDynamicString(PreferencesFlag.scheduleLaboratoryGroup, courseKey);

    return activityCodeToUse == ActivityCode.labGroupA
        ? courseActivity.activityDescription != ActivityDescriptionName.labB
        : activityCodeToUse == ActivityCode.labGroupB
            ? courseActivity.activityDescription != ActivityDescriptionName.labA
            : true;
  }

  /// Update cards order and display status in preferences
  void updatePreferences() {
    if (_cards == null || _cardsToDisplay == null) {
      return;
    }
    for (final MapEntry<PreferencesFlag, int> element in _cards!.entries) {
      _cards![element.key] = _cardsToDisplay!.indexOf(element.key);
      _settingsManager.setInt(element.key, _cardsToDisplay!.indexOf(element.key)).then((value) {
        if (!value) {
          Fluttertoast.showToast(msg: _appIntl.error);
        }
      });
    }
  }

  /// Returns true if dates [a] and [b] are on the same day
  bool isSameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

  /// Get the list of courses for the Grades card.
  Future<List<Course>> futureToRunGrades() async {
    if (!busy(courses)) {
      try {
        setBusyForObject(courses, true);
        if (_courseRepository.sessions == null || _courseRepository.sessions!.isEmpty) {
          await _courseRepository.getSessions();
        }

        // Determine current sessions
        if (_courseRepository.activeSessions.isEmpty) {
          return [];
        }
        final currentSession = _courseRepository.activeSessions.first;

        final coursesCached = await _courseRepository.getCourses(fromCacheOnly: true);
        courses.clear();
        for (final Course course in coursesCached) {
          if (course.session == currentSession.shortName && course.grade != abandonedGradeCode) {
            courses.add(course);
          }
        }
        notifyListeners();

        final fetchedCourses = await _courseRepository.getCourses();
        // Update the courses list
        courses.clear();
        for (final Course course in fetchedCourses) {
          if (course.session == currentSession.shortName && course.grade != abandonedGradeCode) {
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
      broadcastMessage = _broadcastMessageRepository.getBroadcastMessage(_appIntl.localeName);
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

    final PreferencesFlag elementMoved = cards!.keys.firstWhere((element) => cards![element] == oldIndex);

    setOrder(elementMoved, newIndex);
  }
}
