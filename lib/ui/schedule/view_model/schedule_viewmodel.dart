// Package imports:
import 'package:stacked/stacked.dart';

// Project imports:
import 'package:notredame/data/repositories/settings_repository.dart';
import 'package:notredame/data/services/calendar_service.dart';
import 'package:notredame/locator.dart';

class ScheduleViewModel extends BaseViewModel {
  final SettingsRepository _settingsManager = locator<SettingsRepository>();

  CalendarTimeFormat get calendarFormat => _settingsManager.schedule.calendarFormat;
  bool get listView => _settingsManager.schedule.listView;
  bool get showTodayButton => _settingsManager.schedule.todayButton;
}
