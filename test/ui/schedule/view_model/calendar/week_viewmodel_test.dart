// Package imports:
import 'package:calendar_view/calendar_view.dart';
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
    setupSettingsRepositoryMock();
    courseRepositoryMock = setupCourseRepositoryMock();
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
      final CourseActivity saturdayCourse = CourseActivity(
        courseGroup: 'PRE011',
        courseName: 'PRE011',
        activityName: 'PRE011',
        activityDescription: 'PRE011',
        activityLocation: 'PRE011',
        startDateTime: Utils.getFirstdayOfWeek(DateTime.now())
            .add(Duration(days: 6, hours: 12)),
        endDateTime: Utils.getFirstdayOfWeek(DateTime.now())
            .add(Duration(days: 6, hours: 16)),
      );

      // Mocking the class to get our list of data back like a "real" request
      CourseRepositoryMock.stubCoursesActivities(courseRepositoryMock,
          toReturn: [saturdayCourse]);
      // Map the list of CourseActivity to add them in the viewModel
      final Map<DateTime, List<CourseActivity>> coursesMapped = {};
      final DateTime saturday = Utils.getFirstdayOfWeek(DateTime.now())
          .add(Duration(days: 6, hours: 1))
          .withoutTime;
      coursesMapped[saturday]?.add(saturdayCourse);

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
