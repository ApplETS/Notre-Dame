// Package imports:
import 'package:ets_api_clients/models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:mockito/mockito.dart';
import 'package:table_calendar/table_calendar.dart';

// Project imports:
import 'package:notredame/constants/preferences_flags.dart';
import 'package:notredame/features/app/repository/course_repository.dart';
import 'package:notredame/features/more/settings/settings_manager.dart';
import 'package:notredame/features/schedule/schedule_viewmodel.dart';
import '../helpers.dart';
import '../mock/managers/course_repository_mock.dart';
import '../mock/managers/settings_manager_mock.dart';

late CourseRepositoryMock courseRepositoryMock;
late SettingsManagerMock settingsManagerMock;

late ScheduleViewModel viewModel;

void main() {
  // Needed to support FlutterToast.
  TestWidgetsFlutterBinding.ensureInitialized();
  // Some activities
  final gen101 = CourseActivity(
      courseGroup: "GEN101",
      courseName: "Generic course",
      activityName: "TD",
      activityDescription: "Activity description",
      activityLocation: "location",
      startDateTime: DateTime(2020, 1, 1, 18),
      endDateTime: DateTime(2020, 1, 1, 21));
  final gen102 = CourseActivity(
      courseGroup: "GEN102",
      courseName: "Generic course",
      activityName: "TD",
      activityDescription: "Activity description",
      activityLocation: "location",
      startDateTime: DateTime(2020, 1, 2, 18),
      endDateTime: DateTime(2020, 1, 2, 21));
  final gen103 = CourseActivity(
      courseGroup: "GEN103",
      courseName: "Generic course",
      activityName: "TD",
      activityDescription: "Activity description",
      activityLocation: "location",
      startDateTime: DateTime(2020, 1, 2, 18),
      endDateTime: DateTime(2020, 1, 2, 21));
  final course1 = Course(
      title: "Generic course",
      acronym: "GEN101",
      group: "01",
      session: "H2020",
      programCode: "999",
      grade: "A+",
      numberOfCredits: 3);
  final course2 = Course(
      title: "Generic course",
      acronym: "GEN102",
      group: "01",
      session: "H2020",
      programCode: "999",
      grade: "A+",
      numberOfCredits: 3);
  final course3 = Course(
      title: "Generic course",
      acronym: "GEN103",
      group: "04",
      session: "H2020",
      programCode: "999",
      grade: "A+",
      numberOfCredits: 3);

  final List<CourseActivity> activities = [gen101, gen102, gen103];
  final List<Course> courses = [course1, course2, course3];

  final gen101WithLabA = CourseActivity(
      courseGroup: "GEN101-01",
      courseName: "Generic course",
      activityName: "TD",
      activityDescription: "Laboratoire (Groupe A)",
      activityLocation: "location",
      startDateTime: DateTime(2020, 1, 2, 18),
      endDateTime: DateTime(2020, 1, 2, 21));

  final gen101WithLabB = CourseActivity(
      courseGroup: "GEN101-01",
      courseName: "Generic course",
      activityName: "TD",
      activityDescription: "Laboratoire (Groupe B)",
      activityLocation: "location",
      startDateTime: DateTime(2020, 1, 2, 18),
      endDateTime: DateTime(2020, 1, 2, 21));

  final gen103WithLabA = CourseActivity(
      courseGroup: "GEN103-04",
      courseName: "Generic course",
      activityName: "TD",
      activityDescription: "Laboratoire (Groupe A)",
      activityLocation: "location",
      startDateTime: DateTime(2020, 1, 2, 18),
      endDateTime: DateTime(2020, 1, 2, 21));

  final gen103WithLabB = CourseActivity(
      courseGroup: "GEN103-04",
      courseName: "Generic course",
      activityName: "TD",
      activityDescription: "Laboratoire (Groupe B)",
      activityLocation: "location",
      startDateTime: DateTime(2020, 1, 2, 18),
      endDateTime: DateTime(2020, 1, 2, 21));

  final gia540 = CourseActivity(
      courseGroup: "GIA540-02",
      courseName: "Generic course",
      activityName: "TD",
      activityDescription: "Activity description",
      activityLocation: "location",
      startDateTime: DateTime(2020, 1, 2, 18),
      endDateTime: DateTime(2020, 1, 2, 21));

  final List<CourseActivity> activitiesLabs = [
    gen101WithLabA,
    gen101WithLabB,
    gen103WithLabA,
    gen103WithLabB,
    gia540
  ];

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

  final gen104 = CourseActivity(
      courseGroup: "GEN104",
      courseName: "Generic course",
      activityName: "TD",
      activityDescription: "Activity description",
      activityLocation: "location",
      startDateTime: DateTime(2020, 1, 5, 18),
      endDateTime: DateTime(2020, 1, 5, 21));

  final gen105 = CourseActivity(
      courseGroup: "GEN105",
      courseName: "Generic course",
      activityName: "TD",
      activityDescription: "Activity description",
      activityLocation: "location",
      startDateTime: DateTime(2020, 1, 6, 18),
      endDateTime: DateTime(2020, 1, 6, 21));

  final gen106 = CourseActivity(
      courseGroup: "GEN106",
      courseName: "Generic course",
      activityName: "TD",
      activityDescription: "Activity description",
      activityLocation: "location",
      startDateTime: DateTime(2020, 1, 7, 18),
      endDateTime: DateTime(2020, 1, 7, 21));

  final gen107 = CourseActivity(
      courseGroup: "GEN107",
      courseName: "Generic course",
      activityName: "TD",
      activityDescription: "Activity description",
      activityLocation: "location",
      startDateTime: DateTime(2020, 1, 8, 18),
      endDateTime: DateTime(2020, 1, 8, 21));

  final gen108 = CourseActivity(
      courseGroup: "GEN108",
      courseName: "Generic course",
      activityName: "TD",
      activityDescription: "Activity description",
      activityLocation: "location",
      startDateTime: DateTime(2020, 1, 9, 18),
      endDateTime: DateTime(2020, 1, 9, 21));

  final gen109 = CourseActivity(
      courseGroup: "GEN109",
      courseName: "Generic course",
      activityName: "TD",
      activityDescription: "Activity description",
      activityLocation: "location",
      startDateTime: DateTime(2020, 1, 10, 18),
      endDateTime: DateTime(2020, 1, 10, 21));

  final gen110 = CourseActivity(
      courseGroup: "GEN110",
      courseName: "Generic course",
      activityName: "TD",
      activityDescription: "Activity description",
      activityLocation: "location",
      startDateTime: DateTime(2020, 1, 11, 18),
      endDateTime: DateTime(2020, 1, 11, 21));

  final List<CourseActivity> weekOfActivities = [
    gen104,
    gen105,
    gen106,
    gen107,
    gen108,
    gen109,
    gen110
  ];

  // Some settings
  final Map<PreferencesFlag, dynamic> settings = {
    PreferencesFlag.scheduleCalendarFormat: CalendarFormat.week,
    PreferencesFlag.scheduleStartWeekday: StartingDayOfWeek.monday,
    PreferencesFlag.scheduleShowTodayBtn: true
  };

  group("ScheduleViewModel - ", () {
    setUp(() async {
      // Setting up mocks
      courseRepositoryMock = setupCourseRepositoryMock();
      settingsManagerMock = setupSettingsManagerMock();

      viewModel = ScheduleViewModel(intl: await setupAppIntl());
    });

    tearDown(() {
      unregister<CourseRepository>();
      unregister<SettingsManager>();
    });

    group("futureToRun - ", () {
      test(
          "first load from cache than call SignetsAPI to get the latest events",
          () async {
        CourseRepositoryMock.stubGetCoursesActivities(courseRepositoryMock);
        CourseRepositoryMock.stubCoursesActivities(courseRepositoryMock);
        CourseRepositoryMock.stubGetCourses(courseRepositoryMock,
            fromCacheOnly: true);
        CourseRepositoryMock.stubGetCourses(courseRepositoryMock);
        CourseRepositoryMock.stubGetScheduleActivities(courseRepositoryMock);
        SettingsManagerMock.stubGetScheduleSettings(settingsManagerMock,
            toReturn: settings);

        expect(await viewModel.futureToRun(), []);

        verifyInOrder([
          settingsManagerMock.getScheduleSettings(),
          courseRepositoryMock.getCoursesActivities(fromCacheOnly: true),
          courseRepositoryMock.getCoursesActivities(),
          courseRepositoryMock.coursesActivities,
          courseRepositoryMock.coursesActivities,
          courseRepositoryMock.getCourses(fromCacheOnly: true),
          courseRepositoryMock.getScheduleActivities(),
        ]);

        verifyNoMoreInteractions(courseRepositoryMock);
        verifyNoMoreInteractions(settingsManagerMock);
      });

      test("Signets throw an error while trying to get new events", () async {
        setupFlutterToastMock();
        CourseRepositoryMock.stubGetCoursesActivities(courseRepositoryMock,
            fromCacheOnly: true);
        CourseRepositoryMock.stubGetCoursesActivitiesException(
            courseRepositoryMock);
        CourseRepositoryMock.stubGetCourses(courseRepositoryMock,
            fromCacheOnly: true);
        CourseRepositoryMock.stubGetCourses(courseRepositoryMock);
        CourseRepositoryMock.stubCoursesActivities(courseRepositoryMock);
        CourseRepositoryMock.stubGetScheduleActivities(courseRepositoryMock);
        SettingsManagerMock.stubGetScheduleSettings(settingsManagerMock,
            toReturn: settings);

        expect(await viewModel.futureToRun(), [],
            reason: "Even if SignetsAPI fails we should receives a list.");

        // Await until the call to get the activities from signets is sent
        await untilCalled(courseRepositoryMock.getCoursesActivities());

        verifyInOrder([
          settingsManagerMock.getScheduleSettings(),
          courseRepositoryMock.getCoursesActivities(fromCacheOnly: true),
          courseRepositoryMock.getCoursesActivities()
        ]);

        verifyNoMoreInteractions(courseRepositoryMock);
        verifyNoMoreInteractions(settingsManagerMock);
      });
    });

    group("coursesActivities - ", () {
      test("build the list of activities sort by date", () async {
        CourseRepositoryMock.stubCoursesActivities(courseRepositoryMock,
            toReturn: activities);

        final expected = {
          DateTime(2020): [gen101],
          DateTime(2020, 1, 2): [gen102, gen103]
        };

        expect(viewModel.coursesActivities, expected);

        verify(courseRepositoryMock.coursesActivities).called(2);

        verifyNoMoreInteractions(courseRepositoryMock);
        verifyNoMoreInteractions(settingsManagerMock);
      });

      test(
          'scheduleActivityIsSelected returns true when activityDescription is not labA or labB',
          () async {
        CourseRepositoryMock.stubCoursesActivities(courseRepositoryMock,
            toReturn: activitiesLabs);

        SettingsManagerMock.stubGetDynamicString(settingsManagerMock,
            PreferencesFlag.scheduleLaboratoryGroup, "GEN103",
            toReturn: ActivityCode.labGroupA);

        await viewModel.assignScheduleActivities([
          ScheduleActivity(
              courseAcronym: "GEN103",
              courseGroup: "01",
              courseTitle: "Generic Course",
              dayOfTheWeek: 1,
              day: "Lundi",
              startTime: DateFormat("hh:mm").parse("08:30"),
              endTime: DateFormat("hh:mm").parse("12:00"),
              activityCode: ActivityCode.labGroupA,
              isPrincipalActivity: true,
              activityLocation: "En ligne",
              name: "Activity description")
        ]);

        expect(viewModel.scheduleActivityIsSelected(gia540), true);
      });

      test(
          'scheduleActivityIsSelected returns true when the course does not have an activity',
          () async {
        CourseRepositoryMock.stubCoursesActivities(courseRepositoryMock,
            toReturn: activitiesLabs);

        SettingsManagerMock.stubGetDynamicString(
            settingsManagerMock,
            PreferencesFlag.scheduleLaboratoryGroup,
            classOneWithLaboratoryABscheduleActivities.first.courseAcronym);

        await viewModel.assignScheduleActivities([]);

        expect(viewModel.scheduleActivityIsSelected(gia540), true);
      });

      test(
          'scheduleActivityIsSelected returns false when there is no activity selected',
          () async {
        SettingsManagerMock.stubGetDynamicString(
            settingsManagerMock,
            PreferencesFlag.scheduleLaboratoryGroup,
            classOneWithLaboratoryABscheduleActivities.first.courseAcronym,
            toReturn: ActivityCode.labGroupA);

        await viewModel.assignScheduleActivities(
            classOneWithLaboratoryABscheduleActivities);

        expect(viewModel.scheduleActivityIsSelected(gen103WithLabA), false);
      });

      test(
          'scheduleActivityIsSelected returns true when the courseGroup has an activity selected',
          () async {
        SettingsManagerMock.stubGetDynamicString(
            settingsManagerMock,
            PreferencesFlag.scheduleLaboratoryGroup,
            classOneWithLaboratoryABscheduleActivities.first.courseAcronym,
            toReturn: ActivityCode.labGroupA);

        await viewModel.assignScheduleActivities(
            classOneWithLaboratoryABscheduleActivities);

        expect(viewModel.scheduleActivityIsSelected(gen101WithLabA), true);
      });
    });

    group("coursesActivitiesFor - ", () {
      test("Get the correct list of activities for the specified day", () {
        CourseRepositoryMock.stubCoursesActivities(courseRepositoryMock,
            toReturn: activities);

        final expected = [gen102, gen103];

        expect(viewModel.coursesActivitiesFor(DateTime(2020, 1, 2)), expected);

        verify(courseRepositoryMock.coursesActivities).called(2);

        verifyNoMoreInteractions(courseRepositoryMock);
        verifyNoMoreInteractions(settingsManagerMock);
      });

      test("If the day doesn't have any events, return an empty list.", () {
        CourseRepositoryMock.stubCoursesActivities(courseRepositoryMock,
            toReturn: activities);

        expect(viewModel.coursesActivitiesFor(DateTime(2020, 1, 3)), isEmpty,
            reason: "There is no events for the 3rd Jan on activities");

        verify(courseRepositoryMock.coursesActivities).called(2);

        verifyNoMoreInteractions(courseRepositoryMock);
        verifyNoMoreInteractions(settingsManagerMock);
      });
    });

    group("selectedDateEvents", () {
      test("The events of the date currently selected are return", () {
        CourseRepositoryMock.stubCoursesActivities(courseRepositoryMock,
            toReturn: activities);

        final expected = [gen102, gen103];

        // Setting up the viewmodel
        viewModel.coursesActivities;
        viewModel.selectedDate = DateTime(2020, 1, 2);
        clearInteractions(courseRepositoryMock);

        expect(viewModel.selectedDateEvents(viewModel.selectedDate), expected);

        verifyNoMoreInteractions(courseRepositoryMock);
        verifyNoMoreInteractions(settingsManagerMock);
      });

      test("The events of the date currently selected are return", () {
        CourseRepositoryMock.stubCoursesActivities(courseRepositoryMock,
            toReturn: activities);

        final expected = [];

        // Setting up the viewmodel
        viewModel.coursesActivities;
        viewModel.selectedDate = DateTime(2020, 1, 3);
        clearInteractions(courseRepositoryMock);

        expect(viewModel.selectedDateEvents(viewModel.selectedDate), expected);

        verifyNoMoreInteractions(courseRepositoryMock);
        verifyNoMoreInteractions(settingsManagerMock);
      });
    });

    group('selectedWeekEvents', () {
      final Map<PreferencesFlag, dynamic> settingsStartingDayMonday = {
        PreferencesFlag.scheduleStartWeekday: StartingDayOfWeek.monday,
        PreferencesFlag.scheduleCalendarFormat: CalendarFormat.month
      };
      final Map<PreferencesFlag, dynamic> settingsStartingDaySaturday = {
        PreferencesFlag.scheduleStartWeekday: StartingDayOfWeek.saturday,
        PreferencesFlag.scheduleCalendarFormat: CalendarFormat.month
      };
      final Map<PreferencesFlag, dynamic> settingsStartingDaySunday = {
        PreferencesFlag.scheduleStartWeekday: StartingDayOfWeek.sunday,
        PreferencesFlag.scheduleCalendarFormat: CalendarFormat.month
      };

      test('selectedWeekEvents for starting day sunday', () async {
        CourseRepositoryMock.stubCoursesActivities(courseRepositoryMock,
            toReturn: weekOfActivities);
        SettingsManagerMock.stubGetScheduleSettings(settingsManagerMock,
            toReturn: settingsStartingDaySunday);

        final expected = {
          DateTime(2020, 1, 5): [gen104],
          DateTime(2020, 1, 6): [gen105],
          DateTime(2020, 1, 7): [gen106],
          DateTime(2020, 1, 8): [gen107],
          DateTime(2020, 1, 9): [gen108],
          DateTime(2020, 1, 10): [gen109],
          DateTime(2020, 1, 11): [gen110],
        };

        // Setting up the viewmodel
        viewModel.coursesActivities;
        viewModel.selectedDate = DateTime(2020, 1, 8);
        await viewModel.loadSettings();
        clearInteractions(courseRepositoryMock);

        expect(viewModel.selectedWeekEvents(), expected);
      });

      test('selectedWeekEvents for starting day monday', () async {
        SettingsManagerMock.stubGetScheduleSettings(settingsManagerMock,
            toReturn: settingsStartingDayMonday);
        CourseRepositoryMock.stubCoursesActivities(courseRepositoryMock,
            toReturn: weekOfActivities);

        final expected = {
          DateTime(2020, 1, 6): [gen105],
          DateTime(2020, 1, 7): [gen106],
          DateTime(2020, 1, 8): [gen107],
          DateTime(2020, 1, 9): [gen108],
          DateTime(2020, 1, 10): [gen109],
          DateTime(2020, 1, 11): [gen110],
        };

        // Setting up the viewmodel
        viewModel.coursesActivities;
        viewModel.selectedDate = DateTime(2020, 1, 7);
        await viewModel.loadSettings();
        clearInteractions(courseRepositoryMock);

        expect(viewModel.selectedWeekEvents(), expected);
      });

      test('selectedWeekEvents for starting day saturday', () async {
        SettingsManagerMock.stubGetScheduleSettings(settingsManagerMock,
            toReturn: settingsStartingDaySaturday);
        CourseRepositoryMock.stubCoursesActivities(courseRepositoryMock,
            toReturn: weekOfActivities);

        final expected = {
          DateTime(2020, 1, 5): [gen104],
          DateTime(2020, 1, 6): [gen105],
          DateTime(2020, 1, 7): [gen106],
          DateTime(2020, 1, 8): [gen107],
          DateTime(2020, 1, 9): [gen108],
          DateTime(2020, 1, 10): [gen109],
        };

        // Setting up the viewmodel
        viewModel.coursesActivities;
        viewModel.selectedDate = DateTime(2020, 1, 7);
        await viewModel.loadSettings();
        clearInteractions(courseRepositoryMock);

        expect(viewModel.selectedWeekEvents(), expected);
      });
    });

    group('refresh -', () {
      test(
          'Call SignetsAPI to get the coursesActivities than reload the coursesActivities',
          () async {
        CourseRepositoryMock.stubCoursesActivities(courseRepositoryMock,
            toReturn: activities);

        await viewModel.refresh();

        final expected = {
          DateTime(2020): [gen101],
          DateTime(2020, 1, 2): [gen102, gen103]
        };

        expect(viewModel.coursesActivities, expected);

        verifyInOrder([
          courseRepositoryMock.getCoursesActivities(),
          courseRepositoryMock.coursesActivities,
          courseRepositoryMock.coursesActivities
        ]);

        verifyNoMoreInteractions(courseRepositoryMock);
      });
    });

    group('loadSettings -', () {
      test('calendarFormat changing', () async {
        SettingsManagerMock.stubGetScheduleSettings(settingsManagerMock,
            toReturn: {
              PreferencesFlag.scheduleCalendarFormat: CalendarFormat.month
            });
        expect(viewModel.calendarFormat, CalendarFormat.week);

        await viewModel.loadSettings();
        expect(viewModel.calendarFormat, CalendarFormat.month);
        verify(settingsManagerMock.getScheduleSettings()).called(1);
        verifyNoMoreInteractions(settingsManagerMock);
      });
      test('assignScheduleActivities - format the schedule activities in a map',
          () async {
        // Test if empty list is passed, do nothing
        await viewModel.assignScheduleActivities([]);
        expect(viewModel.scheduleActivitiesByCourse.entries.length, 0);

        // Test normal case without laboratory
        await viewModel.assignScheduleActivities([
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
              name: "Activité de cours")
        ]);
        expect(viewModel.scheduleActivitiesByCourse.entries.length, 0);
        expect(
            viewModel.scheduleActivitiesByCourse.containsKey("GEN101"), false);

        // Test normal cases, with laboratory
        SettingsManagerMock.stubGetDynamicString(
            settingsManagerMock,
            PreferencesFlag.scheduleLaboratoryGroup,
            classOneWithLaboratoryABscheduleActivities.first.courseAcronym,
            toReturn: ActivityCode.labGroupA);
        await viewModel.assignScheduleActivities(
            classOneWithLaboratoryABscheduleActivities);
        expect(
            viewModel.scheduleActivitiesByCourse.containsKey("GEN101"), true);
      });

      test(
          'loadSettingsScheduleActivities - test when one is selected from one group',
          () async {
        CourseRepositoryMock.stubGetCoursesActivities(courseRepositoryMock,
            toReturn: activities);
        CourseRepositoryMock.stubCoursesActivities(courseRepositoryMock);
        CourseRepositoryMock.stubGetCourses(courseRepositoryMock,
            fromCacheOnly: true, toReturn: courses);
        CourseRepositoryMock.stubGetCourses(courseRepositoryMock);
        CourseRepositoryMock.stubGetScheduleActivities(courseRepositoryMock,
            toReturn: classOneWithLaboratoryABscheduleActivities);
        SettingsManagerMock.stubGetScheduleSettings(settingsManagerMock,
            toReturn: {
              PreferencesFlag.scheduleCalendarFormat: CalendarFormat.month
            });
        SettingsManagerMock.stubGetDynamicString(
            settingsManagerMock,
            PreferencesFlag.scheduleLaboratoryGroup,
            classOneWithLaboratoryABscheduleActivities.first.courseAcronym,
            toReturn: ActivityCode.labGroupA);

        expect(await viewModel.futureToRun(), activities,
            reason: "Even if SignetsAPI fails we should receives a list.");

        late List<ScheduleActivity> listScheduleActivities;
        await courseRepositoryMock.getScheduleActivities().then((value) {
          listScheduleActivities = value;
        });
        await viewModel.assignScheduleActivities(listScheduleActivities);

        await untilCalled(courseRepositoryMock.getCoursesActivities());
        await untilCalled(courseRepositoryMock.getScheduleActivities());

        verifyInOrder([
          courseRepositoryMock.getCoursesActivities(fromCacheOnly: true),
          courseRepositoryMock.getCoursesActivities(),
          courseRepositoryMock.getScheduleActivities(
              fromCacheOnly: anyNamed("fromCacheOnly"))
        ]);

        // Await the end of the future to run
        await untilCalled(
            viewModel.setBusyForObject(viewModel.isLoadingEvents, false));

        expect(
            viewModel.settingsScheduleActivities[
                classOneWithLaboratoryABscheduleActivities.first.courseAcronym],
            "Laboratoire (Groupe A)");

        verify(settingsManagerMock.getDynamicString(any, any)).called(2);
      });

      test(
          'coursesActivities - should fill coursesActivities with the activities',
          () async {
        CourseRepositoryMock.stubCoursesActivities(courseRepositoryMock,
            toReturn: activitiesLabs);

        SettingsManagerMock.stubGetDynamicString(settingsManagerMock,
            PreferencesFlag.scheduleLaboratoryGroup, "GEN103",
            toReturn: ActivityCode.labGroupA);

        await viewModel.assignScheduleActivities([
          ScheduleActivity(
              courseAcronym: "GEN103",
              courseGroup: "01",
              courseTitle: "Generic Course",
              dayOfTheWeek: 1,
              day: "Lundi",
              startTime: DateFormat("hh:mm").parse("08:30"),
              endTime: DateFormat("hh:mm").parse("12:00"),
              activityCode: ActivityCode.labGroupA,
              isPrincipalActivity: true,
              activityLocation: "En ligne",
              name: "Laboratoire (Groupe A)")
        ]);

        final activities = viewModel.coursesActivities;

        expect(activities.entries.toList()[0].value.length, 4);
      });

      test(
          'coursesActivities - should fill coursesActivities with the activities with no LabB for GEN103',
          () async {
        CourseRepositoryMock.stubCoursesActivities(courseRepositoryMock,
            toReturn: activitiesLabs);

        SettingsManagerMock.stubGetDynamicString(settingsManagerMock,
            PreferencesFlag.scheduleLaboratoryGroup, "GEN103",
            toReturn: ActivityCode.labGroupA);

        await viewModel.assignScheduleActivities([
          ScheduleActivity(
              courseAcronym: "GEN103",
              courseGroup: "01",
              courseTitle: "Generic Course",
              dayOfTheWeek: 1,
              day: "Lundi",
              startTime: DateFormat("hh:mm").parse("08:30"),
              endTime: DateFormat("hh:mm").parse("12:00"),
              activityCode: ActivityCode.labGroupA,
              isPrincipalActivity: true,
              activityLocation: "En ligne",
              name: "Laboratoire (Groupe A)")
        ]);

        final activities = viewModel.coursesActivities;

        expect(activities.entries.toList()[0].value.length, 4);
      });

      test(
          'coursesActivities - should fill coursesActivities with the activities with no LabA for GEN103',
          () async {
        CourseRepositoryMock.stubCoursesActivities(courseRepositoryMock,
            toReturn: activitiesLabs);

        SettingsManagerMock.stubGetDynamicString(settingsManagerMock,
            PreferencesFlag.scheduleLaboratoryGroup, "GEN103",
            toReturn: ActivityCode.labGroupB);

        await viewModel.assignScheduleActivities([
          ScheduleActivity(
              courseAcronym: "GEN103",
              courseGroup: "01",
              courseTitle: "Generic Course",
              dayOfTheWeek: 1,
              day: "Lundi",
              startTime: DateFormat("hh:mm").parse("08:30"),
              endTime: DateFormat("hh:mm").parse("12:00"),
              activityCode: ActivityCode.labGroupB,
              isPrincipalActivity: true,
              activityLocation: "En ligne",
              name: "Laboratoire (Groupe B)")
        ]);

        final activities = viewModel.coursesActivities;

        expect(activities.entries.toList()[0].value.length, 4);
      });

      test(
          'coursesActivities - should fill coursesActivities with all the activities if none are selected',
          () async {
        CourseRepositoryMock.stubCoursesActivities(courseRepositoryMock,
            toReturn: activitiesLabs);

        SettingsManagerMock.stubGetDynamicString(settingsManagerMock,
            PreferencesFlag.scheduleLaboratoryGroup, "GEN103");

        await viewModel.assignScheduleActivities([]);

        final activities = viewModel.coursesActivities;

        expect(activities.entries.toList()[0].value.length, 5);
      });
    });

    group('dateSelection -', () {
      setUp(() async {
        setupFlutterToastMock();
      });

      test('go back to todays schedule', () async {
        final oldSelectedDate = DateTime(2022, 1, 2);
        final currentDate = DateTime.now();

        viewModel.selectedDate = oldSelectedDate;
        viewModel.focusedDate.value = oldSelectedDate;

        final res = viewModel.selectToday();

        expect(viewModel.selectedDate.day, currentDate.day);
        expect(viewModel.focusedDate.value.day, currentDate.day);
        expect(res, true, reason: "Today was not selected before");
      });

      test('show toast if today already selected', () async {
        final today = DateTime.now();

        viewModel.selectedDate = today;
        viewModel.focusedDate.value = today;

        final res = viewModel.selectToday();

        expect(res, false, reason: "Today is already selected");
      });
    });
  });
}
