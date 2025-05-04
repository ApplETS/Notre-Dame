import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:notredame/data/repositories/list_sessions_repository.dart';
import 'package:notredame/domain/models/signets-api/session.dart';
import 'package:notredame/locator.dart';

import '../../helpers.dart';
import '../mocks/services/signets_client_mock.dart';

void main() {
  final now = DateTime.now();

  final activeSession = Session(
      shortName: 'H2019',
      longName: 'Hiver 2019',
      startDate: now.subtract(Duration(days: 10)),
      endDate: now.add(Duration(days: 10)),
      endDateCourses: DateTime(2018, 4, 11),
      startDateRegistration: DateTime(2017, 10, 30),
      deadlineRegistration: DateTime(2017, 11, 14),
      startDateCancellationWithRefund: DateTime(2018, 1, 4),
      deadlineCancellationWithRefund: DateTime(2018, 1, 17),
      deadlineCancellationWithRefundNewStudent: DateTime(2018, 1, 31),
      startDateCancellationWithoutRefundNewStudent: DateTime(2018, 2),
      deadlineCancellationWithoutRefundNewStudent: DateTime(2018, 3, 14),
      deadlineCancellationASEQ: DateTime(2018, 1, 31));
  
  final passedSession = Session(
      shortName: 'H2018',
      longName: 'Hiver 2018',
      startDate: now.subtract(Duration(days: 10)),
      endDate: now.subtract(Duration(days: 8)),
      endDateCourses: DateTime(2018, 4, 11),
      startDateRegistration: DateTime(2017, 10, 30),
      deadlineRegistration: DateTime(2017, 11, 14),
      startDateCancellationWithRefund: DateTime(2018, 1, 4),
      deadlineCancellationWithRefund: DateTime(2018, 1, 17),
      deadlineCancellationWithRefundNewStudent: DateTime(2018, 1, 31),
      startDateCancellationWithoutRefundNewStudent: DateTime(2018, 2),
      deadlineCancellationWithoutRefundNewStudent: DateTime(2018, 3, 14),
      deadlineCancellationASEQ: DateTime(2018, 1, 31));

  final futureSession = Session(
      shortName: 'H2020',
      longName: 'Hiver 2020',
      startDate: now.add(Duration(days: 8)),
      endDate: now.add(Duration(days: 10)),
      endDateCourses: DateTime(2018, 4, 11),
      startDateRegistration: DateTime(2017, 10, 30),
      deadlineRegistration: DateTime(2017, 11, 14),
      startDateCancellationWithRefund: DateTime(2018, 1, 4),
      deadlineCancellationWithRefund: DateTime(2018, 1, 17),
      deadlineCancellationWithRefundNewStudent: DateTime(2018, 1, 31),
      startDateCancellationWithoutRefundNewStudent: DateTime(2018, 2),
      deadlineCancellationWithoutRefundNewStudent: DateTime(2018, 3, 14),
      deadlineCancellationASEQ: DateTime(2018, 1, 31));

  late ListSessionsRepository repository;
  late SignetsClientMock mockSignetsClient;

  setUp(() {
    mockSignetsClient = setupSignetsClientMock();
    setupFlutterSecureStorageMock();
    setupLogger();

    repository = ListSessionsRepository();
  });

  tearDown(() {
    locator.reset();
  });

  group('getSessions', () {
    test('should call _getFromCache and _getFromApi', () async {
      SignetsClientMock.stubGetSessionList(mockSignetsClient, []);

      await repository.getSessions();

      verify(mockSignetsClient.getSessionList()).called(1);
    });
  });

  group('getActiveSession', () {
    test('should return null if value is null', () {
      expect(repository.getActiveSession(), isNull);
    });

    test('should return the active session if within the date range', () {
      // ignore: invalid_use_of_protected_member
      repository.value = [passedSession, activeSession, futureSession];

      final resultSession = repository.getActiveSession();

      expect(activeSession, equals(resultSession));
    });

    test('should return null if no active session is found', () {
      // ignore: invalid_use_of_protected_member
      repository.value = [passedSession, futureSession];

      final activeSession = repository.getActiveSession();

      expect(activeSession, isNull);
    });
  });
}
