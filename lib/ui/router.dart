// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';

// ROUTES
import 'package:notredame/core/constants/router_paths.dart';
import 'package:notredame/ui/views/grade_details_view.dart';

// VIEWS
import 'package:notredame/ui/views/login_view.dart';
import 'package:notredame/ui/views/more_view.dart';
import 'package:notredame/ui/views/quick_links_view.dart';
import 'package:notredame/ui/views/schedule_view.dart';
import 'package:notredame/ui/views/security_view.dart';
import 'package:notredame/ui/views/settings_view.dart';
import 'package:notredame/ui/views/student_view.dart';
import 'package:notredame/ui/views/about_view.dart';
import 'package:notredame/ui/views/contributors_view.dart';

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
      case RouterPaths.grade_details:
        return PageRouteBuilder(
            settings: RouteSettings(name: routeSettings.name),
            pageBuilder: (_, __, ___) => GradesDetailsView());
      case RouterPaths.ets:
        return PageRouteBuilder(
            settings: RouteSettings(name: routeSettings.name),
            pageBuilder: (_, __, ___) => QuickLinksView());
      case RouterPaths.security:
        return PageRouteBuilder(
            settings: RouteSettings(name: routeSettings.name),
            pageBuilder: (_, __, ___) => SecurityView());
      case RouterPaths.more:
        return PageRouteBuilder(
            settings: RouteSettings(name: routeSettings.name),
            pageBuilder: (_, __, ___) => MoreView());
      case RouterPaths.settings:
        return PageRouteBuilder(
            settings: RouteSettings(name: routeSettings.name),
            pageBuilder: (_, __, ___) => SettingsView());
      case RouterPaths.contributors:
        return PageRouteBuilder(
            settings: RouteSettings(name: routeSettings.name),
            pageBuilder: (_, __, ___) => ContributorsView());
      case RouterPaths.about:
        return PageRouteBuilder(
            transitionDuration: const Duration(seconds: 1),
            settings: RouteSettings(name: routeSettings.name),
            pageBuilder: (_, __, ___) => AboutView());
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
