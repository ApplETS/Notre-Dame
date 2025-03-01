import 'package:calendar_view/calendar_view.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notredame/ui/schedule/view_model/calendars/day_viewmodel.dart';
import '../../../../helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late DayViewModel viewModel;

  setUp(() async {
    setupCourseRepositoryMock();
    setupSettingsManagerMock();
    setupFlutterToastMock();

    viewModel = DayViewModel(
      intl: await setupAppIntl(),
    );
  });

  group('return to current date', () {
    test('updates daySelected', () {
      viewModel.daySelected = DateTime(2023, 10, 2);
      final result = viewModel.returnToCurrentDate();
      expect(result, true);
    });

    test('does not update daySelected', () {
      viewModel.daySelected = DateTime.now().withoutTime;
      final result = viewModel.returnToCurrentDate();
      expect(result, false);
    });
  });

  group('handle date selected changed', () {
    test('handleDateSelectedChanged updates events', () {
      viewModel.handleDateSelectedChanged(DateTime(2023, 10, 3));
      expect(viewModel.daySelected, DateTime(2023, 10, 3).withoutTime);
    });
  });
}