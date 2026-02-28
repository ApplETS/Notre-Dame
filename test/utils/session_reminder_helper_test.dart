// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:notredame/data/services/signets-api/models/session.dart';
import 'package:notredame/domain/session_reminder_type.dart';
import 'package:notredame/utils/session_reminder_helper.dart';

void main() {
  late Session session;

  setUp(() {
    session = Session(
      shortName: "H2025",
      name: "Hiver 2025",
      startDate: DateTime(2025, 1, 6),
      endDate: DateTime(2025, 4, 25),
      endDateCourses: DateTime(2025, 4, 15),
      startDateRegistration: DateTime(2025, 1, 10),
      deadlineRegistration: DateTime(2025, 2, 5),
      startDateCancellationWithRefund: DateTime(2025, 2, 10),
      deadlineCancellationWithRefund: DateTime(2025, 3, 15),
      deadlineCancellationWithRefundNewStudent: DateTime(2025, 3, 20),
      startDateCancellationWithoutRefundNewStudent: DateTime(2025, 3, 21),
      deadlineCancellationWithoutRefundNewStudent: DateTime(2025, 4, 10),
      deadlineCancellationASEQ: DateTime(2025, 3, 25),
    );
  });

  group("SessionReminderHelper -", () {
    test("returns sessionStart when today is before session start", () {
      final now = DateTime(2025, 1, 3);
      final result = SessionReminderHelper.getActiveReminder(session, now);

      expect(result, isNotNull);
      expect(result!.type, SessionReminderType.sessionStart);
      expect(result.daysUntil, 3);
    });

    test("returns sessionStart when today is the session start date", () {
      final now = DateTime(2025, 1, 6);
      final result = SessionReminderHelper.getActiveReminder(session, now);

      expect(result, isNotNull);
      expect(result!.type, SessionReminderType.sessionStart);
      expect(result.daysUntil, 0);
    });

    test("returns registrationStart after session start has passed", () {
      final now = DateTime(2025, 1, 7);
      final result = SessionReminderHelper.getActiveReminder(session, now);

      expect(result, isNotNull);
      expect(result!.type, SessionReminderType.registrationStart);
    });

    test("returns registrationDeadline after registration start has passed", () {
      final now = DateTime(2025, 1, 11);
      final result = SessionReminderHelper.getActiveReminder(session, now);

      expect(result, isNotNull);
      expect(result!.type, SessionReminderType.registrationDeadline);
    });

    test("returns cancellationWithRefundStart after registration deadline passed", () {
      final now = DateTime(2025, 2, 6);
      final result = SessionReminderHelper.getActiveReminder(session, now);

      expect(result, isNotNull);
      expect(result!.type, SessionReminderType.cancellationWithRefundStart);
    });

    test("returns cancellationWithRefundDeadline", () {
      final now = DateTime(2025, 2, 11);
      final result = SessionReminderHelper.getActiveReminder(session, now);

      expect(result, isNotNull);
      expect(result!.type, SessionReminderType.cancellationWithRefundDeadline);
    });

    test("returns cancellationWithRefundNewStudentDeadline", () {
      final now = DateTime(2025, 3, 16);
      final result = SessionReminderHelper.getActiveReminder(session, now);

      expect(result, isNotNull);
      expect(result!.type, SessionReminderType.cancellationWithRefundNewStudentDeadline);
    });

    test("returns cancellationWithoutRefundNewStudentStart", () {
      final now = DateTime(2025, 3, 21);
      final result = SessionReminderHelper.getActiveReminder(session, now);

      expect(result, isNotNull);
      expect(result!.type, SessionReminderType.cancellationWithoutRefundNewStudentStart);
    });

    test("returns cancellationASEQDeadline", () {
      final now = DateTime(2025, 3, 22);
      final result = SessionReminderHelper.getActiveReminder(session, now);

      expect(result, isNotNull);
      expect(result!.type, SessionReminderType.cancellationASEQDeadline);
    });

    test("returns cancellationWithoutRefundNewStudentDeadline", () {
      final now = DateTime(2025, 3, 26);
      final result = SessionReminderHelper.getActiveReminder(session, now);

      expect(result, isNotNull);
      expect(result!.type, SessionReminderType.cancellationWithoutRefundNewStudentDeadline);
    });

    test("returns null when all dates have passed", () {
      final now = DateTime(2025, 4, 11);
      final result = SessionReminderHelper.getActiveReminder(session, now);

      expect(result, isNull);
    });

    test("computes correct daysUntil for future event", () {
      final now = DateTime(2025, 1, 3);
      final result = SessionReminderHelper.getActiveReminder(session, now);

      expect(result, isNotNull);
      expect(result!.daysUntil, 3);
    });

    test("daysUntil is 0 when event is today", () {
      final now = DateTime(2025, 2, 5);
      final result = SessionReminderHelper.getActiveReminder(session, now);

      expect(result, isNotNull);
      expect(result!.type, SessionReminderType.registrationDeadline);
      expect(result.daysUntil, 0);
    });

    test("ignores time component for date comparison", () {
      final now = DateTime(2025, 1, 6, 23, 59, 59);
      final result = SessionReminderHelper.getActiveReminder(session, now);

      expect(result, isNotNull);
      expect(result!.type, SessionReminderType.sessionStart);
      expect(result.daysUntil, 0);
    });
  });
}
