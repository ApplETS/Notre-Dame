// Package imports:
import 'package:calendar_view/calendar_view.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

// Project imports:
import 'package:notredame/data/models/activity_code.dart';
import 'package:notredame/data/services/signets-api/models/course.dart';
import 'package:notredame/data/services/signets-api/models/course_activity.dart';
import 'package:notredame/data/services/signets-api/models/schedule_activity.dart';
import 'package:notredame/domain/constants/preferences_flags.dart';
import 'package:notredame/ui/schedule/view_model/calendars/calendar_viewmodel.dart';
import '../../../../data/mocks/repositories/course_repository_mock.dart';
import '../../../../data/mocks/repositories/settings_repository_mock.dart';
import '../../../../helpers.dart';

void main() {
  late CalendarViewModel viewModel;
  late CourseRepositoryMock courseRepositoryMock;
  late SettingsRepositoryMock settingsManagerMock;

  setUp(() async {
    courseRepositoryMock = setupCourseRepositoryMock();
    settingsManagerMock = setupSettingsRepositoryMock();

    viewModel = _TestCalendarViewModel(
      intl: await setupAppIntl(),
    );
  });

  group('CalendarViewModel', () {
    test('getCourseColor assigns unique colors per course', () {
      viewModel.getCourseColor('ING150');
      viewModel.getCourseColor('LOG121');
      expect(viewModel.courseColors.length, 2);
    });

    test('coursesActivities groups activities by date', () {
      final activity = CourseActivity(
        courseName: 'LOG100',
        startDateTime: DateTime(2023, 10, 1, 8),
        endDateTime: DateTime(2023, 10, 1, 10),
        courseGroup: 'ING150-01',
        activityLocation: 'Room 101',
        activityName: 'Lecture',
        activityDescription: '',
      );

      CourseRepositoryMock.stubCoursesActivities(courseRepositoryMock,
          toReturn: [activity]);

      final activitiesByDate = viewModel.coursesActivities;
      expect(activitiesByDate[DateTime(2023, 10, 1)]?.length, 1);
    });

    test('calendarEventData returns correct event data with valid location',
        () async {
      // Arrange: create a dummy Course that will be picked up by calendarEventData.
      final dummyCourse = Course(
          acronym: 'GEN101',
          group: '02',
          session: 'H2020',
          programCode: '999',
          numberOfCredits: 3,
          title: 'Cours générique');
      // Stub the getCourses call to return the dummy course.
      CourseRepositoryMock.stubCourses(courseRepositoryMock,
          toReturn: [dummyCourse]);

      final activity = CourseActivity(
        courseName: 'Lecture',
        startDateTime: DateTime(2023, 10, 2, 9),
        endDateTime: DateTime(2023, 10, 2, 10),
        courseGroup: 'ING150-01',
        activityLocation: 'Room 202',
        activityName: 'Lecture',
        activityDescription: 'Regular lecture',
      );
      // Ensure that the repository returns the activity.
      CourseRepositoryMock.stubCoursesActivities(courseRepositoryMock,
          toReturn: [activity]);
      // Call futureToRun to initialize _courses.
      await viewModel.futureToRun();

      // Act
      final eventData = viewModel.calendarEventData(activity);

      // Assert
      expect(eventData.title, equals("ING150\nRoom 202\nLecture"));
      expect(eventData.description, equals("ING150-01;Room 202;Lecture;null"));
      expect(eventData.date, equals(activity.startDateTime.withoutTime));
      expect(eventData.startTime, equals(activity.startDateTime));
      expect(eventData.endTime,
          equals(activity.endDateTime.subtract(const Duration(minutes: 1))));
      expect(eventData.color, equals(viewModel.getCourseColor('ING150')));
    });

    test(
        'calendarEventData returns correct event data with "Non assign" location',
        () async {
      final dummyCourse = Course(
          acronym: 'GEN101',
          group: '02',
          session: 'H2020',
          programCode: '999',
          numberOfCredits: 3,
          title: 'Cours générique');
      CourseRepositoryMock.stubCourses(courseRepositoryMock,
          toReturn: [dummyCourse]);

      final activity = CourseActivity(
        courseName: 'Tutorial',
        startDateTime: DateTime(2023, 10, 3, 11),
        endDateTime: DateTime(2023, 10, 3, 12),
        courseGroup: 'ING150-01',
        activityLocation: 'Non assign',
        activityName: 'Tutorial',
        activityDescription: 'Session',
      );
      CourseRepositoryMock.stubCoursesActivities(courseRepositoryMock,
          toReturn: [activity]);
      await viewModel.futureToRun();

      final eventData = viewModel.calendarEventData(activity);
      expect(eventData.title, equals("ING150\nN/A\nTutorial"));
      expect(eventData.description, equals("ING150-01;N/A;Tutorial;null"));
    });

    test('calendarEventsFromDate returns correct events for a given date', () {
      final activity1 = CourseActivity(
        courseName: 'Lecture',
        startDateTime: DateTime(2023, 10, 4, 8),
        endDateTime: DateTime(2023, 10, 4, 9),
        courseGroup: 'ING150-01',
        activityLocation: 'Room 101',
        activityName: 'Lecture 1',
        activityDescription: 'Regular',
      );
      final activity2 = CourseActivity(
        courseName: 'Lab',
        startDateTime: DateTime(2023, 10, 4, 10),
        endDateTime: DateTime(2023, 10, 4, 11),
        courseGroup: 'ING150-01',
        activityLocation: 'Room 102',
        activityName: 'Lab Session',
        activityDescription: 'Regular',
      );
      CourseRepositoryMock.stubCoursesActivities(courseRepositoryMock,
          toReturn: [activity1, activity2]);

      // Directly invoke the getter.
      viewModel.coursesActivities;
      final dateKey = DateTime(2023, 10, 4);
      final events = viewModel.calendarEventsFromDate(dateKey);
      expect(events.length, equals(2));

      // Verify that querying a date with no events returns an empty list.
      final noEvents = viewModel.calendarEventsFromDate(DateTime(2023, 10, 5));
      expect(noEvents, isEmpty);
    });

    test('futureToRun returns activities and updates courses from repository',
        () async {
      final activity = CourseActivity(
        courseName: 'Lecture',
        startDateTime: DateTime(2025, 3, 6, 8),
        endDateTime: DateTime(2025, 3, 6, 9),
        courseGroup: 'ING150-01',
        activityLocation: 'Room 103',
        activityName: 'Lecture',
        activityDescription: 'Regular',
      );
      final dummyCourse = Course(
          acronym: 'GEN101',
          group: '02',
          session: 'H2020',
          programCode: '999',
          numberOfCredits: 3,
          title: 'Cours générique');
      // Arrange repository stubs.
      CourseRepositoryMock.stubGetCoursesActivities(courseRepositoryMock,
          fromCacheOnly: true, toReturn: [activity]);
      CourseRepositoryMock.stubCourses(courseRepositoryMock,
          toReturn: [dummyCourse]);
      CourseRepositoryMock.stubGetScheduleActivities(courseRepositoryMock,
          toReturn: []);
      final result = await viewModel.futureToRun();
      expect(result, isNotEmpty);
      expect(result.first.courseName, equals('Lecture'));
    });

    test('futureToRun handles exceptions and calls onError', () async {
      // Use a subclass that records errors.
      final errorViewModel = _TestCalendarViewModelWithError(
        intl: await setupAppIntl(),
      );
      // Arrange: stub getCoursesActivities to throw an exception.
      CourseRepositoryMock.stubGetCoursesActivitiesException(
          courseRepositoryMock,
          toThrow: Exception("Test error"));
      final result = await errorViewModel.futureToRun();
      expect(result, isEmpty);
      expect(errorViewModel.errorMessage, isNotNull);
      expect(errorViewModel.errorMessage, contains("Test error"));
    });

    test(
        'loadSettingsScheduleActivities updates settingsScheduleActivities when matching activity found',
        () async {
      // Arrange: create a dummy schedule activity.
      final scheduleActivity = ScheduleActivity(
          courseAcronym: "XYZ321",
          courseGroup: "01",
          courseTitle: "Sample Course",
          dayOfTheWeek: 1,
          day: "Lundi",
          startTime: DateFormat("hh:mm").parse("08:30"),
          endTime: DateFormat("hh:mm").parse("12:00"),
          activityCode: ActivityCode.labGroupA,
          isPrincipalActivity: true,
          activityLocation: "En ligne",
          name: "Laboratoire (Groupe A)");
      // Set the scheduleActivitiesByCourse manually.
      viewModel.scheduleActivitiesByCourse['XYZ321'] = [scheduleActivity];
      // Stub settingsManager to return the matching activity code.
      SettingsRepositoryMock.stubGetDynamicString(settingsManagerMock,
          PreferencesFlag.scheduleLaboratoryGroup, "XYZ321",
          toReturn: ActivityCode.labGroupA);

      await viewModel.loadSettingsScheduleActivities();
      expect(viewModel.settingsScheduleActivities['XYZ321'],
          equals('Laboratoire (Groupe A)'));
    });

    test(
        'loadSettingsScheduleActivities removes settings when no matching activity found',
        () async {
      final scheduleActivity = ScheduleActivity(
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
          name: "Activité de cours");
      viewModel.scheduleActivitiesByCourse['XYZ321'] = [scheduleActivity];
      // Stub settingsManager to return a non-matching activity code (for example, labGroupB).
      await viewModel.loadSettingsScheduleActivities();
      expect(
          viewModel.settingsScheduleActivities.containsKey('XYZ321'), isFalse);
    });

    test('coursesActivities respects schedule filtering for lab activities',
        () {
      // Arrange: create two activities on the same day, one with a lab description and one regular.
      final date = DateTime(2023, 10, 7, 8);
      final nonLabActivity = CourseActivity(
        courseName: 'Lecture',
        startDateTime: date,
        endDateTime: date.add(const Duration(hours: 1)),
        courseGroup: 'ING150-01',
        activityLocation: 'Room 104',
        activityName: 'Lecture',
        activityDescription: 'Regular',
      );
      final labActivity = CourseActivity(
        courseName: 'Lab',
        startDateTime: date.add(const Duration(hours: 2)),
        endDateTime: date.add(const Duration(hours: 3)),
        courseGroup: 'ING150-01',
        activityLocation: 'Room 105',
        activityName: 'Lab',
        activityDescription: ActivityDescriptionName.labA,
      );
      // Stub the repository to return both activities.
      CourseRepositoryMock.stubCoursesActivities(courseRepositoryMock,
          toReturn: [nonLabActivity, labActivity]);
      // Simulate that the settings select the lab activity.
      viewModel.settingsScheduleActivities['ING150'] =
          ActivityDescriptionName.labA;
      final activitiesByDate = viewModel.coursesActivities;
      final events = activitiesByDate[DateTime(2023, 10, 7)];
      // Expect both activities are added since the lab activity matches the selected setting.
      expect(events?.length, equals(2));
    });
  });
}

// Concrete class for testing abstract CalendarViewModel
class _TestCalendarViewModel extends CalendarViewModel {
  _TestCalendarViewModel({
    required super.intl,
  });

  @override
  bool returnToCurrentDate() => false;

  @override
  handleDateSelectedChanged(DateTime newDate) {}
}

// Subclass for testing error handling by capturing the error message.
class _TestCalendarViewModelWithError extends _TestCalendarViewModel {
  String? errorMessage;

  _TestCalendarViewModelWithError({required super.intl});

  @override
  void onError(error) {
    errorMessage = error.toString();
  }
}
