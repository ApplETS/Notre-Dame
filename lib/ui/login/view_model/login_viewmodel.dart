//

// Package imports:
import 'package:fluttertoast/fluttertoast.dart';
import 'package:msal_auth/msal_auth.dart';
import 'package:stacked/stacked.dart';

// Project imports:
import 'package:notredame/data/repositories/settings_repository.dart';
import 'package:notredame/data/services/analytics_service.dart';
import 'package:notredame/data/services/auth_service.dart';
import 'package:notredame/data/services/navigation_service.dart';
import 'package:notredame/domain/constants/router_paths.dart';
import 'package:notredame/l10n/app_localizations.dart';
import 'package:notredame/locator.dart';

class LoginViewModel extends BaseViewModel {
  /// Localization class of the application.
  final AppIntl _appIntl;

  final SettingsRepository _settingsManager = locator<SettingsRepository>();
  final AuthService _authService = locator<AuthService>();
  final NavigationService navigationService = locator<NavigationService>();
  final AnalyticsService _analyticsService = locator<AnalyticsService>();

  LoginViewModel({required AppIntl intl}) : _appIntl = intl;

  Future authenticate() async {
    AuthenticationResult? token;

    token = (await _authService.acquireToken()).$1;
    if (token == null) {
      Fluttertoast.showToast(msg: _appIntl.startup_viewmodel_acquire_token_fail, toastLength: Toast.LENGTH_LONG);
      await _analyticsService.logError('LoginViewmodel', 'Failed to acquire token');
      return false;
    }

    _settingsManager.isLoggedIn = true;

    navigationService.pushNamedAndRemoveUntil(RouterPaths.startup);
  }
}
