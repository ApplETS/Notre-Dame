// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:notredame/data/models/event_data.dart';
import 'package:notredame/ui/schedule/widgets/tiles/listview_event_tile.dart';
import '../../../../helpers.dart';

final date = DateTime(2020, 9, 3);

final EventData event = EventData(
  courseAcronym: 'GEN101',
  group: 'GEN101-01',
  activityName: 'TP',
  locations: ['D-2020'],
  startTime: date.add(Duration(hours: 18)),
  endTime: date.add(Duration(hours: 20)),
  courseName: 'Generic course',
  date: date,
);

void main() {
  group("ListViewEventTile - ", () {
    testWidgets("display the short title, entire title, type of activity, hours and local of the course", (
      WidgetTester tester,
    ) async {
      // Set the textScaleFactor to 0.5 otherwise the row overflow, only happen in test.
      await tester.pumpWidget(
        localizedWidget(
          child: MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(0.5)),
            child: ListViewEventTile(event),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(event.group!), findsOneWidget);
      expect(find.text("${event.courseName}\n${event.activityName}"), findsOneWidget);
      expect(find.text(event.locations!.first), findsOneWidget);

      expect(find.text("18:00"), findsOneWidget);
      expect(find.text("20:00"), findsOneWidget);
    });
  });
}
