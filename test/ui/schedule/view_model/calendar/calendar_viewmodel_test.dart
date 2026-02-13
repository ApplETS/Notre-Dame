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

  setUp(() async {
    courseRepositoryMock = setupCourseRepositoryMock();
    setupSettingsRepositoryMock();
    setupScheduleServiceMock();

    viewModel = _TestCalendarViewModel(intl: await setupAppIntl());
  });

  group('CalendarViewModel', () {
    test('coursesActivities groups activities by date', () {
      final activity = CourseActivity(
        courseName: 'LOG100',
        startDateTime: DateTime(2023, 10, 1, 8),
        endDateTime: DateTime(2023, 10, 1, 10),
        courseGroup: 'ING150-01',
        activityLocation: ['Room 101'],
        activityName: 'Lecture',
        activityDescription: '',
      );

      // TODO mock service instead
      CourseRepositoryMock.stubCoursesActivities(courseRepositoryMock, toReturn: [activity]);

      expect(viewModel
          .calendarEventsFromDate(DateTime(2023, 10, 1))
          .length, 1);
    });
  });
}

// Concrete class for testing abstract CalendarViewModel
class _TestCalendarViewModel extends CalendarViewModel {
  _TestCalendarViewModel({required super.intl});

  @override
  bool returnToCurrentDate() => false;

  @override
  handleDateSelectedChanged(DateTime newDate) {}
}