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
import 'package:notredame/core/models/course_activity.dart';
import 'package:notredame/core/models/schedule_activity.dart';

// CONSTANTS
import 'package:notredame/core/constants/activity_code.dart';
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

  final List<CourseActivity> activities = [gen101, gen102, gen103];

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
  group("ScheduleViewModel - ", () {
    setUp(() async {
      // Setting up mocks
      courseRepository = setupCourseRepositoryMock();
      settingsManager = setupSettingsManagerMock();
      setupFlutterToastMock();

      viewModel = ScheduleViewModel(intl: await setupAppIntl());
    });

    tearDown(() {
      unregister<CourseRepository>();
      unregister<SettingsManager>();
      tearDownFlutterToastMock();
    });

    group("futureToRun - ", () {
      test(
          "first load from cache than call SignetsAPI to get the latest events",
          () async {
        CourseRepositoryMock.stubGetCoursesActivities(
            courseRepository as CourseRepositoryMock);
        CourseRepositoryMock.stubCoursesActivities(
            courseRepository as CourseRepositoryMock);
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
        CourseRepositoryMock.stubGetCoursesActivities(
            courseRepository as CourseRepositoryMock,
            fromCacheOnly: true);
        CourseRepositoryMock.stubGetCoursesActivitiesException(
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

        verify(courseRepository.coursesActivities).called(1);

        verifyNoMoreInteractions(courseRepository);
        verifyNoMoreInteractions(settingsManager);
      });
    });

    group("coursesActivitiesFor - ", () {
      test("Get the correct list of activities for the specified day", () {
        CourseRepositoryMock.stubCoursesActivities(
            courseRepository as CourseRepositoryMock,
            toReturn: activities);

        final expected = [gen102, gen103];

        expect(viewModel.coursesActivitiesFor(DateTime(2020, 1, 2)), expected);

        verify(courseRepository.coursesActivities).called(1);

        verifyNoMoreInteractions(courseRepository);
        verifyNoMoreInteractions(settingsManager);
      });

      test("If the day doesn't have any events, return an empty list.", () {
        CourseRepositoryMock.stubCoursesActivities(
            courseRepository as CourseRepositoryMock,
            toReturn: activities);

        expect(viewModel.coursesActivitiesFor(DateTime(2020, 1, 3)), isEmpty,
            reason: "There is no events for the 3rd Jan on activities");

        verify(courseRepository.coursesActivities).called(1);

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

        expect(viewModel.selectedDateEvents, expected);

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

        expect(viewModel.selectedDateEvents, expected);

        verifyNoMoreInteractions(courseRepository);
        verifyNoMoreInteractions(settingsManager);
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
              PreferencesFlag.scheduleSettingsCalendarFormat:
                  CalendarFormat.month
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
            DynamicPreferencesFlag(
                groupAssociationFlag:
                    PreferencesFlag.scheduleSettingsLaboratoryGroup,
                uniqueKey: classOneWithLaboratoryABscheduleActivities
                    .first.courseAcronym),
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
        CourseRepositoryMock.stubGetScheduleActivities(
            courseRepository as CourseRepositoryMock,
            toReturn: classOneWithLaboratoryABscheduleActivities);
        SettingsManagerMock.stubGetScheduleSettings(
            settingsManager as SettingsManagerMock,
            toReturn: {
              PreferencesFlag.scheduleSettingsCalendarFormat:
                  CalendarFormat.month
            });
        SettingsManagerMock.stubGetDynamicString(
            settingsManager as SettingsManagerMock,
            DynamicPreferencesFlag(
                groupAssociationFlag:
                    PreferencesFlag.scheduleSettingsLaboratoryGroup,
                uniqueKey: classOneWithLaboratoryABscheduleActivities
                    .first.courseAcronym),
            toReturn: ActivityCode.labGroupA);

        expect(await viewModel.futureToRun(), activities,
            reason: "Even if SignetsAPI fails we should receives a list.");

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

        verify(settingsManager.getDynamicString(any)).called(1);
      });
    });
  });
}
