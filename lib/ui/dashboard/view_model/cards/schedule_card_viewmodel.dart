// Package imports:
import 'dart:async';

import 'package:calendar_view/calendar_view.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:notredame/data/repositories/course_activity_repository.dart';
import 'package:notredame/data/repositories/list_sessions_repository.dart';
import 'package:notredame/domain/models/signets-api/course_activity.dart';
import 'package:stacked/stacked.dart';

// Project imports:
import 'package:notredame/data/repositories/settings_repository.dart';
import 'package:notredame/l10n/app_localizations.dart';
import 'package:notredame/locator.dart';

class ScheduleCardViewmodel extends FutureViewModel {
  final SettingsRepository _settingsManager = locator<SettingsRepository>();
  final CourseActivityRepository _courseRepository = locator<CourseActivityRepository>();
  final _listSessionsRepository = locator<ListSessionsRepository>();
  final AppIntl _appIntl;

  StreamSubscription? _courseActivitySubscription;
  StreamSubscription? _listSessionsSubscription;

  DateTime _date = DateTime.now().withoutTime;
  DateTime get date {
    return _date;
  }

  bool get tomorrow {
    return _date != DateTime.now().withoutTime;
  }

  bool get listView => _settingsManager.dashboard.displayScheduleAsList;

  ScheduleCardViewmodel({required AppIntl intl}) : _appIntl = intl;

  @override
  Future<void> futureToRun() async {
    try {
      setBusy(true);

      _courseActivitySubscription = _courseRepository.stream.listen(
        (courseActivities) => _isEventTomorrow(courseActivities),
        onError: (error) {
          onError(error, null);
        },
      );
      _listSessionsSubscription = _listSessionsRepository.stream.listen(
        (sessions) async {
          await fetchSchedule();
        },
      );
    } catch (e) {
      onError(e, null);
    } finally {
      setBusy(false);
    }
  }

  Future<void> fetchSchedule() async {
    final session = _listSessionsRepository.getActiveSession();
    if(session == null) {
      await _listSessionsRepository.getSessions();
      return;
    }

    final yesterday = _date.subtract(const Duration(days: 1));
    final twoDaysFromNow = _date.add(const Duration(days: 2));
    await _courseRepository.getCourseActivities(
      session.shortName,
      startDate: yesterday,
      endDate: twoDaysFromNow,
    );
  }

  void _isEventTomorrow(List<CourseActivity>? courseActivities) {
    final nowDate = DateTime.now();
    final tomorrowDate = nowDate.withoutTime.add(const Duration(days: 1, hours: 1)).withoutTime;

    bool eventsToday = courseActivities
      ?.any((activity) => activity.endDate.isAfter(nowDate) && activity.endDate.isBefore(tomorrowDate))
        ?? false;
    if(eventsToday) {
      _date = nowDate.withoutTime;
      notifyListeners();
      return;
    }
    
    final twoDaysFromNow = nowDate.withoutTime.add(const Duration(days: 2, hours: 1)).withoutTime;
    
    final eventsTomorrow = courseActivities
      ?.any((activity) => activity.endDate.isAfter(tomorrowDate) && activity.endDate.isBefore(twoDaysFromNow)) ?? false;
    
    if(eventsTomorrow) {
      _date = tomorrowDate;
      notifyListeners();
    }
  }

  @override
  void onError(error, StackTrace? stackTrace) {
    Fluttertoast.showToast(msg: _appIntl.error);
  }

  @override
  void dispose() {
    super.dispose();
    _listSessionsSubscription?.cancel();
    _courseActivitySubscription?.cancel();
  }
}
