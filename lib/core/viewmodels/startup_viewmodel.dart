// FLUTTER / DART / THIRD-PARTIES
import 'package:stacked/stacked.dart';

// SERVICES / MANAGER
import 'package:notredame/core/managers/user_repository.dart';
import 'package:notredame/core/services/networking_service.dart';
import 'package:notredame/core/services/navigation_service.dart'; // MANAGER
import 'package:notredame/core/managers/settings_manager.dart';

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

  /// Try to silent authenticate the user then redirect to [LoginView] or [DashboardView]
  Future handleStartUp() async {
    if (await handleConnectivityIssues()) return;
    final bool isLogin = await _userRepository.silentAuthenticate();

    if (isLogin) {
      _navigationService.pushNamed(RouterPaths.dashboard);
    } else {
      if (await _settingsManager.getString(PreferencesFlag.languageChoice) ==
          null) {
        _navigationService.pushNamed(RouterPaths.chooseLanguage);
        _settingsManager.setString(PreferencesFlag.languageChoice, 'true');
      } else {
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
      _navigationService.pushNamed(RouterPaths.dashboard);
      return true;
    }
    return false;
  }
}
