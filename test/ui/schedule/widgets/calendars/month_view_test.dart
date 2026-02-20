// Package imports:
import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:notredame/l10n/app_localizations.dart';
import 'package:notredame/ui/schedule/widgets/calendars/day_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import 'package:notredame/data/models/event_data.dart';
import 'package:notredame/data/repositories/settings_repository.dart';
import 'package:notredame/data/services/navigation_service.dart';
import 'package:notredame/ui/schedule/schedule_controller.dart';
import 'package:notredame/ui/schedule/widgets/calendars/month_calendar.dart';
import '../../../../data/mocks/repositories/settings_repository_mock.dart';
import '../../../../data/mocks/services/schedule_service_mock.dart';
import '../../../../helpers.dart';

void main() {
  SharedPreferences.setMockInitialValues({});
  late SettingsRepositoryMock settingsManagerMock;
  late ScheduleServiceMock scheduleServiceMock;

  late AppIntl intl;

  DateTime firstDayOfTheMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);

  Map<DateTime, List<EventData>> events = {
    firstDayOfTheMonth: [
      EventData(
        courseAcronym: "LOG100",
        group: "LOG100-01",
        locations: ["D-2020"],
        activityName: "Cours",
        courseName: "Programmation et réseautique en génie logiciel",
        teacherName: "John Doe",
        date: firstDayOfTheMonth,
        startTime: firstDayOfTheMonth.add(Duration(hours: 9)),
        endTime: firstDayOfTheMonth.add(Duration(hours: 12)),
      ),
    ]
  };

  group("month calendar view - ", () {
    setUp(() async {
      settingsManagerMock = setupSettingsRepositoryMock();
      scheduleServiceMock = setupScheduleServiceMock();
      intl = await setupAppIntl();

      SettingsRepositoryMock.stubLocale(settingsManagerMock);
      ScheduleServiceMock.stubEvents(scheduleServiceMock, events);
    });

    tearDown(
      () => {
        unregister<NavigationService>(),
        unregister<SettingsRepository>(),
      },
    );

    testWidgets("displays events", (WidgetTester tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(localizedWidget(child: MonthCalendar(controller: ScheduleController())));
        await tester.pumpAndSettle();
      });

      expect(find.byType(FilledCell), findsExactly(42));
      expect(find.text("LOG100"), findsOneWidget);
    });

    testWidgets("opens bottom sheet when a day is tapped", (WidgetTester tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(
          localizedWidget(
            child: MonthCalendar(controller: ScheduleController()),
          ),
        );
        await tester.pumpAndSettle();
      });

      // Tap on the first day of the month
      await tester.tap(find.text("1").first);
      await tester.pumpAndSettle();

      expect(find.byType(DraggableScrollableSheet), findsOneWidget);

      // Date in the header of the sheet
      expect(find.text(DateFormat.yMMMMd(intl.localeName).format(firstDayOfTheMonth)), findsWidgets);

      expect(find.byType(DayCalendar), findsOneWidget);

      // The event is present in the view
      expect(find.textContaining("D-2020"), findsOneWidget);
    });
  });
}
