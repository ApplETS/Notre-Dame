import 'package:notredame/data/repositories/base_observable_list_repository.dart';
import 'package:notredame/data/services/signets_client.dart';
import 'package:notredame/domain/models/signets-api/session.dart';
import 'package:notredame/locator.dart';

class ListSessionsRepository extends BaseObservableListRepository<Session> {
  static const String sessionsKey = 'sessions';
  
  final _signetsClient = locator<SignetsClient>();

  ListSessionsRepository() : super(sessionsKey);

  Future<String?> getSessions({bool forceUpdate = false}) async {
    List<Future<String?>> tasks = [];
    tasks.add(getFromCache(Session.fromJson));
    tasks.add(getFromApi(() => _signetsClient.getSessionList(), forceUpdate: forceUpdate));

    return Future.wait(tasks).then((value) => value.firstWhere((message) => message != null, orElse: () => null));
  }
}