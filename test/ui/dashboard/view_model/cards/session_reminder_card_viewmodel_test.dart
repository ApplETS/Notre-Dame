// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

// Project imports:
import 'package:notredame/data/services/signets-api/models/session.dart';
import 'package:notredame/ui/dashboard/view_model/cards/session_reminder_card_viewmodel.dart';
import '../../../../data/mocks/repositories/course_repository_mock.dart';
import '../../../../helpers.dart';

void main() {
  late CourseRepositoryMock courseRepositoryMock;
  late SessionReminderCardViewmodel viewModel;

  final Session session = Session(
    shortName: "H2099",
    name: "Hiver 2099",
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
      courseRepositoryMock = setupCourseRepositoryMock();
      viewModel = SessionReminderCardViewmodel(intl: await setupAppIntl());

      CourseRepositoryMock.stubGetSessions(courseRepositoryMock, toReturn: [session]);
      CourseRepositoryMock.stubSessions(courseRepositoryMock, toReturn: [session]);
      CourseRepositoryMock.stubActiveSessions(courseRepositoryMock, toReturn: [session]);
    });

    test("Should compute reminders when active session exists", () async {
      await viewModel.futureToRun();

      expect(viewModel.sessionReminder, isNotNull);
      expect(viewModel.allSessionReminders, isNotEmpty);
      expect(viewModel.carouselReminders, isNotEmpty);
    });

    test("Should have empty reminders when no active sessions", () async {
      CourseRepositoryMock.stubActiveSessions(courseRepositoryMock, toReturn: []);
      await viewModel.futureToRun();

      expect(viewModel.sessionReminder, isNull);
      expect(viewModel.allSessionReminders, isEmpty);
      expect(viewModel.carouselReminders, isEmpty);
    });

    test("Should call getSessions when sessions are not loaded", () async {
      CourseRepositoryMock.stubSessions(courseRepositoryMock, toReturn: []);
      await viewModel.futureToRun();

      verify(courseRepositoryMock.getSessions()).called(1);
    });

    test("Should not call getSessions when sessions are already loaded", () async {
      await viewModel.futureToRun();

      verifyNever(courseRepositoryMock.getSessions());
    });

    test("Should handle repository exception gracefully", () async {
      setupFlutterToastMock();
      CourseRepositoryMock.stubSessions(courseRepositoryMock, toReturn: []);
      CourseRepositoryMock.stubGetSessionsException(courseRepositoryMock);

      try {
        await viewModel.futureToRun();
      } catch (_) {}

      expect(viewModel.sessionReminder, isNull);
      expect(viewModel.allSessionReminders, isEmpty);
    });
  });
}
