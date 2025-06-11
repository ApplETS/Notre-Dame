// Package imports:
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

// Project imports:
import 'package:notredame/data/services/cache_service.dart';
import 'package:notredame/utils/cache_exception.dart';
import 'cache_service_mock.mocks.dart';

/// Mock for the [CacheService]
@GenerateNiceMocks([MockSpec<CacheService>()])
class CacheServiceMock extends MockCacheService {
  /// Stub the get function of [mock], when [key] is used, [valueToReturn] is answered.
  static void stubGet(CacheServiceMock mock, String key, String valueToReturn) {
    when(mock.get(key)).thenAnswer((_) async => valueToReturn);
  }

  /// Stub a exception while calling the get function of [mock] when [key] is used.
  static void stubGetException(
    CacheServiceMock mock,
    String key, {
    Exception exceptionToThrow = const CacheException(prefix: 'CacheException', message: ''),
  }) {
    when(mock.get(key)).thenThrow(exceptionToThrow);
  }

  /// Stub a exception while calling the update function of [mock] when [key] is used.
  static void stubUpdateException(
    CacheServiceMock mock,
    String key, {
    Exception exceptionToThrow = const CacheException(prefix: 'CacheException', message: ''),
  }) {
    when(mock.update(key, any)).thenThrow(exceptionToThrow);
  }

  /// Stub a exception while calling the delete function of [mock] when [key] is used.
  static void stubDeleteException(
    CacheServiceMock mock,
    String key, {
    Exception exceptionToThrow = const CacheException(prefix: 'CacheException', message: ''),
  }) {
    when(mock.delete(key)).thenThrow(exceptionToThrow);
  }

  /// Stub an exception while calling the empty function of [mock] when [key] is used.
  static void stubEmptyException(
    CacheServiceMock mock, {
    Exception exceptionToThrow = const CacheException(prefix: 'CacheException', message: ''),
  }) {
    when(mock.empty()).thenThrow(exceptionToThrow);
  }
}
