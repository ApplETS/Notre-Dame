import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:notredame/data/repositories/settings_repository.dart';
import 'package:notredame/data/services/signets-api/models/session.dart';
import 'package:notredame/l10n/app_localizations.dart';
import 'package:notredame/locator.dart';
import 'package:notredame/ui/dashboard/services/dynamic_messages_service.dart';

import '../../helpers.dart';
import '../mocks/repositories/course_repository_mock.mocks.dart';
import '../mocks/repositories/settings_repository_mock.dart';

void main() {
  late AppIntl mockIntl;
  late DynamicMessagesService service;
  late MockCourseRepository mockCourseRepository;
  late SettingsRepositoryMock mockSettingsRepository;

  setUp(() async {
    mockCourseRepository = setupCourseRepositoryMock();
    mockSettingsRepository = SettingsRepositoryMock();
    locator.registerSingleton<SettingsRepository>(mockSettingsRepository);
    mockIntl = await setupAppIntl();
    service = DynamicMessagesService(mockIntl);
  });

  tearDown(() {
    unregister<SettingsRepository>();
    locator.reset();
  });

  group('sessionHasStarted -', () {
    test('returns true when current date is after session start date', () {
      final session = Session(
        shortName: 'NOW',
        name: 'now',
        startDate: DateTime(2025),
        endDate: DateTime.now().add(const Duration(days: 10)),
        endDateCourses: DateTime(2025),
        startDateRegistration: DateTime(2025),
        deadlineRegistration: DateTime(2025),
        startDateCancellationWithRefund: DateTime(2025),
        deadlineCancellationWithRefund: DateTime(2025),
        deadlineCancellationWithRefundNewStudent: DateTime(2025),
        startDateCancellationWithoutRefundNewStudent: DateTime(2025),
        deadlineCancellationWithoutRefundNewStudent: DateTime(2025),
        deadlineCancellationASEQ: DateTime(2025),
      );

      when(mockCourseRepository.activeSessions).thenReturn([session]);

      expect(service.sessionHasStarted(), isTrue);
    });

    test('returns false when current date is before session start date', () {
      final session = Session(
        shortName: 'NOW',
        name: 'now',
        startDate: DateTime.now().subtract(const Duration(days: 10)),
        endDate: DateTime(2025),
        endDateCourses: DateTime(2025),
        startDateRegistration: DateTime(2025),
        deadlineRegistration: DateTime(2025),
        startDateCancellationWithRefund: DateTime(2025),
        deadlineCancellationWithRefund: DateTime(2025),
        deadlineCancellationWithRefundNewStudent: DateTime(2025),
        startDateCancellationWithoutRefundNewStudent: DateTime(2025),
        deadlineCancellationWithoutRefundNewStudent: DateTime(2025),
        deadlineCancellationASEQ: DateTime(2025),
      );

      when(mockCourseRepository.activeSessions).thenReturn([session]);

      expect(service.sessionHasStarted(), isFalse);
    });
  });
}
