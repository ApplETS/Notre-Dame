// FLUTTER / DART / THIRD-PARTIES
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:feature_discovery/feature_discovery.dart';

// MANAGERS
import 'package:notredame/core/managers/course_repository.dart';
import 'package:notredame/core/managers/settings_manager.dart';

// MODELS / CONSTANTS
import 'package:notredame/core/constants/preferences_flags.dart';
import 'package:ets_api_clients/models.dart';

// VIEW / WIDGETS
import 'package:notredame/ui/views/schedule_view.dart';
import 'package:notredame/ui/widgets/schedule_settings.dart';

// HELPERS
import '../../helpers.dart';

// MOCKS
import '../../mock/managers/course_repository_mock.dart';
import '../../mock/managers/settings_manager_mock.dart';

void main() {
  SettingsManager settingsManager;
  CourseRepository courseRepository;

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
      settingsManager = setupSettingsManagerMock();
      courseRepository = setupCourseRepositoryMock();
      setupNetworkingServiceMock();
      setupAnalyticsServiceMock();

      SettingsManagerMock.stubLocale(settingsManager as SettingsManagerMock);

      settings = {
        PreferencesFlag.scheduleSettingsCalendarFormat: CalendarFormat.week,
        PreferencesFlag.scheduleSettingsStartWeekday: StartingDayOfWeek.monday,
        PreferencesFlag.scheduleSettingsShowTodayBtn: true,
        PreferencesFlag.scheduleSettingsShowWeekEvents: false,
      };

      CourseRepositoryMock.stubGetScheduleActivities(
          courseRepository as CourseRepositoryMock);
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

        await tester.pumpWidget(localizedWidget(
            child: FeatureDiscovery(
                child: ScheduleView(initialDay: DateTime(2020)))));
        await tester.pumpAndSettle(const Duration(seconds: 1));

        await expectLater(find.byType(ScheduleView),
            matchesGoldenFile(goldenFilePath("scheduleView_1")));
      });

      testWidgets("default view (no events), showTodayButton disabled",
          (WidgetTester tester) async {
        SettingsManagerMock.stubGetBool(settingsManager as SettingsManagerMock,
            PreferencesFlag.discoverySchedule);
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

        await tester.pumpWidget(localizedWidget(
            child: FeatureDiscovery(
                child: ScheduleView(initialDay: DateTime(2020)))));
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

        await tester.pumpWidget(localizedWidget(
            child: FeatureDiscovery(
                child: MediaQuery(
                    data: const MediaQueryData(textScaleFactor: 0.5),
                    child: ScheduleView(initialDay: DateTime(2020))))));
        await tester.pumpAndSettle(const Duration(seconds: 1));

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

        await tester.pumpWidget(localizedWidget(
            child: FeatureDiscovery(
                child: ScheduleView(initialDay: DateTime(2020)))));
        await tester.pumpAndSettle(const Duration(seconds: 1));

        await expectLater(find.byType(ScheduleView),
            matchesGoldenFile(goldenFilePath("scheduleView_4")));
      });

      testWidgets("other day is selected, current day still has a square.",
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

        final testingDate = DateTime(2020);

        await tester.pumpWidget(localizedWidget(
            child: FeatureDiscovery(
                child: MediaQuery(
                    data: const MediaQueryData(textScaleFactor: 0.5),
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
      testWidgets("tap on today button to return on today",
          (WidgetTester tester) async {
        tester.binding.window.physicalSizeTestValue = const Size(800, 1410);

        CourseRepositoryMock.stubCoursesActivities(
            courseRepository as CourseRepositoryMock,
            toReturn: [activityToday]);
        CourseRepositoryMock.stubGetCoursesActivities(
            courseRepository as CourseRepositoryMock,
            fromCacheOnly: true);
        CourseRepositoryMock.stubGetCoursesActivities(
            courseRepository as CourseRepositoryMock,
            fromCacheOnly: false);
        SettingsManagerMock.stubGetScheduleSettings(
            settingsManager as SettingsManagerMock,
            toReturn: settings);

        await tester.pumpWidget(localizedWidget(
            child: FeatureDiscovery(child: const ScheduleView())));
        await tester.pumpAndSettle(const Duration(seconds: 1));

        // DateFormat has to be after the pumpWidget to correctly load the locale
        final dateFormat = DateFormat.MMMMEEEEd();
        final otherDay = DateTime.now().weekday == 7
            ? DateTime.now().subtract(const Duration(days: 1))
            : DateTime.now().add(const Duration(days: 1));

        expect(find.text(dateFormat.format(DateTime.now())), findsOneWidget);

        // Tap on the day before today if sunday, otherwise tap on the next day
        await tester.tap(find.descendant(
            of: find.byType(TableCalendar),
            matching: find.text("${otherDay.day}")));

        // Reload view
        await tester.pump();

        expect(find.text(dateFormat.format(otherDay)), findsOneWidget,
            reason: "Should be another day than today");

        // Tap on "today" button.
        await tester.tap(find.byIcon(Icons.today));
        await tester.pump();

        expect(find.text(dateFormat.format(DateTime.now())), findsOneWidget,
            reason:
                "Should display today date because we tapped on today button.");
      });

      testWidgets("tap on settings button to open the schedule settings",
          (WidgetTester tester) async {
        tester.binding.window.physicalSizeTestValue = const Size(800, 1410);

        CourseRepositoryMock.stubCoursesActivities(
            courseRepository as CourseRepositoryMock,
            toReturn: [activityToday]);
        CourseRepositoryMock.stubGetCoursesActivities(
            courseRepository as CourseRepositoryMock,
            fromCacheOnly: true);
        CourseRepositoryMock.stubGetCoursesActivities(
            courseRepository as CourseRepositoryMock,
            fromCacheOnly: false);
        SettingsManagerMock.stubGetScheduleSettings(
            settingsManager as SettingsManagerMock,
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

    // group("golden - ", () {
    //   testWidgets(
    //       "Should display activity selection section when a course has activities",
    //           (WidgetTester tester) async {
    //         SettingsManagerMock.stubGetScheduleSettings(
    //             settingsManager as SettingsManagerMock,
    //             toReturn: settings);
    //         CourseRepositoryMock.stubGetScheduleActivities(courseRepositoryMock,
    //             toReturn: classOneWithLaboratoryABscheduleActivities);
    //
    //         const scheduleSettings = ScheduleSettings(showHandle: false);
    //
    //         await tester.pumpWidget(localizedWidget(child: scheduleSettings));
    //         await tester.pumpAndSettle();
    //
    //         final laboB = find.textContaining(intl.course_activity_group_b);
    //         await tester.dragUntilVisible(
    //             laboB,
    //             find.byKey(const ValueKey("SettingsScrollingArea")),
    //             const Offset(0, -250));
    //         expect(laboB, findsOneWidget);
    //
    //         // generate a golden file
    //         tester.binding.window.physicalSizeTestValue = const Size(800, 1410);
    //
    //         await tester.pumpAndSettle();
    //
    //         await expectLater(find.byType(ScheduleSettings),
    //             matchesGoldenFile(goldenFilePath("scheduleSettingsView_1")));
    //       });
    // });

    //
    // group("ScheduleActivities", () {
    //   testWidgets(
    //       "Should display activity selection section when a course has activities",
    //           (WidgetTester tester) async {
    //         SettingsManagerMock.stubGetScheduleSettings(
    //             settingsManager as SettingsManagerMock,
    //             toReturn: settings);
    //         CourseRepositoryMock.stubGetScheduleActivities(courseRepositoryMock,
    //             toReturn: classOneWithLaboratoryABscheduleActivities);
    //
    //         const scheduleSettings = ScheduleSettings(showHandle: false);
    //
    //         await tester.pumpWidget(localizedWidget(child: scheduleSettings));
    //         await tester.pumpAndSettle();
    //
    //         final titleLabo =
    //         find.textContaining(intl.schedule_select_course_activity);
    //         await tester.dragUntilVisible(
    //             titleLabo,
    //             find.byKey(const ValueKey("SettingsScrollingArea")),
    //             const Offset(0, -250));
    //         expect(titleLabo, findsOneWidget);
    //
    //         final laboA = find.textContaining(intl.course_activity_group_a);
    //         await tester.dragUntilVisible(
    //             laboA,
    //             find.byKey(const ValueKey("SettingsScrollingArea")),
    //             const Offset(0, -250));
    //         expect(laboA, findsOneWidget);
    //
    //         final laboB = find.textContaining(intl.course_activity_group_b);
    //         await tester.dragUntilVisible(
    //             laboB,
    //             find.byKey(const ValueKey("SettingsScrollingArea")),
    //             const Offset(0, -250));
    //         expect(laboB, findsOneWidget);
    //       });
    //
    //   testWidgets(
    //       "When a settings laboratory is already selected, verify that it is in fact preselected",
    //           (WidgetTester tester) async {
    //         SettingsManagerMock.stubGetScheduleSettings(
    //             settingsManager as SettingsManagerMock,
    //             toReturn: settings);
    //         CourseRepositoryMock.stubGetScheduleActivities(courseRepositoryMock,
    //             toReturn: classOneWithLaboratoryABscheduleActivities);
    //         // preselect the laboB
    //         SettingsManagerMock.stubGetDynamicString(
    //             settingsManager as SettingsManagerMock,
    //             PreferencesFlag.scheduleSettingsLaboratoryGroup,
    //             "GEN101",
    //             toReturn: ActivityCode.labGroupB);
    //
    //         const scheduleSettings = ScheduleSettings(showHandle: false);
    //
    //         await tester.pumpWidget(localizedWidget(child: scheduleSettings));
    //         await tester.pumpAndSettle();
    //
    //         final laboB =
    //         find.widgetWithText(ListTile, intl.course_activity_group_b);
    //         await tester.dragUntilVisible(
    //             laboB,
    //             find.byKey(const ValueKey("SettingsScrollingArea")),
    //             const Offset(0, -250));
    //         expect(laboB, findsOneWidget);
    //
    //         // check if laboB is selected
    //         expect(
    //             tester.widget(laboB),
    //             isA<ListTile>()
    //                 .having((source) => source.selected, 'selected', isTrue),
    //             reason:
    //             'The settings says laboB is the current labo, the UI should reflet that.');
    //       });
    //
    //   testWidgets(
    //       "if there is only a laboA (no labo b) the options should not appear on screen",
    //           (WidgetTester tester) async {
    //         SettingsManagerMock.stubGetScheduleSettings(
    //             settingsManager as SettingsManagerMock,
    //             toReturn: settings);
    //         final courseWithOnlyLabA = List<ScheduleActivity>.from(
    //             classOneWithLaboratoryABscheduleActivities);
    //         courseWithOnlyLabA.removeWhere(
    //                 (element) => element.activityCode == ActivityCode.labGroupB);
    //         CourseRepositoryMock.stubGetScheduleActivities(courseRepositoryMock,
    //             toReturn: courseWithOnlyLabA);
    //
    //         const scheduleSettings = ScheduleSettings(showHandle: false);
    //
    //         await tester.pumpWidget(localizedWidget(child: scheduleSettings));
    //         await tester.pumpAndSettle();
    //
    //         final titleLabo =
    //         find.textContaining(intl.schedule_select_course_activity);
    //         expect(
    //                 () async => tester.dragUntilVisible(
    //                 titleLabo,
    //                 find.byKey(const ValueKey("SettingsScrollingArea")),
    //                 const Offset(0, -250)),
    //             throwsA(const TypeMatcher<StateError>()));
    //       });
    // });
  });
}
