// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:calendar_view/calendar_view.dart' as calendar_view;
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart' as table_calendar;

// Project imports:
import 'package:notredame/data/models/event_data.dart';
import 'package:notredame/data/repositories/course_repository.dart';
import 'package:notredame/data/repositories/settings_repository.dart';
import 'package:notredame/data/services/analytics_service.dart';
import 'package:notredame/data/services/navigation_service.dart';
import 'package:notredame/data/services/networking_service.dart';
import 'package:notredame/data/services/remote_config_service.dart';
import 'package:notredame/data/services/schedule_service.dart';
import 'package:notredame/l10n/app_localizations.dart';
import 'package:notredame/ui/schedule/schedule_controller.dart';
import 'package:notredame/ui/schedule/widgets/calendars/day_calendar.dart';
import 'package:notredame/ui/schedule/widgets/tiles/calendar_event_tile.dart';
import 'package:notredame/ui/schedule/widgets/tiles/listview_event_tile.dart';
import '../../../../data/mocks/repositories/settings_repository_mock.dart';
import '../../../../data/mocks/services/schedule_service_mock.dart';
import '../../../../helpers.dart';

void main() {
  SharedPreferences.setMockInitialValues({});
  late SettingsRepositoryMock settingsManagerMock;
  late ScheduleServiceMock scheduleServiceMock;

  late AppIntl intl;

  Map<DateTime, List<EventData>> events = {
    DateTime.now().withoutTime: [
      EventData(
        courseAcronym: "LOG100",
        group: "LOG100-01",
        locations: ["D-2020"],
        activityName: "Cours",
        courseName: "Programmation et réseautique en génie logiciel",
        teacherName: "John Doe",
        date: DateTime.now().withoutTime,
        startTime: DateTime.now().withoutTime.add(Duration(hours: 9)),
        endTime: DateTime.now().withoutTime.add(Duration(hours: 12)),
      ),
      EventData(
        courseAcronym: "ING150",
        group: "ING150-01",
        locations: ["D-2020"],
        activityName: "Cours",
        courseName: "Statique et dynamique",
        teacherName: "Jane Doe",
        date: DateTime.now().withoutTime,
        startTime: DateTime.now().withoutTime.add(Duration(hours: 14)),
        endTime: DateTime.now().withoutTime.add(Duration(hours: 17)),
      ),
    ],
  };

  group("day calendar view - ", () {
    setUp(() async {
      settingsManagerMock = setupSettingsRepositoryMock();
      scheduleServiceMock = setupScheduleServiceMock();
      setupCourseRepositoryMock();
      intl = await setupAppIntl();
      setupNetworkingServiceMock();
      setupAnalyticsServiceMock();

      SettingsRepositoryMock.stubLocale(settingsManagerMock);
    });

    tearDown(
      () => {
        unregister<NavigationService>(),
        unregister<SettingsRepository>(),
        unregister<CourseRepository>(),
        unregister<RemoteConfigService>(),
        unregister<NetworkingService>(),
        unregister<AnalyticsService>(),
        unregister<ScheduleService>(),
      },
    );

    group("list view", () {
      testWidgets("list view", (WidgetTester tester) async {
        ScheduleServiceMock.stubEvents(scheduleServiceMock, events);

        await tester.runAsync(() async {
          await tester.pumpWidget(
            localizedWidget(child: DayCalendar(listView: true, controller: ScheduleController())),
          );
          await tester.pumpAndSettle();
        });

        expect(find.byType(PageView), findsExactly(2), reason: "The page view is displayed");
      });

      testWidgets("list view with no event in selected day", (WidgetTester tester) async {
        ScheduleServiceMock.stubEvents(scheduleServiceMock, {});

        await tester.runAsync(() async {
          await tester.pumpWidget(
            localizedWidget(child: DayCalendar(listView: true, controller: ScheduleController())),
          );
          await tester.pumpAndSettle();
        });

        expect(find.text(intl.schedule_no_event), findsOneWidget);
      });

      testWidgets("list view with event in selected day", (WidgetTester tester) async {
        ScheduleServiceMock.stubEvents(scheduleServiceMock, events);

        await tester.runAsync(() async {
          await tester.pumpWidget(
            localizedWidget(child: DayCalendar(listView: true, controller: ScheduleController())),
          );
          await tester.pumpAndSettle();
        });

        expect(find.text(intl.schedule_no_event), findsNothing);
        expect(find.byType(ListViewEventTile), findsExactly(2));
      });
    });

    group("calendar view", () {
      testWidgets("calendar view", (WidgetTester tester) async {
        ScheduleServiceMock.stubEvents(scheduleServiceMock, events);

        await tester.runAsync(() async {
          await tester.pumpWidget(
            localizedWidget(child: DayCalendar(listView: false, controller: ScheduleController())),
          );
          await tester.pumpAndSettle();
        });

        expect(find.byType(calendar_view.DayView), findsOneWidget, reason: "The page view is displayed");
      });

      testWidgets("calendar view with event in selected day", (WidgetTester tester) async {
        ScheduleServiceMock.stubEvents(scheduleServiceMock, events);

        await tester.runAsync(() async {
          await tester.pumpWidget(
            localizedWidget(child: DayCalendar(listView: false, controller: ScheduleController())),
          );
          await tester.pumpAndSettle();
        });

        expect(find.byType(CalendarEventTile), findsExactly(2));
      });
    });

    group("header", () {
      testWidgets("calendar view with event in selected day", (WidgetTester tester) async {
        ScheduleServiceMock.stubEvents(scheduleServiceMock, events);

        await tester.runAsync(() async {
          await tester.pumpWidget(
            localizedWidget(child: DayCalendar(listView: false, controller: ScheduleController())),
          );
          await tester.pumpAndSettle();
        });

        final dayIndicatorFinder = find.byWidgetPredicate((widget) {
          if (widget is Text) {
            final textStyle = widget.style;
            return widget.data == '2' && textStyle != null && textStyle.fontSize == 12.0;
          }
          return false;
        });

        expect(find.byType(table_calendar.TableCalendarBase), findsOneWidget);
        expect(dayIndicatorFinder, findsOneWidget);
      });
    });
  });
}
