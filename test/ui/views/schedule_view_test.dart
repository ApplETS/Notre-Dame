// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:ets_api_clients/models.dart';
import 'package:feature_discovery/feature_discovery.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

// Project imports:
import 'package:notredame/core/constants/preferences_flags.dart';
import 'package:notredame/ui/views/schedule_view.dart';
import 'package:notredame/ui/widgets/schedule_settings.dart';
import '../../helpers.dart';
import '../../mock/managers/course_repository_mock.dart';
import '../../mock/managers/settings_manager_mock.dart';
import '../../mock/services/remote_config_service_mock.dart';

void main() {
  late SettingsManagerMock settingsManagerMock;
  late CourseRepositoryMock courseRepositoryMock;
  late RemoteConfigServiceMock remoteConfigServiceMock;

  // Some activities
  late CourseActivity activityYesterday;
  late CourseActivity activityToday;
  late CourseActivity activityTomorrow;

  // Some settings
  Map<PreferencesFlag, dynamic> settings = {
    PreferencesFlag.scheduleCalendarFormat: CalendarFormat.week,
    PreferencesFlag.scheduleStartWeekday: StartingDayOfWeek.monday,
    PreferencesFlag.scheduleShowTodayBtn: true
  };

  group("ScheduleView - ", () {
    setUpAll(() {
      DateTime today = DateTime(2020);
      today = today.subtract(Duration(
          hours: today.hour,
          minutes: today.minute,
          seconds: today.second,
          milliseconds: today.millisecond,
          microseconds: today.microsecond));
      final DateTime yesterday = today.subtract(const Duration(days: 1));
      final DateTime tomorrow = today.add(const Duration(days: 1));

      activityYesterday = CourseActivity(
          courseGroup: "GEN102",
          courseName: "Generic course",
          activityName: "TD",
          activityDescription: "Activity description",
          activityLocation: "location",
          startDateTime: tomorrow,
          endDateTime: tomorrow.add(const Duration(hours: 4)));
      activityToday = CourseActivity(
          courseGroup: "GEN101",
          courseName: "Generic course",
          activityName: "TD",
          activityDescription: "Activity description",
          activityLocation: "location",
          startDateTime: today,
          endDateTime: today.add(const Duration(hours: 4)));
      activityTomorrow = CourseActivity(
          courseGroup: "GEN103",
          courseName: "Generic course",
          activityName: "TD",
          activityDescription: "Activity description",
          activityLocation: "location",
          startDateTime: yesterday,
          endDateTime: yesterday.add(const Duration(hours: 4)));
    });

    setUp(() async {
      setupNavigationServiceMock();
      settingsManagerMock = setupSettingsManagerMock();
      courseRepositoryMock = setupCourseRepositoryMock();
      remoteConfigServiceMock = setupRemoteConfigServiceMock();
      setupNetworkingServiceMock();
      setupAnalyticsServiceMock();

      SettingsManagerMock.stubLocale(settingsManagerMock);

      settings = {
        PreferencesFlag.scheduleCalendarFormat: CalendarFormat.week,
        PreferencesFlag.scheduleStartWeekday: StartingDayOfWeek.monday,
        PreferencesFlag.scheduleShowTodayBtn: true,
        PreferencesFlag.scheduleShowWeekEvents: false,
        PreferencesFlag.scheduleListView: true,
      };

      CourseRepositoryMock.stubGetScheduleActivities(courseRepositoryMock);
      RemoteConfigServiceMock.stubGetCalendarViewEnabled(
          remoteConfigServiceMock);
    });

    group("golden - ", () {
      testWidgets("default view (no events), showTodayButton enabled",
          (WidgetTester tester) async {
        tester.view.physicalSize = const Size(800, 1410);

        CourseRepositoryMock.stubCoursesActivities(courseRepositoryMock);
        CourseRepositoryMock.stubGetCoursesActivities(courseRepositoryMock,
            fromCacheOnly: true);
        CourseRepositoryMock.stubGetCourses(courseRepositoryMock,
            fromCacheOnly: true);
        CourseRepositoryMock.stubGetCourses(courseRepositoryMock);
        CourseRepositoryMock.stubGetCoursesActivities(courseRepositoryMock);
        SettingsManagerMock.stubGetScheduleSettings(settingsManagerMock,
            toReturn: settings);

        await tester.pumpWidget(localizedWidget(
            child: FeatureDiscovery(
                child: ScheduleView(initialDay: DateTime(2020)))));
        await tester.pumpAndSettle(const Duration(seconds: 1));

        await expectLater(find.byType(ScheduleView),
            matchesGoldenFile(goldenFilePath("scheduleView_1")));
      });

      testWidgets("default view (no events), showTodayButton disabled",
          (WidgetTester tester) async {
        SettingsManagerMock.stubGetBool(
            settingsManagerMock, PreferencesFlag.discoverySchedule);
        tester.view.physicalSize = const Size(800, 1410);

        settings[PreferencesFlag.scheduleShowTodayBtn] = false;

        CourseRepositoryMock.stubCoursesActivities(courseRepositoryMock);
        CourseRepositoryMock.stubGetCoursesActivities(courseRepositoryMock,
            fromCacheOnly: true);
        CourseRepositoryMock.stubGetCourses(courseRepositoryMock,
            fromCacheOnly: true);
        CourseRepositoryMock.stubGetCourses(courseRepositoryMock);
        CourseRepositoryMock.stubGetCoursesActivities(courseRepositoryMock);
        SettingsManagerMock.stubGetScheduleSettings(settingsManagerMock,
            toReturn: settings);

        await tester.pumpWidget(localizedWidget(
            child: FeatureDiscovery(
                child: ScheduleView(initialDay: DateTime(2020)))));
        await tester.pumpAndSettle();

        await expectLater(find.byType(ScheduleView),
            matchesGoldenFile(goldenFilePath("scheduleView_2")));
      });

      testWidgets("view with events, day with events selected",
          (WidgetTester tester) async {
        tester.view.physicalSize = const Size(800, 1410);
        CourseRepositoryMock.stubCoursesActivities(courseRepositoryMock,
            toReturn: [activityYesterday, activityToday, activityTomorrow]);
        CourseRepositoryMock.stubGetCoursesActivities(courseRepositoryMock,
            fromCacheOnly: true);
        CourseRepositoryMock.stubGetCourses(courseRepositoryMock,
            fromCacheOnly: true);
        CourseRepositoryMock.stubGetCourses(courseRepositoryMock);
        CourseRepositoryMock.stubGetCoursesActivities(courseRepositoryMock);
        SettingsManagerMock.stubGetScheduleSettings(settingsManagerMock,
            toReturn: settings);

        await tester.pumpWidget(localizedWidget(
            child: FeatureDiscovery(
                child: MediaQuery(
                    data: const MediaQueryData(textScaler: TextScaler.linear(0.5)),
                    child: ScheduleView(initialDay: DateTime(2020))))));
        await tester.pumpAndSettle(const Duration(seconds: 1));

        await expectLater(find.byType(ScheduleView),
            matchesGoldenFile(goldenFilePath("scheduleView_3")));
      });

      testWidgets("view with events, day without events selected",
          (WidgetTester tester) async {
        tester.view.physicalSize = const Size(800, 1410);

        CourseRepositoryMock.stubCoursesActivities(courseRepositoryMock,
            toReturn: [activityYesterday, activityTomorrow]);
        CourseRepositoryMock.stubGetCoursesActivities(courseRepositoryMock,
            fromCacheOnly: true);
        CourseRepositoryMock.stubGetCourses(courseRepositoryMock,
            fromCacheOnly: true);
        CourseRepositoryMock.stubGetCourses(courseRepositoryMock);
        CourseRepositoryMock.stubGetCoursesActivities(courseRepositoryMock);
        SettingsManagerMock.stubGetScheduleSettings(settingsManagerMock,
            toReturn: settings);

        await tester.pumpWidget(localizedWidget(
            child: FeatureDiscovery(
                child: ScheduleView(initialDay: DateTime(2020)))));
        await tester.pumpAndSettle(const Duration(seconds: 1));

        await expectLater(find.byType(ScheduleView),
            matchesGoldenFile(goldenFilePath("scheduleView_4")));
      });

      testWidgets("other day is selected, current day still has a square.",
          (WidgetTester tester) async {
        tester.view.physicalSize = const Size(800, 1410);

        CourseRepositoryMock.stubCoursesActivities(courseRepositoryMock,
            toReturn: [activityYesterday, activityTomorrow]);
        CourseRepositoryMock.stubGetCoursesActivities(courseRepositoryMock,
            fromCacheOnly: true);
        CourseRepositoryMock.stubGetCourses(courseRepositoryMock,
            fromCacheOnly: true);
        CourseRepositoryMock.stubGetCourses(courseRepositoryMock);
        CourseRepositoryMock.stubGetCoursesActivities(courseRepositoryMock);
        SettingsManagerMock.stubGetScheduleSettings(settingsManagerMock,
            toReturn: settings);

        final testingDate = DateTime(2020);

        await tester.pumpWidget(localizedWidget(
            child: FeatureDiscovery(
                child: MediaQuery(
                    data: const MediaQueryData(textScaler: TextScaler.linear(0.5)),
                    child: ScheduleView(initialDay: testingDate)))));
        await tester.pumpAndSettle(const Duration(seconds: 1));

        expect(find.byType(TableCalendar, skipOffstage: false), findsOneWidget);
        expect(
            find.descendant(
                of: find.byType(TableCalendar, skipOffstage: false),
                matching: find.text(
                    "${testingDate.add(const Duration(days: 1)).day}",
                    skipOffstage: false)),
            findsOneWidget);

        // Tap on the day after selected day
        await tester.tap(find.descendant(
            of: find.byType(TableCalendar, skipOffstage: false),
            matching: find.text(
                "${testingDate.add(const Duration(days: 1)).day}",
                skipOffstage: false)));

        // Reload the view
        await tester.pump();

        await expectLater(find.byType(ScheduleView),
            matchesGoldenFile(goldenFilePath("scheduleView_5")));
      });
    }, skip: !Platform.isLinux);

    group("interactions - ", () {
      testWidgets("tap on settings button to open the schedule settings",
          (WidgetTester tester) async {
        tester.view.physicalSize = const Size(800, 1410);

        CourseRepositoryMock.stubCoursesActivities(courseRepositoryMock,
            toReturn: [activityToday]);
        CourseRepositoryMock.stubGetCoursesActivities(courseRepositoryMock,
            fromCacheOnly: true);
        CourseRepositoryMock.stubGetCoursesActivities(courseRepositoryMock);
        CourseRepositoryMock.stubGetCourses(courseRepositoryMock,
            fromCacheOnly: true);
        CourseRepositoryMock.stubGetCourses(courseRepositoryMock);
        SettingsManagerMock.stubGetScheduleSettings(settingsManagerMock,
            toReturn: settings);

        await tester.pumpWidget(localizedWidget(
            child: FeatureDiscovery(child: const ScheduleView())));
        await tester.pumpAndSettle();

        expect(find.byType(ScheduleSettings), findsNothing,
            reason: "The settings page should not be open");

        // Tap on the settings button
        await tester.tap(find.byIcon(Icons.settings));
        // Reload view
        await tester.pumpAndSettle();

        expect(find.byType(ScheduleSettings), findsOneWidget,
            reason: "The settings view should be open");
      });
    });
  });
}
