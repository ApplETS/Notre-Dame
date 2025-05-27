// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:notredame/ui/schedule/view_model/calendars/month_viewmodel.dart';
import 'package:notredame/utils/utils.dart';
import '../../../../helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late MonthViewModel viewModel;

  setUp(() async {
    setupCourseRepositoryMock();
    setupSettingsRepositoryMock();
    setupFlutterToastMock();

    viewModel = MonthViewModel(intl: await setupAppIntl());
  });

  group('return to current date', () {
    test('updates monthSelected', () {
      viewModel.monthSelected = DateTime(2023, 9, 1);
      final result = viewModel.returnToCurrentDate();
      expect(result, true);
    });

    test('does not update monthSelected', () {
      viewModel.monthSelected = Utils.getFirstDayOfMonth(DateTime.now());
      final result = viewModel.returnToCurrentDate();
      expect(result, false);
    });
  });

  group('handle selected date changed', () {
    test('handleDateSelectedChanged updates monthSelected', () {
      final newDate = DateTime(2023, 10, 7);
      viewModel.handleDateSelectedChanged(newDate);
      expect(viewModel.monthSelected, Utils.getFirstDayOfMonth(newDate));
    });
  });
}
