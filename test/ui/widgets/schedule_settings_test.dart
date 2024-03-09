// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:ets_api_clients/models.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:mockito/mockito.dart';
import 'package:table_calendar/table_calendar.dart';

// Project imports:
import 'package:notredame/core/constants/preferences_flags.dart';
import 'package:notredame/ui/widgets/schedule_settings.dart';
import '../../helpers.dart';
import '../../mock/managers/course_repository_mock.dart';
import '../../mock/managers/settings_manager_mock.dart';
import '../../mock/services/remote_config_service_mock.dart';

void main() {
  late SettingsManagerMock settingsManagerMock;
  late RemoteConfigServiceMock remoteConfigServiceMock;
  late CourseRepositoryMock courseRepositoryMock;
  late AppIntl intl;

  // Some settings
  final Map<PreferencesFlag, dynamic> settings = {
    PreferencesFlag.scheduleCalendarFormat: CalendarFormat.week,
    PreferencesFlag.scheduleStartWeekday: StartingDayOfWeek.monday,
    PreferencesFlag.scheduleShowTodayBtn: true,
    PreferencesFlag.scheduleListView: true,
    PreferencesFlag.scheduleShowWeekEvents: true
  };

  final List<ScheduleActivity> classOneWithLaboratoryABscheduleActivities = [
    ScheduleActivity(
        courseAcronym: "GEN101",
        courseGroup: "01",
        courseTitle: "Generic Course",
        dayOfTheWeek: 1,
        day: "Lundi",
        startTime: DateFormat("hh:mm").parse("08:30"),
        endTime: DateFormat("hh:mm").parse("12:00"),
        activityCode: ActivityCode.lectureCourse,
        isPrincipalActivity: true,
        activityLocation: "En ligne",
        name: "Activité de cours"),
    ScheduleActivity(
        courseAcronym: "GEN101",
        courseGroup: "01",
        courseTitle: "Generic Course",
        dayOfTheWeek: 2,
        day: "Mardi",
        startTime: DateFormat("hh:mm").parse("13:30"),
        endTime: DateFormat("hh:mm").parse("15:00"),
        activityCode: ActivityCode.labGroupA,
        isPrincipalActivity: true,
        activityLocation: "D-4001",
        name: "Laboratoire (Groupe A)"),
    ScheduleActivity(
        courseAcronym: "GEN101",
        courseGroup: "01",
        courseTitle: "Generic Course",
        dayOfTheWeek: 2,
        day: "Mardi",
        startTime: DateFormat("hh:mm").parse("15:00"),
        endTime: DateFormat("hh:mm").parse("16:30"),
        activityCode: ActivityCode.labGroupB,
        isPrincipalActivity: true,
        activityLocation: "D-4002",
        name: "Laboratoire (Groupe B)"),
  ];

  group("ScheduleSettings - ", () {
    setUp(() async {
      settingsManagerMock = setupSettingsManagerMock();
      courseRepositoryMock =
          setupCourseRepositoryMock();
      remoteConfigServiceMock =
          setupRemoteConfigServiceMock();
      intl = await setupAppIntl();

      CourseRepositoryMock.stubGetScheduleActivities(courseRepositoryMock);
      RemoteConfigServiceMock.stubGetCalendarViewEnabled(remoteConfigServiceMock);
    });

    group("ui - ", () {
      testWidgets("With handle", (WidgetTester tester) async {
        SettingsManagerMock.stubGetScheduleSettings(
            settingsManagerMock,
            toReturn: settings);
        await tester
            .pumpWidget(localizedWidget(child: const ScheduleSettings()));
        await tester.pumpAndSettle();

        // Check the handle
        expect(
            find.byWidgetPredicate((widget) =>
                widget is Container &&
                (widget.decoration! as BoxDecoration).color == Colors.grey),
            findsOneWidget,
            reason: "The handle should be grey");

        // Check the title
        expect(find.text(intl.schedule_settings_title), findsOneWidget);

        // Check calendar format section
        expect(find.text(intl.schedule_settings_calendar_format_pref),
            findsOneWidget);
        expect(
            find.widgetWithText(
                ListTile, intl.schedule_settings_calendar_format_2_weeks),
            findsOneWidget);
        expect(
            find.widgetWithText(
                ListTile, intl.schedule_settings_calendar_format_month),
            findsOneWidget);

        final weekFormatTile = find.widgetWithText(
            ListTile, intl.schedule_settings_calendar_format_week);
        expect(weekFormatTile, findsOneWidget);
        expect(
            tester.widget(weekFormatTile),
            isA<ListTile>()
                .having((source) => source.selected, 'selected', isTrue),
            reason:
                'The settings says week format is the current format, the UI should reflet that.');

        // Check starting day of week section
        expect(
            find.text(intl.schedule_settings_starting_weekday_pref,
                skipOffstage: false),
            findsOneWidget);
        expect(
            find.widgetWithText(
                ListTile, intl.schedule_settings_starting_weekday_saturday,
                skipOffstage: false),
            findsOneWidget);
        expect(
            find.widgetWithText(
                ListTile, intl.schedule_settings_starting_weekday_sunday,
                skipOffstage: false),
            findsOneWidget);

        final startingDayTile = find.widgetWithText(
            ListTile, intl.schedule_settings_starting_weekday_monday,
            skipOffstage: false);
        expect(startingDayTile, findsOneWidget);
        expect(
            tester.widget(startingDayTile),
            isA<ListTile>()
                .having((source) => source.selected, 'selected', isTrue),
            reason:
                'The settings says starting day of week is monday, the UI should reflet that.');

        // Check showTodayButton section
        final showTodayBtnFinder = find.widgetWithText(
            ListTile, intl.schedule_settings_show_today_btn_pref,
            skipOffstage: false);
        expect(showTodayBtnFinder, findsOneWidget);
        expect(
            tester.widget(showTodayBtnFinder),
            isA<ListTile>().having(
                (source) => source.trailing, 'trailing', isA<Switch>()));

        expect(
            tester.widget(find.descendant(
                of: showTodayBtnFinder,
                matching: find.byType(Switch, skipOffstage: false))),
            isA<Switch>().having((source) => source.value, 'value', isTrue),
            reason:
                "the settings says that the showTodayBtn is enabled, the UI should reflet that.");
      });

      testWidgets("Without handle", (WidgetTester tester) async {
        SettingsManagerMock.stubGetScheduleSettings(
            settingsManagerMock,
            toReturn: settings);

        await tester.pumpWidget(
            localizedWidget(child: const ScheduleSettings(showHandle: false)));
        await tester.pumpAndSettle();

        expect(
            find.byWidgetPredicate((widget) =>
                widget is Container &&
                (widget.decoration! as BoxDecoration).color == Colors.grey),
            findsNothing,
            reason: "There should not have a handle.");

        expect(find.text(intl.schedule_settings_title), findsOneWidget);

        // Check calendar format section
        expect(find.text(intl.schedule_settings_calendar_format_pref),
            findsOneWidget);
        expect(
            find.widgetWithText(
                ListTile, intl.schedule_settings_calendar_format_2_weeks),
            findsOneWidget);
        expect(
            find.widgetWithText(
                ListTile, intl.schedule_settings_calendar_format_month),
            findsOneWidget);

        final weekFormatTile = find.widgetWithText(
            ListTile, intl.schedule_settings_calendar_format_week);
        expect(weekFormatTile, findsOneWidget);
        expect(
            tester.widget(weekFormatTile),
            isA<ListTile>()
                .having((source) => source.selected, 'selected', isTrue),
            reason:
                'The settings says week format is the current format, the UI should reflet that.');

        // Check starting day of week section
        expect(
            find.text(intl.schedule_settings_starting_weekday_pref,
                skipOffstage: false),
            findsOneWidget);

        expect(
            find.widgetWithText(
                ListTile, intl.schedule_settings_starting_weekday_saturday,
                skipOffstage: false),
            findsOneWidget);
        expect(
            find.widgetWithText(
                ListTile, intl.schedule_settings_starting_weekday_sunday,
                skipOffstage: false),
            findsOneWidget);

        final startingDayTile = find.widgetWithText(
            ListTile, intl.schedule_settings_starting_weekday_monday,
            skipOffstage: false);
        expect(startingDayTile, findsOneWidget);
        expect(
            tester.widget(startingDayTile),
            isA<ListTile>()
                .having((source) => source.selected, 'selected', isTrue),
            reason:
                'The settings says starting day of week is monday, the UI should reflet that.');

        // Check showTodayButton section
        final showTodayBtnFinder = find.widgetWithText(
            ListTile, intl.schedule_settings_show_today_btn_pref,
            skipOffstage: false);
        expect(showTodayBtnFinder, findsOneWidget);
        expect(
            tester.widget(showTodayBtnFinder),
            isA<ListTile>().having(
                (source) => source.trailing, 'trailing', isA<Switch>()));
        expect(
            tester.widget(find.descendant(
                of: showTodayBtnFinder,
                matching: find.byType(Switch, skipOffstage: false))),
            isA<Switch>().having((source) => source.value, 'value', isTrue),
            reason:
                "the settings says that the showTodayBtn is enabled, the UI should reflet that.");
      });
    });

    group("ScheduleActivities", () {
      testWidgets(
          "Should display activity selection section when a course has activities",
          (WidgetTester tester) async {
        SettingsManagerMock.stubGetScheduleSettings(
            settingsManagerMock,
            toReturn: settings);
        CourseRepositoryMock.stubGetScheduleActivities(courseRepositoryMock,
            toReturn: classOneWithLaboratoryABscheduleActivities);

        const scheduleSettings = ScheduleSettings(showHandle: false);

        await tester.pumpWidget(localizedWidget(child: scheduleSettings));
        await tester.pumpAndSettle();

        final titleLabo =
            find.textContaining(intl.schedule_select_course_activity);
        await tester.dragUntilVisible(
            titleLabo,
            find.byKey(const ValueKey("SettingsScrollingArea")),
            const Offset(0, -250));
        expect(titleLabo, findsOneWidget);

        final laboA = find.textContaining(intl.course_activity_group_a);
        await tester.dragUntilVisible(
            laboA,
            find.byKey(const ValueKey("SettingsScrollingArea")),
            const Offset(0, -250));
        expect(laboA, findsOneWidget);

        final laboB = find.textContaining(intl.course_activity_group_b);
        await tester.dragUntilVisible(
            laboB,
            find.byKey(const ValueKey("SettingsScrollingArea")),
            const Offset(0, -250));
        expect(laboB, findsOneWidget);
      });

      testWidgets(
          "When a settings laboratory is already selected, verify that it is in fact preselected",
          (WidgetTester tester) async {
        SettingsManagerMock.stubGetScheduleSettings(
            settingsManagerMock,
            toReturn: settings);
        CourseRepositoryMock.stubGetScheduleActivities(courseRepositoryMock,
            toReturn: classOneWithLaboratoryABscheduleActivities);
        // preselect the laboB
        SettingsManagerMock.stubGetDynamicString(
            settingsManagerMock,
            PreferencesFlag.scheduleLaboratoryGroup,
            "GEN101",
            toReturn: ActivityCode.labGroupB);

        const scheduleSettings = ScheduleSettings(showHandle: false);

        await tester.pumpWidget(localizedWidget(child: scheduleSettings));
        await tester.pumpAndSettle();

        final laboB =
            find.widgetWithText(ListTile, intl.course_activity_group_b);
        await tester.dragUntilVisible(
            laboB,
            find.byKey(const ValueKey("SettingsScrollingArea")),
            const Offset(0, -250));
        expect(laboB, findsOneWidget);

        // check if laboB is selected
        expect(
            tester.widget(laboB),
            isA<ListTile>()
                .having((source) => source.selected, 'selected', isTrue),
            reason:
                'The settings says laboB is the current labo, the UI should reflet that.');
      });

      testWidgets(
          "if there is only a laboA (no labo b) the options should not appear on screen",
          (WidgetTester tester) async {
        SettingsManagerMock.stubGetScheduleSettings(
            settingsManagerMock,
            toReturn: settings);
        final courseWithOnlyLabA = List<ScheduleActivity>.from(
            classOneWithLaboratoryABscheduleActivities);
        courseWithOnlyLabA.removeWhere(
            (element) => element.activityCode == ActivityCode.labGroupB);
        CourseRepositoryMock.stubGetScheduleActivities(courseRepositoryMock,
            toReturn: courseWithOnlyLabA);

        const scheduleSettings = ScheduleSettings(showHandle: false);

        await tester.pumpWidget(localizedWidget(child: scheduleSettings));
        await tester.pumpAndSettle();

        final titleLabo =
            find.textContaining(intl.schedule_select_course_activity);
        expect(
            () async => tester.dragUntilVisible(
                titleLabo,
                find.byKey(const ValueKey("SettingsScrollingArea")),
                const Offset(0, -250)),
            throwsA(const TypeMatcher<StateError>()));
      });
    });

    group("interactions - ", () {
      testWidgets("onChange calendarFormat", (WidgetTester tester) async {
        SettingsManagerMock.stubGetScheduleSettings(
            settingsManagerMock,
            toReturn: settings);
        SettingsManagerMock.stubSetString(
            settingsManagerMock,
            PreferencesFlag.scheduleCalendarFormat);

        await tester.pumpWidget(
            localizedWidget(child: const ScheduleSettings(showHandle: false)));
        await tester.pumpAndSettle();

        await tester.tap(find.widgetWithText(
            ListTile, intl.schedule_settings_calendar_format_2_weeks));
        await tester.pump();

        await untilCalled(settingsManagerMock.setString(
            PreferencesFlag.scheduleCalendarFormat, any));

        final formatTile = find.widgetWithText(
            ListTile, intl.schedule_settings_calendar_format_2_weeks);
        expect(
            tester.widget(formatTile),
            isA<ListTile>()
                .having((source) => source.selected, 'selected', isTrue),
            reason:
                'The settings says 2 week format now, the UI should reflet that.');
      });

      testWidgets("onChange showTodayBtn", (WidgetTester tester) async {
        SettingsManagerMock.stubGetScheduleSettings(
            settingsManagerMock,
            toReturn: settings);
        SettingsManagerMock.stubSetBool(settingsManagerMock,
            PreferencesFlag.scheduleShowTodayBtn);

        await tester.pumpWidget(
            localizedWidget(child: const ScheduleSettings(showHandle: false)));
        await tester.pumpAndSettle();

        final showTodayBtnFinder = find.widgetWithText(
            ListTile, intl.schedule_settings_show_today_btn_pref,
            skipOffstage: false);

        expect(find.byType(Switch, skipOffstage: false), findsOneWidget);
        // Currently the await tester.tap on a switch in a tile isn't working. Workaround:
        (find.byType(Switch, skipOffstage: false).evaluate().single.widget
                as Switch)
            .onChanged!(false);

        await tester.pumpAndSettle();

        await untilCalled(
            settingsManagerMock.setBool(PreferencesFlag.scheduleShowTodayBtn, any));

        expect(
            tester.widget(find.descendant(
                of: showTodayBtnFinder,
                matching: find.byType(Switch, skipOffstage: false))),
            isA<Switch>().having((source) => source.value, 'value', isFalse),
            reason:
                "the settings says that the showTodayBtn is enabled, the UI should reflet that.");
      });
    });

    group("golden - ", () {
      testWidgets(
          "Should display activity selection section when a course has activities",
          (WidgetTester tester) async {
        SettingsManagerMock.stubGetScheduleSettings(
            settingsManagerMock,
            toReturn: settings);
        CourseRepositoryMock.stubGetScheduleActivities(courseRepositoryMock,
            toReturn: classOneWithLaboratoryABscheduleActivities);

        const scheduleSettings = ScheduleSettings(showHandle: false);

        await tester.pumpWidget(localizedWidget(child: scheduleSettings));
        await tester.pumpAndSettle();

        final laboB = find.textContaining(intl.course_activity_group_b);
        await tester.dragUntilVisible(
            laboB,
            find.byKey(const ValueKey("SettingsScrollingArea")),
            const Offset(0, -250));
        expect(laboB, findsOneWidget);

        // generate a golden file
        tester.binding.window.physicalSizeTestValue = const Size(800, 1410);

        await tester.pumpAndSettle();

        await expectLater(find.byType(ScheduleSettings),
            matchesGoldenFile(goldenFilePath("scheduleSettingsView_1")));
      });
    }, skip: !Platform.isLinux);
  });
}
