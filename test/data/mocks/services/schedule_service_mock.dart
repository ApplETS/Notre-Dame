// Package imports:
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

// Project imports:
import 'package:notredame/data/models/event_data.dart';
import 'package:notredame/data/services/schedule_service.dart';
import 'schedule_service_mock.mocks.dart';

@GenerateNiceMocks([MockSpec<ScheduleService>()])
class ScheduleServiceMock extends MockScheduleService {
  static void stubEvents(MockScheduleService mock, Map<DateTime, List<EventData>> eventsToReturn) {
    when(mock.events).thenAnswer((_) async => eventsToReturn);
  }
}
