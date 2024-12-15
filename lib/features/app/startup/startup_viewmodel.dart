// Package imports:
import 'package:stacked/stacked.dart';

// Project imports:
import 'package:notredame/domain/constants/preferences_flags.dart';
import 'package:notredame/data/services/networking_service.dart';
import 'package:notredame/data/services/navigation_service.dart';
import 'package:notredame/domain/constants/router_paths.dart';
import 'package:notredame/data/repositories/user_repository.dart';
import 'package:notredame/features/more/settings/settings_manager.dart';
import 'package:notredame/locator.dart';

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
}
