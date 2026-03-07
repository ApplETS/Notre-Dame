// Package imports:
import 'package:calendar_view/calendar_view.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:notredame/data/repositories/settings_repository.dart';
import 'package:stacked/stacked.dart';

// Project imports:
import 'package:notredame/data/repositories/course_repository.dart';
import 'package:notredame/data/services/signets-api/models/course_activity.dart';
import 'package:notredame/l10n/app_localizations.dart';
import 'package:notredame/locator.dart';

class ScheduleCardViewmodel extends FutureViewModel {
  final CourseRepository _courseRepository = locator<CourseRepository>();
  final SettingsRepository _settingsManager = locator<SettingsRepository>();

  List<CourseActivity> _scheduleEvents = [];

  bool _tomorrow = false;
  DateTime _date = DateTime.now().withoutTime;

  final AppIntl _appIntl;

  DateTime get date {
    return _date;
  }

  bool get tomorrow {
    return _tomorrow;
  }

  bool get listView => _settingsManager.dashboard.dashboardScheduleList;

  ScheduleCardViewmodel({required AppIntl intl}) : _appIntl = intl;

  @override
  Future<void> futureToRun() async {
    try {
      setBusyForObject(tomorrow, true);
      setBusyForObject(date, true);

      _scheduleEvents.clear();
      await _courseRepository.getCoursesActivities();

      final nowDate = DateTime.now();
      // The extra hours prevents daylight savings problems
      final tomorrowDate = nowDate.withoutTime.add(const Duration(days: 1, hours: 1)).withoutTime;
      final twoDaysFromNow = nowDate.withoutTime.add(const Duration(days: 2, hours: 1)).withoutTime;

      bool hasActivitiesTodayAfterNow =
          _courseRepository.coursesActivities?.any(
            (activity) => activity.endDateTime.isAfter(nowDate) && activity.endDateTime.isBefore(tomorrowDate),
          ) ??
          false;

      if (hasActivitiesTodayAfterNow) {
        return;
      }

      bool hasActivitiesTomorrow =
          _courseRepository.coursesActivities?.any(
            (activity) => activity.endDateTime.isAfter(tomorrowDate) && activity.endDateTime.isBefore(twoDaysFromNow),
          ) ??
          false;

      if (hasActivitiesTomorrow) {
        _tomorrow = true;
        _date = tomorrowDate;
        return;
      }
    } catch (e) {
      onError(e, null);
    } finally {
      setBusyForObject(tomorrow, false);
      setBusyForObject(date, false);
    }
    _scheduleEvents = [];
  }

  @override
  void onError(error, StackTrace? stackTrace) {
    Fluttertoast.showToast(msg: _appIntl.error);
  }
}
