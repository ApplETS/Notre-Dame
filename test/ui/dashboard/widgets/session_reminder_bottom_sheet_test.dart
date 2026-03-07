// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:notredame/data/models/session_reminder.dart';
import 'package:notredame/domain/session_reminder_type.dart';
import 'package:notredame/l10n/app_localizations.dart';
import 'package:notredame/ui/dashboard/widgets/session_reminder_bottom_sheet.dart';
import '../../../helpers.dart';

void main() {
  late AppIntl intl;

  setUp(() async {
    intl = await setupAppIntl();
  });

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

      expect(find.text(intl.session_reminder_bottom_sheet_title), findsOneWidget);
      expect(find.text(intl.session_reminder_registration_deadline), findsOneWidget);
      expect(find.text(intl.session_reminder_cancellation_refund_start), findsOneWidget);
      expect(find.text(intl.session_reminder_cancellation_aseq), findsOneWidget);
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

      expect(find.text(intl.session_reminder_today), findsOneWidget);
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
