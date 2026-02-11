// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:notredame/data/models/event_data.dart';

// Project imports:
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
                buildContext: context,
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
                  buildContext: context,
                  padding: const EdgeInsets.all(8.0),
                  event: EventData(
                    courseAcronym: "GEN101",
                    courseName: "Generic course",
                    date: date,
                    startTime: start,
                    endTime: end,
                    teacherName: "John Doe",
                    activityName: "Cours",
                    locations: ["D-2020"]
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

    // The dialog title should display the course name and location.
    expect(find.text('GEN101'), findsExactly(2));
    // The dialog content should show the course type.
    expect(find.text('Cours'), findsOneWidget);
    expect(find.text('D-2020'), findsOneWidget);
    // It should also display the teacher info.
    expect(find.textContaining('By John Doe'), findsOneWidget);
    // And the time info should be formatted correctly.
    // TODO fix this
    expect(
      find.textContaining('${intl.schedule_calendar_from_time} 9:00 ${intl.schedule_calendar_to_time} 12:00'),
      findsOneWidget,
    );
  });

  // Test that when teacherName equals the literal "null", no teacher info is displayed.
  // testWidgets('Does not display teacher info if teacherName is "null"', (WidgetTester tester) async {
  //   final start = DateTime(2025, 3, 1, 11, 30);
  //   final end = DateTime(2025, 3, 1, 12, 30);
  //
  //   await tester.pumpWidget(
  //     localizedWidget(
  //       child: Builder(
  //         builder: (context) {
  //           return CalendarEventTile(
  //             buildContext: context,
  //             padding: const EdgeInsets.all(8.0),
  //           );
  //         },
  //       ),
  //     ),
  //   );
  //
  //   // Tap the tile.
  //   await tester.tap(find.byType(CalendarEventTile));
  //   await tester.pumpAndSettle();
  //
  //   // Verify that no teacher info (i.e. text containing the word "by") is displayed.
  //   expect(find.textContaining('by'), findsNothing);
  // });
}
