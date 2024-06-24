// Package imports:
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

// Project imports:
import 'package:notredame/features/app/repository/quick_link_repository.dart';
import 'package:notredame/features/ets/quick-link/models/quick_link.dart';
import 'package:notredame/features/ets/quick-link/models/quick_link_data.dart';
import 'package:notredame/utils/api_exception.dart';
import 'quick_links_repository_mock.mocks.dart';

@GenerateNiceMocks([MockSpec<QuickLinkRepository>()])
class QuickLinkRepositoryMock extends MockQuickLinkRepository {
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
