// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';

/// Navigation service who doesn't use the BuildContext which allow us to call it from anywhere.
class NavigationService {
  GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  GlobalKey<NavigatorState> get navigatorKey => _navigatorKey;

  /// Pop the last route of the navigator if possible
  bool pop() {
    if(_navigatorKey.currentState.canPop()) {
      _navigatorKey.currentState.pop();
      return true;
    }
    return false;
  }

  /// Push a named route ([routeName] onto the navigator.
  Future<dynamic> pushNamed(String routeName, {dynamic arguments}) {
    return _navigatorKey.currentState.pushNamed(routeName, arguments: arguments);
  }

  /// Replace the current route of the navigator by pushing the route named
  /// [routeName] and then disposing the previous route once the new route has
  /// finished animating in.
  Future<dynamic> pushReplacementNamed(String routeName) {
    return _navigatorKey.currentState.pushReplacementNamed(routeName);
  }
}