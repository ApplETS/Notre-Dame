// Package imports:
import 'package:stacked/stacked.dart';

// Project imports:
import 'package:notredame/constants/preferences_flags.dart';
import 'package:notredame/constants/update_code.dart';
import 'package:notredame/features/app/analytics/analytics_service.dart';
import 'package:notredame/features/app/error/internal_info_service.dart';
import 'package:notredame/features/app/integration/networking_service.dart';
import 'package:notredame/features/app/navigation/navigation_service.dart';
import 'package:notredame/features/app/navigation/router_paths.dart';
import 'package:notredame/features/app/repository/user_repository.dart';
import 'package:notredame/features/app/storage/preferences_service.dart';
import 'package:notredame/features/app/storage/siren_flutter_service.dart';
import 'package:notredame/features/more/settings/settings_manager.dart';
import 'package:notredame/utils/locator.dart';

class StartUpViewModel extends BaseViewModel {
  /// Manage the settings
  final SettingsManager _settingsManager = locator<SettingsManager>();

  /// Preferences service
  /// TODO remove when everyone is moved to 4.4.6
  final PreferencesService _preferencesService = locator<PreferencesService>();

  /// Used to authenticate the user
  final UserRepository _userRepository = locator<UserRepository>();

  /// Used to verify if the user has internet connectivity
  final NetworkingService _networkingService = locator<NetworkingService>();

  /// Used to redirect on the dashboard.
  final NavigationService _navigationService = locator<NavigationService>();

  /// Used to access the lib siren for updates
  final SirenFlutterService _sirenFlutterService =
      locator<SirenFlutterService>();

  /// Internal Info Service
  final InternalInfoService _internalInfoService =
      locator<InternalInfoService>();

  /// Analytics
  final AnalyticsService _analyticsService = locator<AnalyticsService>();

  /// Try to silent authenticate the user then redirect to [LoginView] or [DashboardView]
  Future handleStartUp() async {
    if (await handleConnectivityIssues()) return;

    final bool hasTheSameVersionAsBefore = await hasSameSemanticVersion();
    if (!hasTheSameVersionAsBefore) {
      // TODO remove when everyone is moved to 4.4.6
      final flagsToCheck = [
        PreferencesFlag.discoveryDashboard,
        PreferencesFlag.discoverySchedule,
        PreferencesFlag.discoveryStudentGrade,
        PreferencesFlag.discoveryGradeDetails,
        PreferencesFlag.discoveryStudentProfile,
        PreferencesFlag.discoveryETS,
        PreferencesFlag.discoveryMore,
        PreferencesFlag.languageChoice
      ];

      for (final PreferencesFlag flag in flagsToCheck) {
        final Object? object =
            await _preferencesService.getPreferencesFlag(flag);

        if (object is String) {
          _preferencesService.removePreferencesFlag(flag);
          _settingsManager.setBool(flag, object == 'true');
        }
      }

      setSemanticVersionInPrefs();
    }

    final bool isLogin = await _userRepository.silentAuthenticate();

    if (isLogin) {
      final updateStatus = await checkUpdateStatus();
      _navigationService.pushNamedAndRemoveUntil(
          RouterPaths.dashboard, RouterPaths.dashboard, updateStatus);
    } else {
      if (await _settingsManager.getBool(PreferencesFlag.languageChoice) ==
          null) {
        _navigationService.pushNamed(RouterPaths.chooseLanguage);
        _settingsManager.setBool(PreferencesFlag.languageChoice, true);
      } else {
        _navigationService.pop();
        _navigationService.pushNamed(RouterPaths.login);
      }
    }
  }

  /// Verify if user has an active internet connection. If the user does have
  /// an active internet connection, proceed with the normal app workflow.
  /// Otherwise if the user was previously logged in, let him access the app
  /// with the cached data
  Future<bool> handleConnectivityIssues() async {
    final hasConnectivityIssues = !await _networkingService.hasConnectivity();
    final wasLoggedIn = await _userRepository.wasPreviouslyLoggedIn();
    if (hasConnectivityIssues && wasLoggedIn) {
      _navigationService.pushNamedAndRemoveUntil(RouterPaths.dashboard);
      return true;
    }
    return false;
  }

  /// Check whether prefs contains the right version
  Future<bool> hasSameSemanticVersion() async {
    final currentVersion =
        (await _internalInfoService.getPackageInfo()).version;
    final versionSaved =
        await _settingsManager.getString(PreferencesFlag.appVersion);

    if (versionSaved != null) {
      return versionSaved == currentVersion;
    }
    return false;
  }

  /// Set the version in the prefs to be able to retrieve it and match them together
  Future setSemanticVersionInPrefs() async {
    final currentVersion =
        (await _internalInfoService.getPackageInfo()).version;
    await _settingsManager.setString(
        PreferencesFlag.appVersion, currentVersion);
  }

  /// Check if the user has a new version of the app and show a message to
  /// prompt him to update it. Returns the [UpdateCode] that can be used to
  /// handle the update.
  Future<UpdateCode> checkUpdateStatus() async {
    bool isUpdateAvailable = false;
    try {
      isUpdateAvailable = await _sirenFlutterService.updateIsAvailable();
    } catch (e) {
      _analyticsService.logError(
          "Error while checking for update", e.toString());
    }
    if (isUpdateAvailable) {
      final latestVersion = await _sirenFlutterService.storeVersion;
      final localVersion = await _sirenFlutterService.localVersion;

      if (latestVersion.major != localVersion.major ||
          latestVersion.minor != localVersion.minor) {
        return UpdateCode.ask;
      } else if (latestVersion.major == localVersion.major &&
          latestVersion.minor == localVersion.minor &&
          latestVersion.patch != localVersion.patch) {
        return UpdateCode.force;
      }
    }
    return UpdateCode.none;
  }
}
