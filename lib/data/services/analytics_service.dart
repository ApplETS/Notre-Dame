// Package imports:
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

/// Manage the analytics of the application
class AnalyticsService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  final FirebaseCrashlytics _crashlytics = FirebaseCrashlytics.instance;

  FirebaseAnalyticsObserver getAnalyticsObserver() =>
      FirebaseAnalyticsObserver(analytics: _analytics);

  /// Log a error. [prefix] should be the service where the error was triggered.
  Future logError(String prefix, String message,
      [Exception? error, StackTrace? stackTrace]) async {
    final mesTruncated =
        message.length > 100 ? message.substring(0, 99) : message;
    await _analytics.logEvent(
        name: "${prefix}Error", parameters: {'message': mesTruncated});

    if (error != null) {
      await _crashlytics.recordError(error, stackTrace, reason: message);
    }
  }

  /// Log a event. [prefix] should be the service where the event was triggered.
  Future logEvent(String prefix, String message) async {
    final mesTruncated =
        message.length > 100 ? message.substring(0, 99) : message;
    await _analytics
        .logEvent(name: prefix, parameters: {'message': mesTruncated});
  }

  /// Set user properties to identify the user against firebase app.
  Future setUserProperties() async {
    String? userPseudoId = await _analytics.appInstanceId;

    await _analytics.setUserId(id: userPseudoId);

    final appMode = kDebugMode ? "debug" : "release";
    await _analytics.setUserProperty(name: "app_mode", value: appMode);
  }
}
