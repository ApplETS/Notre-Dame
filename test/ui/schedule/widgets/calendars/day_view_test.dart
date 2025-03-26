// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:calendar_view/calendar_view.dart' as calendar_view;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart' as table_calendar;

// Project imports:
import 'package:notredame/data/repositories/course_repository.dart';
import 'package:notredame/data/repositories/settings_repository.dart';
import 'package:notredame/data/services/analytics_service.dart';
import 'package:notredame/data/services/navigation_service.dart';
import 'package:notredame/data/services/networking_service.dart';
import 'package:notredame/data/services/remote_config_service.dart';
import 'package:notredame/data/services/signets-api/models/course_activity.dart';
import 'package:notredame/ui/dashboard/widgets/course_activity_tile.dart';
import 'package:notredame/ui/schedule/schedule_controller.dart';
import 'package:notredame/ui/schedule/widgets/calendars/day_calendar.dart';
import 'package:notredame/ui/schedule/widgets/schedule_calendar_tile.dart';
import '../../../../data/mocks/repositories/course_repository_mock.dart';
import '../../../../data/mocks/repositories/settings_repository_mock.dart';
import '../../../../helpers.dart';

void main() {
  SharedPreferences.setMockInitialValues({});
  late SettingsRepositoryMock settingsManagerMock;
  late CourseRepositoryMock courseRepositoryMock;
  late AppIntl intl;

  List<CourseActivity> activites = [
    CourseActivity(
      courseName: 'Lecture',
      startDateTime: DateTime.now().withoutTime.add(Duration(hours: 14)),
      endDateTime: DateTime.now().withoutTime.add(Duration(hours: 17)),
      courseGroup: 'ING150-01',
      activityLocation: 'Room 101',
      activityName: 'Lecture 1',
      activityDescription: 'Regular',
    ),
    CourseActivity(
      courseName: 'Lab',
      startDateTime: DateTime.now().withoutTime.add(Duration(hours: 9)),
      endDateTime: DateTime.now().withoutTime.add(Duration(hours: 12)),
      courseGroup: 'ING150-01',
      activityLocation: 'Room 102',
      activityName: 'Lab Session',
      activityDescription: 'Regular',
    )
  ];

  group("day calendar view - ", () {
    setUp(() async {
      settingsManagerMock = setupSettingsManagerMock();
      courseRepositoryMock = setupCourseRepositoryMock();
      intl = await setupAppIntl();
      setupNetworkingServiceMock();
      setupAnalyticsServiceMock();

      SettingsRepositoryMock.stubLocale(settingsManagerMock);
      CourseRepositoryMock.stubGetScheduleActivities(courseRepositoryMock);
    });

    tearDown(() => {
          unregister<NavigationService>(),
          unregister<SettingsRepository>(),
          unregister<CourseRepository>(),
          unregister<RemoteConfigService>(),
          unregister<NetworkingService>(),
          unregister<AnalyticsService>(),
        });

    group("list view", () {
      testWidgets("list view", (WidgetTester tester) async {
        CourseRepositoryMock.stubGetCourses(courseRepositoryMock);

        await tester.runAsync(() async {
          await tester
              .pumpWidget(localizedWidget(child: DayCalendar(listView: true, controller: ScheduleController())));
          await tester.pumpAndSettle();
        });

        expect(find.byType(PageView), findsExactly(2), reason: "The page view is displayed");
      });

      testWidgets("list view with no event in selected day", (WidgetTester tester) async {
        CourseRepositoryMock.stubGetCourses(courseRepositoryMock);

        await tester.runAsync(() async {
          await tester
              .pumpWidget(localizedWidget(child: DayCalendar(listView: true, controller: ScheduleController())));
          await tester.pumpAndSettle();
        });

        expect(find.text(intl.schedule_no_event), findsOneWidget);
      });

      testWidgets("list view with event in selected day", (WidgetTester tester) async {
        CourseRepositoryMock.stubCoursesActivities(courseRepositoryMock, toReturn: activites);

        CourseRepositoryMock.stubGetCourses(courseRepositoryMock);

        await tester.runAsync(() async {
          await tester
              .pumpWidget(localizedWidget(child: DayCalendar(listView: true, controller: ScheduleController())));
          await tester.pumpAndSettle();
        });

        expect(find.text(intl.schedule_no_event), findsNothing);
        expect(find.byType(CourseActivityTile), findsExactly(2));
      });
    });

    group("calendar view", () {
      testWidgets("calendar view", (WidgetTester tester) async {
        CourseRepositoryMock.stubGetCourses(courseRepositoryMock);

        await tester.runAsync(() async {
          await tester
              .pumpWidget(localizedWidget(child: DayCalendar(listView: false, controller: ScheduleController())));
          await tester.pumpAndSettle();
        });

        expect(find.byType(calendar_view.DayView), findsOneWidget, reason: "The page view is displayed");
      });

      testWidgets("calendar view with event in selected day", (WidgetTester tester) async {
        CourseRepositoryMock.stubCoursesActivities(courseRepositoryMock, toReturn: activites);
        CourseRepositoryMock.stubGetCourses(courseRepositoryMock);

        await tester.runAsync(() async {
          await tester
              .pumpWidget(localizedWidget(child: DayCalendar(listView: false, controller: ScheduleController())));
          await tester.pumpAndSettle();
        });

        expect(find.byType(ScheduleCalendarTile), findsExactly(2));
      });
    });

    group("header", () {
      testWidgets("calendar view with event in selected day", (WidgetTester tester) async {
        CourseRepositoryMock.stubCoursesActivities(courseRepositoryMock, toReturn: activites);
        CourseRepositoryMock.stubGetCourses(courseRepositoryMock);

        await tester.runAsync(() async {
          await tester
              .pumpWidget(localizedWidget(child: DayCalendar(listView: false, controller: ScheduleController())));
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
