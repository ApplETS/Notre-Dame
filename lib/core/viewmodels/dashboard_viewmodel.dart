// FLUTTER / DART / THIRD-PARTIES
import 'dart:collection';
import 'package:feature_discovery/feature_discovery.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:stacked/stacked.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// CONSTANTS
import 'package:notredame/core/constants/preferences_flags.dart';
import 'package:notredame/core/constants/discovery_ids.dart';
import 'package:notredame/core/constants/progress_bar_text_options.dart';
import 'package:notredame/core/constants/update_code.dart';
import 'package:notredame/core/constants/widget_helper.dart';

// MANAGER / SERVICE
import 'package:notredame/core/managers/settings_manager.dart';
import 'package:notredame/core/managers/course_repository.dart';
import 'package:notredame/core/services/in_app_review_service.dart';
import 'package:notredame/core/services/siren_flutter_service.dart';
import 'package:notredame/core/services/preferences_service.dart';
import 'package:notredame/core/services/analytics_service.dart';
import 'package:notredame/core/services/app_widget_service.dart';
import 'package:notredame/core/services/remote_config_service.dart';

// MODEL
import 'package:notredame/core/models/widget_models.dart';
import 'package:ets_api_clients/models.dart';

// UTILS
import 'package:notredame/ui/utils/discovery_components.dart';

// OTHER
import 'package:notredame/locator.dart';

class DashboardViewModel extends FutureViewModel<Map<PreferencesFlag, int>> {
  static const String tag = "DashboardViewModel";

  final SettingsManager _settingsManager = locator<SettingsManager>();
  final PreferencesService _preferencesService = locator<PreferencesService>();
  final CourseRepository _courseRepository = locator<CourseRepository>();
  final AnalyticsService _analyticsService = locator<AnalyticsService>();
  final AppWidgetService _appWidgetService = locator<AppWidgetService>();
  final RemoteConfigService remoteConfigService =
      locator<RemoteConfigService>();

  /// All dashboard displayable cards
  Map<PreferencesFlag, int> _cards;

  /// Localization class of the application.
  final AppIntl _appIntl;

  /// Update code that must be used to prompt user for update if necessary.
  UpdateCode updateCode;

  /// Cards to display on dashboard
  List<PreferencesFlag> _cardsToDisplay;

  /// Percentage of completed days for the session
  double _progress = 0.0;

  /// Numbers of days elapsed and total number of days of the current session
  List<int> _sessionDays = [0, 0];

  /// Message to display in case of urgent/important broadcast need (Firebase
  /// remote config), and the associated card title
  String broadcastMessage = "";
  String broadcastTitle = "";
  String broadcastColor = "";
  String broadcastUrl = "";
  String broadcastType = "";

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
  Map<PreferencesFlag, int> get cards => _cards;

  /// Get cards to display
  List<PreferencesFlag> get cardsToDisplay => _cardsToDisplay;

  ProgressBarText _currentProgressBarText =
      ProgressBarText.daysElapsedWithTotalDays;

  ProgressBarText get currentProgressBarText => _currentProgressBarText;

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

    DateTime ratingTimerFlagDate =
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

