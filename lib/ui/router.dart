// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';

// ROUTES
import 'package:notredame/core/constants/router_paths.dart';

// VIEWS
import 'package:notredame/ui/views/login_view.dart';
import 'package:notredame/ui/views/not_found_view.dart';
import 'package:notredame/ui/views/quick_links_view.dart';
import 'package:notredame/ui/views/schedule_view.dart';
import 'package:notredame/ui/views/security_view.dart';
import 'package:notredame/ui/views/student_view.dart';

class AppRouter {
  // ignore: missing_return
  static Route<dynamic> generateRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case RouterPaths.login:
        return MaterialPageRoute(
            settings: RouteSettings(name: routeSettings.name),
            builder: (_) => LoginView());
      case RouterPaths.schedule:
        return PageRouteBuilder(
            settings: RouteSettings(name: routeSettings.name),
            pageBuilder: (_, __, ___) => const ScheduleView());
      case RouterPaths.student:
        return PageRouteBuilder(
            settings: RouteSettings(name: routeSettings.name),
            pageBuilder: (_, __, ___) => StudentView());
      case RouterPaths.ets:
        return PageRouteBuilder(
            settings: RouteSettings(name: routeSettings.name),
            pageBuilder: (_, __, ___) => QuickLinksView());
      case RouterPaths.security:
        return PageRouteBuilder(
            settings: RouteSettings(name: routeSettings.name),
            pageBuilder: (_, __, ___) => SecurityView());
      default:
        return PageRouteBuilder(
            settings: RouteSettings(name: routeSettings.name),
            pageBuilder: (_, __, ___) => NotFoundView());
    }
  }
}
