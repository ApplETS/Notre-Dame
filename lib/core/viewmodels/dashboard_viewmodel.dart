// FLUTTER / DART / THIRD-PARTIES
import 'dart:collection';
import 'package:feature_discovery/feature_discovery.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:stacked/stacked.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// CONSTANTS
import 'package:notredame/core/constants/preferences_flags.dart';

// MANAGER
import 'package:notredame/core/managers/settings_manager.dart';
import 'package:notredame/core/managers/course_repository.dart';

// MODEL
import 'package:notredame/core/models/session.dart';

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

  /// Get the status of all displayable cards
  Map<PreferencesFlag, int> get cards => _cards;

  /// Get cards to display
  List<PreferencesFlag> get cardsToDisplay => _cardsToDisplay;

  /// Return session progress based on today's [date]
  double getSessionProgress() {
    if (_courseRepository.activeSessions.isEmpty) {
      return 0.0;
    } else {
      return todayDate
              .difference(_courseRepository.activeSessions.first.startDate)
              .inDays /
          _courseRepository.activeSessions.first.endDate
              .difference(_courseRepository.activeSessions.first.startDate)
              .inDays;
    }
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
          if (key == PreferencesFlag.progressBarCard) {
            futureToRunSessionProgressBar();
          }
        }
      });
    }
  }

  Future<List<Session>> futureToRunSessionProgressBar() async {
    setBusyForObject(_progress, true);
    return _courseRepository
        .getSessions()
        // ignore: invalid_return_type_for_catch_error
        .catchError(onError)
        .whenComplete(() {
      _sessionDays = getSessionDays();
      _progress = getSessionProgress();
      setBusyForObject(_progress, false);
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

  Future<void> startDiscovery(BuildContext context) async {
    if (await _settingsManager.getString(PreferencesFlag.discovery) == null) {
      final List<String> ids =
          discoveryComponents(context).map((e) => e.featureId).toList();
      FeatureDiscovery.discoverFeatures(context, ids);
      _settingsManager.setString(PreferencesFlag.discovery, 'true');
    }
  }
}
