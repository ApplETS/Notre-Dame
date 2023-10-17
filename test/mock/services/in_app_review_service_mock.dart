// Package imports:
import 'package:mockito/mockito.dart';

// Project imports:
import 'package:notredame/core/services/in_app_review_service.dart';

/// Mock for the [AnalyticsService]
class InAppReviewServiceMock extends Mock implements InAppReviewService {
  /// Stub the answer of [isAvailable]
  static void stubIsAvailable(InAppReviewServiceMock mock,
      {bool toReturn = true}) {
    when(mock.isAvailable()).thenAnswer((_) async => toReturn);
  }

  /// Stub the answer of [requestReview]
  static void stubRequestReview(InAppReviewServiceMock mock,
      {bool toReturn = true}) {
    when(mock.requestReview()).thenAnswer((_) async => toReturn);
  }
}
