// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:notredame/data/services/signets-api/models/course_activity.dart';
import 'package:notredame/ui/schedule/view_model/calendars/calendar_viewmodel.dart';
import '../../../../data/mocks/repositories/course_repository_mock.dart';
import '../../../../helpers.dart';

void main() {
  late CalendarViewModel viewModel;
  late CourseRepositoryMock mockCourseRepository;

  setUp(() async {
    mockCourseRepository = setupCourseRepositoryMock();
    setupSettingsManagerMock();

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

      CourseRepositoryMock.stubCoursesActivities(mockCourseRepository,
          toReturn: [activity]);

      final activitiesByDate = viewModel.coursesActivities;
      expect(activitiesByDate[DateTime(2023, 10, 1)]?.length, 1);
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
