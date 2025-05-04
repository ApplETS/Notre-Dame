import 'package:flutter_test/flutter_test.dart';
import 'package:notredame/domain/models/signets-api/session.dart';

void main() {
  final session = Session(
    shortName: "H2025",
    longName: "Hiver 2025",
    startDate: DateTime.now().subtract(const Duration(days: 100)),
    endDate: DateTime.now().add(const Duration(days: 5)),
    endDateCourses: DateTime(2025, 04, 12),
    startDateRegistration: DateTime(2024, 10, 28),
    deadlineRegistration: DateTime(2024, 11, 12),
    startDateCancellationWithRefund: DateTime(2025, 01, 06),
    deadlineCancellationWithRefund: DateTime(2025, 01, 19),
    deadlineCancellationWithRefundNewStudent: DateTime(2025, 02, 02),
    startDateCancellationWithoutRefundNewStudent: DateTime(2025, 02, 03),
    deadlineCancellationWithoutRefundNewStudent: DateTime(2025, 03, 17),
    deadlineCancellationASEQ: DateTime(2025,01, 31)
  );

  group("Session - ", () {
    test("Days completed should return correct value", () {
      expect(session.daysCompleted, 100, 
          reason: "The number of days completed should be 100");
    });

    test("Total days should return correct value", () {
      expect(session.totalDays, 105, 
          reason: "The number of days completed should be 100");
    });
  });
}