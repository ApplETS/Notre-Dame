// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:notredame/data/models/event_data.dart';
import 'package:notredame/l10n/app_localizations.dart';
import 'package:notredame/ui/schedule/widgets/tiles/calendar_event_tile.dart';
import '../../../../helpers.dart';

void main() {
  late AppIntl intl;

  setUp(() async {
    intl = await setupAppIntl();
  });

  // Test to ensure that the title is rendered correctly.
  testWidgets('Displays the course acronym', (WidgetTester tester) async {
    final date = DateTime(2025, 3, 1);
    final start = DateTime(2025, 3, 1, 9, 0);
    final end = DateTime(2025, 3, 1, 12, 0);

    await tester.pumpWidget(
      MaterialApp(
        home: localizedWidget(
          child: Builder(
            builder: (context) {
              return CalendarEventTile(
                padding: const EdgeInsets.all(8.0),
                event: EventData(
                  courseAcronym: "GEN101",
                  courseName: "Generic course",
                  date: date,
                  startTime: start,
                  endTime: end,
                  teacherName: "John Doe",
                ),
              );
            },
          ),
        ),
      ),
    );

    expect(find.text('GEN101'), findsOneWidget);
  });

  // Test that tapping the tile shows the dialog with the expected course info.
  testWidgets('Tapping tile shows dialog with course info', (WidgetTester tester) async {
    final date = DateTime(2025, 3, 1);
    final start = DateTime(2025, 3, 1, 9, 0);
    final end = DateTime(2025, 3, 1, 12, 0);

    await tester.pumpWidget(
      localizedWidget(
        child: MaterialApp(
          home: localizedWidget(
            child: Builder(
              builder: (context) {
                return CalendarEventTile(
                  padding: const EdgeInsets.all(8.0),
                  event: EventData(
                    courseAcronym: "GEN101",
                    courseName: "Generic course",
                    date: date,
                    startTime: start,
                    endTime: end,
                    teacherName: "John Doe",
                    activityName: "Cours",
                    locations: ["D-2020"],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );

    // Tap the tile.
    await tester.tap(find.byType(CalendarEventTile));
    await tester.pumpAndSettle();

    expect(find.byType(BottomSheet), findsOneWidget);
    expect(find.text('GEN101'), findsExactly(2));
    expect(find.text('Cours'), findsOneWidget);
    expect(find.text('D-2020'), findsOneWidget);
    expect(find.textContaining('${intl.schedule_calendar_by} John Doe'), findsOneWidget);
    expect(
      find.textContaining('${intl.schedule_calendar_from_time} 9:00 ${intl.schedule_calendar_to_time} 12:00'),
      findsOneWidget,
    );
  });
}
