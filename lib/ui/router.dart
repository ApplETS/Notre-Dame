// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';

// MODELS
import 'package:notredame/core/models/quick_link.dart';

// ROUTES
import 'package:notredame/core/constants/router_paths.dart';

// MODELS
import 'package:ets_api_clients/models.dart';
import 'package:notredame/ui/views/feedback_view.dart';

// VIEWS
import 'package:notredame/ui/views/login_view.dart';
import 'package:notredame/ui/views/faq_view.dart';
import 'package:notredame/ui/views/not_found_view.dart';
import 'package:notredame/ui/views/more_view.dart';
import 'package:notredame/ui/views/outage_view.dart';
import 'package:notredame/ui/views/quick_links_view.dart';
import 'package:notredame/ui/views/schedule_view.dart';
import 'package:notredame/ui/views/security_view.dart';
import 'package:notredame/ui/views/settings_view.dart';
import 'package:notredame/ui/views/startup_view.dart';
import 'package:notredame/ui/views/student_view.dart';
import 'package:notredame/ui/views/about_view.dart';
import 'package:notredame/ui/views/contributors_view.dart';
import 'package:notredame/ui/views/choose_language_view.dart';
import 'package:notredame/ui/views/dashboard_view.dart';
import 'package:notredame/ui/views/grade_details_view.dart';

// WIDGETS
import 'package:notredame/ui/widgets/link_web_view.dart';

// CONSTANTS
import 'package:notredame/core/constants/update_code.dart';

Route<dynamic> generateRoute(RouteSettings routeSettings) {
  switch (routeSettings.name) {
    case RouterPaths.startup:
      return PageRouteBuilder(
          settings: RouteSettings(name: routeSettings.name),
          pageBuilder: (_, __, ___) => StartUpView());
    case RouterPaths.serviceOutage:
      return MaterialPageRoute(
          settings: RouteSettings(name: routeSettings.name),
          builder: (_) => OutageView());
    case RouterPaths.login:
      return MaterialPageRoute(
          settings: RouteSettings(name: routeSettings.name),
          builder: (_) => LoginView());
    case RouterPaths.faq:
      return MaterialPageRoute(
          settings: RouteSettings(name: routeSettings.name),
          builder: (_) => FaqView(backgroundColor: routeSettings.arguments as Color));
    case RouterPaths.dashboard:
      final code = (routeSettings.arguments as UpdateCode) ?? UpdateCode.none;
      return PageRouteBuilder(
          settings: RouteSettings(
              name: routeSettings.name, arguments: routeSettings.arguments),
          pageBuilder: (_, __, ___) => DashboardView(updateCode: code));
    case RouterPaths.schedule:
      return PageRouteBuilder(
          settings: RouteSettings(name: routeSettings.name),
          pageBuilder: (_, __, ___) => const ScheduleView());
    case RouterPaths.student:
      return PageRouteBuilder(
          settings: RouteSettings(name: routeSettings.name),
          pageBuilder: (_, __, ___) => StudentView());
    case RouterPaths.gradeDetails:
      return PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 600),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0.0, 1.0);
            const end = Offset.zero;
            const curve = Curves.ease;

            final tween =
                Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
          settings: RouteSettings(name: routeSettings.name),
          pageBuilder: (_, __, ___) =>
              GradesDetailsView(course: routeSettings.arguments as Course));
    case RouterPaths.ets:
      return PageRouteBuilder(
          settings: RouteSettings(name: routeSettings.name),
          pageBuilder: (_, __, ___) => QuickLinksView());
    case RouterPaths.webView:
      return PageRouteBuilder(
          pageBuilder: (_, __, ___) =>
              LinkWebView(routeSettings.arguments as QuickLink));
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
    case RouterPaths.feedback:
      return PageRouteBuilder(
          settings: RouteSettings(name: routeSettings.name),
          pageBuilder: (_, __, ___) => FeedbackView());
    case RouterPaths.about:
      return PageRouteBuilder(
          transitionDuration: const Duration(seconds: 1),
          settings: RouteSettings(name: routeSettings.name),
          pageBuilder: (_, __, ___) => AboutView());
    case RouterPaths.chooseLanguage:
      return MaterialPageRoute(
          settings: RouteSettings(name: routeSettings.name),
          builder: (_) => ChooseLanguageView());
    default:
      return PageRouteBuilder(
          settings: RouteSettings(name: routeSettings.name),
          pageBuilder: (_, __, ___) =>
              NotFoundView(pageName: routeSettings.name));
  }
}
