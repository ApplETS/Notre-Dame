// Package imports:
import 'package:mockito/annotations.dart';

// Project imports:
import 'package:notredame/data/services/dynamic_messages_service.dart';
import 'dynamic_messages_service_mock.mocks.dart';

@GenerateNiceMocks([MockSpec<DynamicMessagesService>()])
class DynamicMessagesServiceMock extends MockDynamicMessagesService {}
