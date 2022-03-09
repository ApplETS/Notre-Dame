// FLUTTER / DART / THIRD-PARTIES
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';

/// Manage the analytics of the application
class AnalyticsService {
  static const String _userPropertiesDomainKey = "domain";

  final FirebaseAnalytics _analytics = FirebaseAnalytics();

  final FirebaseCrashlytics _crashlytics = FirebaseCrashlytics.instance;

  FirebaseAnalyticsObserver getAnalyticsObserver() =>
      FirebaseAnalyticsObserver(analytics: _analytics);

  /// Log a error. [prefix] should be the service where the error was triggered.
  Future logError(String prefix, String message,
      [Exception error, StackTrace stackTrace]) async {
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

  Future setUserProperties({@required String userId, String domain}) async {
    await _analytics.setUserId(userId);
    await _analytics.setUserProperty(
        name: _userPropertiesDomainKey, value: domain);
    await _crashlytics.setUserIdentifier(userId);
  }
}
