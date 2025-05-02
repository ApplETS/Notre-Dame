import 'package:collection/collection.dart';
import 'package:notredame/data/repositories/base_stream_repository.dart';
import 'package:notredame/data/services/signets_client.dart';
import 'package:notredame/domain/models/signets-api/session.dart';
import 'package:notredame/locator.dart';

class ListSessionsRepository extends BaseStreamRepository<List<Session>> {
  static const String sessionsKey = 'sessions';
  
  final _signetsClient = locator<SignetsClient>();

  ListSessionsRepository() : super(sessionsKey);

  Future getSessions({bool forceUpdate = false}) async {
    List<Future> tasks = [];
    tasks.add(getFromCache(Session.fromJson));
    tasks.add(getFromApi(() => _signetsClient.getSessionList(), forceUpdate: forceUpdate));

    return Future.wait(tasks);
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