// Package imports:
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';

// Project imports:
import 'package:notredame/core/services/analytics_service.dart';
import 'package:notredame/locator.dart';

/// Manage the analytics of the application
class FirebaseStorageService {
  static const String tag = "FirebaseStorageService";
  static const String _defaultPath = "app-images";

  FirebaseStorage firebaseStorage;

  final AnalyticsService _analyticsService = locator<AnalyticsService>();

  /// Reference to the app images folder in default cloud storage
  Reference _appImageReferences;

  @visibleForTesting
  Reference get appImageReferences => _appImageReferences;

  FirebaseStorageService({this.firebaseStorage}) {
    firebaseStorage ??= FirebaseStorage.instance;
    _appImageReferences = firebaseStorage.ref(_defaultPath);
  }

  /// Get the url of the image from the firebase storage
  /// [fileName] is the fileName of the image in the firebase storage
  Future<String> getImageUrl(String fileName) async {
    try {
      _appImageReferences ??= firebaseStorage.ref(_defaultPath);

      final child = _appImageReferences.child(fileName);
      final url = await child.getDownloadURL();
      return url;
    } on Exception catch (e) {
      _analyticsService.logError(tag, "Error while getting the image url", e);
      rethrow;
    }
  }
}
