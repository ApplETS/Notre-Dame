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

  group("SessionReminderCard carousel -", () {
    final reminder1 = SessionReminder(
      type: SessionReminderType.registrationStart,
      date: DateTime(2025, 1, 27),
      daysUntil: 5,
    );
    final reminder2 = SessionReminder(
      type: SessionReminderType.registrationDeadline,
      date: DateTime(2025, 1, 27),
      daysUntil: 5,
    );
    final sameDayReminders = [reminder1, reminder2];

    testWidgets("renders PageView with multiple same-day reminders", (WidgetTester tester) async {
      await tester.pumpWidget(
        localizedWidget(
          child: SessionReminderCard(
            reminder: reminder1,
            loading: false,
            allReminders: sameDayReminders,
            sameDayReminders: sameDayReminders,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(PageView), findsOneWidget);
    });

    testWidgets("dot indicators appear for carousel", (WidgetTester tester) async {
      await tester.pumpWidget(
        localizedWidget(
          child: SessionReminderCard(
            reminder: reminder1,
            loading: false,
            allReminders: sameDayReminders,
            sameDayReminders: sameDayReminders,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Should have 2 AnimatedContainer dot indicators
      expect(find.byType(AnimatedContainer), findsNWidgets(2));
    });

    testWidgets("swiping changes displayed content", (WidgetTester tester) async {
      await tester.pumpWidget(
        localizedWidget(
          child: SessionReminderCard(
            reminder: reminder1,
            loading: false,
            allReminders: sameDayReminders,
            sameDayReminders: sameDayReminders,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // First page shows registration start
      expect(find.text("Registration Opens"), findsOneWidget);

      // Swipe left to go to second page
      await tester.drag(find.byType(PageView), const Offset(-400, 0));
      await tester.pumpAndSettle();

      // Second page shows registration deadline
      expect(find.text("Registration Closes"), findsOneWidget);
    });

    testWidgets("auto-scroll advances after 5 seconds", (WidgetTester tester) async {
      await tester.pumpWidget(
        localizedWidget(
          child: SessionReminderCard(
            reminder: reminder1,
            loading: false,
            allReminders: sameDayReminders,
            sameDayReminders: sameDayReminders,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // First page shows registration start
      expect(find.text("Registration Opens"), findsOneWidget);

      // Advance timer by 5 seconds to trigger auto-scroll
      await tester.pump(const Duration(seconds: 5));
      // Let the animation complete
      await tester.pumpAndSettle();

      // Second page should now be visible
      expect(find.text("Registration Closes"), findsOneWidget);
    });

    testWidgets("tap on carousel opens bottom sheet", (WidgetTester tester) async {
      await tester.pumpWidget(
        localizedWidget(
          child: SessionReminderCard(
            reminder: reminder1,
            loading: false,
            allReminders: sameDayReminders,
            sameDayReminders: sameDayReminders,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(SessionReminderCard));
      await tester.pumpAndSettle();

      expect(find.text("Upcoming Dates"), findsOneWidget);
    });

    testWidgets("single reminder does not render PageView", (WidgetTester tester) async {
      final singleReminder = [reminder1];

      await tester.pumpWidget(
        localizedWidget(
          child: SessionReminderCard(
            reminder: reminder1,
            loading: false,
            allReminders: singleReminder,
            sameDayReminders: singleReminder,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(PageView), findsNothing);
      expect(find.text("Registration Opens"), findsOneWidget);
    });
  });
}
