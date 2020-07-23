// FLUTTER / DART / THIRD-PARTIES
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';

/// Manage the analytics of the application
class AnalyticsService {
  static const String _userPropertiesDomainKey = "domain";

  final FirebaseAnalytics _analytics = FirebaseAnalytics();

  FirebaseAnalyticsObserver getAnalyticsOberser() => FirebaseAnalyticsObserver(analytics: _analytics);

  /// Log a error. [prefix] should be the service where the error was triggered.
  Future logError(String prefix, String message) async {
    await _analytics.logEvent(name: prefix, parameters: {'message': message});
  }

  Future setUserProperties({@required String userId, String domain}) async {
    await _analytics.setUserId(userId);
    await _analytics.setUserProperty(name: _userPropertiesDomainKey, value: domain);
  }
}