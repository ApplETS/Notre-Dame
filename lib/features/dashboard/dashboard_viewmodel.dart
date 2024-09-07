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
import 'package:notredame/features/app/analytics/analytics_service.dart';
import 'package:notredame/features/app/analytics/remote_config_service.dart';
import 'package:notredame/features/app/repository/course_repository.dart';
import 'package:notredame/features/app/signets-api/models/course.dart';
import 'package:notredame/features/app/storage/preferences_service.dart';
import 'package:notredame/features/app/storage/siren_flutter_service.dart';
import 'package:notredame/features/more/feedback/in_app_review_service.dart';
import 'package:notredame/features/more/settings/settings_manager.dart';
import 'package:notredame/features/welcome/discovery/discovery_components.dart';
import 'package:notredame/features/welcome/discovery/models/discovery_ids.dart';
import 'package:notredame/utils/locator.dart';

class DashboardViewModel extends FutureViewModel<Map<PreferencesFlag, int>> {
  static const String tag = "DashboardViewModel";

  final SettingsManager _settingsManager = locator<SettingsManager>();
  final AnalyticsService _analyticsService = locator<AnalyticsService>();
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

  /// Get the status of all displayable cards
  Map<PreferencesFlag, int>? get cards => _cards;

  /// Get cards to display
  List<PreferencesFlag>? get cardsToDisplay => _cardsToDisplay;

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
  DashboardViewModel({required AppIntl intl}) : _appIntl = intl;

  @override
  Future<Map<PreferencesFlag, int>> futureToRun() async {
    final dashboard = await _settingsManager.getDashboard();

    //TODO: remove when all users are on 4.50.1 or more
    final sharedPreferences = await SharedPreferences.getInstance();
    if (sharedPreferences.containsKey("PreferencesFlag.broadcastChange")) {
      sharedPreferences.remove("PreferencesFlag.broadcastChange");
    }
    if (sharedPreferences.containsKey("PreferencesFlag.broadcastCard")) {
      sharedPreferences.remove("PreferencesFlag.broadcastCard");
    }
    final sortedList = dashboard.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));
    final sortedDashboard = LinkedHashMap.fromEntries(sortedList);
    int index = 0;
    for (final element in sortedDashboard.entries) {
      if (element.value >= 0) {
        sortedDashboard.update(element.key, (value) => index);
        index++;
      }
    }
    //TODO: end remove when all users are on 4.50.1 or more

    _cards = sortedDashboard;

    getCardsToDisplay();

    // load data for both grade cards & grades home screen widget
    // (moved from getCardsToDisplay())
    await loadDataAndUpdateWidget();

    return sortedDashboard;
  }

  Future loadDataAndUpdateWidget() async {
    return Future.wait([]);
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
}
