import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:notredame/data/models/broadcast_message.dart';
import 'package:notredame/data/repositories/broadcast_message_repository.dart';

import 'broadcast_message_repository_mock.mocks.dart';

@GenerateNiceMocks([MockSpec<BroadcastMessageRepository>()])
class BroadcastMessageRepositoryMock extends MockBroadcastMessageRepository {
  /// Stub the getter [broadcastMessage] of [mock] when called will return [toReturn].
  static void stubGetBroadcastMessage(
      BroadcastMessageRepositoryMock mock, String localeName, BroadcastMessage toReturn) {
    when(mock.getBroadcastMessage(localeName)).thenReturn(toReturn);
  }
}