// Package imports:
import 'package:calendar_view/calendar_view.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:notredame/ui/schedule/schedule_default/widgets/schedule_default.dart';
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
          child: const ScheduleDefault(calendarEvents: [], loaded: true, displaySaturday: false, displaySunday: false)));
      await tester.pumpAndSettle();
      expect(find.text(intl.no_schedule_available), findsOneWidget);
      expect(find.text("S"), findsNothing);
      expect(find.text("D"), findsNothing);
    });

    testWidgets('Displays saturday',
            (WidgetTester tester) async {
      await tester.pumpWidget(localizedWidget(
          child: ScheduleDefault(calendarEvents: [CalendarEventData(title: "My Event", date: DateTime(2024))], loaded: true, displaySaturday: true, displaySunday: false)));
      await tester.pumpAndSettle();
      expect(find.text("S"), findsOneWidget);
    });

    testWidgets('Displays sunday',
            (WidgetTester tester) async {
      await tester.pumpWidget(localizedWidget(
          child: ScheduleDefault(calendarEvents: [CalendarEventData(title: "My Event", date: DateTime(2024))], loaded: true, displaySaturday: false, displaySunday: true)));
      await tester.pumpAndSettle();
      expect(find.text("D"), findsOneWidget);
    });

    testWidgets('Displays no weekend day',
            (WidgetTester tester) async {
      await tester.pumpWidget(localizedWidget(
          child: ScheduleDefault(calendarEvents: [CalendarEventData(title: "My Event", date: DateTime(2024))], loaded: true, displaySaturday: false, displaySunday: false)));
      await tester.pumpAndSettle();
      expect(find.text("S"), findsNothing);
      expect(find.text("D"), findsNothing);
    });

    testWidgets('Displays no empty schedule message when loading',
        (WidgetTester tester) async {
      await tester.pumpWidget(localizedWidget(
          child: const ScheduleDefault(calendarEvents: [], loaded: false, displaySaturday: false, displaySunday: false)));
      await tester.pumpAndSettle();
      expect(find.text(intl.no_schedule_available), findsNothing);
    });
  });
}
