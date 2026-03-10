// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:notredame/data/repositories/settings_repository.dart';
import 'package:notredame/data/services/calendar_service.dart';
import 'package:notredame/locator.dart';
import 'package:notredame/ui/schedule/view_model/schedule_viewmodel.dart';
import '../../../data/mocks/repositories/settings_repository_mock.dart';

late SettingsRepositoryMock mockSettingsRepository;

void main() {
  late ScheduleViewModel viewModel;

  setUp(() {
    mockSettingsRepository = SettingsRepositoryMock();
    locator.registerSingleton<SettingsRepository>(mockSettingsRepository);
    viewModel = ScheduleViewModel();
  });

  tearDown(() => locator.reset());

  test('fetches calendar format setting', () async {
    SettingsRepositoryMock.stubScheduleCalendarFormat(mockSettingsRepository, toReturn: CalendarTimeFormat.month);

    expect(viewModel.calendarFormat, CalendarTimeFormat.month);
  });

  test('fetches list view setting', () {
    SettingsRepositoryMock.stubScheduleListView(mockSettingsRepository, toReturn: true);

    expect(viewModel.listView, true);
  });

  test('fetches today button setting', () {
    SettingsRepositoryMock.stubTodayButton(mockSettingsRepository, toReturn: false);

    expect(viewModel.showTodayButton, false);
  });
}
