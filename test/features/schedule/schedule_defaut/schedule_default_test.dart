// Package imports:
import 'package:calendar_view/calendar_view.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:notredame/features/schedule/schedule_default/schedule_default.dart';
import '../../../common/helpers.dart';

void main() {
  late AppIntl intl;

  group('ScheduleDefault Tests', () {
    setUpAll(() async {
      intl = await setupAppIntl();
    });

    testWidgets('Displays no schedule message when there are no events',
        (WidgetTester tester) async {
      await tester.pumpWidget(localizedWidget(
          child: const ScheduleDefault(calendarEvents: [], loaded: true, displaySaturday: true)));
      await tester.pumpAndSettle();
      expect(find.text(intl.no_schedule_available), findsOneWidget);
    });

    testWidgets('Displays saturday',
            (WidgetTester tester) async {
      await tester.pumpWidget(localizedWidget(
          child: ScheduleDefault(calendarEvents: [CalendarEventData(title: "My Event", date: DateTime(2024))], loaded: true, displaySaturday: true)));
      await tester.pumpAndSettle();
      expect(find.text("S"), findsOneWidget);
    });

    testWidgets('Displays saturday',
            (WidgetTester tester) async {
      await tester.pumpWidget(localizedWidget(
          child: ScheduleDefault(calendarEvents: [CalendarEventData(title: "My Event", date: DateTime(2024))], loaded: true, displaySaturday: false)));
      await tester.pumpAndSettle();
      expect(find.text("S"), findsNothing);
    });

    testWidgets('Displays no empty schedule message when loading',
        (WidgetTester tester) async {
      await tester.pumpWidget(localizedWidget(
          child: const ScheduleDefault(calendarEvents: [], loaded: false, displaySaturday: true)));
      await tester.pumpAndSettle();
      expect(find.text(intl.no_schedule_available), findsNothing);
    });
  });
}
