// FLUTTER / DART / THIRD-PARTIES

import 'package:fluttertoast/fluttertoast.dart';
import 'package:notredame/core/constants/preferences_flags.dart';
import 'package:notredame/core/managers/settings_manager.dart';
import 'package:stacked/stacked.dart';

import '../../locator.dart';

class DashboardViewModel extends FutureViewModel<Map<PreferencesFlag, int>> {
  /// Manage the cards
  final SettingsManager _settingsManager = locator<SettingsManager>();

  Map<PreferencesFlag, int> _cards;

  List<PreferencesFlag> _cardsToDisplay;

  Map<PreferencesFlag, int> get cards => _cards;

  List<PreferencesFlag> get cardsToDisplay => _cardsToDisplay;

  /// Set card order
  void setOrder(PreferencesFlag flag, int newIndex, int oldIndex) {
    _cardsToDisplay.removeAt(oldIndex);
    _cardsToDisplay.insert(newIndex, flag);

    updatePreferences();

    notifyListeners();
  }

  /// Hide card from dashboard
  void hideCard(PreferencesFlag flag) {
    _settingsManager.setInt(flag, -1).then((value) {
      if (!value) {
        Fluttertoast.showToast(msg: "Failed");
      }
    });

    _cards.update(flag, (value) => -1);

    _cardsToDisplay.remove(flag);

    updatePreferences();

    notifyListeners();
  }

  /// Set card visible on dashboard
  void setCardVisible(PreferencesFlag flag) {
    _settingsManager.setInt(flag, flag.index - 6).then((value) {
      if (!value) {
        Fluttertoast.showToast(msg: "Failed");
      }
    });

    _cards.update(flag, (value) => flag.index - 6);

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

  void updatePreferences() {
    for (final MapEntry<PreferencesFlag, int> element in _cards.entries) {
      if (element.value != -1) {
        _cards[element.key] = _cardsToDisplay.indexOf(element.key);
        _settingsManager
            .setInt(element.key, _cardsToDisplay.indexOf(element.key))
            .then((value) {
          if (!value) {
            Fluttertoast.showToast(msg: "Failed");
          }
        });
      }
    }
  }

  @override
  Future<Map<PreferencesFlag, int>> futureToRun() async {
    final dashboard = await _settingsManager.getDashboard();

    _cards = dashboard;

    getCardsToDisplay();

    return dashboard;
  }
}
