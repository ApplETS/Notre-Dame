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
}
