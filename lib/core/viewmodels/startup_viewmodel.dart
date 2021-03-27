// FLUTTER / DART / THIRD-PARTIES
import 'package:stacked/stacked.dart';

// SERVICE
import 'package:notredame/core/managers/user_repository.dart';
import 'package:notredame/core/services/navigation_service.dart';

// MANAGER
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

  /// Used to redirect on the dashboard.
  final NavigationService _navigationService = locator<NavigationService>();

  /// Try to silent authenticate the user then redirect to [LoginView] or [DashboardView]
  Future handleStartUp() async {
    final bool isLogin = await _userRepository.silentAuthenticate();

    if (isLogin) {
      _navigationService.pushNamed(RouterPaths.dashboard);
    } else {
      if (await _settingsManager.getString(PreferencesFlag.chooseLanguage) ==
          null) {
        _navigationService.pushNamed(RouterPaths.chooseLanguage);
        _settingsManager.setString(PreferencesFlag.chooseLanguage, 'true');
      } else {
        _navigationService.pushNamed(RouterPaths.login);
      }
    }
  }
}
