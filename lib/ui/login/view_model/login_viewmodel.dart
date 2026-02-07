// Package imports:
import 'package:fluttertoast/fluttertoast.dart';
import 'package:msal_auth/msal_auth.dart';
import 'package:stacked/stacked.dart';

// Project imports:
import 'package:notredame/data/repositories/settings_repository.dart';
import 'package:notredame/data/services/analytics_service.dart';
import 'package:notredame/data/services/auth_service.dart';
import 'package:notredame/data/services/navigation_service.dart';
import 'package:notredame/domain/constants/preferences_flags.dart';
import 'package:notredame/domain/constants/router_paths.dart';
import 'package:notredame/l10n/app_localizations.dart';
import 'package:notredame/locator.dart';

class LoginViewModel extends BaseViewModel {
  /// Localization class of the application.
  final AppIntl _appIntl;

  LoginViewModel({required AppIntl intl}) : _appIntl = intl;

  Future authenticate() async {
    final SettingsRepository _settingsManager = locator<SettingsRepository>();
    final AuthService _authService = locator<AuthService>();
    final AnalyticsService _analyticsService = locator<AnalyticsService>();

    AuthenticationResult? token;
    int attempts = 0;
    const maxAttempts = 3;

    while (token == null && attempts < maxAttempts) {
      attempts++;
      token = (await _authService.acquireToken()).$1;
      if (token == null && attempts >= maxAttempts) {
        Fluttertoast.showToast(msg: _appIntl.startup_viewmodel_acquire_token_fail, toastLength: Toast.LENGTH_LONG);
        await _analyticsService.logError('StartupViewmodel', 'Failed to acquire token after $maxAttempts attempts');
        return;
      }
    }

    _settingsManager.setBool(PreferencesFlag.isLoggedIn, true);
  }

  void navigateToFAQ() {
    final NavigationService _navigationService = locator<NavigationService>();
    _navigationService.pushNamedAndRemoveUntil(RouterPaths.faq);
  }
}
