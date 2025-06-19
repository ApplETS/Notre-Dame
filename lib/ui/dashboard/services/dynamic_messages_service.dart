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

    if (sessionRecentlyStarted()) {
      return "Bon début de session !";
    }

    if (isEndOfWeek()) {
      return isEndOfFirstWeek()
          ? "Première semaine de la session complétée, continue !"
          : "${getCompletedWeeks()} semaine complétée !";
    }

    if (isOneMonthOrLessRemaining()) {
      final remaining = getRemainingWeeks();
      final semaine = remaining == 1 ? 'semaine' : 'semaines';
      return "Tiens bon, il ne reste que $remaining $semaine !";
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

  bool sessionRecentlyStarted() {
    final now = DateTime.now();
    final oneWeekAgo = now.subtract(Duration(days: 7));
    final firstActiveSession = _courseRepository.activeSessions.first;

    return firstActiveSession.startDate.isAfter(oneWeekAgo) && firstActiveSession.startDate.isBefore(now);
  }

  bool isEndOfWeek() {
    // TODO: Add checks
    // if there are weekend courses
    // if friday time is after courses
    final now = DateTime.now();
    return now.weekday == DateTime.friday || now.weekday == DateTime.saturday || now.weekday == DateTime.sunday;
  }

  bool isEndOfFirstWeek() {
    final now = DateTime.now();
    final startDate = _courseRepository.activeSessions.first.startDate;

    final isFirstWeek = now.difference(startDate).inDays < 7 && now.weekday >= startDate.weekday;

    return isFirstWeek;
  }

  int getCompletedWeeks() {
    final now = DateTime.now();
    final startDate = _courseRepository.activeSessions.first.startDate;

    final daysPassed = now.difference(startDate).inDays;
    final fullWeeks = daysPassed ~/ 7;

    return fullWeeks > 0 ? fullWeeks : 0;
  }

  bool isOneMonthOrLessRemaining() {
    final now = DateTime.now();
    final firstActiveSession = _courseRepository.activeSessions.first;
    final endDate = firstActiveSession.endDate;

    final daysRemaining = endDate.difference(now).inDays;

    return daysRemaining <= 30 && daysRemaining >= 0;
  }

  int getRemainingWeeks() {
    final now = DateTime.now();
    final endDate = _courseRepository.activeSessions.first.endDate;

    if (endDate.isBefore(now)) return 0;

    final daysRemaining = endDate.difference(now).inDays;
    final remainingWeeks = (daysRemaining / 7).ceil();

    return remainingWeeks;
  }
}
