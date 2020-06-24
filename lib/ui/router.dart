// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';

// ROUTES
import 'package:notredame/core/constants/router_paths.dart';

class Router {
  // ignore: missing_return
  static Route<dynamic> generateRoute(RouteSettings routeSettings) {

    switch(routeSettings.name) {
      case RouterPaths.login:
        return MaterialPageRoute(
            builder: (_) => const Scaffold(
              body: Center(child: Text("Login view")),
            )
        );
      case RouterPaths.dashboard:
        break;
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text("Oups! Page ${routeSettings.name} not found!")),
          )
        );
    }
  }
}