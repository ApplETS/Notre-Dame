import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:notredame/data/services/signets_client.dart';
import 'package:notredame/domain/models/signets-api/session.dart';
import 'package:notredame/domain/models/signets-api/signets_api_response.dart';

import 'signets_client_mock.mocks.dart';

@GenerateNiceMocks([MockSpec<SignetsClient>()])
class SignetsClientMock extends MockSignetsClient {
  /// Stub the answer of the [getSessionList]
  static void stubGetSessionList(MockSignetsClient mock, List<Session> sessionsToReturn) {
    when(mock.getSessionList()).thenAnswer((_) async => SignetsApiResponse(
          data: sessionsToReturn,
          error: "",
        ));
  }
}