// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:mockito/mockito.dart';

// Project imports:
import 'package:notredame/data/models/activity_code.dart';
import 'package:notredame/data/services/calendar_service.dart';
import 'package:notredame/data/services/signets-api/models/schedule_activity.dart';
import 'package:notredame/domain/constants/preferences_flags.dart';
import 'package:notredame/l10n/app_localizations.dart';
import 'package:notredame/ui/schedule/schedule_controller.dart';
import 'package:notredame/ui/schedule/widgets/schedule_settings.dart';
import '../../../data/mocks/repositories/course_repository_mock.dart';
import '../../../data/mocks/repositories/settings_repository_mock.dart';
import '../../../data/mocks/services/remote_config_service_mock.dart';
import '../../../helpers.dart';

void main() {
  late SettingsRepositoryMock settingsManagerMock;
  late RemoteConfigServiceMock remoteConfigServiceMock;
  late CourseRepositoryMock courseRepositoryMock;
  late AppIntl intl;
  ScheduleController controller = ScheduleController();
  controller.settingsUpdated = () {};

  // Some settings
  final Map<PreferencesFlag, dynamic> settings = {
    PreferencesFlag.scheduleCalendarFormat: CalendarTimeFormat.week,
    PreferencesFlag.scheduleShowTodayBtn: true,
    PreferencesFlag.scheduleListView: true,
  };

  final List<ScheduleActivity> classOneWithLaboratoryABscheduleActivities = [
    ScheduleActivity(
      courseAcronym: "GEN101",
      courseTitle: "Generic Course",
      dayOfTheWeek: 1,
      startTime: DateFormat("hh:mm").parse("08:30"),
      endTime: DateFormat("hh:mm").parse("12:00"),
      activityCode: ActivityCode.lectureCourse,
    ),
    ScheduleActivity(
      courseAcronym: "GEN101",
      courseTitle: "Generic Course",
      dayOfTheWeek: 2,
      startTime: DateFormat("hh:mm").parse("13:30"),
      endTime: DateFormat("hh:mm").parse("15:00"),
      activityCode: ActivityCode.labGroupA,
    ),
    ScheduleActivity(
      courseAcronym: "GEN101",
      courseTitle: "Generic Course",
      dayOfTheWeek: 2,
      startTime: DateFormat("hh:mm").parse("15:00"),
      endTime: DateFormat("hh:mm").parse("16:30"),
      activityCode: ActivityCode.labGroupB,
    ),
  ];

  group("ScheduleSettings - ", () {
    setUp(() async {
      settingsManagerMock = setupSettingsRepositoryMock();
      courseRepositoryMock = setupCourseRepositoryMock();
      remoteConfigServiceMock = setupRemoteConfigServiceMock();
      intl = await setupAppIntl();

      CourseRepositoryMock.stubGetScheduleActivities(courseRepositoryMock);
      RemoteConfigServiceMock.stubGetCalendarViewEnabled(remoteConfigServiceMock);
    });

    group("ui - ", () {
      testWidgets("With handle", (WidgetTester tester) async {
        SettingsRepositoryMock.stubGetScheduleSettings(settingsManagerMock, toReturn: settings);

        Widget scheduleSettings = ScheduleSettings(controller: controller);
        await tester.pumpWidget(localizedWidget(child: scheduleSettings));
        await tester.pumpAndSettle();

        // Check the handle
        expect(
          find.byWidgetPredicate(
            (widget) =>
                widget is Container &&
                widget.decoration is BoxDecoration &&
                (widget.decoration! as BoxDecoration).color == Color(0xff868383),
          ),
          findsOneWidget,
          reason: "The handle should be grey",
        );

        // Check the title
        expect(find.text(intl.schedule_settings_title), findsOneWidget);

        // Check calendar format section
        expect(find.text(intl.schedule_settings_calendar_format_pref), findsOneWidget);
        expect(find.widgetWithText(InputChip, intl.schedule_settings_calendar_format_day), findsOneWidget);
        expect(find.widgetWithText(InputChip, intl.schedule_settings_calendar_format_month), findsOneWidget);

        final weekFormatTile = find.widgetWithText(InputChip, intl.schedule_settings_calendar_format_week);
        expect(weekFormatTile, findsOneWidget);
        expect(
          tester.widget(weekFormatTile),
          isA<InputChip>().having((source) => source.selected, 'selected', isTrue),
          reason: 'The settings says week format is the current format, the UI should reflet that.',
        );

        // Check showTodayButton section
        final showTodayBtnFinder = find.widgetWithText(
          ListTile,
          intl.schedule_settings_show_today_btn_pref,
          skipOffstage: false,
        );
        expect(showTodayBtnFinder, findsOneWidget);
        expect(
          tester.widget(showTodayBtnFinder),
          isA<ListTile>().having((source) => source.trailing, 'trailing', isA<Switch>()),
        );

        expect(
          tester.widget(find.descendant(of: showTodayBtnFinder, matching: find.byType(Switch, skipOffstage: false))),
          isA<Switch>().having((source) => source.value, 'value', isTrue),
          reason: "the settings says that the showTodayBtn is enabled, the UI should reflet that.",
        );

        const screenHeight = 600;

        final draggableScrollableSheetFinder = find.byType(DraggableScrollableSheet);
        expect(draggableScrollableSheetFinder, findsOneWidget);

        final Size initialSize = tester.getSize(draggableScrollableSheetFinder);
        expect(initialSize.height, 0.55 * screenHeight);

        await tester.fling(find.byType(ListView).first, const Offset(0.0, -4000.0), 400.0);
        final Size maxSize = tester.getSize(draggableScrollableSheetFinder);
        expect(maxSize.height, 0.85 * screenHeight);
      });
    });

    group("ScheduleActivities", () {
      testWidgets("Should display activity selection section when a course has activities", (
        WidgetTester tester,
      ) async {
        SettingsRepositoryMock.stubGetScheduleSettings(settingsManagerMock, toReturn: settings);
        CourseRepositoryMock.stubGetScheduleActivities(
          courseRepositoryMock,
          toReturn: classOneWithLaboratoryABscheduleActivities,
        );

        Widget scheduleSettings = ScheduleSettings(controller: controller);
        await tester.pumpWidget(localizedWidget(child: scheduleSettings));

        await tester.pumpWidget(localizedWidget(child: scheduleSettings));
        await tester.pumpAndSettle();

        final titleLabo = find.textContaining(intl.schedule_select_course_activity);
        await tester.dragUntilVisible(
          titleLabo,
          find.byKey(const ValueKey("SettingsScrollingArea")),
          const Offset(0, -250),
        );
        expect(titleLabo, findsOneWidget);

        final laboA = find.textContaining(intl.course_activity_group_a);
        await tester.dragUntilVisible(
          laboA,
          find.byKey(const ValueKey("SettingsScrollingArea")),
          const Offset(0, -250),
        );
        expect(laboA, findsOneWidget);

        final laboB = find.textContaining(intl.course_activity_group_b);
        await tester.dragUntilVisible(
          laboB,
          find.byKey(const ValueKey("SettingsScrollingArea")),
          const Offset(0, -250),
        );
        expect(laboB, findsOneWidget);
      });

      testWidgets("When a settings laboratory is already selected, verify that it is in fact preselected", (
        WidgetTester tester,
      ) async {
        SettingsRepositoryMock.stubGetScheduleSettings(settingsManagerMock, toReturn: settings);
        CourseRepositoryMock.stubGetScheduleActivities(
          courseRepositoryMock,
          toReturn: classOneWithLaboratoryABscheduleActivities,
        );
        // preselect the laboB
        SettingsRepositoryMock.stubGetDynamicString(
          settingsManagerMock,
          PreferencesFlag.scheduleLaboratoryGroup,
          "GEN101",
          toReturn: ActivityCode.labGroupB,
        );

        Widget scheduleSettings = ScheduleSettings(controller: controller);

        await tester.pumpWidget(localizedWidget(child: scheduleSettings));
        await tester.pumpAndSettle();

        final laboB = find.widgetWithText(InputChip, intl.course_activity_group_b);
        await tester.dragUntilVisible(
          laboB,
          find.byKey(const ValueKey("SettingsScrollingArea")),
          const Offset(0, -250),
        );
        expect(laboB, findsOneWidget);

        // check if laboB is selected
        expect(
          tester.widget(laboB),
          isA<InputChip>().having((source) => source.selected, 'selected', isTrue),
          reason: 'The settings says laboB is the current labo, the UI should reflet that.',
        );
      });

      testWidgets("if there is only a laboA (no labo b) the options should not appear on screen", (
        WidgetTester tester,
      ) async {
        SettingsRepositoryMock.stubGetScheduleSettings(settingsManagerMock, toReturn: settings);
        final courseWithOnlyLabA = List<ScheduleActivity>.from(classOneWithLaboratoryABscheduleActivities);
        courseWithOnlyLabA.removeWhere((element) => element.activityCode == ActivityCode.labGroupB);
        CourseRepositoryMock.stubGetScheduleActivities(courseRepositoryMock, toReturn: courseWithOnlyLabA);

        Widget scheduleSettings = ScheduleSettings(controller: controller);
        await tester.pumpWidget(localizedWidget(child: scheduleSettings));

        await tester.pumpWidget(localizedWidget(child: scheduleSettings));
        await tester.pumpAndSettle();

        final titleLabo = find.textContaining(intl.schedule_select_course_activity);
        expect(
          () async => tester.dragUntilVisible(
            titleLabo,
            find.byKey(const ValueKey("SettingsScrollingArea")),
            const Offset(0, -250),
          ),
          throwsA(const TypeMatcher<StateError>()),
        );
      });
    });

    group("interactions - ", () {
      testWidgets("onChange calendarFormat", (WidgetTester tester) async {
        SettingsRepositoryMock.stubGetScheduleSettings(settingsManagerMock, toReturn: settings);
        SettingsRepositoryMock.stubSetString(settingsManagerMock, PreferencesFlag.scheduleCalendarFormat);

        Widget scheduleSettings = ScheduleSettings(controller: controller);
        await tester.pumpWidget(localizedWidget(child: scheduleSettings));
        await tester.pumpAndSettle();

        await tester.tap(find.widgetWithText(InputChip, intl.schedule_settings_calendar_format_day));
        await tester.pump();

        await untilCalled(settingsManagerMock.setString(PreferencesFlag.scheduleCalendarFormat, any));

        final formatTile = find.widgetWithText(InputChip, intl.schedule_settings_calendar_format_day);
        expect(
          tester.widget(formatTile),
          isA<InputChip>().having((source) => source.selected, 'selected', isTrue),
          reason: 'The settings says 2 week format now, the UI should reflet that.',
        );
      });

      testWidgets("onChange scheduleListView", (WidgetTester tester) async {
        final Map<PreferencesFlag, dynamic> settings = {
          PreferencesFlag.scheduleCalendarFormat: CalendarTimeFormat.day,
          PreferencesFlag.scheduleShowTodayBtn: true,
          PreferencesFlag.scheduleListView: true,
        };

        SettingsRepositoryMock.stubGetScheduleSettings(settingsManagerMock, toReturn: settings);
        SettingsRepositoryMock.stubSetBool(settingsManagerMock, PreferencesFlag.scheduleListView);
        await tester
            .runAsync(() async {
              Widget scheduleSettings = ScheduleSettings(controller: controller);
              await tester.pumpWidget(localizedWidget(child: scheduleSettings));
              await tester.pumpAndSettle();
            })
            .then((value) async {
              final scheduleListViewFinder = find.widgetWithText(
                ListTile,
                intl.schedule_settings_list_view,
                skipOffstage: false,
              );

              (find.byType(Switch, skipOffstage: false).evaluate().elementAt(1).widget as Switch).onChanged!(false);

              await tester.pumpAndSettle();

              await untilCalled(settingsManagerMock.setBool(PreferencesFlag.scheduleListView, any));

              expect(
                tester.widget(
                  find.descendant(of: scheduleListViewFinder, matching: find.byType(Switch, skipOffstage: false)),
                ),
                isA<Switch>().having((source) => source.value, 'value', isFalse),
                reason: "the settings says calendar view format now, the UI should reflet that.",
              );

              Widget scheduleSettings = ScheduleSettings(controller: controller);
              await tester.pumpWidget(localizedWidget(child: scheduleSettings));
              await tester.pumpAndSettle();

              expect(find.widgetWithText(InputChip, intl.schedule_settings_calendar_format_month), findsOneWidget);
              expect(find.widgetWithText(InputChip, intl.schedule_settings_calendar_format_week), findsOneWidget);
              expect(find.widgetWithText(InputChip, intl.schedule_settings_calendar_format_day), findsOneWidget);
            });
      });

      testWidgets("onChange showTodayBtn", (WidgetTester tester) async {
        SettingsRepositoryMock.stubGetScheduleSettings(settingsManagerMock, toReturn: settings);
        SettingsRepositoryMock.stubSetBool(settingsManagerMock, PreferencesFlag.scheduleShowTodayBtn);
        await tester
            .runAsync(() async {
              Widget scheduleSettings = ScheduleSettings(controller: controller);
              await tester.pumpWidget(localizedWidget(child: scheduleSettings));
              await tester.pumpAndSettle();
            })
            .then((value) async {
              final showTodayBtnFinder = find.widgetWithText(
                ListTile,
                intl.schedule_settings_show_today_btn_pref,
                skipOffstage: false,
              );

              (find.byType(Switch, skipOffstage: false).evaluate().first.widget as Switch).onChanged!(false);

              await tester.pumpAndSettle();

              await untilCalled(settingsManagerMock.setBool(PreferencesFlag.scheduleShowTodayBtn, any));

              expect(
                tester.widget(
                  find.descendant(of: showTodayBtnFinder, matching: find.byType(Switch, skipOffstage: false)),
                ),
                isA<Switch>().having((source) => source.value, 'value', isFalse),
                reason: "the settings says that the showTodayBtn is enabled, the UI should reflet that.",
              );
            });
      });
    });
  });
}
