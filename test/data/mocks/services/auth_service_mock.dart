// Package imports:
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:msal_auth/msal_auth.dart';

// Project imports:
import 'package:notredame/data/services/auth_service.dart';
import 'auth_service_mock.mocks.dart';

@GenerateNiceMocks([MockSpec<AuthService>()])
class AuthServiceMock extends MockAuthService {
  static void stubCreatePublicClientApplication(AuthServiceMock mock,
      {bool success = true}) {
    when(mock.createPublicClientApplication(
            authorityType: anyNamed('authorityType'),
            broker: anyNamed('broker')))
        .thenAnswer((_) async => (success, null));
  }

  static void stubAcquireTokenSilent(AuthServiceMock mock,
      {bool success = true}) {
    AuthenticationResult? result;
    MsalException? exception;
    if (success) {
      result = AuthenticationResult(
          accessToken: '',
          authenticationScheme: '',
          expiresOn: DateTime.now(),
          idToken: '',
          authority: '',
          tenantId: '',
          scopes: [''],
          correlationId: '',
          account: Account(id: '', username: '', name: ''));
    } else {
      exception = MsalException(message: 'Error');
    }
    when(mock.acquireTokenSilent())
        .thenAnswer((_) async => (result, exception));
  }

  static void stubAcquireToken(AuthServiceMock mock, {bool success = true}) {
    AuthenticationResult? result;
    MsalException? exception;
    if (success) {
      result = AuthenticationResult(
          accessToken: '',
          authenticationScheme: '',
          expiresOn: DateTime.now(),
          idToken: '',
          authority: '',
          tenantId: '',
          scopes: [''],
          correlationId: '',
          account: Account(id: '', username: '', name: ''));
    } else {
      exception = MsalException(message: 'Error');
    }
    when(mock.acquireToken()).thenAnswer((_) async => (result, exception));
  }

  static void stubSignOut(AuthServiceMock mock) {
    when(mock.signOut()).thenAnswer((_) async => (true, null));
  }
}
