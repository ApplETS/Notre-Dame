import 'dart:async';

import 'package:calendar_view/calendar_view.dart';
import 'package:notredame/data/repositories/course_activity_repository.dart';
import 'package:notredame/data/repositories/list_sessions_repository.dart';
import 'package:notredame/domain/models/signets-api/course_activity.dart';
import 'package:notredame/locator.dart';

class DaysScheduleUseCase {
  final _courseActivityRepository = locator<CourseActivityRepository>();
  final _listSessionsRepository = locator<ListSessionsRepository>();

  final _controller = StreamController<List<CourseActivity>>.broadcast();
  Stream<List<CourseActivity>> get stream => _controller.stream;
  StreamSubscription? _courseActivitySubscription;
  StreamSubscription? _listSessionsSubscription;

  Future<void> init() async {
    _courseActivitySubscription = _courseActivityRepository.stream.listen(
      (activities) {
        if(activities != null) _controller.add(activities);
      },
      onError: (error) {
        _controller.addError(error as Object);
      },
    );

    _listSessionsSubscription = _listSessionsRepository.stream.listen(
      (sessions) async {
        await fetchSchedule();
      },
    );
  }

  Future<void> fetchSchedule({bool forceUpdate = false}) async {
    final session = _listSessionsRepository.getActiveSession();
    if(session == null) {
      await _listSessionsRepository.getSessions();
      return;
    }
    final today = DateTime.now().withoutTime;
    final tomorrow = today.add(const Duration(days: 1));
    await _courseActivityRepository.getCourseActivities(
      session.shortName,
      startDate: today,
      endDate: tomorrow,
      forceUpdate: forceUpdate,
    );
  }

  void dispose() {
    _courseActivitySubscription?.cancel();
    _listSessionsSubscription?.cancel();
    _controller.close();
  }
}