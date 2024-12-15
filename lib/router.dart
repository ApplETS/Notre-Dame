// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:notredame/features/app/error/not_found/not_found_view.dart';
import 'package:notredame/features/app/error/outage/outage_view.dart';
import 'package:notredame/domain/constants/router_paths.dart';
import 'package:notredame/data/services/signets-api/models/course.dart';
import 'package:notredame/features/app/startup/startup_view.dart';
import 'package:notredame/features/dashboard/dashboard_view.dart';
import 'package:notredame/features/ets/ets_view.dart';
import 'package:notredame/data/models/hello/news.dart';
import 'package:notredame/features/ets/events/author/author_view.dart';
import 'package:notredame/features/ets/events/news/news-details/news_details_view.dart';
import 'package:notredame/features/ets/events/news/news_view.dart';
import 'package:notredame/features/ets/quick-link/quick_links_view.dart';
import 'package:notredame/features/ets/quick-link/widgets/security-info/security_view.dart';
import 'package:notredame/features/more/about/about_view.dart';
import 'package:notredame/features/more/contributors/contributors_view.dart';
import 'package:notredame/features/more/faq/faq_view.dart';
import 'package:notredame/features/more/more_view.dart';
import 'package:notredame/features/more/settings/choose_language_view.dart';
import 'package:notredame/features/more/settings/settings_view.dart';
import 'package:notredame/features/schedule/schedule_default/schedule_default_view.dart';
import 'package:notredame/features/schedule/schedule_view.dart';
import 'package:notredame/features/student/grades/grade_details/grade_details_view.dart';
import 'package:notredame/features/student/student_view.dart';
import 'package:notredame/features/welcome/login/login_view.dart';

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
          builder: (_) =>
              FaqView(backgroundColor: routeSettings.arguments! as Color));
    case RouterPaths.dashboard:
      return PageRouteBuilder(
          settings: RouteSettings(
              name: routeSettings.name, arguments: routeSettings.arguments),
          transitionsBuilder: (_, animation, ___, child) =>
              rootPagesAnimation(animation, child),
          pageBuilder: (_, __, ___) => const DashboardView());
    case RouterPaths.schedule:
      return PageRouteBuilder(
          settings: RouteSettings(name: routeSettings.name),
          transitionsBuilder: (_, animation, ___, child) =>
              rootPagesAnimation(animation, child),
          pageBuilder: (_, __, ___) => const ScheduleView());
    case RouterPaths.defaultSchedule:
      return MaterialPageRoute(
          settings: RouteSettings(
              name: routeSettings.name, arguments: routeSettings.arguments),
          builder: (_) => ScheduleDefaultView(
              sessionCode: routeSettings.arguments as String?));
    case RouterPaths.student:
      return PageRouteBuilder(
          settings: RouteSettings(name: routeSettings.name),
          transitionsBuilder: (_, animation, ___, child) =>
              rootPagesAnimation(animation, child),
          pageBuilder: (_, __, ___) => StudentView());
    case RouterPaths.gradeDetails:
      return MaterialPageRoute(
          settings: RouteSettings(name: routeSettings.name),
          builder: (context) =>
              GradesDetailsView(course: routeSettings.arguments! as Course));
    case RouterPaths.ets:
      return PageRouteBuilder(
          settings: RouteSettings(name: routeSettings.name),
          transitionsBuilder: (_, animation, ___, child) =>
              rootPagesAnimation(animation, child),
          pageBuilder: (_, __, ___) => ETSView());
    case RouterPaths.usefulLinks:
      return PageRouteBuilder(
          settings: RouteSettings(name: routeSettings.name),
          pageBuilder: (_, __, ___) => QuickLinksView());
    case RouterPaths.news:
      return PageRouteBuilder(
          settings: RouteSettings(name: routeSettings.name),
          pageBuilder: (_, __, ___) => NewsView());
    case RouterPaths.newsDetails:
      return PageRouteBuilder(
          settings: RouteSettings(
              name: routeSettings.name, arguments: routeSettings.arguments),
          pageBuilder: (_, __, ___) =>
              NewsDetailsView(news: routeSettings.arguments! as News));
    case RouterPaths.newsAuthor:
      return PageRouteBuilder(
          settings: RouteSettings(
              name: routeSettings.name, arguments: routeSettings.arguments),
          pageBuilder: (_, __, ___) => AuthorView(
                authorId: routeSettings.arguments! as String,
              ));
    case RouterPaths.security:
      return MaterialPageRoute(
          settings: RouteSettings(name: routeSettings.name),
          builder: (_) => SecurityView());
    case RouterPaths.more:
      return PageRouteBuilder(
          settings: RouteSettings(name: routeSettings.name),
          transitionsBuilder: (_, animation, ___, child) =>
              rootPagesAnimation(animation, child),
          pageBuilder: (_, __, ___) => MoreView());
    case RouterPaths.settings:
      return MaterialPageRoute(
          settings: RouteSettings(name: routeSettings.name),
          builder: (_) => SettingsView());
    case RouterPaths.contributors:
      return MaterialPageRoute(
          settings: RouteSettings(name: routeSettings.name),
          builder: (_) => ContributorsView());
    case RouterPaths.about:
      return MaterialPageRoute(
          settings: RouteSettings(name: routeSettings.name),
          builder: (_) => AboutView());
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

Widget rootPagesAnimation(Animation<double> animation, Widget child) {
  return Align(
      child: FadeTransition(
    opacity: animation,
    child: SizeTransition(
      sizeFactor: CurvedAnimation(
        curve: Curves.easeIn,
        parent: animation,
      ),
      child: child,
    ),
  ));
}
