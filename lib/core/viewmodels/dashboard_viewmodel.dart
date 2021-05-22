// FLUTTER / DART / THIRD-PARTIES
import 'dart:collection';
import 'package:feature_discovery/feature_discovery.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:stacked/stacked.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// MANAGERS
import 'package:notredame/core/managers/settings_manager.dart';
import 'package:notredame/core/managers/course_repository.dart';

// MODELS / CONSTANTS
import 'package:notredame/core/constants/preferences_flags.dart';
import 'package:notredame/core/models/course_activity.dart';

// OTHER
import 'package:notredame/locator.dart';

class DashboardViewModel extends FutureViewModel<Map<PreferencesFlag, int>> {
  final SettingsManager _settingsManager = locator<SettingsManager>();
  final CourseRepository _courseRepository = locator<CourseRepository>();

  // All dashboard displayable cards
  Map<PreferencesFlag, int> _cards;

  /// Localization class of the application.
  final AppIntl _appIntl;

  /// Cards to display on dashboard
  List<PreferencesFlag> _cardsToDisplay;

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

  DashboardViewModel({@required AppIntl intl}) : _appIntl = intl;

  /// Day currently selected
  DateTime todayDate = DateTime.now().subtract(
      Duration(hours: DateTime.now().hour, minutes: DateTime.now().minute));

  bool isLoadingEvents = false;

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
        }
      });
    }
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
          .whenComplete(() {
        if (_todayDateEvents.isEmpty) {
          // Build the list
          for (final CourseActivity course
              in _courseRepository.coursesActivities) {
            final DateTime dateOnly = course.startDateTime;

            if (compareDates(todayDate, dateOnly)) {
              _todayDateEvents.add(course);
            }
          }
        }
        _todayDateEvents
            .sort((a, b) => a.startDateTime.compareTo(b.startDateTime));

        setBusyForObject(_todayDateEvents, false);
      });

      return value;
    });
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

  bool compareDates(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
  Future<void> startDiscovery(BuildContext context) async {
    if (await _settingsManager.getString(PreferencesFlag.discovery) == null) {
      final List<String> ids = discoveryComponents(context).map((e) => e.featureId).toList();
      FeatureDiscovery.discoverFeatures(context, ids);
      _settingsManager.setString(PreferencesFlag.discovery, 'true');
    }
  }
}
