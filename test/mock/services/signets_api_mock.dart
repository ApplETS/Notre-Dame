// FLUTTER / DART / THIRD-PARTIES
import 'package:mockito/mockito.dart';

// MODELS
import 'package:notredame/core/models/course_activity.dart';

// SERVICE
import 'package:notredame/core/services/signets_api.dart';

/// Mock for the [SignetsApi]
class SignetsApiMock extends Mock implements SignetsApi {
  /// Stub the answer of the [getCoursesActivities] when the [session] is used.
  static void stubGetCoursesSessions(SignetsApiMock mock, String session,
      List<CourseActivity> sessionsToReturn) {
    when(mock.getCoursesActivities(username: any, password: any, session: session))
        .thenAnswer((_) async => sessionsToReturn);
  }
}
