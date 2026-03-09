// Package imports:
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

// Project imports:
import 'package:notredame/data/services/signets_client_service.dart';
import 'package:notredame/domain/models/signets-api/session.dart';
import 'package:notredame/domain/models/signets-api/signets_api_response.dart';
import 'signets_client_service_mock.mocks.dart';

@GenerateNiceMocks([MockSpec<SignetsClientService>()])
class SignetsClientServiceMock extends MockSignetsClientService {
  /// Stub the answer of the [getSessionList]
  static void stubGetSessionList(MockSignetsClientService mock, List<Session> sessionsToReturn) {
    when(mock.getSessionList()).thenAnswer((_) async => SignetsApiResponse(data: sessionsToReturn, error: ""));
  }
}
