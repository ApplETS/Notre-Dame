// FLUTTER / DART / THIRD-PARTIES
import 'dart:io';
import 'dart:typed_data';
import 'package:feature_discovery/feature_discovery.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:package_info/package_info.dart';
import 'package:stacked/stacked.dart';
import 'package:image/image.dart' as image;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// UTILS
import 'package:notredame/ui/utils/discovery_components.dart';

// CONSTANTS
import 'package:notredame/core/constants/preferences_flags.dart';

// MANAGER
import 'package:notredame/core/managers/cache_manager.dart';
import 'package:notredame/core/managers/user_repository.dart';
import 'package:notredame/core/managers/settings_manager.dart';
import 'package:notredame/core/managers/course_repository.dart';

//SERVICE
import 'package:notredame/core/services/navigation_service.dart';
import 'package:notredame/core/services/preferences_service.dart';
import 'package:notredame/core/services/github_api.dart';

// OTHERS
import 'package:notredame/core/constants/router_paths.dart';
import 'package:notredame/locator.dart';

class MoreViewModel extends FutureViewModel {
  /// Cache manager
  final CacheManager _cacheManager = locator<CacheManager>();

  /// Settings manager
  final SettingsManager settingsManager = locator<SettingsManager>();

  /// Course repository
  final CourseRepository _courseRepository = locator<CourseRepository>();

  /// Preferences service
  final PreferencesService _preferencesService = locator<PreferencesService>();

  /// User repository needed to log out
  final UserRepository _userRepository = locator<UserRepository>();

  /// Used to redirect on the dashboard.
  final NavigationService navigationService = locator<NavigationService>();

  /// Used to access Github functionalities
  final GithubApi _githubApi = locator<GithubApi>();

  String _appVersion;

  final AppIntl _appIntl;

  /// Get the application version
  String get appVersion => _appVersion;

  MoreViewModel({@required AppIntl intl}) : _appIntl = intl;

  @override
  Future futureToRun() async {
    setBusy(true);

    await PackageInfo.fromPlatform()
        .then((value) => _appVersion = value.version)
        .onError((error, stackTrace) => null);

    setBusy(false);
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
    navigationService.pop();
    navigationService.pushNamedAndRemoveUntil(RouterPaths.login);
    Fluttertoast.showToast(msg: _appIntl.login_msg_logout_success);
    try {
      await _cacheManager.empty();
    } on Exception catch (e) {
      onError(e);
    }

    await _preferencesService.clear();

    await _userRepository.logOut();
    settingsManager.resetLanguageAndThemeMode();

    // clear all previous cached value in courseRepository
    _courseRepository.sessions?.clear();
    _courseRepository.courses?.clear();
    _courseRepository.coursesActivities?.clear();

    setBusy(false);
  }

  /// Create a Github issue with [feedbackText] and the screenshot associated.
  Future<void> sendFeedback(
      String feedbackText, Uint8List feedbackScreenshot) async {
    //Generate info to pass to github
    final File file = await _githubApi.localFile;
    await file.writeAsBytes(image.encodePng(
        image.copyResize(image.decodeImage(feedbackScreenshot), width: 307)));

    final String fileName = file.path.split('/').last;

    // Upload the file and create the issue
    _githubApi.uploadFileToGithub(filePath: fileName, file: file);

    _githubApi.createGithubIssue(
        feedbackText: feedbackText, fileName: fileName);

    file.deleteSync();
    Fluttertoast.showToast(
      msg: _appIntl.thank_you_for_the_feedback,
      gravity: ToastGravity.CENTER,
    );
  }

  Future<void> startDiscovery(BuildContext context) async {
    if (await settingsManager.getString(PreferencesFlag.discoveryMore) ==
        null) {
      final List<String> ids = findDiscoveriesByGroupName(context, 'pageMore')
          .map((e) => e.featureId)
          .toList();

      FeatureDiscovery.discoverFeatures(context, ids);

      settingsManager.setString(PreferencesFlag.discoveryMore, 'true');
    }
  }
}
