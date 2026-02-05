// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:notredame/data/models/calendar_event_tile.dart';
import 'package:notredame/l10n/app_localizations.dart';
import 'package:notredame/ui/student/session_schedule/widgets/session_schedule.dart';
import '../../../../helpers.dart';

void main() {
  late AppIntl intl;

  group('ScheduleDefault Tests', () {
    setUpAll(() async {
      intl = await setupAppIntl();
    });

    testWidgets('Displays no schedule message when there are no events', (WidgetTester tester) async {
      await tester.pumpWidget(
        localizedWidget(
          child: const SessionSchedule(calendarEvents: [], loaded: true, displaySaturday: false, displaySunday: false),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text(intl.no_schedule_available), findsOneWidget);
      expect(find.text("S"), findsNothing);
      expect(find.text("D"), findsNothing);
    });

    testWidgets('Displays saturday', (WidgetTester tester) async {
      await tester.pumpWidget(
        localizedWidget(
          child: SessionSchedule(
            calendarEvents: [EventData(title: "My Event", date: DateTime(2024))],
            loaded: true,
            displaySaturday: true,
            displaySunday: false,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text("S"), findsOneWidget);
    });

    testWidgets('Displays sunday', (WidgetTester tester) async {
      await tester.pumpWidget(
        localizedWidget(
          child: SessionSchedule(
            calendarEvents: [EventData(title: "My Event", date: DateTime(2024))],
            loaded: true,
            displaySaturday: false,
            displaySunday: true,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text("D"), findsOneWidget);
    });

    testWidgets('Displays no weekend day', (WidgetTester tester) async {
      await tester.pumpWidget(
        localizedWidget(
          child: SessionSchedule(
            calendarEvents: [EventData(title: "My Event", date: DateTime(2024))],
            loaded: true,
            displaySaturday: false,
            displaySunday: false,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text("S"), findsNothing);
      expect(find.text("D"), findsNothing);
    });

    testWidgets('Displays no empty schedule message when loading', (WidgetTester tester) async {
      await tester.pumpWidget(
        localizedWidget(
          child: const SessionSchedule(calendarEvents: [], loaded: false, displaySaturday: false, displaySunday: false),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text(intl.no_schedule_available), findsNothing);
    });
  });
}
