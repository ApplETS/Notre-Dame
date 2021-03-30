// FLUTTER / DART / THIRD-PARTIES
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'package:stacked/stacked.dart';
import 'package:image/image.dart' as image;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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

  /// Get the application version
  String get appVersion => _appVersion;

  MoreViewModel();

  @override
  Future futureToRun() async {
    setBusy(true);

    await PackageInfo.fromPlatform()
        .then((value) => _appVersion = value.version)
        .onError((error, stackTrace) => null);

    setBusy(false);
    return true;
  }

  /// Used to logout user, delete cache, and return to login
  Future<void> logout() async {
    setBusy(true);

    await _cacheManager.empty();

    await _preferencesService.clear();
    await _userRepository.logOut();

    settingsManager.resetLanguageAndThemeMode();
    _courseRepository.sessions.clear();
    _courseRepository.courses.clear();
    _courseRepository.coursesActivities.clear();
    setBusy(false);
    // Dismiss alertDialog
    navigationService.pop();
    navigationService.pushNamedAndRemoveUntil(RouterPaths.login);
  }

  /// Create a Github issue with [feedbackText] and the screenshot associated.
  Future<void> sendFeedback(
      String feedbackText, Uint8List feedbackScreenshot) async {
    //Generate info to pass to github
    final File file = await _githubApi.localFile;
    await file.writeAsBytes(image.encodePng(
        image.copyResize(image.decodeImage(feedbackScreenshot), width: 307)));

    final String fileName = file.path.replaceFirst(
        'storage/emulated/0/Android/data/ca.etsmtl.applets.notredame/files/',
        '');

    // Upload the file and create the issue
    _githubApi.uploadFileToGithub(filePath: fileName, file: file);

    _githubApi.createGithubIssue(
        feedbackText: feedbackText, fileName: fileName);

    file.deleteSync();
  }
}
