// Package imports:
import 'package:fluttertoast/fluttertoast.dart';
import 'package:msal_auth/msal_auth.dart';
import 'package:stacked/stacked.dart';

// Project imports:
import 'package:notredame/data/repositories/settings_repository.dart';
import 'package:notredame/data/services/analytics_service.dart';
import 'package:notredame/data/services/auth_service.dart';
import 'package:notredame/data/services/navigation_service.dart';
import 'package:notredame/data/services/networking_service.dart';
import 'package:notredame/domain/constants/preferences_flags.dart';
import 'package:notredame/domain/constants/router_paths.dart';
import 'package:notredame/l10n/app_localizations.dart';
import 'package:notredame/locator.dart';

class StartUpViewModel extends BaseViewModel {
  /// Manage the settings
  final SettingsRepository _settingsManager = locator<SettingsRepository>();
  final AuthService _authService = locator<AuthService>();
  final NetworkingService _networkingService = locator<NetworkingService>();
  final NavigationService _navigationService = locator<NavigationService>();
  final AnalyticsService _analyticsService = locator<AnalyticsService>();

  final AppIntl intl;
  StartUpViewModel({required this.intl});

  /// Try to silent authenticate the user then redirect to [LoginView] or [DashboardView]
  Future handleStartUp() async {
    if (await handleConnectivityIssues()) return;

    if (await _settingsManager.getBool(PreferencesFlag.languageChoice) == null) {
      _navigationService.pushNamed(RouterPaths.chooseLanguage);
      return;
    }

    final clientAppResult = await _authService.createPublicClientApplication(
      authorityType: AuthorityType.aad,
      broker: Broker.msAuthenticator,
    );

    if (!clientAppResult.$1) {
      final message = clientAppResult.$2?.message ?? 'Failed to create public client application';
      await _analyticsService.logError('StartupViewmodel', message);
      throw Exception("StartupViewmodel - Failed to create public client application");
    }

    final bool isLogin = (await _authService.acquireTokenSilent()).$2 == null;

    if (isLogin) {
      _settingsManager.setBool(PreferencesFlag.isLoggedIn, true);

      _navigationService.pushNamedAndRemoveUntil(RouterPaths.dashboard);
    } else {
      AuthenticationResult? token;
      int attempts = 0;
      const maxAttempts = 3;

      while (token == null && attempts < maxAttempts) {
        attempts++;
        token = (await _authService.acquireToken()).$1;
        if (token == null && attempts >= maxAttempts) {
          Fluttertoast.showToast(msg: intl.startup_viewmodel_acquire_token_fail, toastLength: Toast.LENGTH_LONG);
          await _analyticsService.logError('StartupViewmodel', 'Failed to acquire token after $maxAttempts attempts');
          return;
        }
      }

      _settingsManager.setBool(PreferencesFlag.isLoggedIn, true);

      _navigationService.pushNamedAndRemoveUntil(RouterPaths.dashboard);
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
      _navigationService.pushNamedAndRemoveUntil(RouterPaths.dashboard);
      return true;
    }
    return false;
  }
}
