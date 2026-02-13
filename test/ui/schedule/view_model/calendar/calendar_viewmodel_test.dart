// Package imports:
import 'package:calendar_view/calendar_view.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

// Project imports:
import 'package:notredame/data/models/activity_code.dart';
import 'package:notredame/data/models/event_data.dart';
import 'package:notredame/data/services/signets-api/models/course.dart';
import 'package:notredame/data/services/signets-api/models/course_activity.dart';
import 'package:notredame/data/services/signets-api/models/schedule_activity.dart';
import 'package:notredame/domain/constants/preferences_flags.dart';
import 'package:notredame/ui/schedule/view_model/calendars/calendar_viewmodel.dart';
import '../../../../data/mocks/repositories/course_repository_mock.dart';
import '../../../../data/mocks/repositories/settings_repository_mock.dart';
import '../../../../data/mocks/services/schedule_service_mock.dart';
import '../../../../helpers.dart';

void main() {
  late CalendarViewModel viewModel;
  late CourseRepositoryMock courseRepositoryMock;
  late ScheduleServiceMock scheduleServiceMock;

  setUp(() async {
    courseRepositoryMock = setupCourseRepositoryMock();
    setupSettingsRepositoryMock();
    scheduleServiceMock = setupScheduleServiceMock();

    viewModel = _TestCalendarViewModel(intl: await setupAppIntl());
  });

  group('CalendarViewModel', () {
    test('coursesActivities groups activities by date', () async {
      final Map<DateTime, List<EventData>> events = {
        DateTime(2023, 10, 1): [
          EventData(
            courseAcronym: "LOG100",
            courseName: "Programmation et réseautique en génie logiciel",
            date: DateTime(2023, 10, 1),
            startTime: DateTime(2023, 10, 1, 8),
            endTime: DateTime(2023, 10, 1, 10),
          ),
        ],
      };

      ScheduleServiceMock.stubEvents(scheduleServiceMock, events);
      await viewModel.futureToRun();
      expect(viewModel.calendarEventsFromDate(DateTime(2023, 10, 1)).length, 1);
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
