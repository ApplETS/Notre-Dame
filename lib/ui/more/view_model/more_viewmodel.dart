// Package imports:
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:stacked/stacked.dart';

// Project imports:
import 'package:notredame/data/repositories/course_repository.dart';
import 'package:notredame/data/repositories/settings_repository.dart';
import 'package:notredame/data/services/auth_service.dart';
import 'package:notredame/data/services/cache_service.dart';
import 'package:notredame/data/services/in_app_review_service.dart';
import 'package:notredame/data/services/launch_url_service.dart';
import 'package:notredame/data/services/navigation_service.dart';
import 'package:notredame/data/services/preferences_service.dart';
import 'package:notredame/data/services/remote_config_service.dart';
import 'package:notredame/domain/constants/preferences_flags.dart';
import 'package:notredame/domain/constants/router_paths.dart';
import 'package:notredame/locator.dart';

class MoreViewModel extends FutureViewModel {
  /// Cache manager
  final CacheService _cacheManager = locator<CacheService>();

  /// Settings manager
  final SettingsRepository _settingsManager = locator<SettingsRepository>();

  /// Course repository
  final CourseRepository _courseRepository = locator<CourseRepository>();

  /// Preferences service
  final PreferencesService _preferencesService = locator<PreferencesService>();

  /// Remote config service
  final RemoteConfigService _remoteConfigService =
      locator<RemoteConfigService>();

  /// User repository needed to log out
  final _authService = locator<AuthService>();

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
        RouterPaths.startup, RouterPaths.chooseLanguage);
    Fluttertoast.showToast(msg: _appIntl.login_msg_logout_success);
    try {
      await _cacheManager.empty();
    } on Exception catch (e) {
      onError(e);
    }

    await _preferencesService.clearWithoutPersistentKey();

    await _authService.signOut();
    _settingsManager.resetLanguageAndThemeMode();

    // clear all previous cached value in courseRepository
    _courseRepository.sessions?.clear();
    _courseRepository.courses?.clear();
    _courseRepository.coursesActivities?.clear();

    setBusy(false);
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
    launchUrlService.launchInBrowser(remoteConfigService.privacyPolicyUrl);
  }

  /// Get the privacy policy toggle
  bool get privacyPolicyToggle => _remoteConfigService.privacyPolicyToggle;
}
