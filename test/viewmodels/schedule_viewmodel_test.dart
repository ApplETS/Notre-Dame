// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

// MANAGERS
import 'package:notredame/core/managers/course_repository.dart';
import 'package:notredame/core/managers/settings_manager.dart';

// VIEW-MODEL
import 'package:notredame/core/viewmodels/schedule_viewmodel.dart';

// MODEL
import 'package:notredame/core/models/course_activity.dart';

import '../helpers.dart';

// MOCKS
import '../mock/managers/course_repository_mock.dart';
import '../mock/services/networking_service_mock.dart';

CourseRepository courseRepository;
SettingsManager settingsManager;
NetworkingServiceMock networkingService;
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

  group("ScheduleViewModel - ", () {
    setUp(() async {
      // Setting up mocks
      courseRepository = setupCourseRepositoryMock();
      settingsManager = setupSettingsManagerMock();
      networkingService = setupNetworkingServiceMock() as NetworkingServiceMock;
      setupFlutterToastMock();

      // Stub to simulate that the user has an active internet connection
      NetworkingServiceMock.stubHasConnectivity(networkingService);

      viewModel = ScheduleViewModel(intl: await setupAppIntl());
    });

    tearDown(() {
      unregister<CourseRepository>();
      unregister<SettingsManager>();
      unregister<NetworkingServiceMock>();
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
  });
}
