// Flutter imports:
import 'package:flutter/widgets.dart';

class NavigationHistoryObserver extends NavigatorObserver {
  final List<Route<dynamic>?> _history = <Route<dynamic>?>[];

  /// Gets a clone of the navigation history
  List<Route<dynamic>> get history => List<Route<dynamic>>.from(_history);

  /// Implements a singleton pattern for NavigationHistoryObserver.
  static final NavigationHistoryObserver _singleton = NavigationHistoryObserver._internal();
  factory NavigationHistoryObserver() {
    return _singleton;
  }
  NavigationHistoryObserver._internal();

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _history.removeLast();
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _history.add(route);
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _history.remove(route);
  }
}
