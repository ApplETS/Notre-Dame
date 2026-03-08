// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:calendar_view/calendar_view.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:notredame/ui/schedule/widgets/schedule_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import 'package:notredame/data/repositories/course_repository.dart';
import 'package:notredame/data/repositories/settings_repository.dart' hide ScheduleSettings;
import 'package:notredame/data/services/analytics_service.dart';
import 'package:notredame/data/services/calendar_service.dart';
import 'package:notredame/data/services/navigation_service.dart';
import 'package:notredame/data/services/networking_service.dart';
import 'package:notredame/data/services/remote_config_service.dart';
import 'package:notredame/locator.dart';
import 'package:notredame/ui/schedule/schedule_controller.dart';
import 'package:notredame/ui/schedule/widgets/schedule_view.dart';
import '../../../data/mocks/repositories/course_repository_mock.dart';
import '../../../data/mocks/repositories/settings_repository_mock.dart';
import '../../../helpers.dart';

void main() {
  SharedPreferences.setMockInitialValues({});
  late SettingsRepositoryMock settingsManagerMock;
  late CourseRepositoryMock courseRepositoryMock;

  group("ScheduleView - ", () {
    setUp(() async {
      setupNavigationServiceMock();
      settingsManagerMock = setupSettingsRepositoryMock();
      courseRepositoryMock = setupCourseRepositoryMock();
      setupScheduleServiceMock();
      setupNetworkingServiceMock();
      setupAnalyticsServiceMock();

      SettingsRepositoryMock.stubLocale(settingsManagerMock);
      CourseRepositoryMock.stubGetScheduleActivities(courseRepositoryMock);
    });

    tearDown(
      () => {
        unregister<NavigationService>(),
        unregister<SettingsRepository>(),
        unregister<CourseRepository>(),
        unregister<RemoteConfigService>(),
        unregister<NetworkingService>(),
        unregister<AnalyticsService>(),
      },
    );

    group("interactions - ", () {
      testWidgets("tap on settings button to open the schedule settings", (WidgetTester tester) async {
        CourseRepositoryMock.stubGetCourses(courseRepositoryMock);

        await tester.runAsync(() async {
          await tester.pumpWidget(localizedWidget(child: ScheduleView(controller: ScheduleController())));
          await tester.pumpAndSettle();
        });

        expect(find.byType(ScheduleSettings), findsNothing, reason: "The settings page should not be open");

        await tester.tap(find.byIcon(Icons.settings_outlined));
        await tester.pumpAndSettle();

        expect(find.byType(ScheduleSettings), findsOneWidget, reason: "The settings view should be open");
      });

      testWidgets("tap on today button when enabled triggers action and logs analytics", (WidgetTester tester) async {
        SettingsRepositoryMock.stubTodayButton(settingsManagerMock, toReturn: true);
        CourseRepositoryMock.stubGetCourses(courseRepositoryMock);

        await tester.runAsync(() async {
          await tester.pumpWidget(localizedWidget(child: ScheduleView(controller: ScheduleController())));
          await tester.pumpAndSettle();
        });

        expect(find.byIcon(Icons.today_outlined), findsOneWidget);

        final analyticsService = locator<AnalyticsService>();
        verifyNever(analyticsService.logEvent("ScheduleView", "Select today clicked"));

        await tester.tap(find.byIcon(Icons.today_outlined));
        await tester.pumpAndSettle();

        verify(analyticsService.logEvent("ScheduleView", "Select today clicked")).called(1);
      });
    });

    group("respects settings - ", () {
      testWidgets("displays week view", (WidgetTester tester) async {
        CourseRepositoryMock.stubGetCourses(courseRepositoryMock);
        SettingsRepositoryMock.stubScheduleCalendarFormat(settingsManagerMock, toReturn: CalendarTimeFormat.week);

        await tester
            .runAsync(() async {
              await tester.pumpWidget(localizedWidget(child: ScheduleView(controller: ScheduleController())));
              await tester.pumpAndSettle();
            })
            .then((value) async {
              expect(find.byType(WeekView), findsOneWidget);
            });
      });

      testWidgets("displays month view", (WidgetTester tester) async {
        CourseRepositoryMock.stubGetCourses(courseRepositoryMock);
        SettingsRepositoryMock.stubScheduleCalendarFormat(settingsManagerMock, toReturn: CalendarTimeFormat.month);

        await tester
            .runAsync(() async {
              await tester.pumpWidget(localizedWidget(child: ScheduleView(controller: ScheduleController())));
              await tester.pumpAndSettle();
            })
            .then((value) async {
              expect(find.byType(MonthView), findsOneWidget);
            });
      });

      testWidgets("displays day view calendar", (WidgetTester tester) async {
        CourseRepositoryMock.stubGetCourses(courseRepositoryMock);
        SettingsRepositoryMock.stubScheduleCalendarFormat(settingsManagerMock, toReturn: CalendarTimeFormat.day);
        SettingsRepositoryMock.stubScheduleListView(settingsManagerMock, toReturn: false);

        await tester
            .runAsync(() async {
              await tester.pumpWidget(localizedWidget(child: ScheduleView(controller: ScheduleController())));
              await tester.pumpAndSettle();
            })
            .then((value) async {
              expect(find.byType(DayView), findsOneWidget);
              expect(find.byType(PageView), findsExactly(2));
            });
      });

      testWidgets("displays day view list", (WidgetTester tester) async {
        CourseRepositoryMock.stubGetCourses(courseRepositoryMock);
        SettingsRepositoryMock.stubScheduleCalendarFormat(settingsManagerMock, toReturn: CalendarTimeFormat.week);
        SettingsRepositoryMock.stubScheduleListView(settingsManagerMock, toReturn: true);

        await tester
            .runAsync(() async {
              await tester.pumpWidget(localizedWidget(child: ScheduleView(controller: ScheduleController())));
              await tester.pumpAndSettle();
            })
            .then((value) async {
              expect(find.byType(DayView), findsNothing);
              expect(find.byType(PageView), findsOne);
            });
      });

      testWidgets("displays today button", (WidgetTester tester) async {
        CourseRepositoryMock.stubGetCourses(courseRepositoryMock);
        SettingsRepositoryMock.stubTodayButton(settingsManagerMock, toReturn: true);

        await tester
            .runAsync(() async {
              await tester.pumpWidget(localizedWidget(child: ScheduleView(controller: ScheduleController())));
              await tester.pumpAndSettle();
            })
            .then((value) async {
              expect(find.byType(IconButton), findsExactly(5));
            });
      });

      testWidgets("does not display today button", (WidgetTester tester) async {
        CourseRepositoryMock.stubGetCourses(courseRepositoryMock);
        SettingsRepositoryMock.stubTodayButton(settingsManagerMock, toReturn: false);

        await tester
            .runAsync(() async {
              await tester.pumpWidget(localizedWidget(child: ScheduleView(controller: ScheduleController())));
              await tester.pumpAndSettle();
            })
            .then((value) async {
              expect(find.byType(IconButton), findsExactly(4));
            });
      });
    });
  });
}
