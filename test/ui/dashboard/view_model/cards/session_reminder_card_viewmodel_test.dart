// Dart imports:
import 'dart:async';

// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

// Project imports:
import 'package:notredame/domain/models/signets-api/session.dart';
import 'package:notredame/ui/dashboard/view_model/cards/session_reminder_card_viewmodel.dart';
import '../../../../data/mocks/repositories/list_sessions_repository_mock.dart';
import '../../../../helpers.dart';

void main() {
  late ListSessionsRepositoryMock listSessionsRepositoryMock;
  late StreamController<List<Session>> streamController;
  late SessionReminderCardViewmodel viewModel;

  final Session session = Session(
    shortName: "H2099",
    longName: "Hiver 2099",
    startDate: DateTime(2099, 1, 6),
    endDate: DateTime(2099, 4, 25),
    endDateCourses: DateTime(2099, 4, 14),
    startDateRegistration: DateTime(2098, 10, 28),
    deadlineRegistration: DateTime(2098, 11, 11),
    startDateCancellationWithRefund: DateTime(2099, 1, 20),
    deadlineCancellationWithRefund: DateTime(2099, 2, 3),
    deadlineCancellationWithRefundNewStudent: DateTime(2099, 2, 3),
    startDateCancellationWithoutRefundNewStudent: DateTime(2099, 2, 4),
    deadlineCancellationWithoutRefundNewStudent: DateTime(2099, 3, 14),
    deadlineCancellationASEQ: DateTime(2099, 1, 31),
  );

  TestWidgetsFlutterBinding.ensureInitialized();

  group("SessionReminderCardViewmodel - ", () {
    setUp(() async {
      listSessionsRepositoryMock = setupListSessionsRepositoryMock();
      streamController = StreamController<List<Session>>.broadcast();

      ListSessionsRepositoryMock.stubGetStream(listSessionsRepositoryMock, stream: streamController.stream);
      ListSessionsRepositoryMock.stubGetSessions(
        listSessionsRepositoryMock,
        controller: streamController,
        sessions: [],
      );

      ListSessionsRepositoryMock.stubGetActiveSession(listSessionsRepositoryMock, session: session);

      viewModel = SessionReminderCardViewmodel(intl: await setupAppIntl());
    });

    tearDown(() {
      streamController.close();
    });

    test("Should compute reminders when active session exists", () async {
      await viewModel.futureToRun();

      expect(viewModel.sessionReminder, isNotNull);
      expect(viewModel.allSessionReminders, isNotEmpty);
      expect(viewModel.carouselReminders, isNotEmpty);
    });

    test("Should have empty reminders when no active sessions", () async {
      ListSessionsRepositoryMock.stubGetActiveSession(listSessionsRepositoryMock, session: null);
      await viewModel.futureToRun();

      expect(viewModel.sessionReminder, isNull);
      expect(viewModel.allSessionReminders, isEmpty);
      expect(viewModel.carouselReminders, isEmpty);
    });

    test("Should subscribe to ListSessionsRepository stream", () async {
      await viewModel.futureToRun();
      await Future.delayed(Duration.zero);

      verify(listSessionsRepositoryMock.getSessions()).called(1);
    });

    test("Should recalculate reminders when stream emits new data", () async {
      ListSessionsRepositoryMock.stubGetActiveSession(listSessionsRepositoryMock, session: null);
      await viewModel.futureToRun();

      expect(viewModel.sessionReminder, isNull);

      ListSessionsRepositoryMock.stubGetActiveSession(listSessionsRepositoryMock, session: session);
      streamController.add([]);

      await Future.delayed(Duration.zero);

      expect(viewModel.sessionReminder, isNotNull);
      expect(viewModel.allSessionReminders, isNotEmpty);
      expect(viewModel.carouselReminders, isNotEmpty);
    });

    test("Should cancel subscription on dispose", () async {
      await viewModel.futureToRun();

      viewModel.dispose();

      ListSessionsRepositoryMock.stubGetActiveSession(listSessionsRepositoryMock, session: null);
      streamController.add([]);
      await Future.delayed(Duration.zero);

      expect(viewModel.sessionReminder, isNotNull);
    });

    test("Should handle repository exception gracefully when no cached data", () async {
      setupFlutterToastMock();
      ListSessionsRepositoryMock.stubGetActiveSession(listSessionsRepositoryMock, session: null);
      when(listSessionsRepositoryMock.getSessions()).thenThrow(Exception("test"));

      try {
        await viewModel.futureToRun();
      } catch (_) {}

      expect(viewModel.sessionReminder, isNull);
      expect(viewModel.allSessionReminders, isEmpty);
    });

    test("Should still show cached reminders when repository throws", () async {
      setupFlutterToastMock();
      when(listSessionsRepositoryMock.getSessions()).thenThrow(Exception("test"));

      await viewModel.futureToRun();
      await Future.delayed(Duration.zero);

      expect(viewModel.sessionReminder, isNotNull);
      expect(viewModel.allSessionReminders, isNotEmpty);
    });
  });
}
