// FLUTTER / DART / THIRD-PARTIES
import 'package:mockito/mockito.dart';

// SERVICE
import 'package:notredame/core/managers/user_repository.dart';

/// Mock for the [UserRepository]
class UserRepositoryMock extends Mock implements UserRepository {
  /// Stub the authentication, when [username] is used will return [toReturn].
  /// By default validate the authentication
  static void stubAuthenticate(UserRepositoryMock mock, String username, {bool toReturn = true}) {
    when(mock.authenticate(username: username, password: anyNamed('password')))
        .thenAnswer((_) async => toReturn);
  }

  /// Stub the silent authentication, return [toReturn]
  /// By default validate the silent authentication
  static void stubSilentAuthenticate(UserRepositoryMock mock, {bool toReturn = true}) {
    when(mock.silentAuthenticate())
        .thenAnswer((_) async => toReturn);
  }
}