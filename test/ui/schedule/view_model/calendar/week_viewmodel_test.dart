// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:notredame/ui/schedule/view_model/calendars/week_viewmodel.dart';
import 'package:notredame/utils/utils.dart';
import '../../../../helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late WeekViewModel viewModel;

  setUp(() async {
    setupCourseRepositoryMock();
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
