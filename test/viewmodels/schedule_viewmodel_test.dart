// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:mockito/mockito.dart';
import 'package:table_calendar/table_calendar.dart';

// MANAGERS
import 'package:notredame/core/managers/course_repository.dart';
import 'package:notredame/core/managers/settings_manager.dart';

// VIEW-MODEL
import 'package:notredame/core/viewmodels/schedule_viewmodel.dart';

// MODEL
import 'package:ets_api_clients/models.dart';

// CONSTANTS
import 'package:notredame/core/constants/preferences_flags.dart';

// OTHERS
import '../helpers.dart';

// MOCKS
import '../mock/managers/course_repository_mock.dart';
import '../mock/managers/settings_manager_mock.dart';

CourseRepository courseRepository;
SettingsManager settingsManager;
ScheduleViewModel viewModel;

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

  group("ScheduleViewModel - ", () {
    setUp(() async {
      // Setting up mocks
      courseRepository = setupCourseRepositoryMock();
      settingsManager = setupSettingsManagerMock();

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
        CourseRepositoryMock.stubGetCoursesActivities(
            courseRepository as CourseRepositoryMock);
        CourseRepositoryMock.stubCoursesActivities(
            courseRepository as CourseRepositoryMock);
        CourseRepositoryMock.stubGetCourses(
            courseRepository as CourseRepositoryMock,
            fromCacheOnly: true);
        CourseRepositoryMock.stubGetCourses(
            courseRepository as CourseRepositoryMock,
            fromCacheOnly: false);
        CourseRepositoryMock.stubGetScheduleActivities(
            courseRepository as CourseRepositoryMock);

        expect(await viewModel.futureToRun(), []);

        verifyInOrder([
          courseRepository.getCoursesActivities(fromCacheOnly: true),
          courseRepository.getCoursesActivities()
        ]);

        verifyNoMoreInteractions(courseRepository);
        verifyNoMoreInteractions(settingsManager);
      });

      test("Signets throw an error while trying to get new events", () async {
        setupFlutterToastMock();
        CourseRepositoryMock.stubGetCoursesActivities(
            courseRepository as CourseRepositoryMock,
            fromCacheOnly: true);
        CourseRepositoryMock.stubGetCoursesActivitiesException(
            courseRepository as CourseRepositoryMock,
            fromCacheOnly: false);
        CourseRepositoryMock.stubGetCourses(
            courseRepository as CourseRepositoryMock,
            fromCacheOnly: true);
        CourseRepositoryMock.stubGetCourses(
            courseRepository as CourseRepositoryMock,
            fromCacheOnly: false);
        CourseRepositoryMock.stubCoursesActivities(
            courseRepository as CourseRepositoryMock);
        CourseRepositoryMock.stubGetScheduleActivities(
            courseRepository as CourseRepositoryMock);

        expect(await viewModel.futureToRun(), [],
            reason: "Even if SignetsAPI fails we should receives a list.");

        // Await until the call to get the activities from signets is sent
        await untilCalled(courseRepository.getCoursesActivities());

        verifyInOrder([
          courseRepository.getCoursesActivities(fromCacheOnly: true),
          courseRepository.getCoursesActivities()
        ]);

        verifyNoMoreInteractions(courseRepository);
        verifyNoMoreInteractions(settingsManager);
      });
    });

    group("coursesActivities - ", () {
      test("build the list of activities sort by date", () async {
        CourseRepositoryMock.stubCoursesActivities(
            courseRepository as CourseRepositoryMock,
            toReturn: activities);

        final expected = {
          DateTime(2020): [gen101],
          DateTime(2020, 1, 2): [gen102, gen103]
        };

        expect(viewModel.coursesActivities, expected);

        verify(courseRepository.coursesActivities).called(2);

        verifyNoMoreInteractions(courseRepository);
        verifyNoMoreInteractions(settingsManager);
      });

      test(
          'scheduleActivityIsSelected returns true when activityDescription is not labA or labB',
          () async {
        CourseRepositoryMock.stubCoursesActivities(
            courseRepository as CourseRepositoryMock,
            toReturn: activitiesLabs);

        SettingsManagerMock.stubGetDynamicString(
            settingsManager as SettingsManagerMock,
            PreferencesFlag.scheduleLaboratoryGroup,
            "GEN103",
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
        CourseRepositoryMock.stubCoursesActivities(
            courseRepository as CourseRepositoryMock,
            toReturn: activitiesLabs);

        SettingsManagerMock.stubGetDynamicString(
            settingsManager as SettingsManagerMock,
            PreferencesFlag.scheduleLaboratoryGroup,
            classOneWithLaboratoryABscheduleActivities.first.courseAcronym,
            toReturn: null);

        await viewModel.assignScheduleActivities([]);

        expect(viewModel.scheduleActivityIsSelected(gia540), true);
      });

      test(
          'scheduleActivityIsSelected returns false when there is no activity selected',
          () async {
        SettingsManagerMock.stubGetDynamicString(
            settingsManager as SettingsManagerMock,
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
            settingsManager as SettingsManagerMock,
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
        CourseRepositoryMock.stubCoursesActivities(
            courseRepository as CourseRepositoryMock,
            toReturn: activities);

        final expected = [gen102, gen103];

        expect(viewModel.coursesActivitiesFor(DateTime(2020, 1, 2)), expected);

        verify(courseRepository.coursesActivities).called(2);

        verifyNoMoreInteractions(courseRepository);
        verifyNoMoreInteractions(settingsManager);
      });

      test("If the day doesn't have any events, return an empty list.", () {
        CourseRepositoryMock.stubCoursesActivities(
            courseRepository as CourseRepositoryMock,
            toReturn: activities);

        expect(viewModel.coursesActivitiesFor(DateTime(2020, 1, 3)), isEmpty,
            reason: "There is no events for the 3rd Jan on activities");

        verify(courseRepository.coursesActivities).called(2);

        verifyNoMoreInteractions(courseRepository);
        verifyNoMoreInteractions(settingsManager);
      });
    });

    group("selectedDateEvents", () {
      test("The events of the date currently selected are return", () {
        CourseRepositoryMock.stubCoursesActivities(
            courseRepository as CourseRepositoryMock,
            toReturn: activities);

        final expected = [gen102, gen103];

        // Setting up the viewmodel
        viewModel.coursesActivities;
        viewModel.selectedDate = DateTime(2020, 1, 2);
        clearInteractions(courseRepository);

        expect(viewModel.selectedDateEvents(viewModel.selectedDate), expected);

        verifyNoMoreInteractions(courseRepository);
        verifyNoMoreInteractions(settingsManager);
      });

      test("The events of the date currently selected are return", () {
        CourseRepositoryMock.stubCoursesActivities(
            courseRepository as CourseRepositoryMock,
            toReturn: activities);

        final expected = [];

        // Setting up the viewmodel
        viewModel.coursesActivities;
        viewModel.selectedDate = DateTime(2020, 1, 3);
        clearInteractions(courseRepository);

        expect(viewModel.selectedDateEvents(viewModel.selectedDate), expected);

        verifyNoMoreInteractions(courseRepository);
        verifyNoMoreInteractions(settingsManager);
      });
    });

    group('selectedWeekEvents', () {
      final Map<PreferencesFlag, dynamic> settingsStartingDayMonday = {
        PreferencesFlag.scheduleStartWeekday: StartingDayOfWeek.monday,
      };
      final Map<PreferencesFlag, dynamic> settingsStartingDaySaturday = {
        PreferencesFlag.scheduleStartWeekday: StartingDayOfWeek.saturday,
      };

      test('selectedWeekEvents for starting day sunday', () {
        CourseRepositoryMock.stubCoursesActivities(
            courseRepository as CourseRepositoryMock,
            toReturn: weekOfActivities);

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
        clearInteractions(courseRepository);

        expect(viewModel.selectedWeekEvents(), expected);
      });

      test('selectedWeekEvents for starting day monday', () async {
        SettingsManagerMock.stubGetScheduleSettings(
            settingsManager as SettingsManagerMock,
            toReturn: settingsStartingDayMonday);
        CourseRepositoryMock.stubCoursesActivities(
            courseRepository as CourseRepositoryMock,
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
        clearInteractions(courseRepository);

        expect(viewModel.selectedWeekEvents(), expected);
      });

      test('selectedWeekEvents for starting day saturday', () async {
        SettingsManagerMock.stubGetScheduleSettings(
            settingsManager as SettingsManagerMock,
            toReturn: settingsStartingDaySaturday);
        CourseRepositoryMock.stubCoursesActivities(
            courseRepository as CourseRepositoryMock,
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
        clearInteractions(courseRepository);

        expect(viewModel.selectedWeekEvents(), expected);
      });
    });

    group('refresh -', () {
      test(
          'Call SignetsAPI to get the coursesActivities than reload the coursesActivities',
          () async {
        CourseRepositoryMock.stubCoursesActivities(
            courseRepository as CourseRepositoryMock,
            toReturn: activities);

        await viewModel.refresh();

        final expected = {
          DateTime(2020): [gen101],
          DateTime(2020, 1, 2): [gen102, gen103]
        };

        expect(viewModel.coursesActivities, expected);

        verifyInOrder([
          courseRepository.getCoursesActivities(),
          courseRepository.coursesActivities,
          courseRepository.coursesActivities
        ]);

        verifyNoMoreInteractions(courseRepository);
      });
    });

    group('loadSettings -', () {
      test('calendarFormat changing', () async {
        SettingsManagerMock.stubGetScheduleSettings(
            settingsManager as SettingsManagerMock,
            toReturn: {
              PreferencesFlag.scheduleCalendarFormat: CalendarFormat.month
            });
        expect(viewModel.calendarFormat, CalendarFormat.week);

        await viewModel.loadSettings();
        expect(viewModel.calendarFormat, CalendarFormat.month);
        verify(settingsManager.getScheduleSettings()).called(1);
        verifyNoMoreInteractions(settingsManager);
      });
      test('assignScheduleActivities - format the schedule activities in a map',
          () async {
        // Test if null, return without doing any change to the schedule list
        await viewModel.assignScheduleActivities(null);
        expect(viewModel.scheduleActivitiesByCourse.entries.length, 0);

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
            settingsManager as SettingsManagerMock,
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
        CourseRepositoryMock.stubGetCoursesActivities(
            courseRepository as CourseRepositoryMock,
            toReturn: activities);
        CourseRepositoryMock.stubCoursesActivities(
            courseRepository as CourseRepositoryMock);
        CourseRepositoryMock.stubGetCourses(
            courseRepository as CourseRepositoryMock,
            fromCacheOnly: true,
            toReturn: courses);
        CourseRepositoryMock.stubGetCourses(
            courseRepository as CourseRepositoryMock,
            fromCacheOnly: false);
        CourseRepositoryMock.stubGetScheduleActivities(
            courseRepository as CourseRepositoryMock,
            toReturn: classOneWithLaboratoryABscheduleActivities);
        SettingsManagerMock.stubGetScheduleSettings(
            settingsManager as SettingsManagerMock,
            toReturn: {
              PreferencesFlag.scheduleCalendarFormat: CalendarFormat.month
            });
        SettingsManagerMock.stubGetDynamicString(
            settingsManager as SettingsManagerMock,
            PreferencesFlag.scheduleLaboratoryGroup,
            classOneWithLaboratoryABscheduleActivities.first.courseAcronym,
            toReturn: ActivityCode.labGroupA);

        expect(await viewModel.futureToRun(), activities,
            reason: "Even if SignetsAPI fails we should receives a list.");

        List<ScheduleActivity> listScheduleActivities;
        await courseRepository.getScheduleActivities().then((value) {
          listScheduleActivities = value;
        });
        await viewModel.assignScheduleActivities(listScheduleActivities);

        await untilCalled(courseRepository.getCoursesActivities());
        await untilCalled(courseRepository.getScheduleActivities());

        verifyInOrder([
          courseRepository.getCoursesActivities(fromCacheOnly: true),
          courseRepository.getCoursesActivities(),
          courseRepository.getScheduleActivities(
              fromCacheOnly: anyNamed("fromCacheOnly"))
        ]);

        // Await the end of the future to run
        await untilCalled(
            viewModel.setBusyForObject(viewModel.isLoadingEvents, false));

        expect(
            viewModel.settingsScheduleActivities[
                classOneWithLaboratoryABscheduleActivities.first.courseAcronym],
            "Laboratoire (Groupe A)");

        verify(settingsManager.getDynamicString(any, any)).called(2);
      });

      test(
          'coursesActivities - should fill coursesActivities with the activities',
          () async {
        CourseRepositoryMock.stubCoursesActivities(
            courseRepository as CourseRepositoryMock,
            toReturn: activitiesLabs);

        SettingsManagerMock.stubGetDynamicString(
            settingsManager as SettingsManagerMock,
            PreferencesFlag.scheduleLaboratoryGroup,
            "GEN103",
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
        CourseRepositoryMock.stubCoursesActivities(
            courseRepository as CourseRepositoryMock,
            toReturn: activitiesLabs);

        SettingsManagerMock.stubGetDynamicString(
            settingsManager as SettingsManagerMock,
            PreferencesFlag.scheduleLaboratoryGroup,
            "GEN103",
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
        CourseRepositoryMock.stubCoursesActivities(
            courseRepository as CourseRepositoryMock,
            toReturn: activitiesLabs);

        SettingsManagerMock.stubGetDynamicString(
            settingsManager as SettingsManagerMock,
            PreferencesFlag.scheduleLaboratoryGroup,
            "GEN103",
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
        CourseRepositoryMock.stubCoursesActivities(
            courseRepository as CourseRepositoryMock,
            toReturn: activitiesLabs);

        SettingsManagerMock.stubGetDynamicString(
            settingsManager as SettingsManagerMock,
            PreferencesFlag.scheduleLaboratoryGroup,
            "GEN103",
            toReturn: null);

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
