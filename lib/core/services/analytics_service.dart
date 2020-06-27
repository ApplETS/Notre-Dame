// FLUTTER / DART / THIRD-PARTIES
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';

/// Manage the analytics of the application
class AnalyticsService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics();

  FirebaseAnalyticsObserver getAnalyticsOberser() => FirebaseAnalyticsObserver(analytics: _analytics);
}