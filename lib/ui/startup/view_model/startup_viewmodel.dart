// Package imports:
import 'package:msal_auth/msal_auth.dart';
import 'package:stacked/stacked.dart';

// Project imports:
import 'package:notredame/data/repositories/settings_repository.dart';
import 'package:notredame/data/repositories/user_repository.dart';
import 'package:notredame/data/services/analytics_service.dart';
import 'package:notredame/data/services/auth_service.dart';
import 'package:notredame/data/services/navigation_service.dart';
import 'package:notredame/data/services/networking_service.dart';
import 'package:notredame/domain/constants/preferences_flags.dart';
import 'package:notredame/domain/constants/router_paths.dart';
import 'package:notredame/locator.dart';

class StartUpViewModel extends BaseViewModel {
  /// Manage the settings
  final SettingsRepository _settingsManager = locator<SettingsRepository>();
  final AuthService _authService = locator<AuthService>();
  final NetworkingService _networkingService = locator<NetworkingService>();
  final NavigationService _navigationService = locator<NavigationService>();
  final AnalyticsService _analyticsService = locator<AnalyticsService>();

  // TODO: remove when all users are on 4.58.0 or more
  final UserRepository _userRepository = locator<UserRepository>();
  // TODO END: remove when all users are on 4.58.0 or more

  /// Try to silent authenticate the user then redirect to [LoginView] or [DashboardView]
  Future handleStartUp() async {
    if (await handleConnectivityIssues()) return;

    if (await _settingsManager.getBool(PreferencesFlag.languageChoice) == null) {
      _navigationService.pushNamed(RouterPaths.chooseLanguage);
      return;
    }

    //TODO: remove when all users are on 4.58.0 or more
    if (await _userRepository.wasPreviouslyLoggedIn()) {
      _userRepository.logOut();
    }
    //TODO END: remove when all users are on 4.58.0 or more

    final clientAppResult = await _authService.createPublicClientApplication(
        authorityType: AuthorityType.aad, broker: Broker.msAuthenticator);

    if (!clientAppResult.$1) {
      final message = clientAppResult.$2?.message ?? 'Failed to create public client application';
      await _analyticsService.logError('StartupViewmodel', message);
      throw Exception("StartupViewmodel - Failed to create public client application");
    }

    final bool isLogin = (await _authService.acquireTokenSilent()).$2 == null;

    if (isLogin) {
      _settingsManager.setBool(PreferencesFlag.isLoggedIn, true);
      _navigationService.pushNamedAndRemoveUntil(RouterPaths.root);
    } else {
      AuthenticationResult? token;
      while (token == null) {
        token = (await _authService.acquireToken()).$1;
      }
      _settingsManager.setBool(PreferencesFlag.isLoggedIn, true);
      _navigationService.pushNamedAndRemoveUntil(RouterPaths.root);
    }
  }

  /// Verify if user has an active internet connection. If the user does have
  /// an active internet connection, proceed with the normal app workflow.
  /// Otherwise if the user was previously logged in, let him access the app
  /// with the cached data
  Future<bool> handleConnectivityIssues() async {
    final hasConnectivityIssues = !await _networkingService.hasConnectivity();
    final wasLoggedIn = (await _settingsManager.getBool(PreferencesFlag.isLoggedIn)) ?? false;
    if (hasConnectivityIssues && wasLoggedIn) {
      _navigationService.pushNamedAndRemoveUntil(RouterPaths.root);
      return true;
    }
    return false;
  }
}
