// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// SERVICES
import 'package:notredame/core/models/mon_ets_user.dart';
import 'package:notredame/core/services/analytics_service.dart';
import 'package:notredame/core/services/mon_ets_api.dart';
import 'package:notredame/core/utils/http_exceptions.dart';

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
  Future<bool> authenticate(String username, String password) async {
    try {
      _monETSUser =
          await _monETSApi.authenticate(username: username, password: password);
    } catch (e) {
      if (e is! HttpException) {
        _analyticsService.logError(tag, "Authenticate - ${e.toString()}");
      }
      return false;
    }

    await _analyticsService.setUserProperties(
        userId: username, domain: _monETSUser.domaine);

    // Save the credentials in the secure storage
    await _secureStorage.write(key: usernameSecureKey, value: username);
    await _secureStorage.write(key: passwordSecureKey, value: password);

    return true;
  }
}
