// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:notredame/data/models/hello/news.dart';
import 'package:notredame/data/services/signets-api/models/course.dart';
import 'package:notredame/domain/constants/router_paths.dart';
import 'package:notredame/ui/dashboard/widgets/dashboard_view.dart';
import 'package:notredame/ui/ets/events/author/widgets/author_view.dart';
import 'package:notredame/ui/ets/events/news/widgets/news_view.dart';
import 'package:notredame/ui/ets/events/news_details/widgets/news_details_view.dart';
import 'package:notredame/ui/ets/quick_links/security_info/widgets/security_view.dart';
import 'package:notredame/ui/ets/quick_links/widgets/quick_links_view.dart';
import 'package:notredame/ui/ets/widgets/ets_view.dart';
import 'package:notredame/ui/login/widgets/login_view.dart';
import 'package:notredame/ui/more/about/widgets/about_view.dart';
import 'package:notredame/ui/more/contributors/widgets/contributors_view.dart';
import 'package:notredame/ui/more/faq/widgets/faq_view.dart';
import 'package:notredame/ui/more/settings/choose_language/widgets/choose_language_view.dart';
import 'package:notredame/ui/more/settings/widgets/settings_view.dart';
import 'package:notredame/ui/more/widgets/more_view.dart';
import 'package:notredame/ui/not_found/widgets/not_found_view.dart';
import 'package:notredame/ui/outage/widgets/outage_view.dart';
import 'package:notredame/ui/schedule/calendar_controller.dart';
import 'package:notredame/ui/schedule/widgets/schedule_view.dart';
import 'package:notredame/ui/startup/widgets/startup_view.dart';
import 'package:notredame/ui/student/grades/grade_details/widgets/grade_details_view.dart';
import 'package:notredame/ui/student/session_schedule/widgets/session_schedule_view.dart';
import 'package:notredame/ui/student/widgets/student_view.dart';

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
          builder: (_) => FaqView());
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
          pageBuilder: (_, __, ___) => ScheduleView(
              controller: routeSettings.arguments as CalendarController));
    case RouterPaths.defaultSchedule:
      return MaterialPageRoute(
          settings: RouteSettings(
              name: routeSettings.name, arguments: routeSettings.arguments),
          builder: (_) => SessionScheduleView(
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
