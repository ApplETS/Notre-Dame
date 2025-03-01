// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:calendar_view/calendar_view.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import 'package:notredame/data/repositories/course_repository.dart';
import 'package:notredame/data/repositories/settings_repository.dart';
import 'package:notredame/data/services/analytics_service.dart';
import 'package:notredame/data/services/calendar_service.dart';
import 'package:notredame/data/services/navigation_service.dart';
import 'package:notredame/data/services/networking_service.dart';
import 'package:notredame/data/services/remote_config_service.dart';
import 'package:notredame/domain/constants/preferences_flags.dart';
import 'package:notredame/ui/schedule/widgets/schedule_settings.dart';
import 'package:notredame/ui/schedule/widgets/schedule_view.dart';
import '../../../data/mocks/repositories/course_repository_mock.dart';
import '../../../data/mocks/repositories/settings_repository_mock.dart';
import '../../../data/mocks/services/remote_config_service_mock.dart';
import '../../../helpers.dart';

void main() {
  SharedPreferences.setMockInitialValues({});
  late SettingsRepositoryMock settingsManagerMock;
  late CourseRepositoryMock courseRepositoryMock;
  late RemoteConfigServiceMock remoteConfigServiceMock;

  // Some settings
  Map<PreferencesFlag, dynamic> settingsWeek = {
    PreferencesFlag.scheduleCalendarFormat: CalendarTimeFormat.week,
    PreferencesFlag.scheduleShowTodayBtn: true
  };

  Map<PreferencesFlag, dynamic> settingsMonth = {
    PreferencesFlag.scheduleCalendarFormat: CalendarTimeFormat.month,
    PreferencesFlag.scheduleShowTodayBtn: true
  };

  Map<PreferencesFlag, dynamic> settingsDay = {
    PreferencesFlag.scheduleCalendarFormat: CalendarTimeFormat.day,
    PreferencesFlag.scheduleListView: false,
    PreferencesFlag.scheduleShowTodayBtn: true
  };

  Map<PreferencesFlag, dynamic> settingsDayList = {
    PreferencesFlag.scheduleCalendarFormat: CalendarTimeFormat.day,
    PreferencesFlag.scheduleListView: true,
    PreferencesFlag.scheduleShowTodayBtn: true
  };

  Map<PreferencesFlag, dynamic> settingsDontShowTodayBtn = {
    PreferencesFlag.scheduleCalendarFormat: CalendarTimeFormat.week,
    PreferencesFlag.scheduleShowTodayBtn: false
  };

  group("ScheduleView - ", () {
    setUp(() async {
      setupNavigationServiceMock();
      settingsManagerMock = setupSettingsManagerMock();
      courseRepositoryMock = setupCourseRepositoryMock();
      remoteConfigServiceMock = setupRemoteConfigServiceMock();
      setupNetworkingServiceMock();
      setupAnalyticsServiceMock();

      SettingsRepositoryMock.stubLocale(settingsManagerMock);
      CourseRepositoryMock.stubGetScheduleActivities(courseRepositoryMock);
      RemoteConfigServiceMock.stubGetCalendarViewEnabled(
          remoteConfigServiceMock);
    });

    tearDown(() => {
          unregister<NavigationService>(),
          unregister<SettingsRepository>(),
          unregister<CourseRepository>(),
          unregister<RemoteConfigService>(),
          unregister<NetworkingService>(),
          unregister<AnalyticsService>(),
        });
    group("interactions - ", () {
      testWidgets("tap on settings button to open the schedule settings",
          (WidgetTester tester) async {
        CourseRepositoryMock.stubGetCourses(courseRepositoryMock);
        SettingsRepositoryMock.stubGetScheduleSettings(settingsManagerMock,
            toReturn: settingsWeek);

        await tester.runAsync(() async {
          await tester.pumpWidget(localizedWidget(child: const ScheduleView()));
          await tester.pumpAndSettle();
        }).then((value) async {
          expect(find.byType(ScheduleSettings), findsNothing,
              reason: "The settings page should not be open");

          // Tap on the settings button
          await tester.tap(find.byIcon(Icons.settings_outlined));
          // Reload view
          await tester.pumpAndSettle();

          expect(find.byType(ScheduleSettings), findsOneWidget,
              reason: "The settings view should be open");
        });
      });
    });

    group("respects settings - ", () {
      testWidgets("displays week view", (WidgetTester tester) async {
        CourseRepositoryMock.stubGetCourses(courseRepositoryMock);
        SettingsRepositoryMock.stubGetScheduleSettings(settingsManagerMock,
            toReturn: settingsWeek);

        await tester.runAsync(() async {
          await tester.pumpWidget(localizedWidget(child: const ScheduleView()));
          await tester.pumpAndSettle();
        }).then((value) async {
          expect(find.byType(WeekView), findsOneWidget);
        });
      });

      testWidgets("displays month view", (WidgetTester tester) async {
        CourseRepositoryMock.stubGetCourses(courseRepositoryMock);
        SettingsRepositoryMock.stubGetScheduleSettings(settingsManagerMock,
            toReturn: settingsMonth);

        await tester.runAsync(() async {
          await tester.pumpWidget(localizedWidget(child: const ScheduleView()));
          await tester.pumpAndSettle();
        }).then((value) async {
          expect(find.byType(MonthView), findsOneWidget);
        });
      });

      testWidgets("displays day view calendar", (WidgetTester tester) async {
        CourseRepositoryMock.stubGetCourses(courseRepositoryMock);
        SettingsRepositoryMock.stubGetScheduleSettings(settingsManagerMock,
            toReturn: settingsDay);

        await tester.runAsync(() async {
          await tester.pumpWidget(localizedWidget(child: const ScheduleView()));
          await tester.pumpAndSettle();
        }).then((value) async {
          expect(find.byType(DayView), findsOneWidget);
        });
      });

      testWidgets("displays day view calendar", (WidgetTester tester) async {
        CourseRepositoryMock.stubGetCourses(courseRepositoryMock);
        SettingsRepositoryMock.stubGetScheduleSettings(settingsManagerMock,
            toReturn: settingsDayList);

        await tester.runAsync(() async {
          await tester.pumpWidget(localizedWidget(child: const ScheduleView()));
          await tester.pumpAndSettle();
        }).then((value) async {
          expect(find.byType(PageView), findsExactly(2));
        });
      });

      testWidgets("displays today button", (WidgetTester tester) async {
        CourseRepositoryMock.stubGetCourses(courseRepositoryMock);
        SettingsRepositoryMock.stubGetScheduleSettings(settingsManagerMock,
            toReturn: settingsWeek);

        await tester.runAsync(() async {
          await tester.pumpWidget(localizedWidget(child: const ScheduleView()));
          await tester.pumpAndSettle();
        }).then((value) async {
          expect(find.byType(IconButton), findsExactly(5));
        });
      });

      testWidgets("does not display today button", (WidgetTester tester) async {
        CourseRepositoryMock.stubGetCourses(courseRepositoryMock);
        SettingsRepositoryMock.stubGetScheduleSettings(settingsManagerMock,
            toReturn: settingsDontShowTodayBtn);

        await tester.runAsync(() async {
          await tester.pumpWidget(localizedWidget(child: const ScheduleView()));
          await tester.pumpAndSettle();
        }).then((value) async {
          expect(find.byType(IconButton), findsExactly(4));
        });
      });
    });
  });
}
