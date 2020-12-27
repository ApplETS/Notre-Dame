// FLUTTER / DART / THIRD-PARTIES
import 'package:mockito/mockito.dart';

// MODELS
import 'package:notredame/core/models/class_session.dart';

// SERVICE
import 'package:notredame/core/services/signets_api.dart';

/// Mock for the [SignetsApi]
class SignetsApiMock extends Mock implements SignetsApi {
  /// Stub the answer of the [getClassSessions] when the [session] is used.
  static void stubGetCoursesSessions(SignetsApiMock mock, String session,
      List<ClassSession> sessionsToReturn) {
    when(mock.getClassSessions(username: any, password: any, session: session))
        .thenAnswer((_) async => sessionsToReturn);
  }
}
