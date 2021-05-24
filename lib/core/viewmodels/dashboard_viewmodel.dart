// FLUTTER / DART / THIRD-PARTIES
import 'dart:collection';
import 'package:feature_discovery/feature_discovery.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:stacked/stacked.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// UTILS
import 'package:notredame/ui/utils/discovery_components.dart';

// MANAGER
import 'package:notredame/core/managers/settings_manager.dart';

// CONSTANTS
import 'package:notredame/core/constants/preferences_flags.dart';

// CORE
import 'package:notredame/core/managers/course_repository.dart';
import 'package:notredame/core/models/course.dart';

// OTHER
import 'package:notredame/locator.dart';

class DashboardViewModel extends FutureViewModel<Map<PreferencesFlag, int>> {
  final SettingsManager _settingsManager = locator<SettingsManager>();

  final CourseRepository _courseRepository = locator<CourseRepository>();

  // All dashboard displayable cards
  Map<PreferencesFlag, int> _cards;

  /// Localization class of the application.
  final AppIntl _appIntl;

  /// Day currently selected
  DateTime todayDate = DateTime.now();

  /// Cards to display on dashboard
  List<PreferencesFlag> _cardsToDisplay;

  /// Get the status of all displayable cards
  Map<PreferencesFlag, int> get cards => _cards;

  /// Get cards to display
  List<PreferencesFlag> get cardsToDisplay => _cardsToDisplay;

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
          if (key == PreferencesFlag.gradesCards) {
            futureToRunGrades();
          }
        }
      });
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

  Future<void> startDiscovery(BuildContext context) async {
    if (await _settingsManager.getString(PreferencesFlag.discovery) == null) {
      final List<String> ids =
          discoveryComponents(context).map((e) => e.featureId).toList();
      FeatureDiscovery.discoverFeatures(context, ids);
      _settingsManager.setString(PreferencesFlag.discovery, 'true');
    }
  }

  /// Get the list of courses for the Grades card.
  Future<List<Course>> futureToRunGrades() async {
    setBusyForObject(courses, true);
    if (_courseRepository.sessions == null) {
      // ignore: return_type_invalid_for_catch_error
      await _courseRepository.getSessions().catchError(onError);
    }

    // Determine current sessions

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
