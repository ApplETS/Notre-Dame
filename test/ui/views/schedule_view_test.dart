// FLUTTER / DART / THIRD-PARTIES
import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:table_calendar/table_calendar.dart';

// MANAGERS
import 'package:notredame/core/managers/course_repository.dart';
import 'package:notredame/core/managers/settings_manager.dart';

// MODELS / CONSTANTS
import 'package:notredame/core/constants/preferences_flags.dart';
import 'package:notredame/core/models/course_activity.dart';

// VIEW
import 'package:notredame/ui/views/schedule_view.dart';

import '../../helpers.dart';

// MOCKS
import '../../mock/managers/course_repository_mock.dart';
import '../../mock/managers/settings_manager_mock.dart';

void main() {
  SettingsManager settingsManager;
  CourseRepository courseRepository;

  DateTime yesterday;
  DateTime today;
  DateTime tomorrow;

  // Some activities
  CourseActivity activityYesterday;
  CourseActivity activityToday;
  CourseActivity activityTomorrow;

  // Some settings
  Map<PreferencesFlag, dynamic> settings = {
    PreferencesFlag.scheduleSettingsCalendarFormat: CalendarFormat.week,
    PreferencesFlag.scheduleSettingsStartWeekday: StartingDayOfWeek.monday,
    PreferencesFlag.scheduleSettingsShowTodayBtn: true
  };

  group("ScheduleView - ", () {
    setUpAll(() {
      today = DateTime.now();
      today = today.subtract(Duration(
          hours: today.hour, minutes: today.minute, seconds: today.second));
      yesterday = today.subtract(const Duration(days: 1));
      tomorrow = today.add(const Duration(days: 1));

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

    setUp(() {
      setupNavigationServiceMock();
      settingsManager = setupSettingsManagerMock();
      courseRepository = setupCourseRepositoryMock();

      settings = {
        PreferencesFlag.scheduleSettingsCalendarFormat: CalendarFormat.week,
        PreferencesFlag.scheduleSettingsStartWeekday: StartingDayOfWeek.monday,
        PreferencesFlag.scheduleSettingsShowTodayBtn: true
      };
    });

    group("golden - ", () {
      testWidgets("default view (no events), showTodayButton enabled",
          (WidgetTester tester) async {
        tester.binding.window.physicalSizeTestValue = const Size(800, 1410);

        CourseRepositoryMock.stubCoursesActivities(
            courseRepository as CourseRepositoryMock);
        CourseRepositoryMock.stubGetCoursesActivities(
            courseRepository as CourseRepositoryMock,
            fromCacheOnly: true);
        CourseRepositoryMock.stubGetCoursesActivities(
            courseRepository as CourseRepositoryMock,
            fromCacheOnly: false);
        SettingsManagerMock.stubGetScheduleSettings(
            settingsManager as SettingsManagerMock,
            toReturn: settings);

        await tester.pumpWidget(localizedWidget(child: ScheduleView()));
        await tester.pumpAndSettle();

        await expectLater(find.byType(ScheduleView),
            matchesGoldenFile(goldenFilePath("scheduleView_1")));
      });

      testWidgets("default view (no events), showTodayButton disabled",
          (WidgetTester tester) async {
        tester.binding.window.physicalSizeTestValue = const Size(800, 1410);

        settings[PreferencesFlag.scheduleSettingsShowTodayBtn] = false;

        CourseRepositoryMock.stubCoursesActivities(
            courseRepository as CourseRepositoryMock);
        CourseRepositoryMock.stubGetCoursesActivities(
            courseRepository as CourseRepositoryMock,
            fromCacheOnly: true);
        CourseRepositoryMock.stubGetCoursesActivities(
            courseRepository as CourseRepositoryMock,
            fromCacheOnly: false);
        SettingsManagerMock.stubGetScheduleSettings(
            settingsManager as SettingsManagerMock,
            toReturn: settings);

        await tester.pumpWidget(localizedWidget(child: ScheduleView()));
        await tester.pumpAndSettle();

        await expectLater(find.byType(ScheduleView),
            matchesGoldenFile(goldenFilePath("scheduleView_2")));
      });

      testWidgets("view with events, day with events selected",
          (WidgetTester tester) async {
        tester.binding.window.physicalSizeTestValue = const Size(800, 1410);
        CourseRepositoryMock.stubCoursesActivities(
            courseRepository as CourseRepositoryMock,
            toReturn: [activityYesterday, activityToday, activityTomorrow]);
        CourseRepositoryMock.stubGetCoursesActivities(
            courseRepository as CourseRepositoryMock,
            fromCacheOnly: true);
        CourseRepositoryMock.stubGetCoursesActivities(
            courseRepository as CourseRepositoryMock,
            fromCacheOnly: false);
        SettingsManagerMock.stubGetScheduleSettings(
            settingsManager as SettingsManagerMock,
            toReturn: settings);

        await tester.pumpWidget(localizedWidget(child: ScheduleView()));
        await tester.pumpAndSettle();

        await expectLater(find.byType(ScheduleView),
            matchesGoldenFile(goldenFilePath("scheduleView_3")));
      });

      testWidgets("view with events, day without events selected",
          (WidgetTester tester) async {
        tester.binding.window.physicalSizeTestValue = const Size(800, 1410);

        CourseRepositoryMock.stubCoursesActivities(
            courseRepository as CourseRepositoryMock,
            toReturn: [activityYesterday, activityTomorrow]);
        CourseRepositoryMock.stubGetCoursesActivities(
            courseRepository as CourseRepositoryMock,
            fromCacheOnly: true);
        CourseRepositoryMock.stubGetCoursesActivities(
            courseRepository as CourseRepositoryMock,
            fromCacheOnly: false);
        SettingsManagerMock.stubGetScheduleSettings(
            settingsManager as SettingsManagerMock,
            toReturn: settings);

        await tester.pumpWidget(localizedWidget(child: ScheduleView()));
        await tester.pumpAndSettle();

        await expectLater(find.byType(ScheduleView),
            matchesGoldenFile(goldenFilePath("scheduleView_4")));
      });
    });

    group("interactions - ", () {
      testWidgets("tap on today button to return on today",
          (WidgetTester tester) async {});

      testWidgets("tap on settings button to open the schedule settings",
          (WidgetTester tester) async {});
    });
  });
}
