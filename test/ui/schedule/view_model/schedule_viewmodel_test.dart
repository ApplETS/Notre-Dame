// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

// Project imports:
import 'package:notredame/data/repositories/settings_repository.dart';
import 'package:notredame/data/services/calendar_service.dart';
import 'package:notredame/domain/constants/preferences_flags.dart';
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

  test('Initialization calls loadSettings', () async {
    when(mockSettingsRepository.getScheduleSettings()).thenAnswer(
      (_) async => {
        PreferencesFlag.scheduleCalendarFormat: CalendarTimeFormat.week,
        PreferencesFlag.scheduleListView: false,
        PreferencesFlag.scheduleShowTodayBtn: true,
      },
    );

    await viewModel.futureToRun();
    verify(mockSettingsRepository.getScheduleSettings()).called(1);
  });

  test('loadSettings updates settings and calendarFormat', () async {
    final testSettings = {
      PreferencesFlag.scheduleCalendarFormat: CalendarTimeFormat.month,
      PreferencesFlag.scheduleListView: true,
      PreferencesFlag.scheduleShowTodayBtn: false,
    };
    when(mockSettingsRepository.getScheduleSettings()).thenAnswer((_) async => testSettings);

    await viewModel.loadSettings();

    expect(viewModel.settings, testSettings);
    expect(viewModel.calendarFormat, CalendarTimeFormat.month);
  });

  test('calendarViewSetting returns false when settings are busy', () {
    viewModel.setBusyForObject(viewModel.settings, true);
    expect(viewModel.calendarViewSetting, false);
  });

  test('calendarViewSetting returns correct value when settings are not busy', () {
    viewModel.settings[PreferencesFlag.scheduleListView] = true;
    viewModel.setBusyForObject(viewModel.settings, false);
    expect(viewModel.calendarViewSetting, true);
  });
}
