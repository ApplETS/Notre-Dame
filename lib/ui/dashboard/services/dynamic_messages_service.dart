// Project imports:
import 'package:notredame/data/repositories/course_repository.dart';
import 'package:notredame/data/repositories/settings_repository.dart';
import 'package:notredame/locator.dart';

class DynamicMessagesService {
  final CourseRepository _courseRepository = locator<CourseRepository>();
  final SettingsRepository _settingsManager = locator<SettingsRepository>();

  Future<String> getMessageToDisplay() async {
    if (!(sessionHasStarted())) {
      return "Repose-toi bien! La session recommence le ${upcomingSessionstartDate()}";
    }

    if (oneWeekRemainingUntilSessionEnd()) {
      return "Encore ${sessionEndDaysRemaining()} jours et c'est fini !";
    }

    return "";
  }

  bool sessionHasStarted() {
    final now = DateTime.now();
    final firstActiveSession = _courseRepository.activeSessions.first;
    return firstActiveSession.startDate.isAfter(now);
  }

  String upcomingSessionstartDate() {
    final firstActiveSession = _courseRepository.activeSessions.first;
    return firstActiveSession.startDate.toString();
  }

  bool oneWeekRemainingUntilSessionEnd() {
    final now = DateTime.now();
    final firstActiveSession = _courseRepository.activeSessions.first;
    final endDate = firstActiveSession.endDate;

    final difference = endDate.difference(now).inDays;
    return difference <= 7 && difference >= 0;
  }

  String sessionEndDaysRemaining() {
    final now = DateTime.now();
    final firstActiveSession = _courseRepository.activeSessions.first;
    final endDate = firstActiveSession.endDate;

    return endDate.difference(now).inDays.toString();
  }
}
