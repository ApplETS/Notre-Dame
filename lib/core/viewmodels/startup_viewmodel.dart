// FLUTTER / DART / THIRD-PARTIES
import 'package:stacked/stacked.dart';

// SERVICES / MANAGER
import 'package:notredame/core/managers/user_repository.dart';
import 'package:notredame/core/services/networking_service.dart';
import 'package:notredame/core/services/navigation_service.dart'; // MANAGER
import 'package:notredame/core/managers/settings_manager.dart';
import 'package:notredame/core/managers/cache_manager.dart';
import 'package:notredame/core/services/internal_info_service.dart';

// CONSTANTS
import 'package:notredame/core/constants/preferences_flags.dart';

// OTHER
import 'package:notredame/locator.dart';
import 'package:notredame/core/constants/router_paths.dart';

class StartUpViewModel extends BaseViewModel {
  /// Manage the settings
  final SettingsManager _settingsManager = locator<SettingsManager>();

  /// Used to authenticate the user
  final UserRepository _userRepository = locator<UserRepository>();

  /// Used to verify if the user has internet connectivity
  final NetworkingService _networkingService = locator<NetworkingService>();

  /// Used to redirect on the dashboard.
  final NavigationService _navigationService = locator<NavigationService>();

  /// Cache manager
  final CacheManager _cacheManager = locator<CacheManager>();

  /// Internal Info Service
  final InternalInfoService _internalInfoService =
      locator<InternalInfoService>();

  /// Try to silent authenticate the user then redirect to [LoginView] or [DashboardView]
  Future handleStartUp() async {
    if (await handleConnectivityIssues()) return;

    final bool hasTheSameVersionAsBefore = await hasSameSemanticVersion();
    if (hasTheSameVersionAsBefore) {
      _cacheManager.empty();
      setSemanticVersionInPrefs();
    }

    final bool isLogin = await _userRepository.silentAuthenticate();

    if (isLogin) {
      _navigationService.pushNamedAndRemoveUntil(RouterPaths.dashboard);
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
    return versionSaved == null || versionSaved == currentVersion;
  }

  /// Set the version in the prefs to be able to retrieve it and match them together
  Future setSemanticVersionInPrefs() async {
    final currentVersion =
        (await _internalInfoService.getPackageInfo()).version;
    await _settingsManager.setString(
        PreferencesFlag.appVersion, currentVersion);
  }
}
