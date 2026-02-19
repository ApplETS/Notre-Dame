import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notredame/l10n/app_localizations.dart';
import 'package:notredame/ui/dashboard/widgets/cards/schedule_card.dart';
import 'package:notredame/ui/schedule/schedule_controller.dart';
import 'package:notredame/ui/schedule/widgets/calendars/day_calendar.dart';

import '../../../../helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    setupCourseRepositoryMock();
    setupScheduleServiceMock();
  });

  Widget makeTestableWidget(Widget child) {
    return MaterialApp(
      localizationsDelegates: AppIntl.localizationsDelegates,
      supportedLocales: AppIntl.supportedLocales,
      home: Scaffold(body: child),
    );
  }

  group('ScheduleCard', () {
    testWidgets('renders base title', (tester) async {
      await tester.pumpWidget(makeTestableWidget(const ScheduleCard()));

      await tester.pumpAndSettle();

      expect(find.byType(ScheduleCard), findsOneWidget);
      expect(find.byType(DayCalendar), findsOneWidget);
    });

    testWidgets('passes correct parameters to DayCalendar', (tester) async {
      await tester.pumpWidget(makeTestableWidget(const ScheduleCard()));

      await tester.pumpAndSettle();

      final dayCalendar = tester.widget<DayCalendar>(find.byType(DayCalendar));

      expect(dayCalendar.listView, false);
      expect(dayCalendar.controller, isA<ScheduleController>());
      expect(dayCalendar.selectedDate, isNotNull);
    });
  });
}
