// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:mockito/mockito.dart';
import 'package:table_calendar/table_calendar.dart';

// MANAGER
import 'package:notredame/core/managers/settings_manager.dart';
import 'package:notredame/core/managers/course_repository.dart';

// VIEWMODEL
import 'package:notredame/core/viewmodels/schedule_settings_viewmodel.dart';

// MODELS
import 'package:ets_api_clients/models.dart';

// CONSTANTS
import 'package:notredame/core/constants/preferences_flags.dart';

// OTHER
import '../helpers.dart';
import '../mock/managers/course_repository_mock.dart';
import '../mock/managers/settings_manager_mock.dart';

SettingsManager settingsManager;
CourseRepository courseRepository;
ScheduleSettingsViewModel viewModel;

void main() {
  // Needed to support FlutterToast.
  TestWidgetsFlutterBinding.ensureInitialized();

  final Map<PreferencesFlag, dynamic> settings = {
    PreferencesFlag.scheduleCalendarFormat: CalendarFormat.week,
    PreferencesFlag.scheduleStartWeekday: StartingDayOfWeek.monday,
    PreferencesFlag.scheduleShowTodayBtn: true
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
      settingsManager = setupSettingsManagerMock();
      courseRepository = setupCourseRepositoryMock();
      viewModel = ScheduleSettingsViewModel();

      twoClassesWithLaboratoryABscheduleActivities
          .addAll(classOneWithLaboratoryABscheduleActivities);
      twoClassesWithLaboratoryABscheduleActivities
          .addAll(classTwoWithLaboratoryABscheduleActivities);
    });

    tearDown(() {
      unregister<SettingsManager>();
    });

    group("futureToRun - ", () {
      test(
          "The settings are correctly loaded and sets (if no schedule activities present to use)",
          () async {
        SettingsManagerMock.stubGetScheduleSettings(
            settingsManager as SettingsManagerMock,
            toReturn: settings);

        CourseRepositoryMock.stubGetScheduleActivities(
            courseRepository as CourseRepositoryMock,
            toReturn: []);

        expect(await viewModel.futureToRun(), settings);
        expect(viewModel.calendarFormat,
            settings[PreferencesFlag.scheduleCalendarFormat]);
        expect(viewModel.startingDayOfWeek,
            settings[PreferencesFlag.scheduleStartWeekday]);
        expect(viewModel.showTodayBtn,
            settings[PreferencesFlag.scheduleShowTodayBtn]);

        verify(settingsManager.getScheduleSettings()).called(1);
        verifyNoMoreInteractions(settingsManager);

        verify(courseRepository.getScheduleActivities()).called(1);
        verifyNoMoreInteractions(courseRepository);
      });

      test(
          "If there is one valid class which has grouped laboratory, we parse it and store it (None selected)",
          () async {
        SettingsManagerMock.stubGetScheduleSettings(
            settingsManager as SettingsManagerMock,
            toReturn: settings);

        CourseRepositoryMock.stubGetScheduleActivities(
            courseRepository as CourseRepositoryMock,
            toReturn: classOneWithLaboratoryABscheduleActivities);

        final courseAcronymWithLaboratory =
            classOneWithLaboratoryABscheduleActivities.first.courseAcronym;

        SettingsManagerMock.stubGetDynamicString(
            settingsManager as SettingsManagerMock,
            PreferencesFlag.scheduleLaboratoryGroup,
            courseAcronymWithLaboratory,
            toReturn: null);

        expect(await viewModel.futureToRun(), settings);
        expect(
            viewModel.scheduleActivitiesByCourse
                .containsKey(courseAcronymWithLaboratory),
            true);
        expect(
            viewModel
                .scheduleActivitiesByCourse[courseAcronymWithLaboratory].length,
            2);
        expect(
            viewModel.selectedScheduleActivity
                .containsKey(courseAcronymWithLaboratory),
            false);

        verify(courseRepository.getScheduleActivities()).called(1);
        verifyNoMoreInteractions(courseRepository);

        verify(settingsManager.getDynamicString(any, any)).called(1);
      });
      test(
          "If there is two valid class which has grouped laboratory, we store both (First => none selected, Second => group A selected)",
          () async {
        SettingsManagerMock.stubGetScheduleSettings(
            settingsManager as SettingsManagerMock,
            toReturn: settings);

        CourseRepositoryMock.stubGetScheduleActivities(
            courseRepository as CourseRepositoryMock,
            toReturn: twoClassesWithLaboratoryABscheduleActivities);

        final firstCourseAcronymWithLab =
            classOneWithLaboratoryABscheduleActivities.first.courseAcronym;

        final secondCourseAcronymWithLab =
            classTwoWithLaboratoryABscheduleActivities.first.courseAcronym;

        SettingsManagerMock.stubGetDynamicString(
            settingsManager as SettingsManagerMock,
            PreferencesFlag.scheduleLaboratoryGroup,
            firstCourseAcronymWithLab,
            toReturn: null);
        SettingsManagerMock.stubGetDynamicString(
            settingsManager as SettingsManagerMock,
            PreferencesFlag.scheduleLaboratoryGroup,
            secondCourseAcronymWithLab,
            toReturn: ActivityCode.labGroupA);

        expect(await viewModel.futureToRun(), settings);
        expect(viewModel.scheduleActivitiesByCourse.keys.length, 2);
        expect(
            viewModel
                .scheduleActivitiesByCourse[firstCourseAcronymWithLab].length,
            2);
        expect(
            viewModel
                .scheduleActivitiesByCourse[secondCourseAcronymWithLab].length,
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

        verify(courseRepository.getScheduleActivities()).called(1);
        verifyNoMoreInteractions(courseRepository);

        verify(settingsManager.getDynamicString(any, any)).called(2);
      });
    });

    group("setter calendarFormat - ", () {
      test("calendarFormat is updated on the settings", () async {
        SettingsManagerMock.stubSetString(
            settingsManager as SettingsManagerMock,
            PreferencesFlag.scheduleCalendarFormat);

        // Call the setter.
        viewModel.calendarFormat = CalendarFormat.twoWeeks;

        await untilCalled(settingsManager.setString(
            PreferencesFlag.scheduleCalendarFormat, any));

        expect(viewModel.calendarFormat, CalendarFormat.twoWeeks);
        expect(viewModel.isBusy, false);

        verify(settingsManager.setString(
                PreferencesFlag.scheduleCalendarFormat, any))
            .called(1);
        verifyNoMoreInteractions(settingsManager);
      });
    });

    group("setter startingDayOfWeek - ", () {
      test("startingDayOfWeek is updated on the settings", () async {
        SettingsManagerMock.stubSetString(
            settingsManager as SettingsManagerMock,
            PreferencesFlag.scheduleStartWeekday);

        // Call the setter.
        viewModel.startingDayOfWeek = StartingDayOfWeek.friday;

        await untilCalled(settingsManager.setString(
            PreferencesFlag.scheduleStartWeekday, any));

        expect(viewModel.startingDayOfWeek, StartingDayOfWeek.friday);
        expect(viewModel.isBusy, false);

        verify(settingsManager.setString(
                PreferencesFlag.scheduleStartWeekday, any))
            .called(1);
        verifyNoMoreInteractions(settingsManager);
      });
    });

    group("setter showTodayBtn - ", () {
      test("showTodayBtn is updated on the settings", () async {
        SettingsManagerMock.stubSetString(
            settingsManager as SettingsManagerMock,
            PreferencesFlag.scheduleStartWeekday);

        const expected = false;

        // Call the setter.
        viewModel.showTodayBtn = expected;

        await untilCalled(
            settingsManager.setBool(PreferencesFlag.scheduleShowTodayBtn, any));

        expect(viewModel.showTodayBtn, expected);
        expect(viewModel.isBusy, false);

        verify(settingsManager.setBool(
                PreferencesFlag.scheduleShowTodayBtn, any))
            .called(1);
        verifyNoMoreInteractions(settingsManager);
      });
    });
  });
}
