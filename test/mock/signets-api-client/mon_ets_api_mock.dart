// FLUTTER / DART / THIRD-PARTIES

// Package imports:
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

// Project imports:
import 'package:notredame/features/app/monets_api/models/mon_ets_user.dart';
import 'package:notredame/features/app/monets_api/monets_api_client.dart';
import 'package:notredame/utils/http_exception.dart';
import 'mon_ets_api_mock.mocks.dart';

// UTILS


/// Mock of the [MonETSApiClient]
@GenerateNiceMocks([MockSpec<MonETSAPIClient>()])
class MonETSAPIClientMock extends MockMonETSAPIClient {
  /// Stub the user to return when a authenticate is called using the username
  /// of [userToReturn]
  static void stubAuthenticate(MonETSAPIClientMock mock, MonETSUser userToReturn) {
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
      {Exception? exception}) {
    exception ??= Exception();
    when(mock.authenticate(username: username, password: anyNamed('password')))
        .thenThrow(exception);
  }
}
