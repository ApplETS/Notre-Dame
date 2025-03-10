import 'package:logger/logger.dart';
import 'package:msal_auth/msal_auth.dart';
import 'package:notredame/data/services/remote_config_service.dart';
import 'package:notredame/locator.dart';

class AuthService {
  String? _token;
  final int _maxRetry = 3;
  int _retries = 0;

  final _scopes = [
    'api://etsmobileapi/access_as_user',
  ];

  SingleAccountPca? singleAccountPca;
  final _remoteConfigService = locator<RemoteConfigService>();
  final Logger _logger = locator<Logger>();

  Future<String> getToken() async {
    if (_token == null) {
      final result = await acquireTokenSilent();
      if (result.$1 != null) {
        _token = result.$1?.accessToken;
      } else {
        _retries++;
        if(_retries > _maxRetry) {
          _retries = 0;
          throw Exception('Max retries reached');
        }
        getToken();
      }
    }
    _retries = 0;
    return _token!;
  }

  Future<(bool, MsalException?)> createPublicClientApplication({
    required AuthorityType authorityType,
    required Broker broker,
  }) async {
    final androidConfig = AndroidConfig(
      configFilePath: 'assets/msal_config.json',
      redirectUri: await _remoteConfigService.aadAndroidRedirectUri,
    );

    final appleConfig = AppleConfig(
      authority: await _remoteConfigService.aadAppleAuthority,
      authorityType: authorityType,
      broker: broker,
    );

    try {
      singleAccountPca = await SingleAccountPca.create(
        clientId: await _remoteConfigService.aadClientId,
        androidConfig: androidConfig,
        appleConfig: appleConfig,
      );
      return (true, null);
    } on MsalException catch (e) {
      _logger.e('Create public client application failed => ${e.message}');
      return (false, e);
    }
  }

  Future<(AuthenticationResult?, MsalException?)> acquireToken({
    String? loginHint,
  }) async {
    try {
      final result = await singleAccountPca?.acquireToken(
        scopes: _scopes,
        loginHint: loginHint,
        prompt: Prompt.login,
      );
      _token = result?.accessToken;
      _logger.d('Acquire token => ${result?.toJson()}');
      return (result, null);
    } on MsalException catch (e) {
      _logger.e('Acquire token failed => $e');
      return (null, e);
    }
  }

  Future<(AuthenticationResult?, MsalException?)> acquireTokenSilent({
    String? identifier,
  }) async {
    try {
      final result = await singleAccountPca?.acquireTokenSilent(
        scopes: _scopes,
        identifier: identifier,
      );
      _token = result?.accessToken;
      _logger.d('Acquire token silent => ${result?.toJson()}');
      return (result, null);
    } on MsalException catch (e) {
      _logger.e('Acquire token silent failed => $e');

      // If it is a UI required exception, try to acquire token interactively.
      if (e is MsalUiRequiredException) {
        return acquireToken();
      }
      return (null, e);
    }
  }

  Future<(Account?, MsalException?)> getCurrentAccount() async {
    try {
      final result = await singleAccountPca?.currentAccount;
      _logger.d('Current account => ${result?.toJson()}');
      return (result, null);
    } on MsalException catch (e) {
      _logger.e('Current account failed => $e');
      return (null, e);
    }
  }

  Future<(bool, MsalException?)> signOut() async {
    try {
      _token = null;
      final result = await singleAccountPca?.signOut();
      _logger.d('Sign out => $result');
      return (true, null);
    } on MsalException catch (e) {
      _logger.e('Sign out failed => $e');
      return (false, e);
    }
  }

}