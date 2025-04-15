// Package imports:
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

// Project imports:
import 'package:notredame/data/models/broadcast_message.dart';
import 'package:notredame/data/repositories/broadcast_message_repository.dart';
import 'broadcast_message_repository_mock.mocks.dart';

@GenerateNiceMocks([MockSpec<BroadcastMessageRepository>()])
class BroadcastMessageRepositoryMock extends MockBroadcastMessageRepository {
  static void stubGetBroadcastMessage(
      BroadcastMessageRepositoryMock mock, String localeName, BroadcastMessage toReturn) {
    when(mock.getBroadcastMessage(localeName)).thenReturn(toReturn);
  }
}
