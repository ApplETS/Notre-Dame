// FLUTTER / DART / THIRD-PARTIES
import 'package:mockito/mockito.dart';

// MANAGER
import 'package:notredame/core/managers/quick_link_repository.dart';

// MODELS
import 'package:notredame/core/models/quick_link.dart';
import 'package:notredame/core/models/quick_link_data.dart';

// UTILS
import 'package:ets_api_clients/exceptions.dart';

class QuickLinkRepositoryMock extends Mock implements QuickLinkRepository {
  /// Stub the function [getQuickLinkDataFromCache] of [mock] when called will return [toReturn].
  static void stubGetQuickLinkDataFromCache(QuickLinkRepositoryMock mock,
      {List<QuickLinkData> toReturn = const []}) {
    when(mock.getQuickLinkDataFromCache()).thenAnswer((_) async => toReturn);
  }

  /// Stub the function [getQuickLinkDataFromCache] of [mock] when called will throw [toThrow].
  static void stubGetQuickLinkDataFromCacheException(
      QuickLinkRepositoryMock mock,
      {Exception toThrow = const ApiException(prefix: 'ApiException')}) {
    when(mock.getQuickLinkDataFromCache()).thenAnswer((_) =>
        Future.delayed(const Duration(milliseconds: 50))
            .then((value) => throw toThrow));
  }

  /// Stub the function [getDefaultQuickLinks] of [mock] when called will return [toReturn].
  static void stubGetDefaultQuickLinks(QuickLinkRepositoryMock mock,
      {List<QuickLink> toReturn = const []}) {
    when(mock.getDefaultQuickLinks(any)).thenAnswer((_) => toReturn);
  }

  /// Stub the function [updateQuickLinkDataToCache] of [mock] when called will complete without errors.
  static void stubUpdateQuickLinkDataToCache(QuickLinkRepositoryMock mock) {
    when(mock.updateQuickLinkDataToCache(any)).thenAnswer((_) async => {});
  }

  /// Stub the function [updateQuickLinkDataToCache] of [mock] when called will throw [toThrow].
  static void stubUpdateQuickLinkDataToCacheException(
      QuickLinkRepositoryMock mock,
      {Exception toThrow = const ApiException(prefix: 'ApiException')}) {
    when(mock.updateQuickLinkDataToCache(any)).thenAnswer((_) =>
        Future.delayed(const Duration(milliseconds: 50))
            .then((value) => throw toThrow));
  }
}
