// Package imports:
import 'package:collection/collection.dart';
import 'package:logger/logger.dart';

// Project imports:
import 'package:notredame/data/repositories/base_stream_repository.dart';
import 'package:notredame/data/services/signets_client.dart';
import 'package:notredame/domain/models/signets-api/session.dart';
import 'package:notredame/locator.dart';

class ListSessionsRepository extends BaseStreamRepository<List<Session>> {
  static const String sessionsKey = 'sessions';
  static const String tag = "ListSessionsRepository";

  final _signetsClient = locator<SignetsClient>();
  final _logger = locator<Logger>();

  ListSessionsRepository() : super(sessionsKey);

  Future<void> getSessions({bool forceUpdate = false}) async {
    await fetch(() => _signetsClient.getSessionList(), Session.fromJson, forceUpdate: forceUpdate);
    if (value != null) {
      _logger.d("$tag - getSessions: ${value!.length} sessions loaded.");
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
}
