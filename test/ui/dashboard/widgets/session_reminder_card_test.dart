// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:notredame/data/models/session_reminder.dart';
import 'package:notredame/domain/session_reminder_type.dart';
import 'package:notredame/ui/dashboard/widgets/session_reminder_card.dart';
import '../../../helpers.dart';

void main() {
  group("SessionReminderCard -", () {
    testWidgets("displays event name and 'Today!' when daysUntil is 0", (WidgetTester tester) async {
      final reminder = SessionReminder(
        type: SessionReminderType.registrationDeadline,
        date: DateTime(2025, 2, 5),
        daysUntil: 0,
      );

      await tester.pumpWidget(
        localizedWidget(
          child: SessionReminderCard(reminder: reminder, loading: false, allReminders: [reminder]),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text("Registration Closes"), findsOneWidget);
      expect(find.text("Today!"), findsOneWidget);
      expect(find.byIcon(Icons.assignment_late_outlined), findsOneWidget);
    });

    testWidgets("displays event name with countdown and date for future event", (WidgetTester tester) async {
      final reminder = SessionReminder(
        type: SessionReminderType.sessionStart,
        date: DateTime(2025, 1, 15),
        daysUntil: 5,
      );

      await tester.pumpWidget(
        localizedWidget(
          child: SessionReminderCard(reminder: reminder, loading: false, allReminders: [reminder]),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text("Session Starts"), findsOneWidget);
      expect(find.textContaining("5 days"), findsOneWidget);
      expect(find.byIcon(Icons.school_outlined), findsOneWidget);
    });

    testWidgets("displays 'Tomorrow' when daysUntil is 1", (WidgetTester tester) async {
      final reminder = SessionReminder(
        type: SessionReminderType.sessionStart,
        date: DateTime(2025, 1, 15),
        daysUntil: 1,
      );

      await tester.pumpWidget(
        localizedWidget(
          child: SessionReminderCard(reminder: reminder, loading: false, allReminders: [reminder]),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining("Tomorrow"), findsOneWidget);
    });

    testWidgets("displays empty state when reminder is null", (WidgetTester tester) async {
      await tester.pumpWidget(localizedWidget(child: const SessionReminderCard(reminder: null, loading: false)));
      await tester.pumpAndSettle();

      expect(find.text("No reminders"), findsOneWidget);
    });

    testWidgets("displays skeleton when loading", (WidgetTester tester) async {
      await tester.pumpWidget(localizedWidget(child: const SessionReminderCard(reminder: null, loading: true)));
      await tester.pump();

      // Should not show the empty state text when loading
      expect(find.text("No reminders"), findsNothing);
    });

    testWidgets("tap opens bottom sheet when allReminders is not empty", (WidgetTester tester) async {
      final reminder = SessionReminder(
        type: SessionReminderType.registrationDeadline,
        date: DateTime(2025, 2, 5),
        daysUntil: 3,
      );
      final reminder2 = SessionReminder(
        type: SessionReminderType.cancellationWithRefundStart,
        date: DateTime(2025, 2, 10),
        daysUntil: 8,
      );

      await tester.pumpWidget(
        localizedWidget(
          child: SessionReminderCard(reminder: reminder, loading: false, allReminders: [reminder, reminder2]),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(SessionReminderCard));
      await tester.pumpAndSettle();

      expect(find.text("Upcoming Dates"), findsOneWidget);
      // "Registration Closes" appears in both the card and bottom sheet
      expect(find.text("Registration Closes"), findsNWidgets(2));
      expect(find.text("Cancellation with refund begins"), findsOneWidget);
    });
  });
}
