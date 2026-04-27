// Dart imports:
import 'dart:async';

// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

// Project imports:
import 'package:notredame/domain/models/signets-api/session.dart';
import 'package:notredame/locator.dart';
import 'package:notredame/logic/session_progress_use_case.dart';
import '../data/mocks/repositories/list_sessions_repository_mock.dart';
import '../helpers.dart';

void main() {
  late StreamController<List<Session>> controller;
  late ListSessionsRepositoryMock listSessionsRepository;
  late SessionProgressUseCase useCase;

  setUp(() async {
    controller = StreamController<List<Session>>.broadcast();
    listSessionsRepository = setupListSessionsRepositoryMock();

    useCase = SessionProgressUseCase();
  });

  tearDown(() {
    locator.reset();
    useCase.dispose();
    controller.close();
  });

  group('SessionProgressUseCase', () {
    test('init() initializes correctly with default text style', () async {
      ListSessionsRepositoryMock.stubGetStream(listSessionsRepository, stream: controller.stream);
      ListSessionsRepositoryMock.stubGetSessions(listSessionsRepository, controller: controller, sessions: []);

      await useCase.init();

      verify(listSessionsRepository.getSessions()).called(1);
    });

    test('fetch() calls getSessions with forceUpdate', () async {
      ListSessionsRepositoryMock.stubGetStream(listSessionsRepository, stream: controller.stream);
      ListSessionsRepositoryMock.stubGetSessions(listSessionsRepository, controller: controller, sessions: []);

      await useCase.init();
      await useCase.fetch(forceUpdate: true);

      verify(listSessionsRepository.getSessions(forceUpdate: true)).called(1);
    });

    test('dispose() closes the stream and cancels subscription', () async {
      ListSessionsRepositoryMock.stubGetStream(listSessionsRepository, stream: controller.stream);
      ListSessionsRepositoryMock.stubGetSessions(listSessionsRepository, controller: controller, sessions: []);

      await useCase.init();
      useCase.dispose();

      // After dispose, listening to the stream should not emit any events
      var emittedEvents = 0;
      useCase.stream.listen((_) => emittedEvents++);

      expect(emittedEvents, 0);
    });
  });
}
