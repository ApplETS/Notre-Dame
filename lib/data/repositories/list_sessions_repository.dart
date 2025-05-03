import 'package:collection/collection.dart';
import 'package:logger/logger.dart';
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

  Future getSessions({bool forceUpdate = false}) async {
    List<Future> tasks = [
      _getFromCache(),
      _getFromApi(forceUpdate: forceUpdate)
    ];

    return Future.wait(tasks);
  }

  Future<void> _getFromCache() async {
    var executed = await super.getFromCache(Session.fromJson);
    if(executed) {
      _logger.d("$tag - getSessions: ${value?.length ?? 0} sessions loaded from cache.");
    }
  }

  Future<void> _getFromApi({bool forceUpdate = false}) async {
    var executed = await super.getFromApi(() => _signetsClient.getSessionList(), forceUpdate: forceUpdate);
    if (executed) {
      _logger.d("$tag - getSessions: ${value?.length ?? 0} sessions fetched.");
    }
  }

  Session? getActiveSession() {
    if (value == null) {
      return null;
    } else {
      DateTime now = DateTime.now();
      now = DateTime(now.year, now.month, now.day);

      return value!.firstWhereOrNull((session) =>
          now.isAfter(session.startDate) && now.isBefore(session.endDate)
          || now.isAtSameMomentAs(session.startDate) || now.isAtSameMomentAs(session.endDate));
    }
  }
}