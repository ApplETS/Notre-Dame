// Dart imports:
import 'dart:async';

// Package imports:
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

// Project imports:
import 'package:notredame/data/repositories/list_sessions_repository.dart';
import 'package:notredame/domain/models/signets-api/session.dart';
import 'list_sessions_repository_mock.mocks.dart';

@GenerateNiceMocks([MockSpec<ListSessionsRepository>()])
class ListSessionsRepositoryMock extends MockListSessionsRepository {
  static void stubGetSessions(
    ListSessionsRepositoryMock mock, {
    required StreamController<List<Session>> controller,
    required List<Session> sessions,
  }) {
    when(mock.getSessions()).thenAnswer((_) async {
      controller.add(sessions);
    });
  }

  static void stubGetActiveSession(ListSessionsRepositoryMock mock, {Session? session}) {
    when(mock.getActiveSession()).thenAnswer((_) => session);
  }

  static void stubGetStream(ListSessionsRepositoryMock mock, {required Stream<List<Session>?> stream}) {
    when(mock.stream).thenAnswer((_) => stream);
  }
}
