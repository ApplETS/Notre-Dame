// Package imports:
import 'package:calendar_view/calendar_view.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:mockito/mockito.dart';
import 'package:table_calendar/table_calendar.dart';

// Project imports:
import 'package:notredame/data/models/activity_code.dart';
import 'package:notredame/data/repositories/course_repository.dart';
import 'package:notredame/data/repositories/settings_repository.dart';
import 'package:notredame/data/services/calendar_service.dart';
import 'package:notredame/data/services/signets-api/models/course.dart';
import 'package:notredame/data/services/signets-api/models/course_activity.dart';
import 'package:notredame/data/services/signets-api/models/schedule_activity.dart';
import 'package:notredame/domain/constants/preferences_flags.dart';
import 'package:notredame/ui/schedule/view_model/schedule_viewmodel.dart';
import 'package:notredame/utils/utils.dart';
import '../../../data/mocks/repositories/course_repository_mock.dart';
import '../../../data/mocks/repositories/settings_repository_mock.dart';
import '../../../helpers.dart';

late CourseRepositoryMock courseRepositoryMock;
late SettingsRepositoryMock settingsManagerMock;

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
    PreferencesFlag.scheduleCalendarFormat: CalendarTimeFormat.week,
    PreferencesFlag.scheduleShowTodayBtn: true
  };

  group("ScheduleViewModel - ", () {
    setUp(() async {
      // Setting up mocks
      courseRepositoryMock = setupCourseRepositoryMock();
      settingsManagerMock = setupSettingsRepositoryMock();

      viewModel = ScheduleViewModel(intl: await setupAppIntl());
    });

    tearDown(() {
      unregister<CourseRepository>();
      unregister<SettingsRepository>();
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
        SettingsRepositoryMock.stubGetScheduleSettings(settingsManagerMock,
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
        SettingsRepositoryMock.stubGetScheduleSettings(settingsManagerMock,
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

        SettingsRepositoryMock.stubGetDynamicString(settingsManagerMock,
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

        SettingsRepositoryMock.stubGetDynamicString(
            settingsManagerMock,
            PreferencesFlag.scheduleLaboratoryGroup,
            classOneWithLaboratoryABscheduleActivities.first.courseAcronym);

        await viewModel.assignScheduleActivities([]);

        expect(viewModel.scheduleActivityIsSelected(gia540), true);
      });

      test(
          'scheduleActivityIsSelected returns false when there is no activity selected',
          () async {
        SettingsRepositoryMock.stubGetDynamicString(
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
        SettingsRepositoryMock.stubGetDynamicString(
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
        viewModel.weekSelected = DateTime(2020, 1, 2);
        clearInteractions(courseRepositoryMock);

        expect(viewModel.selectedDateEvents(viewModel.weekSelected), expected);

        verifyNoMoreInteractions(courseRepositoryMock);
        verifyNoMoreInteractions(settingsManagerMock);
      });

      test("The events of the date currently selected are return", () {
        CourseRepositoryMock.stubCoursesActivities(courseRepositoryMock,
            toReturn: activities);

        final expected = [];

        // Setting up the viewmodel
        viewModel.coursesActivities;
        viewModel.weekSelected = DateTime(2020, 1, 3);
        clearInteractions(courseRepositoryMock);

        expect(viewModel.selectedDateEvents(viewModel.weekSelected), expected);

        verifyNoMoreInteractions(courseRepositoryMock);
        verifyNoMoreInteractions(settingsManagerMock);
      });
    });

    group('selectedWeekEvents', () {
      test('selectedWeekEvents for starting day', () async {
        CourseRepositoryMock.stubCoursesActivities(courseRepositoryMock,
            toReturn: weekOfActivities);
        SettingsRepositoryMock.stubGetScheduleSettings(settingsManagerMock,
            toReturn: settings);

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
        viewModel.weekSelected = DateTime(2020, 1, 8);
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
        SettingsRepositoryMock.stubGetScheduleSettings(settingsManagerMock,
            toReturn: {
              PreferencesFlag.scheduleCalendarFormat: CalendarTimeFormat.month
            });
        expect(viewModel.calendarFormat, CalendarTimeFormat.week);

        await viewModel.loadSettings();
        expect(viewModel.calendarFormat, CalendarTimeFormat.month);
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
        SettingsRepositoryMock.stubGetDynamicString(
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
        SettingsRepositoryMock.stubGetScheduleSettings(settingsManagerMock,
            toReturn: {
              PreferencesFlag.scheduleCalendarFormat: CalendarTimeFormat.month
            });
        SettingsRepositoryMock.stubGetDynamicString(
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

        SettingsRepositoryMock.stubGetDynamicString(settingsManagerMock,
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

        SettingsRepositoryMock.stubGetDynamicString(settingsManagerMock,
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

        SettingsRepositoryMock.stubGetDynamicString(settingsManagerMock,
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

        SettingsRepositoryMock.stubGetDynamicString(settingsManagerMock,
            PreferencesFlag.scheduleLaboratoryGroup, "GEN103");

        await viewModel.assignScheduleActivities([]);

        final activities = viewModel.coursesActivities;

        expect(activities.entries.toList()[0].value.length, 5);
      });
    });

    group('ScheduleViewModel - handleViewChanged', () {
      test(
          'should update weekSelected to next week if date is Saturday and no events',
          () {
        final DateTime saturday = DateTime(2024, 9, 21); // Date d'un samedi

        viewModel.settings[PreferencesFlag.scheduleListView] = false;
        viewModel.weekSelected = DateTime(2024, 9, 15);
        viewModel.handleViewChanged(saturday, EventController(), []);

        final nextWeekSunday = Utils.getFirstDayOfCurrentWeek(
            saturday.add(const Duration(days: 7, hours: 1)));
        expect(viewModel.weekSelected, nextWeekSunday);
        expect(viewModel.displaySaturday, false);
      });

      test('displays saturday on view changed', () async {
        final DateTime saturday = DateTime(2024, 9, 21);
        // Add Saturday course activity
        viewModel.coursesActivities.addAll({
          saturday: [
            CourseActivity(
                courseGroup: "courseGroup",
                courseName: "courseName",
                activityName: "activityName",
                activityDescription: "activityDescription",
                activityLocation: "activityLocation",
                startDateTime: DateTime.now(),
                endDateTime: DateTime.now())
          ]
        });

        viewModel.settings[PreferencesFlag.scheduleListView] = false;
        viewModel.weekSelected = DateTime(2024, 9, 15);
        viewModel.handleViewChanged(saturday, EventController(), []);

        expect(
            viewModel.weekSelected, Utils.getFirstDayOfCurrentWeek(saturday));
        expect(viewModel.displaySaturday, true);
      });

      test('does not display saturday on view changed', () {
        viewModel.weekSelected = DateTime(2024, 8, 19);
        viewModel.calendarFormat = CalendarTimeFormat.week;
        final DateTime wednesday = DateTime(2023, 9, 13);

        viewModel.handleViewChanged(wednesday, EventController(), []);

        final currentWeekSunday = Utils.getFirstDayOfCurrentWeek(wednesday);
        expect(viewModel.weekSelected, currentWeekSunday);
      });

      test('should update daySelected if day view', () {
        viewModel.daySelected = DateTime.now().withoutTime;
        viewModel.calendarFormat = CalendarTimeFormat.day;

        final DateTime newDate = DateTime(2023, 9, 14);
        viewModel.handleViewChanged(newDate, EventController(), []);

        expect(viewModel.daySelected, newDate);
      });
    });

    group('dateSelection -', () {
      setUp(() async {
        setupFlutterToastMock();
      });

      test('day view go back to todays schedule', () async {
        final oldSelectedDate = DateTime(2022, 1, 2);
        final currentDate = DateTime.now();

        viewModel.calendarFormat = CalendarTimeFormat.day;
        viewModel.daySelected = oldSelectedDate;
        viewModel.listViewCalendarSelectedDate = oldSelectedDate;

        final res = viewModel.selectToday();

        expect(viewModel.daySelected.day, currentDate.day);
        expect(viewModel.listViewCalendarSelectedDate.day, currentDate.day);
        expect(res, true, reason: "Today was not selected before");
      });

      test('day view go back to todays but calendar date different', () async {
        final currentDate = DateTime.now();
        final oldSelectedDate = DateTime(2022, 1, 2);

        viewModel.calendarFormat = CalendarTimeFormat.day;
        viewModel.weekSelected = currentDate;
        viewModel.daySelected = currentDate;
        viewModel.listViewCalendarSelectedDate = oldSelectedDate;

        final res = viewModel.selectToday();

        expect(isSameDay(viewModel.daySelected, currentDate), true);
        expect(isSameDay(viewModel.listViewCalendarSelectedDate, currentDate),
            true);
        expect(res, true, reason: "Today was not selected before");
      });

      test('listview show toast if today already selected', () async {
        final today = DateTime.now();

        viewModel.settings[PreferencesFlag.scheduleListView] = true;
        viewModel.daySelected = today;
        viewModel.listViewCalendarSelectedDate = today;

        final res = viewModel.selectToday();

        expect(res, false, reason: "Today is already selected");
      });

      test('week view show toast if today already selected', () async {
        final currentWeek = Utils.getFirstDayOfCurrentWeek(DateTime.now());

        viewModel.settings[PreferencesFlag.scheduleListView] = false;
        viewModel.calendarFormat = CalendarTimeFormat.week;
        viewModel.weekSelected = currentWeek;

        final res = viewModel.selectToday();

        expect(res, false, reason: "Today is already selected");
      });

      test('week view go back to current week', () async {
        final currentWeek = Utils.getFirstDayOfCurrentWeek(DateTime.now());
        final oldSelectedDate = DateTime(2022, 1, 2);

        viewModel.settings[PreferencesFlag.scheduleListView] = false;
        viewModel.calendarFormat = CalendarTimeFormat.week;
        viewModel.weekSelected = oldSelectedDate;

        final res = viewModel.selectToday();

        expect(viewModel.weekSelected.day, currentWeek.day);
        expect(res, true, reason: "Today was not focused before");
      });

      test('month view show toast if today already selected', () async {
        final currentMonth = DateTime.now();

        viewModel.settings[PreferencesFlag.scheduleListView] = false;
        viewModel.calendarFormat = CalendarTimeFormat.month;
        viewModel.weekSelected = currentMonth;

        final res = viewModel.selectToday();

        expect(res, false, reason: "Today is already selected");
      });

      test('month view go back to current week', () async {
        final currentWeek = Utils.getFirstDayOfCurrentWeek(DateTime.now());
        final oldSelectedDate = DateTime(2022, 1, 2);

        viewModel.settings[PreferencesFlag.scheduleListView] = false;
        viewModel.calendarFormat = CalendarTimeFormat.week;
        viewModel.weekSelected = oldSelectedDate;

        final res = viewModel.selectToday();

        expect(viewModel.weekSelected, currentWeek);
        expect(res, true, reason: "Today was not focused before");
      });
    });
  });
}
