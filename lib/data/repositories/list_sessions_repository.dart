// Package imports:
import 'package:collection/collection.dart';
import 'package:logger/logger.dart';

// Project imports:
import 'package:notredame/data/repositories/base_stream_repository.dart';
import 'package:notredame/data/services/signets_client_service.dart';
import 'package:notredame/domain/models/signets-api/session.dart';
import 'package:notredame/locator.dart';

class ListSessionsRepository extends BaseStreamRepository<List<Session>> {
  static const String sessionsKey = 'sessions';

  final _signetsClientService = locator<SignetsClientService>();
  final _logger = locator<Logger>();

  ListSessionsRepository() : super(sessionsKey);

  Future<void> getSessions({bool forceUpdate = false}) async {
    _logger.d("$runtimeType - getSessions: fetch called with forceUpdate=$forceUpdate");
    await fetch(() => _signetsClientService.getSessionList(), Session.fromJson, forceUpdate: forceUpdate);
    if (value != null) {
      _logger.d("$runtimeType - getSessions: ${value!.length} sessions loaded.");
    }
  }

  Session? getActiveSession() {
    if (value == null) {
      return null;
    } else {
      DateTime now = DateTime.now();
      now = DateTime(now.year, now.month, now.day);
      return value!.firstWhereOrNull(
        (session) =>
            now.isAfter(session.startDate) && now.isBefore(session.endDate) ||
            now.isAtSameMomentAs(session.startDate) ||
            now.isAtSameMomentAs(session.endDate),
      );
    }
  }

  Session? getSessionForDate(DateTime date) {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    return value?.firstWhereOrNull(
      (session) =>
          normalizedDate.isAfter(session.startDate) && normalizedDate.isBefore(session.endDate) ||
          normalizedDate.isAtSameMomentAs(session.startDate) ||
          normalizedDate.isAtSameMomentAs(session.endDate),
    );
  }

  Session? getSessionForRange(DateTime startDate, DateTime endDate) {
    if (value == null) {
      return null;
    }

    final normalizedStart = DateTime(startDate.year, startDate.month, startDate.day);
    final normalizedEnd = DateTime(endDate.year, endDate.month, endDate.day).subtract(const Duration(days: 1));

    return value!.firstWhereOrNull((session) {
      final sessionStart = DateTime(session.startDate.year, session.startDate.month, session.startDate.day);
      final sessionEnd = DateTime(session.endDate.year, session.endDate.month, session.endDate.day);
      return !normalizedEnd.isBefore(sessionStart) && !normalizedStart.isAfter(sessionEnd);
    });
  }
}
