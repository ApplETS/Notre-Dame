// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:mockito/mockito.dart';

// Project imports:
import 'package:notredame/data/models/activity_code.dart';
import 'package:notredame/data/repositories/settings_repository.dart';
import 'package:notredame/data/services/calendar_service.dart';
import 'package:notredame/data/services/signets-api/models/schedule_activity.dart';
import 'package:notredame/domain/constants/preferences_flags.dart';
import 'package:notredame/ui/schedule/view_model/schedule_settings_viewmodel.dart';
import '../../../data/mocks/repositories/course_repository_mock.dart';
import '../../../data/mocks/repositories/settings_repository_mock.dart';
import '../../../helpers.dart';

late SettingsRepositoryMock settingsManagerMock;
late CourseRepositoryMock courseRepositoryMock;

late ScheduleSettingsViewModel viewModel;

void main() {
  // Needed to support FlutterToast.
  TestWidgetsFlutterBinding.ensureInitialized();

  final Map<PreferencesFlag, dynamic> settings = {
    PreferencesFlag.scheduleCalendarFormat: CalendarTimeFormat.week,
    PreferencesFlag.scheduleShowTodayBtn: true,
    PreferencesFlag.scheduleListView: false,
  };

  final List<ScheduleActivity> classOneWithLaboratoryABscheduleActivities = [
    ScheduleActivity(
        courseAcronym: "ABC123",
        courseGroup: "01",
        courseTitle: "Sample Course",
        dayOfTheWeek: 1,
        day: "Lundi",
        startTime: DateFormat("hh:mm").parse("08:30"),
        endTime: DateFormat("hh:mm").parse("12:00"),
        activityCode: ActivityCode.lectureCourse,
        isPrincipalActivity: true,
        activityLocation: "En ligne",
        name: "Activité de cours"),
    ScheduleActivity(
        courseAcronym: "ABC123",
        courseGroup: "01",
        courseTitle: "Sample Course",
        dayOfTheWeek: 2,
        day: "Mardi",
        startTime: DateFormat("hh:mm").parse("13:30"),
        endTime: DateFormat("hh:mm").parse("15:00"),
        activityCode: ActivityCode.labGroupA,
        isPrincipalActivity: true,
        activityLocation: "D-4001",
        name: "Laboratoire (Groupe A)"),
    ScheduleActivity(
        courseAcronym: "ABC123",
        courseGroup: "01",
        courseTitle: "Sample Course",
        dayOfTheWeek: 2,
        day: "Mardi",
        startTime: DateFormat("hh:mm").parse("15:00"),
        endTime: DateFormat("hh:mm").parse("16:30"),
        activityCode: ActivityCode.labGroupB,
        isPrincipalActivity: true,
        activityLocation: "D-4002",
        name: "Laboratoire (Groupe B)"),
  ];

  final List<ScheduleActivity> classTwoWithLaboratoryABscheduleActivities = [
    ScheduleActivity(
        courseAcronym: "XYZ321",
        courseGroup: "01",
        courseTitle: "Sample Course",
        dayOfTheWeek: 1,
        day: "Lundi",
        startTime: DateFormat("hh:mm").parse("08:30"),
        endTime: DateFormat("hh:mm").parse("12:00"),
        activityCode: ActivityCode.lectureCourse,
        isPrincipalActivity: true,
        activityLocation: "En ligne",
        name: "Activité de cours"),
    ScheduleActivity(
        courseAcronym: "XYZ321",
        courseGroup: "01",
        courseTitle: "Sample Course",
        dayOfTheWeek: 2,
        day: "Mardi",
        startTime: DateFormat("hh:mm").parse("13:30"),
        endTime: DateFormat("hh:mm").parse("15:00"),
        activityCode: ActivityCode.labGroupA,
        isPrincipalActivity: true,
        activityLocation: "D-4003",
        name: "Laboratoire (Groupe A)"),
    ScheduleActivity(
        courseAcronym: "XYZ321",
        courseGroup: "01",
        courseTitle: "Sample Course",
        dayOfTheWeek: 2,
        day: "Mardi",
        startTime: DateFormat("hh:mm").parse("15:00"),
        endTime: DateFormat("hh:mm").parse("16:30"),
        activityCode: ActivityCode.labGroupB,
        isPrincipalActivity: true,
        activityLocation: "D-4004",
        name: "Laboratoire (Groupe B)"),
  ];
  final List<ScheduleActivity> twoClassesWithLaboratoryABscheduleActivities =
      [];
  group("ScheduleSettingsViewModel - ", () {
    setUp(() {
      settingsManagerMock = setupSettingsManagerMock();
      courseRepositoryMock = setupCourseRepositoryMock();
      viewModel = ScheduleSettingsViewModel();

      twoClassesWithLaboratoryABscheduleActivities
          .addAll(classOneWithLaboratoryABscheduleActivities);
      twoClassesWithLaboratoryABscheduleActivities
          .addAll(classTwoWithLaboratoryABscheduleActivities);
    });

    tearDown(() {
      unregister<SettingsRepository>();
    });

    group("futureToRun - ", () {
      test(
          "The settings are correctly loaded and sets (if no schedule activities present to use)",
          () async {
        SettingsRepositoryMock.stubGetScheduleSettings(settingsManagerMock,
            toReturn: settings);

        CourseRepositoryMock.stubGetScheduleActivities(courseRepositoryMock,
            toReturn: []);

        expect(await viewModel.futureToRun(), settings);
        expect(viewModel.calendarFormat,
            settings[PreferencesFlag.scheduleCalendarFormat]);
        expect(viewModel.showTodayBtn,
            settings[PreferencesFlag.scheduleShowTodayBtn]);

        verify(settingsManagerMock.getScheduleSettings()).called(1);
        verifyNoMoreInteractions(settingsManagerMock);

        verify(courseRepositoryMock.getScheduleActivities()).called(1);
        verifyNoMoreInteractions(courseRepositoryMock);
      });

      test(
          "If there is one valid class which has grouped laboratory, we parse it and store it (None selected)",
          () async {
        SettingsRepositoryMock.stubGetScheduleSettings(settingsManagerMock,
            toReturn: settings);

        CourseRepositoryMock.stubGetScheduleActivities(courseRepositoryMock,
            toReturn: classOneWithLaboratoryABscheduleActivities);

        final courseAcronymWithLaboratory =
            classOneWithLaboratoryABscheduleActivities.first.courseAcronym;

        SettingsRepositoryMock.stubGetDynamicString(
            settingsManagerMock,
            PreferencesFlag.scheduleLaboratoryGroup,
            courseAcronymWithLaboratory);

        expect(await viewModel.futureToRun(), settings);
        expect(
            viewModel.scheduleActivitiesByCourse
                .containsKey(courseAcronymWithLaboratory),
            true);
        expect(
            viewModel.scheduleActivitiesByCourse[courseAcronymWithLaboratory]!
                .length,
            2);
        expect(
            viewModel.selectedScheduleActivity
                .containsKey(courseAcronymWithLaboratory),
            false);

        verify(courseRepositoryMock.getScheduleActivities()).called(1);
        verifyNoMoreInteractions(courseRepositoryMock);

        verify(settingsManagerMock.getDynamicString(any, any)).called(1);
      });
      test(
          "If there is two valid class which has grouped laboratory, we store both (First => none selected, Second => group A selected)",
          () async {
        SettingsRepositoryMock.stubGetScheduleSettings(settingsManagerMock,
            toReturn: settings);

        CourseRepositoryMock.stubGetScheduleActivities(courseRepositoryMock,
            toReturn: twoClassesWithLaboratoryABscheduleActivities);

        final firstCourseAcronymWithLab =
            classOneWithLaboratoryABscheduleActivities.first.courseAcronym;

        final secondCourseAcronymWithLab =
            classTwoWithLaboratoryABscheduleActivities.first.courseAcronym;

        SettingsRepositoryMock.stubGetDynamicString(settingsManagerMock,
            PreferencesFlag.scheduleLaboratoryGroup, firstCourseAcronymWithLab);
        SettingsRepositoryMock.stubGetDynamicString(settingsManagerMock,
            PreferencesFlag.scheduleLaboratoryGroup, secondCourseAcronymWithLab,
            toReturn: ActivityCode.labGroupA);

        expect(await viewModel.futureToRun(), settings);
        expect(viewModel.scheduleActivitiesByCourse.keys.length, 2);
        expect(
            viewModel
                .scheduleActivitiesByCourse[firstCourseAcronymWithLab]!.length,
            2);
        expect(
            viewModel
                .scheduleActivitiesByCourse[secondCourseAcronymWithLab]!.length,
            2);
        expect(
            viewModel.selectedScheduleActivity
                .containsKey(firstCourseAcronymWithLab),
            false);
        expect(
            viewModel.selectedScheduleActivity
                .containsKey(secondCourseAcronymWithLab),
            true);
        expect(
            viewModel.selectedScheduleActivity[secondCourseAcronymWithLab],
            classTwoWithLaboratoryABscheduleActivities.firstWhere(
                (element) => element.activityCode == ActivityCode.labGroupA));

        verify(courseRepositoryMock.getScheduleActivities()).called(1);
        verifyNoMoreInteractions(courseRepositoryMock);

        verify(settingsManagerMock.getDynamicString(any, any)).called(2);
      });
    });

    group("setter calendarFormat - ", () {
      test("calendarFormat is updated on the settings", () async {
        SettingsRepositoryMock.stubSetString(
            settingsManagerMock, PreferencesFlag.scheduleCalendarFormat);

        // Call the setter.
        viewModel.calendarFormat = CalendarTimeFormat.day;

        await untilCalled(settingsManagerMock.setString(
            PreferencesFlag.scheduleCalendarFormat, any));

        expect(viewModel.calendarFormat, CalendarTimeFormat.day);
        expect(viewModel.isBusy, false);

        verify(settingsManagerMock.setString(
                PreferencesFlag.scheduleCalendarFormat, any))
            .called(1);
        verifyNoMoreInteractions(settingsManagerMock);
      });
    });

    group("setter calendarView - ", () {
      test("calendarView is updated on the settings", () async {
        SettingsRepositoryMock.stubSetString(
            settingsManagerMock, PreferencesFlag.scheduleListView);

        const expected = true;

        // Call the setter.
        viewModel.toggleCalendarView = expected;

        await untilCalled(
            settingsManagerMock.setBool(PreferencesFlag.scheduleListView, any));

        expect(viewModel.toggleCalendarView, true);
        expect(viewModel.isBusy, false);

        verify(settingsManagerMock.setBool(
                PreferencesFlag.scheduleListView, any))
            .called(1);
        verifyNoMoreInteractions(settingsManagerMock);
      });
    });

    group("setter showTodayBtn - ", () {
      test("showTodayBtn is updated on the settings", () async {
        const expected = false;

        // Call the setter.
        viewModel.showTodayBtn = expected;

        await untilCalled(settingsManagerMock.setBool(
            PreferencesFlag.scheduleShowTodayBtn, any));

        expect(viewModel.showTodayBtn, expected);
        expect(viewModel.isBusy, false);

        verify(settingsManagerMock.setBool(
                PreferencesFlag.scheduleShowTodayBtn, any))
            .called(1);
        verifyNoMoreInteractions(settingsManagerMock);
      });
    });
  });
}
