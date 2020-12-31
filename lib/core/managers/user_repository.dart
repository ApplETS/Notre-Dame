// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// SERVICES
import 'package:notredame/core/models/mon_ets_user.dart';
import 'package:notredame/core/services/analytics_service.dart';
import 'package:notredame/core/services/mon_ets_api.dart';
import 'package:notredame/core/utils/api_exception.dart';

// OTHER
import 'package:notredame/locator.dart';

class UserRepository {
  static const String tag = "UserRepository";

  static const String usernameSecureKey = "usernameKey";
  static const String passwordSecureKey = "passwordKey";

  final MonETSApi _monETSApi = locator<MonETSApi>();
  final AnalyticsService _analyticsService = locator<AnalyticsService>();
  final FlutterSecureStorage _secureStorage = locator<FlutterSecureStorage>();

  MonETSUser _monETSUser;

  MonETSUser get monETSUser => _monETSUser;

  /// Authenticate the user using the [username] (for a student should be the
  /// universal code like AAXXXXX).
  /// If the authentication is successful the credentials ([username] and [password])
  /// will be saved in the secure storage of the device to authorize a silent
  /// authentication next time.
  Future<bool> authenticate({@required String username, @required String password, bool isSilent = false}) async {
    try {
      _monETSUser =
          await _monETSApi.authenticate(username: username, password: password);
    } catch (e) {
      _analyticsService.logError(tag, "Authenticate - ${e.toString()}");
      return false;
    }

    await _analyticsService.setUserProperties(
        userId: username, domain: _monETSUser.domain);

    // Save the credentials in the secure storage
    if(!isSilent) {
      try {
        await _secureStorage.write(key: usernameSecureKey, value: username);
        await _secureStorage.write(key: passwordSecureKey, value: password);
      } on PlatformException catch (e) {
        _analyticsService.logError(tag, "Authenticate - PlatformException - ${e.toString()}");
        return false;
      }
    }

    return true;
  }

  /// Check if there are credentials saved and so authenticate the user, otherwise
  /// return false
  Future<bool> silentAuthenticate() async {
    final String username = await _secureStorage.read(key: usernameSecureKey);

    if(username != null) {
      final String password = await _secureStorage.read(key: passwordSecureKey);

      return authenticate(username: username, password: password, isSilent: true);
    }

    return false;
  }

  /// Log out the user
  Future<bool> logOut() async {
    _monETSUser = null;

    // Delete the credentials from the secure storage
    try {
      await _secureStorage.delete(key: usernameSecureKey);
      await _secureStorage.delete(key: passwordSecureKey);
    } on PlatformException catch (e) {
      _analyticsService.logError(tag, "Authenticate - PlatformException - ${e.toString()}");
      return false;
    }
    return true;
  }

  /// Retrieve and get the password for the current authenticated user.
  /// WARNING This isn't a good practice but currently the password has to be sent in clear.
  Future<String> getPassword() async {
    if(_monETSUser == null) {
      _analyticsService.logEvent(tag, "Trying to acquire password but not authenticated");
      final result = await silentAuthenticate();

      if(!result) {
        throw const ApiException(prefix: tag, message: "Not authenticated");
      }
    }

    final String password = await _secureStorage.read(key: passwordSecureKey);

    return password;
  }
}
