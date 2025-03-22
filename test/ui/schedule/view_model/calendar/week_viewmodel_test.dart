// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:notredame/data/services/signets-api/models/course_activity.dart';
import 'package:notredame/ui/schedule/view_model/calendars/week_viewmodel.dart';
import 'package:notredame/utils/utils.dart';
import '../../../../data/mocks/repositories/course_repository_mock.dart';
import '../../../../helpers.dart';

late CourseRepositoryMock courseRepositoryMock;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late WeekViewModel viewModel;

  setUp(() async {
    courseRepositoryMock = setupCourseRepositoryMock();
    setupSettingsManagerMock();
    setupFlutterToastMock();

    viewModel = WeekViewModel(
      intl: await setupAppIntl(),
    );
  });

  group('return to current date', () {
    test('updates weekSelected', () {
      viewModel.weekSelected = Utils.getFirstdayOfWeek(DateTime(2023, 10, 1));
      final result = viewModel.returnToCurrentDate();
      expect(result, true);
    });

    test('does not update weekSelected', () {
      final List<CourseActivity> sundayCourses = [
        CourseActivity(
          courseGroup: 'PRE013',
          courseName: 'PRE013',
          activityName: 'PRE013',
          activityDescription: 'PRE013',
          activityLocation: 'PRE013',
          startDateTime: Utils.getCurrentSundayOfWeek(DateTime.now()),
          endDateTime: Utils.getCurrentSundayOfWeek(DateTime.now()),
        ),
        CourseActivity(
          courseGroup: 'PRE013',
          courseName: 'PRE013',
          activityName: 'PRE013',
          activityDescription: 'PRE013',
          activityLocation: 'PRE013',
          startDateTime: Utils.getCurrentSundayOfWeek(DateTime.now()),
          endDateTime: Utils.getCurrentSundayOfWeek(DateTime.now()),
        ),
      ];

      // Mocking the class to get our list of data back like a "real" request
      CourseRepositoryMock.stubCoursesActivities(courseRepositoryMock,
          toReturn: sundayCourses);
      // Map the list of CourseActivity to add them in the viewModel
      final Map<DateTime, List<CourseActivity>> coursesMapped = {};

      for (CourseActivity c in sundayCourses) {
        final DateTime date = Utils.getCurrentSundayOfWeek(DateTime.now());
        coursesMapped[date]?.add(c);
      }

      viewModel.coursesActivities.addAll(coursesMapped);
      viewModel.weekSelected = Utils.getFirstdayOfWeek(DateTime.now());

      final result = viewModel.returnToCurrentDate();
      expect(result, false);
    });
  });

  group('handle selected date changed', () {
    test('handleDateSelectedChanged updates weekSelected', () {
      final newDate = DateTime(2023, 10, 10);
      viewModel.handleDateSelectedChanged(newDate);
      expect(viewModel.weekSelected, Utils.getFirstdayOfWeek(newDate));
    });
  });
}
