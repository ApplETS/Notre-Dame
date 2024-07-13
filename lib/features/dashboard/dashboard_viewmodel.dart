// Dart imports:
import 'dart:collection';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:feature_discovery/feature_discovery.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stacked/stacked.dart';

// Project imports:
import 'package:notredame/constants/preferences_flags.dart';
import 'package:notredame/constants/update_code.dart';
import 'package:notredame/constants/widget_helper.dart';
import 'package:notredame/features/app/analytics/analytics_service.dart';
import 'package:notredame/features/app/analytics/remote_config_service.dart';
import 'package:notredame/features/app/integration/launch_url_service.dart';
import 'package:notredame/features/app/navigation/navigation_service.dart';
import 'package:notredame/features/app/navigation/router_paths.dart';
import 'package:notredame/features/app/repository/course_repository.dart';
import 'package:notredame/features/app/signets-api/models/course.dart';
import 'package:notredame/features/app/signets-api/models/course_activity.dart';
import 'package:notredame/features/app/signets-api/models/session.dart';
import 'package:notredame/features/app/storage/preferences_service.dart';
import 'package:notredame/features/app/storage/siren_flutter_service.dart';
import 'package:notredame/features/app/widgets/app_widget_service.dart';
import 'package:notredame/features/dashboard/progress_bar_text_options.dart';
import 'package:notredame/features/more/feedback/in_app_review_service.dart';
import 'package:notredame/features/more/settings/settings_manager.dart';
import 'package:notredame/features/student/grades/widget_models.dart';
import 'package:notredame/features/welcome/discovery/discovery_components.dart';
import 'package:notredame/features/welcome/discovery/models/discovery_ids.dart';
import 'package:notredame/utils/activity_code.dart';
import 'package:notredame/utils/locator.dart';

class DashboardViewModel extends FutureViewModel<Map<PreferencesFlag, int>> {
  static const String tag = "DashboardViewModel";

  final SettingsManager _settingsManager = locator<SettingsManager>();
  final CourseRepository _courseRepository = locator<CourseRepository>();
  final AnalyticsService _analyticsService = locator<AnalyticsService>();
  final AppWidgetService _appWidgetService = locator<AppWidgetService>();
  final RemoteConfigService remoteConfigService =
      locator<RemoteConfigService>();

  /// All dashboard displayable cards
  Map<PreferencesFlag, int>? _cards;

  /// Localization class of the application.
  final AppIntl _appIntl;

  /// Update code that must be used to prompt user for update if necessary.
  UpdateCode? updateCode;

  /// Cards to display on dashboard
  List<PreferencesFlag>? _cardsToDisplay;

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
  Map<PreferencesFlag, int>? get cards => _cards;

  /// Get cards to display
  List<PreferencesFlag>? get cardsToDisplay => _cardsToDisplay;

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
    final NavigationService navigationService = locator<NavigationService>();
    try {
      await launchUrlService.launchInBrowser(url, Brightness.light);
    } catch (error) {
      // An exception is thrown if browser app is not installed on Android device.
      await navigationService.pushNamed(RouterPaths.webView, arguments: url);
    }
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
  List<Course> courses = [];

  DashboardViewModel({required AppIntl intl}) : _appIntl = intl;

  @override
  Future<Map<PreferencesFlag, int>> futureToRun() async {
    final dashboard = await _settingsManager.getDashboard();

    //TODO: remove when all users are on 4.48.0 or more
    final sharedPreferences = await SharedPreferences.getInstance();
    if(sharedPreferences.containsKey("broadcastCard")) {
      sharedPreferences.remove("broadcastCard");
    }
    final sortedList = dashboard.entries.toList()
        ..sort((a, b) => a.value.compareTo(b.value));
    final sortedDashboard = LinkedHashMap.fromEntries(sortedList);
    int index = 0;
    for (final element in sortedDashboard.entries) {
      if(element.value >= 0) {
        sortedDashboard.update(element.key, (value) => index);
        index++;
      }
    }

    _cards = sortedDashboard;

    getCardsToDisplay();

    // load data for both grade cards & grades home screen widget
    // (moved from getCardsToDisplay())
    await loadDataAndUpdateWidget();

    return sortedDashboard;
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
          return course.grade!;
        } else if (course.summary != null &&
            course.summary!.markOutOf > 0 &&
            !(course.inReviewPeriod &&
                (course.allReviewsCompleted != null &&
                    !course.allReviewsCompleted!))) {
          return _appIntl.grades_grade_in_percentage(
              course.summary!.currentMarkInPercent.round());
        }
        return _appIntl.grades_not_available;
      }).toList();

      await _appWidgetService.sendGradesData(GradesWidgetData(
          title:
              "${_appIntl.grades_title} - ${_courseRepository.activeSessions.first.shortName.isEmpty ? _appIntl.session_without : ''}",
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
    try {
      var courseActivities =
          await _courseRepository.getCoursesActivities(fromCacheOnly: true);
      setBusyForObject(_todayDateEvents, true);
      setBusyForObject(_tomorrowDateEvents, true);
      _todayDateEvents.clear();
      _tomorrowDateEvents.clear();
      final todayDate = _settingsManager.dateTimeNow;
      courseActivities = await _courseRepository.getCoursesActivities();

      if (_todayDateEvents.isEmpty &&
          _courseRepository.coursesActivities != null) {
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

  /// Start discovery is needed
  static Future<void> startDiscovery(BuildContext context) async {
    final SettingsManager settingsManager = locator<SettingsManager>();
    if (await settingsManager.getBool(PreferencesFlag.discoveryDashboard) ==
        null) {
      if (!context.mounted) return;
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

  /// Prompt the update for the app if the navigation service arguments passed
  /// is not none. When [UpdateCode] is forced, the user will be force to update.
  /// If [UpdateCode] is not forced, the user will be prompted to update.
  static Future<void> promptUpdate(
      BuildContext context, UpdateCode? updateCode) async {
    if (updateCode != null && updateCode != UpdateCode.none) {
      final appIntl = AppIntl.of(context);

      bool isAForcedUpdate = false;
      String message = '';
      switch (updateCode) {
        case UpdateCode.force:
          isAForcedUpdate = true;
          message = appIntl!.update_version_message_force;
        case UpdateCode.ask:
          isAForcedUpdate = false;
          message = appIntl!.update_version_message;
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
