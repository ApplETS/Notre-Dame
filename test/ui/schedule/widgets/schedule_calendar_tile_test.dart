// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:notredame/ui/schedule/widgets/schedule_calendar_tile.dart';
import '../../../helpers.dart';

void main() {
  late AppIntl intl;

  setUp(() async {
    intl = await setupAppIntl();
  });

  // Test to ensure that the title is rendered correctly.
  testWidgets('Displays the provided title text', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: localizedWidget(
          child: Builder(
            builder: (context) {
              return ScheduleCalendarTile(
                buildContext: context,
                title: 'Test Title',
                description: 'Math101-Algebra;Room 101;Lecture;John Doe',
                backgroundColor: Colors.white,
                padding: const EdgeInsets.all(8.0),
              );
            },
          ),
        ),
      ),
    );

    expect(find.text('Test Title'), findsOneWidget);
  });

  // Test that tapping the tile shows the dialog with the expected course info.
  testWidgets('Tapping tile shows dialog with course info',
      (WidgetTester tester) async {
    // Define start and end times.
    final start = DateTime(2025, 3, 1, 9, 5);
    final end = DateTime(2025, 3, 1, 10, 0);

    await tester.pumpWidget(
      MaterialApp(
        home: localizedWidget(
          child: Builder(
            builder: (context) {
              return ScheduleCalendarTile(
                buildContext: context,
                title: 'Test Title',
                description: 'Math101-Algebra;Room 101;Lecture;John Doe',
                start: start,
                end: end,
                backgroundColor: Colors.white,
                padding: const EdgeInsets.all(8.0),
              );
            },
          ),
        ),
      ),
    );

    // Tap the tile.
    await tester.tap(find.byType(ScheduleCalendarTile));
    await tester.pumpAndSettle();

    // The dialog title should display the course name and location.
    expect(find.text('Math101 (Room 101)'), findsOneWidget);
    // The dialog content should show the course type.
    expect(find.text('Lecture'), findsOneWidget);
    // It should also display the teacher info.
    expect(find.textContaining('By John Doe'), findsOneWidget);
    // And the time info should be formatted correctly.
    // Note: The end time is computed by adding one minute to the provided end time.
    expect(
        find.textContaining(
            '${intl.schedule_calendar_from_time} 9:05 ${intl.schedule_calendar_to_time} 10:01'),
        findsOneWidget);
  });

  // Test that when start and end times are null, the dialog shows the "not available" text.
  testWidgets('Displays N/A for null start and end times',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: localizedWidget(
          child: Builder(
            builder: (context) {
              return ScheduleCalendarTile(
                buildContext: context,
                title: 'Test Title',
                description: 'Science101-Physics;Lab 1;Practical;Jane Doe',
                backgroundColor: Colors.white,
                padding: const EdgeInsets.all(8.0),
                // start and end are intentionally null
              );
            },
          ),
        ),
      ),
    );

    // Tap the tile.
    await tester.tap(find.byType(ScheduleCalendarTile));
    await tester.pumpAndSettle();

    expect(find.textContaining('N/A'), findsOneWidget);
    expect(find.text('Science101 (Lab 1)'), findsOneWidget);
  });

  // Test that when teacherName equals the literal "null", no teacher info is displayed.
  testWidgets('Does not display teacher info if teacherName is "null"',
      (WidgetTester tester) async {
    final start = DateTime(2025, 3, 1, 11, 30);
    final end = DateTime(2025, 3, 1, 12, 30);

    await tester.pumpWidget(
      MaterialApp(
        home: localizedWidget(
          child: Builder(
            builder: (context) {
              return ScheduleCalendarTile(
                buildContext: context,
                title: 'Test Title',
                description: 'History101-History;Room 201;Seminar;null',
                start: start,
                end: end,
                backgroundColor: Colors.white,
                padding: const EdgeInsets.all(8.0),
              );
            },
          ),
        ),
      ),
    );

    // Tap the tile.
    await tester.tap(find.byType(ScheduleCalendarTile));
    await tester.pumpAndSettle();

    // Verify that no teacher info (i.e. text containing the word "by") is displayed.
    expect(find.textContaining('by'), findsNothing);
  });
}
