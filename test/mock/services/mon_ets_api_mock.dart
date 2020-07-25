// FLUTTER / DART / THIRD-PARTIES
import 'package:mockito/mockito.dart';

// MODELS
import 'package:notredame/core/models/mon_ets_user.dart';

// SERVICE
import 'package:notredame/core/services/mon_ets_api.dart';

// UTILS
import 'package:notredame/core/utils/http_exceptions.dart';

/// Mock for the [MonETSApi]
class MonETSApiMock extends Mock implements MonETSApi {
  /// Stub the user to return when a authenticate is called using the username
  /// of [userToReturn]
  static void stubAuthenticate(MonETSApiMock mock, MonETSUser userToReturn) {
    when(mock.authenticate(username: userToReturn.username, password: anyNamed('password')))
        .thenAnswer((_) async => userToReturn);
  }

  /// Stub to throw an [HttpException] when the authenticate
  /// will be called with this [username]
  static void stubAuthenticateException(
      MonETSApiMock mock, String username) {
    when(mock.authenticate(username: username, password: anyNamed('password'))).thenThrow(
        HttpException(
            code: 500, prefix: MonETSApi.tagError, message: ""));
  }
}
