// Package imports:
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

// Project imports:
import 'package:notredame/core/services/in_app_review_service.dart';

import 'in_app_review_service_mock.mocks.dart';

/// Mock for the [AnalyticsService]
@GenerateNiceMocks([MockSpec<InAppReviewService>()])
class InAppReviewServiceMock extends MockInAppReviewService {
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
