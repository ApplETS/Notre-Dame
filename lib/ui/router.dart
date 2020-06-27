// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';

// ROUTES
import 'package:notredame/core/constants/router_paths.dart';
import 'package:notredame/ui/views/login_view.dart';

import '../locator.dart';

class Router {
  // ignore: missing_return
  static Route<dynamic> generateRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case RouterPaths.login:
        return MaterialPageRoute(
            settings: RouteSettings(name: routeSettings.name),
            builder: (_) => LoginView());
      default:
        return MaterialPageRoute(
            settings: RouteSettings(name: routeSettings.name),
            builder: (_) => Scaffold(
                  body: Center(
                      child:
                          Text("Oups! Page ${routeSettings.name} not found!")),
                ));
    }
  }
}