  void changeProgressBarText() {
    if (currentProgressBarText.index <= 1) {
      _currentProgressBarText =
          ProgressBarText.values[currentProgressBarText.index + 1];
    } else {
      _currentProgressBarText = ProgressBarText.values[0];
    }

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
  final List<Course> courses = [];

  DashboardViewModel({@required AppIntl intl}) : _appIntl = intl;

  @override
  Future<Map<PreferencesFlag, int>> futureToRun() async {
    final dashboard = await _settingsManager.getDashboard();

    _cards = dashboard;

    await checkForBroadcastChange();

    getCardsToDisplay();

    // load data for both grade cards & grades home screen widget
    // (moved from getCardsToDisplay())
    await loadDataAndUpdateWidget();

    return dashboard;
  }

  Future loadDataAndUpdateWidget() async {
    return Future.wait([
      futureToRunBroadcast(),
      futureToRunGrades(),
      futureToRunSessionProgressBar(),
      futureToRunSchedule()
    ]).then((_) {
      updateGradesWidget();
      updateProgressWidget();
    });
  }

  Future updateProgressWidget() async {
    try {
      final progress = _progress;
      final sessionDays = _sessionDays;
      final elapsedDays = sessionDays[0];
      final totalDays = sessionDays[1];

      await _appWidgetService.sendProgressData(ProgressWidgetData(
          title: _appIntl.progress_bar_title,
          progress: progress,
          elapsedDays: elapsedDays,
          totalDays: totalDays,
          suffix: _appIntl.progress_bar_suffix));
      await _appWidgetService.updateWidget(WidgetType.progress);
    } on Exception catch (e) {
      _analyticsService.logError(tag, e.toString());
    }
  }

  /// Update grades widget with current courses data
  /// MUST be called after futureToRunGrades() completed (uses courses object)
  Future updateGradesWidget() async {
    try {
      final List<String> acronyms =
          courses.map((course) => course.acronym).toList();
      final List<String> grades = courses.map((course) {
        // Code copied from GradeButton.gradeString
        if (course.grade != null) {
          return course.grade;
        } else if (course.summary != null &&
            course.summary.markOutOf > 0 &&
            !(course.inReviewPeriod && !course.reviewCompleted)) {
          return _appIntl.grades_grade_in_percentage(
              course.summary.currentMarkInPercent.round());
        }
        return _appIntl.grades_not_available;
      }).toList();

      await _appWidgetService.sendGradesData(GradesWidgetData(
          title:
              "${_appIntl.grades_title} - ${_courseRepository.activeSessions.first.shortName ?? _appIntl.session_without}",
          courseAcronyms: acronyms,
          grades: grades));
      await _appWidgetService.updateWidget(WidgetType.grades);
    } on Exception catch (e) {
      _analyticsService.logError(tag, e.toString());
    }
  }

  @override
  // ignore: type_annotate_public_apis
  void onError(error) {
    Fluttertoast.showToast(msg: _appIntl.error);
  }

  /// Change the order of [flag] card from [oldIndex] to [newIndex].
  void setOrder(PreferencesFlag flag, int newIndex) {
    _cardsToDisplay.remove(flag);
    _cardsToDisplay.insert(newIndex, flag);

    updatePreferences();

    notifyListeners();

    _analyticsService.logEvent(tag, "Reordoring ${flag.name}");
  }

  /// Hide [flag] card from dashboard by setting int value -1
  void hideCard(PreferencesFlag flag) {
    _cards.update(flag, (value) => -1);

    _cardsToDisplay.remove(flag);

    updatePreferences();

    notifyListeners();

    _analyticsService.logEvent(tag, "Deleting ${flag.name}");
  }

  /// Reset all card indexes to their default values
  void setAllCardsVisible() {
    _cards.updateAll((key, value) {
      _settingsManager
          .setInt(key, key.index - PreferencesFlag.broadcastCard.index)
          .then((value) {
        if (!value) {
          Fluttertoast.showToast(msg: _appIntl.error);
        }
      });
      return key.index - PreferencesFlag.broadcastCard.index;
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
          _cards, (a, b) => _cards[a].compareTo(_cards[b]));

      orderedCards.forEach((key, value) {
        if (value >= 0) {
          _cardsToDisplay.insert(value, key);
        }
      });
    }

    _analyticsService.logEvent(tag, "Restoring cards");
  }

  Future<void> checkForBroadcastChange() async {
    final broadcastChange =
        await _preferencesService.getString(PreferencesFlag.broadcastChange) ??
            "";
    if (broadcastChange != remoteConfigService.dashboardMessageEn) {
      // Update pref
      _preferencesService.setString(PreferencesFlag.broadcastChange,
          remoteConfigService.dashboardMessageEn);
      if (_cards[PreferencesFlag.broadcastCard] < 0) {
        _cards.updateAll((key, value) {
          if (value >= 0) {
            return value + 1;
          } else {
            return value;
          }
        });
        _cards[PreferencesFlag.broadcastCard] = 0;
      }
    }
  }

  Future<List<Session>> futureToRunSessionProgressBar() async {
    String progressBarText =
        await _settingsManager.getString(PreferencesFlag.progressBarText);

    progressBarText ??= ProgressBarText.daysElapsedWithTotalDays.toString();

    _currentProgressBarText = ProgressBarText.values
        .firstWhere((e) => e.toString() == progressBarText);

    setBusyForObject(progress, true);
    return _courseRepository
        .getSessions()
        // ignore: invalid_return_type_for_catch_error
        .catchError(onError)
        .whenComplete(() {
      _sessionDays = getSessionDays();
      _progress = getSessionProgress();
      setBusyForObject(progress, false);
    });
  }

  Future<List<CourseActivity>> futureToRunSchedule() async {
    return _courseRepository
        .getCoursesActivities(fromCacheOnly: true)
        .then((value) {
      setBusyForObject(_todayDateEvents, true);
      setBusyForObject(_tomorrowDateEvents, true);
      _todayDateEvents.clear();
      _tomorrowDateEvents.clear();

      final todayDate = _settingsManager.dateTimeNow;
      _courseRepository
          .getCoursesActivities()
          // ignore: return_type_invalid_for_catch_error
          .catchError(onError)
          .whenComplete(() async {
        if (_todayDateEvents.isEmpty) {
          final DateTime tomorrowDate = todayDate.add(const Duration(days: 1));
          // Build the list
          for (final CourseActivity course
              in _courseRepository.coursesActivities) {
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

        setBusyForObject(_todayDateEvents, false);
        setBusyForObject(_tomorrowDateEvents, false);
      });

      return value;
    });
  }

  Future<List<CourseActivity>> removeLaboratoryGroup(
      List<CourseActivity> todayDateEvents) async {
    final List<CourseActivity> todayDateEventsCopy = List.from(todayDateEvents);

    for (final courseAcronym in todayDateEvents) {
      final courseKey = courseAcronym.courseGroup.split('-')[0];

      final String activityCodeToUse = await _settingsManager.getDynamicString(
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
    for (final MapEntry<PreferencesFlag, int> element in _cards.entries) {
      _cards[element.key] = _cardsToDisplay.indexOf(element.key);
      _settingsManager
          .setInt(element.key, _cardsToDisplay.indexOf(element.key))
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

  /// Start discovery is needed
  static Future<void> startDiscovery(BuildContext context) async {
    final SettingsManager settingsManager = locator<SettingsManager>();
    if (await settingsManager.getBool(PreferencesFlag.discoveryDashboard) ==
        null) {
      final List<String> ids =
          findDiscoveriesByGroupName(context, DiscoveryGroupIds.bottomBar)
              .map((e) => e.featureId)
              .toList();

      FeatureDiscovery.discoverFeatures(context, ids);
    }
  }

  /// Mark as complete the discovery step
  Future<bool> discoveryCompleted() async {
    await _settingsManager.setBool(PreferencesFlag.discoveryDashboard, true);

    return true;
  }

  /// Get the list of courses for the Grades card.
  // ignore: missing_return
  Future<List<Course>> futureToRunGrades() async {
    if (!busy(courses)) {
      setBusyForObject(courses, true);
      if (_courseRepository.sessions == null ||
          _courseRepository.sessions.isEmpty) {
        // ignore: return_type_invalid_for_catch_error
        await _courseRepository.getSessions().catchError(onError);
      }

      // Determine current sessions
      if (_courseRepository.activeSessions.isEmpty) {
        setBusyForObject(courses, false);
        return [];
      }
      final currentSession = _courseRepository.activeSessions.first;

      return _courseRepository.getCourses(fromCacheOnly: true).then(
          (coursesCached) {
        courses.clear();
        for (final Course course in coursesCached) {
          if (course.session == currentSession.shortName) {
            courses.add(course);
          }
        }
        notifyListeners();
        // ignore: return_type_invalid_for_catch_error
        _courseRepository.getCourses().catchError(onError).then((value) {
          if (value != null) {
            // Update the courses list
            courses.clear();
            for (final Course course in value) {
              if (course.session == currentSession.shortName) {
                courses.add(course);
              }
            }
          }
        }).whenComplete(() {
          setBusyForObject(courses, false);
        });

        return courses;
      }, onError: onError);
    }
  }

  /// Prompt the update for the app if the navigation service arguments passed
  /// is not none. When [UpdateCode] is forced, the user will be force to update.
  /// If [UpdateCode] is not forced, the user will be prompted to update.
  static Future<void> promptUpdate(
      BuildContext context, UpdateCode updateCode) async {
    if (updateCode != null && updateCode != UpdateCode.none) {
      final appIntl = AppIntl.of(context);

      bool isAForcedUpdate = false;
      String message = '';
      switch (updateCode) {
        case UpdateCode.force:
          isAForcedUpdate = true;
          message = appIntl.update_version_message_force;
          break;
        case UpdateCode.ask:
          isAForcedUpdate = false;
          message = appIntl.update_version_message;
          break;
        case UpdateCode.none:
          return;
      }
      final prefService = locator<PreferencesService>();
      final sirenService = locator<SirenFlutterService>();

      final storeVersion = await sirenService.storeVersion;

      final versionStoredInPrefs =
          await prefService.getString(PreferencesFlag.updateAskedVersion);

      if (versionStoredInPrefs != storeVersion.toString()) {
        // ignore: use_build_context_synchronously
        await sirenService.promptUpdate(context,
            title: appIntl.update_version_title,
            message: message,
            buttonUpgradeText: appIntl.update_version_button_text,
            buttonCancelText: appIntl.close_button_text,
            forceUpgrade: isAForcedUpdate);
      }
      prefService.setString(
          PreferencesFlag.updateAskedVersion, storeVersion.toString());
    }
  }

  Future<void> futureToRunBroadcast() async {
    setBusyForObject(broadcastMessage, true);
    setBusyForObject(broadcastTitle, true);
    setBusyForObject(broadcastColor, true);
    setBusyForObject(broadcastUrl, true);
    setBusyForObject(broadcastType, true);

    if (_appIntl.localeName == "fr") {
      broadcastMessage = remoteConfigService.dashboardMessageFr;
      broadcastTitle = remoteConfigService.dashboardMessageTitleFr;
    } else {
      broadcastMessage = remoteConfigService.dashboardMessageEn;
      broadcastTitle = remoteConfigService.dashboardMessageTitleEn;
    }
    broadcastColor = remoteConfigService.dashboardMsgColor;
    broadcastUrl = remoteConfigService.dashboardMsgUrl;
    broadcastType = remoteConfigService.dashboardMsgType;

    setBusyForObject(broadcastMessage, false);
    setBusyForObject(broadcastTitle, false);
    setBusyForObject(broadcastColor, false);
    setBusyForObject(broadcastUrl, false);
    setBusyForObject(broadcastType, false);
  }
}
