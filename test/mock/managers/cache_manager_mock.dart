// Package imports:
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

// Project imports:
import 'package:notredame/core/managers/cache_manager.dart';
import 'package:notredame/core/utils/cache_exception.dart';

import 'cache_manager_mock.mocks.dart';

/// Mock for the [CacheManager]
@GenerateNiceMocks([MockSpec<CacheManager>()])
class CacheManagerMock extends MockCacheManager {
  /// Stub the get function of [mock], when [key] is used, [valueToReturn] is answered.
  static void stubGet(CacheManagerMock mock, String key, String valueToReturn) {
    when(mock.get(key)).thenAnswer((_) async => valueToReturn);
  }

  /// Stub a exception while calling the get function of [mock] when [key] is used.
  static void stubGetException(CacheManagerMock mock, String key,
      {Exception exceptionToThrow =
          const CacheException(prefix: 'CacheException', message: '')}) {
    when(mock.get(key)).thenThrow(exceptionToThrow);
  }

  /// Stub a exception while calling the update function of [mock] when [key] is used.
  static void stubUpdateException(CacheManagerMock mock, String key,
      {Exception exceptionToThrow =
          const CacheException(prefix: 'CacheException', message: '')}) {
    when(mock.update(key, '')).thenThrow(exceptionToThrow);
  }

  /// Stub a exception while calling the delete function of [mock] when [key] is used.
  static void stubDeleteException(CacheManagerMock mock, String key,
      {Exception exceptionToThrow =
          const CacheException(prefix: 'CacheException', message: '')}) {
    when(mock.delete(key)).thenThrow(exceptionToThrow);
  }

  /// Stub an exception while calling the empty function of [mock] when [key] is used.
  static void stubEmptyException(CacheManagerMock mock,
      {Exception exceptionToThrow =
          const CacheException(prefix: 'CacheException', message: '')}) {
    when(mock.empty()).thenThrow(exceptionToThrow);
  }
}
