// FLUTTER / DART / THIRD-PARTIES
import 'package:in_app_review/in_app_review.dart';

/// Manage the analytics of the application
class InAppReviewService {
  final InAppReview _inAppReview = InAppReview.instance;

  /// Checks if the device is able to show a review dialog.
  /// On Android the Google Play Store must be installed and the device must be
  /// running **Android 5 Lollipop(API 21)** or higher.
  Future<bool> isAvailable() => _inAppReview.isAvailable();

  /// Attempts to show the review dialog. It's recommended to first check if
  /// the device supports this feature via [isAvailable].
  Future<void> requestReview() => _inAppReview.requestReview();

  /// Opens the Play Store on Android, the App Store with a review
  Future<void> openStoreListing({
    String appStoreId,
    String microsoftStoreId,
  }) =>
      _inAppReview.openStoreListing(
        appStoreId: appStoreId,
        microsoftStoreId: microsoftStoreId,
      );
}
