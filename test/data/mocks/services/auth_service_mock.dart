import 'package:mockito/annotations.dart';
import 'package:notredame/data/services/auth_service.dart';

import 'auth_service_mock.mocks.dart';

@GenerateNiceMocks([MockSpec<AuthService>()])
class AuthServiceMock extends MockAuthService {}