// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:feature_discovery/feature_discovery.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:notredame/core/services/launch_url_service.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:stacked/stacked.dart';

// Project imports:
import 'package:notredame/core/constants/discovery_ids.dart';
import 'package:notredame/core/constants/preferences_flags.dart';
import 'package:notredame/core/constants/router_paths.dart';
import 'package:notredame/core/managers/cache_manager.dart';
import 'package:notredame/core/managers/course_repository.dart';
import 'package:notredame/core/managers/settings_manager.dart';
import 'package:notredame/core/managers/user_repository.dart';
import 'package:notredame/core/services/in_app_review_service.dart';
import 'package:notredame/core/services/navigation_service.dart';
import 'package:notredame/core/services/preferences_service.dart';
import 'package:notredame/core/services/remote_config_service.dart';
import 'package:notredame/locator.dart';
import 'package:notredame/ui/utils/discovery_components.dart';

class MoreViewModel extends FutureViewModel {
  /// Cache manager
  final CacheManager _cacheManager = locator<CacheManager>();

  /// Settings manager
  final SettingsManager _settingsManager = locator<SettingsManager>();

  /// Course repository
  final CourseRepository _courseRepository = locator<CourseRepository>();

  /// Preferences service
  final PreferencesService _preferencesService = locator<PreferencesService>();

  /// Remote config service
  final RemoteConfigService _remoteConfigService =
      locator<RemoteConfigService>();

  /// User repository needed to log out
  final UserRepository _userRepository = locator<UserRepository>();

  /// Used to redirect on the dashboard.
  final NavigationService navigationService = locator<NavigationService>();

  String? _appVersion;

  final AppIntl _appIntl;

  /// Get the application version
  String? get appVersion => _appVersion;

  MoreViewModel({required AppIntl intl}) : _appIntl = intl;

  @override
  Future futureToRun() async {
    try {
      setBusy(true);
      final packageInfo = await PackageInfo.fromPlatform();
      _appVersion = packageInfo.version;
    } catch (error) {
      onError(error);
    } finally {
      setBusy(false);
    }
    return true;
  }

  @override
  // ignore: type_annotate_public_apis
  void onError(error) {
    Fluttertoast.showToast(msg: _appIntl.error);
  }

  /// Used to logout user, delete cache, and return to login
  Future<void> logout() async {
    setBusy(true);
    // Dismiss alertDialog
    navigationService.pushNamedAndRemoveUntil(
        RouterPaths.login, RouterPaths.chooseLanguage);
    Fluttertoast.showToast(msg: _appIntl.login_msg_logout_success);
    try {
      await _cacheManager.empty();
    } on Exception catch (e) {
      onError(e);
    }

    await _preferencesService.clearWithoutPersistentKey();

    await _userRepository.logOut();
    _settingsManager.resetLanguageAndThemeMode();

    // clear all previous cached value in courseRepository
    _courseRepository.sessions?.clear();
    _courseRepository.courses?.clear();
    _courseRepository.coursesActivities?.clear();

    setBusy(false);
  }

  /// Start the discovery of this page if needed
  static Future<void> startDiscovery(BuildContext context) async {
    final SettingsManager settingsManager = locator<SettingsManager>();

    if (await settingsManager.getBool(PreferencesFlag.discoveryMore) == null) {
      final List<String> ids =
          findDiscoveriesByGroupName(context, DiscoveryGroupIds.pageMore)
              .map((e) => e.featureId)
              .toList();

      Future.delayed(const Duration(milliseconds: 700),
          () => FeatureDiscovery.discoverFeatures(context, ids));

      settingsManager.setBool(PreferencesFlag.discoveryMore, true);
    }
  }

  /// Mark the discovery of this page completed
  Future<bool> discoveryCompleted() async {
    await _settingsManager.setBool(PreferencesFlag.discoveryMore, true);

    return true;
  }

  static Future<bool> launchInAppReview() async {
    final PreferencesService preferencesService = locator<PreferencesService>();
    final InAppReviewService inAppReviewService = locator<InAppReviewService>();

    if (await inAppReviewService.isAvailable()) {
      await inAppReviewService.openStoreListing();
      preferencesService.setBool(PreferencesFlag.hasRatingBeenRequested,
          value: true);

      return true;
    }
    return false;
  }

  static Future<void> launchPrivacyPolicy() async {
    final LaunchUrlService launchUrlService = locator<LaunchUrlService>();
    final RemoteConfigService remoteConfigService =
        locator<RemoteConfigService>();
    final NavigationService navigationService = locator<NavigationService>();
    try {
      await launchUrlService.launchInBrowser(
          remoteConfigService.privacyPolicyUrl, Brightness.light);
    } catch (error) {
      // An exception is thrown if browser app is not installed on Android device.
      await navigationService.pushNamed(RouterPaths.webView,
          arguments: remoteConfigService.privacyPolicyUrl);
    }
  }

  /// Get the privacy policy toggle
  bool get privacyPolicyToggle => _remoteConfigService.privacyPolicyToggle;
}
