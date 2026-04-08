// Package imports:
import 'package:calendar_view/calendar_view.dart';
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:notredame/data/models/event_data.dart';
import 'package:notredame/ui/schedule/view_model/calendars/week_viewmodel.dart';
import 'package:notredame/utils/date_extensions.dart';
import '../../../../data/mocks/services/schedule_service_mock.dart';
import '../../../../helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late WeekViewModel viewModel;
  late ScheduleServiceMock scheduleServiceMock;

  setUp(() async {
    setupSettingsRepositoryMock();
    setupCourseRepositoryMock();
    setupFlutterToastMock();
    scheduleServiceMock = setupScheduleServiceMock();

    viewModel = WeekViewModel(intl: await setupAppIntl());
  });

  group('return to current date', () {
    test('updates weekSelected', () {
      viewModel.weekSelected = DateTime(2023, 10, 1).startOfWeek(start: WeekDays.sunday);
      final result = viewModel.returnToCurrentDate();
      expect(result, true);
    });

    test('does not update weekSelected', () async {
      final DateTime saturday = DateTime.now()
          .startOfWeek(start: WeekDays.sunday)
          .add(Duration(days: 6, hours: 1))
          .withoutTime;

      final Map<DateTime, List<EventData>> events = {
        saturday: [
          EventData(
            courseAcronym: 'PRE011',
            courseName: 'PRE011',
            activityName: 'PRE011',
            date: saturday,
            startTime: saturday.add(Duration(hours: 12)),
            endTime: saturday.add(Duration(hours: 16)),
          ),
        ],
      };

      ScheduleServiceMock.stubEvents(scheduleServiceMock, events);
      await viewModel.futureToRun();

      viewModel.weekSelected = DateTime.now().startOfWeek(start: WeekDays.sunday);

      final result = viewModel.returnToCurrentDate();
      expect(result, false);
    });
  });

  group('handle selected date changed', () {
    test('handleDateSelectedChanged updates weekSelected', () {
      final newDate = DateTime(2023, 10, 10);
      viewModel.handleDateSelectedChanged(newDate);
      expect(viewModel.weekSelected, newDate.startOfWeek(start: WeekDays.sunday).withoutTime);
    });
  });
}
