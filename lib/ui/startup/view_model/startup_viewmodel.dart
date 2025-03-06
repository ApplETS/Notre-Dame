// Package imports:
import 'dart:developer';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:msal_auth/msal_auth.dart';
import 'package:notredame/data/services/auth_service.dart';
import 'package:stacked/stacked.dart';

// Project imports:
import 'package:notredame/data/repositories/settings_repository.dart';
import 'package:notredame/data/repositories/user_repository.dart';
import 'package:notredame/data/services/navigation_service.dart';
import 'package:notredame/data/services/networking_service.dart';
import 'package:notredame/domain/constants/router_paths.dart';
import 'package:notredame/locator.dart';

import '../../../domain/constants/preferences_flags.dart';

class StartUpViewModel extends BaseViewModel {
  /// Manage the settings
  final SettingsRepository _settingsManager = locator<SettingsRepository>();

  /// Used to authenticate the user
  final UserRepository _userRepository = locator<UserRepository>();
  final AuthService _authService = locator<AuthService>();

  /// Used to verify if the user has internet connectivity
  final NetworkingService _networkingService = locator<NetworkingService>();

  /// Used to redirect on the dashboard.
  final NavigationService _navigationService = locator<NavigationService>();

  /// Try to silent authenticate the user then redirect to [LoginView] or [DashboardView]
  Future handleStartUp() async {
    if (await handleConnectivityIssues()) return;

    // TODO: remove when everyone is on the version with the new auth
    if(await _userRepository.wasPreviouslyLoggedIn()) {
      _userRepository.logOut();
    }
    // TODO: remove when everyone is on the version with the new auth

    await _authService.createPublicClientApplication(authorityType: AuthorityType.aad, broker: Broker.msAuthenticator);
    final bool isLogin = (await _authService.acquireTokenSilent()).$2 == null;

    if (isLogin) {
      _navigationService.pushNamedAndRemoveUntil(RouterPaths.dashboard);
    } else {
      AuthenticationResult? token;
      while(token == null) {
        token = (await _authService.acquireToken()).$1;
      }

      if (await _settingsManager.getBool(PreferencesFlag.languageChoice) ==
          null) {
        _navigationService.pushNamed(RouterPaths.chooseLanguage);
        _settingsManager.setBool(PreferencesFlag.languageChoice, true);
      } else {
        _navigationService.pop();
        _navigationService.pushNamed(RouterPaths.dashboard);
      }
    }
  }

  /// Verify if user has an active internet connection. If the user does have
  /// an active internet connection, proceed with the normal app workflow.
  /// Otherwise if the user was previously logged in, let him access the app
  /// with the cached data
  Future<bool> handleConnectivityIssues() async {
    final hasConnectivityIssues = !await _networkingService.hasConnectivity();
    final wasLoggedIn = (await _authService.getCurrentAccount()).$1 != null;
    if (hasConnectivityIssues && wasLoggedIn) {
      _navigationService.pushNamedAndRemoveUntil(RouterPaths.dashboard);
      return true;
    }
    return false;
  }
}
