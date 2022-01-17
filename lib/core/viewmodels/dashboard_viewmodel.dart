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
import 'package:notredame/core/constants/activity_code.dart';

// MANAGER / SERVICE
import 'package:notredame/core/managers/settings_manager.dart';
import 'package:notredame/core/managers/course_repository.dart';
import 'package:notredame/core/services/siren_flutter_service.dart';
import 'package:notredame/core/services/preferences_service.dart';

// MODEL
import 'package:notredame/core/models/session.dart';
import 'package:notredame/core/models/course_activity.dart';

// CORE
import 'package:notredame/core/models/course.dart';

// UTILS
import 'package:notredame/ui/utils/discovery_components.dart';

// OTHER
import 'package:notredame/locator.dart';

class DashboardViewModel extends FutureViewModel<Map<PreferencesFlag, int>> {
  final SettingsManager _settingsManager = locator<SettingsManager>();
  final CourseRepository _courseRepository = locator<CourseRepository>();

  /// All dashboard displayable cards
  Map<PreferencesFlag, int> _cards;

  /// Localization class of the application.
  final AppIntl _appIntl;

  /// Update code that must be used to prompt user for update if necessary.
  UpdateCode updateCode;

  /// Day currently selected
  DateTime todayDate = DateTime.now();

  /// Cards to display on dashboard
  List<PreferencesFlag> _cardsToDisplay;

  /// Percentage of completed days for the session
  double _progress = 0.0;

  /// Numbers of days elapsed and total number of days of the current session
  List<int> _sessionDays = [0, 0];

  /// Get progress of the session
  double get progress => _progress;

  List<int> get sessionDays => _sessionDays;

  /// Activities for today
  final List<CourseActivity> _todayDateEvents = [];

  /// Get the list of activities for today
  List<CourseActivity> get todayDateEvents {
    return _todayDateEvents;
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
      return todayDate
              .difference(_courseRepository.activeSessions.first.startDate)
              .inDays /
          _courseRepository.activeSessions.first.endDate
              .difference(_courseRepository.activeSessions.first.startDate)
              .inDays;
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
      return [
        todayDate
            .difference(_courseRepository.activeSessions.first.startDate)
            .inDays,
        _courseRepository.activeSessions.first.endDate
            .difference(_courseRepository.activeSessions.first.startDate)
            .inDays
      ];
    }
  }

  /// List of courses for the current session
  final List<Course> courses = [];

  DashboardViewModel({@required AppIntl intl}) : _appIntl = intl;

  @override
  Future<Map<PreferencesFlag, int>> futureToRun() async {
    final dashboard = await _settingsManager.getDashboard();

    _cards = dashboard;

    getCardsToDisplay();

    return dashboard;
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
  }

  /// Hide [flag] card from dashboard by setting int value -1
  void hideCard(PreferencesFlag flag) {
    _cards.update(flag, (value) => -1);

    _cardsToDisplay.remove(flag);

    updatePreferences();

    notifyListeners();
  }

  /// Reset all card indexes to their default values
  void setAllCardsVisible() {
    _cards.updateAll((key, value) {
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
          if (key == PreferencesFlag.scheduleCard) {
            futureToRunSchedule();
          }
          if (key == PreferencesFlag.progressBarCard) {
            futureToRunSessionProgressBar();
          }
          if (key == PreferencesFlag.gradesCard) {
            futureToRunGrades();
          }
        }
      });
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
      _todayDateEvents.clear();

      _courseRepository
          .getCoursesActivities()
          // ignore: return_type_invalid_for_catch_error
          .catchError(onError)
          .whenComplete(() async {
        if (_todayDateEvents.isEmpty) {
          // Build the list
          for (final CourseActivity course
              in _courseRepository.coursesActivities) {
            final DateTime dateOnly = course.startDateTime;

            if (isSameDay(todayDate, dateOnly)) {
              _todayDateEvents.add(course);
            }
          }
        }
        _todayDateEvents
            .sort((a, b) => a.startDateTime.compareTo(b.startDateTime));

        await removeLaboratoryGroup();

        setBusyForObject(_todayDateEvents, false);
      });

      return value;
    });
  }

  Future<void> removeLaboratoryGroup() async {
    final _todayDateEventsCopy = List.from(_todayDateEvents);

    for (final courseAcronym in _todayDateEventsCopy) {
      final courseKey = courseAcronym.courseGroup.toString().split('-')[0];

      final String activityCodeToUse = await _settingsManager.getDynamicString(
        PreferencesFlag.scheduleSettingsLaboratoryGroup,
        courseKey);

      if (activityCodeToUse == ActivityCode.labGroupA) {
        _todayDateEvents.removeWhere((element) =>
            element.activityDescription == ActivityDescriptionName.labB &&
            element.courseGroup == courseAcronym.courseGroup);
      } else if (activityCodeToUse == ActivityCode.labGroupB) {
        _todayDateEvents.removeWhere((element) =>
            element.activityDescription == ActivityDescriptionName.labA &&
            element.courseGroup == courseAcronym.courseGroup);
      }
    }
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
    final SettingsManager _settingsManager = locator<SettingsManager>();
    if (await _settingsManager.getBool(PreferencesFlag.discoveryDashboard) ==
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
  Future<List<Course>> futureToRunGrades() async {
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
}
