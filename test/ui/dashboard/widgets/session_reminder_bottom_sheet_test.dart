// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:notredame/data/models/session_reminder.dart';
import 'package:notredame/domain/session_reminder_type.dart';
import 'package:notredame/ui/dashboard/widgets/session_reminder_bottom_sheet.dart';
import '../../../helpers.dart';

void main() {
  group("SessionReminderBottomSheet -", () {
    testWidgets("displays title and all reminders", (WidgetTester tester) async {
      final reminders = [
        SessionReminder(type: SessionReminderType.registrationDeadline, date: DateTime(2025, 2, 5), daysUntil: 0),
        SessionReminder(
          type: SessionReminderType.cancellationWithRefundStart,
          date: DateTime(2025, 2, 10),
          daysUntil: 5,
        ),
        SessionReminder(type: SessionReminderType.cancellationASEQDeadline, date: DateTime(2025, 3, 25), daysUntil: 48),
      ];

      await tester.pumpWidget(localizedWidget(child: SessionReminderBottomSheet(reminders: reminders)));
      await tester.pumpAndSettle();

      expect(find.text("Upcoming Dates"), findsOneWidget);
      expect(find.text("Registration Closes"), findsOneWidget);
      expect(find.text("Cancellation with refund begins"), findsOneWidget);
      expect(find.text("ASEQ Opt-Out Ends"), findsOneWidget);
    });

    testWidgets("highlights today's reminder with Today! text", (WidgetTester tester) async {
      final reminders = [
        SessionReminder(type: SessionReminderType.registrationDeadline, date: DateTime(2025, 2, 5), daysUntil: 0),
        SessionReminder(
          type: SessionReminderType.cancellationWithRefundStart,
          date: DateTime(2025, 2, 10),
          daysUntil: 5,
        ),
      ];

      await tester.pumpWidget(localizedWidget(child: SessionReminderBottomSheet(reminders: reminders)));
      await tester.pumpAndSettle();

      expect(find.text("Today!"), findsOneWidget);
    });

    testWidgets("displays icons for each reminder type", (WidgetTester tester) async {
      final reminders = [
        SessionReminder(type: SessionReminderType.sessionStart, date: DateTime(2025, 1, 6), daysUntil: 3),
      ];

      await tester.pumpWidget(localizedWidget(child: SessionReminderBottomSheet(reminders: reminders)));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.school_outlined), findsOneWidget);
    });
  });
}
