import 'package:mockito/annotations.dart';
import 'package:notredame/data/services/schedule_service.dart';

import 'schedule_service_mock.mocks.dart';

@GenerateNiceMocks([MockSpec<ScheduleService>()])
class ScheduleServiceMock extends MockScheduleService {
}