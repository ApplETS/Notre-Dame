// FLUTTER / DART / THIRD-PARTIES
import 'package:fluttertoast/fluttertoast.dart';
import 'package:stacked/stacked.dart';
import 'package:flutter/material.dart';
import 'package:notredame/core/constants/preferences_flags.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// MANAGER
import 'package:notredame/core/managers/settings_manager.dart';

// OTHER
import 'package:notredame/locator.dart';

class DashboardViewModel extends FutureViewModel<Map<PreferencesFlag, int>> {
  final SettingsManager _settingsManager = locator<SettingsManager>();

  // All dashboard displayable cards
  Map<PreferencesFlag, int> _cards;

  /// Localization class of the application.
  final AppIntl _appIntl;

  /// Cards to display on dashboard
  List<PreferencesFlag> _cardsToDisplay;

  /// Get the status of all displayable cards
  Map<PreferencesFlag, int> get cards => _cards;

  /// Get cards to display
  List<PreferencesFlag> get cardsToDisplay => _cardsToDisplay;

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

  /// Set card order
  void setOrder(PreferencesFlag flag, int newIndex, int oldIndex) {
    _cardsToDisplay.removeAt(oldIndex);
    _cardsToDisplay.insert(newIndex, flag);

    updatePreferences();

    notifyListeners();
  }

  /// Hide card from dashboard
  void hideCard(PreferencesFlag flag) {
    _cards.update(flag, (value) => -1);

    _cardsToDisplay.remove(flag);

    updatePreferences();

    notifyListeners();
  }

  /// Set card visible on dashboard
  void setCardVisible(PreferencesFlag flag) {
    _settingsManager
        .setInt(flag, flag.index - PreferencesFlag.aboutUsCard.index)
        .then((value) {
      if (!value) {
        Fluttertoast.showToast(msg: _appIntl.error);
      }
    });

    _cards.update(
        flag, (value) => flag.index - PreferencesFlag.aboutUsCard.index);

    getCardsToDisplay();

    notifyListeners();
  }

  void setAllCardsVisible() {
    _cards.updateAll((key, value) {
      _settingsManager
          .setInt(key, key.index - PreferencesFlag.aboutUsCard.index)
          .then((value) {
        if (!value) {
          Fluttertoast.showToast(msg: _appIntl.error);
        }
      });
      return key.index;
    });

    getCardsToDisplay();

    notifyListeners();
  }

  /// Populate list of cards used in view
  void getCardsToDisplay() {
    int numberOfCards = 0;

    _cards.forEach((key, value) {
      if (value >= 0) {
        numberOfCards++;
      }
    });

    _cardsToDisplay =
        List.filled(numberOfCards, PreferencesFlag.aboutUsCard, growable: true);

    _cards.forEach((key, value) {
      if (value >= 0) {
        _cardsToDisplay[value] = key;
      }
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
}
