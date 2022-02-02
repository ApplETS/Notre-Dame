// FLUTTER / DART / THIRD-PARTIES
import 'package:mockito/mockito.dart';

// MODELS
import 'package:ets_api_clients/models.dart';

// SERVICE
import 'package:ets_api_clients/clients.dart';

// UTILS
import 'package:ets_api_clients/exceptions.dart';

/// Mock for the [MonETSApi]
class MonETSAPIClientMock extends Mock implements MonETSAPIClient {
  /// Stub the user to return when a authenticate is called using the username
  /// of [userToReturn]
  static void stubAuthenticate(
      MonETSAPIClientMock mock, MonETSUser userToReturn) {
    when(mock.authenticate(
            username: userToReturn.username, password: anyNamed('password')))
        .thenAnswer((_) async => userToReturn);
  }

  /// Stub to throw an [HttpException] when the authenticate
  /// will be called with this [username]
  static void stubAuthenticateException(
      MonETSAPIClientMock mock, String username) {
    when(mock.authenticate(username: username, password: anyNamed('password')))
        .thenThrow(HttpException(code: 500, prefix: MonETSAPIClient.tagError));
  }

  /// Stub to throw an [Exception] when the authenticate
  /// will be called with this [username]
  static void stubException(MonETSAPIClientMock mock, String username,
      {Exception exception}) {
    exception ??= Exception();
    when(mock.authenticate(username: username, password: anyNamed('password')))
        .thenThrow(exception);
  }
}
