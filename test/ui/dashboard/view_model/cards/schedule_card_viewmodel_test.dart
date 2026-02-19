// Package imports:
import 'package:calendar_view/calendar_view.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

// Project imports:
import 'package:notredame/data/services/signets-api/models/course_activity.dart';
import 'package:notredame/ui/dashboard/view_model/cards/schedule_card_viewmodel.dart';
import '../../../../data/mocks/repositories/course_repository_mock.dart';
import '../../../../helpers.dart';

void main() {
  late CourseRepositoryMock courseRepositoryMock;

  late ScheduleCardViewmodel viewModel;

  late DateTime now;
  late DateTime today;
  late DateTime tomorrow;

  final gen101 = CourseActivity(
    courseGroup: "GEN101",
    courseName: "Generic course",
    activityName: "TD",
    activityDescription: "Activity description",
    activityLocation: ["location"],
    startDateTime: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 9),
    endDateTime: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 12),
  );
  final gen102 = CourseActivity(
    courseGroup: "GEN102",
    courseName: "Generic course",
    activityName: "TD",
    activityDescription: "Activity description",
    activityLocation: ["location"],
    startDateTime: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 13),
    endDateTime: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 16),
  );
  final gen103 = CourseActivity(
    courseGroup: "GEN103",
    courseName: "Generic course",
    activityName: "TD",
    activityDescription: "Activity description",
    activityLocation: ["location"],
    startDateTime: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 18),
    endDateTime: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 21),
  );
  final gen104 = CourseActivity(
    courseGroup: "GEN104",
    courseName: "Generic course",
    activityName: "TD",
    activityDescription: "Activity description",
    activityLocation: ["location"],
    startDateTime: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day + 1, 8),
    endDateTime: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day + 1, 12),
  );
  final gen105 = CourseActivity(
    courseGroup: "GEN105",
    courseName: "Generic course",
    activityName: "TD",
    activityDescription: "Activity description",
    activityLocation: ["location"],
    startDateTime: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day + 1, 13),
    endDateTime: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day + 1, 16),
  );
  final gen106 = CourseActivity(
    courseGroup: "GEN106",
    courseName: "Generic course",
    activityName: "TD",
    activityDescription: "Activity description",
    activityLocation: ["location"],
    startDateTime: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day + 2, 13),
    endDateTime: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day + 2, 16),
  );
  final List<CourseActivity> todayActivities = [gen101, gen102, gen103];
  final List<CourseActivity> tomorrowActivities = [gen104, gen105];

  // Needed to support FlutterToast.
  TestWidgetsFlutterBinding.ensureInitialized();

  group("ScheduleViewModel - ", () {
    setUp(() async {
      now = DateTime.now();
      today = now.withoutTime;
      tomorrow = today.add(const Duration(days: 1));

      courseRepositoryMock = setupCourseRepositoryMock();
      viewModel = ScheduleCardViewmodel(intl: await setupAppIntl());

      CourseRepositoryMock.stubGetCoursesActivities(courseRepositoryMock);
    });

    test("Should stay on today when there are activities remaining today", () async {
      // Arrange
      when(courseRepositoryMock.coursesActivities).thenReturn(todayActivities);

      // Act
      await viewModel.futureToRun();

      // Assert
      expect(viewModel.tomorrow, false);
      expect(viewModel.date.withoutTime, today);
    });

    test("Should switch to tomorrow when no activities left today but some tomorrow", () async {
      // Arrange
      when(courseRepositoryMock.coursesActivities).thenReturn(tomorrowActivities);

      // Act
      await viewModel.futureToRun();

      // Assert
      expect(viewModel.tomorrow, true);
      expect(viewModel.date.withoutTime, tomorrow);
    });

    test("Should stay on today when no activities today nor tomorrow", () async {
      // Arrange
      when(courseRepositoryMock.coursesActivities).thenReturn([gen106]); // only in 2 days

      // Act
      await viewModel.futureToRun();

      // Assert
      expect(viewModel.tomorrow, false);
      expect(viewModel.date.withoutTime, today);
    });

    test("Should handle repository exception gracefully", () async {
      // Arrange
      when(courseRepositoryMock.getCoursesActivities()).thenThrow(Exception("Repository error"));

      // Act
      await viewModel.futureToRun();

      // Assert
      expect(viewModel.tomorrow, false);
    });
  });
}
