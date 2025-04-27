// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:notredame/data/models/hello/news.dart';
import 'package:notredame/data/services/signets-api/models/course.dart';
import 'package:notredame/domain/constants/router_paths.dart';
import 'package:notredame/ui/choose_language/widgets/choose_language_view.dart';
import 'package:notredame/ui/core/ui/root_view.dart';
import 'package:notredame/ui/ets/events/author/widgets/author_view.dart';
import 'package:notredame/ui/ets/events/news/widgets/news_view.dart';
import 'package:notredame/ui/ets/events/news_details/widgets/news_details_view.dart';
import 'package:notredame/ui/ets/quick_links/security_info/widgets/security_view.dart';
import 'package:notredame/ui/more/about/widgets/about_view.dart';
import 'package:notredame/ui/more/contributors/widgets/contributors_view.dart';
import 'package:notredame/ui/more/faq/widgets/faq_view.dart';
import 'package:notredame/ui/more/settings/widgets/settings_view.dart';
import 'package:notredame/ui/not_found/widgets/not_found_view.dart';
import 'package:notredame/ui/outage/widgets/outage_view.dart';
import 'package:notredame/ui/startup/widgets/startup_view.dart';
import 'package:notredame/ui/student/grades/grade_details/widgets/grade_details_view.dart';
import 'package:notredame/ui/student/session_schedule/widgets/session_schedule_view.dart';

Route<dynamic> generateRoute(RouteSettings routeSettings) {
  switch (routeSettings.name) {
    case RouterPaths.startup:
      return PageRouteBuilder(
          settings: RouteSettings(name: routeSettings.name), pageBuilder: (_, __, ___) => StartUpView());
    case RouterPaths.serviceOutage:
      return MaterialPageRoute(settings: RouteSettings(name: routeSettings.name), builder: (_) => OutageView());
    case RouterPaths.faq:
      return MaterialPageRoute(settings: RouteSettings(name: routeSettings.name), builder: (_) => FaqView());
    case RouterPaths.root:
      return PageRouteBuilder(
          settings: RouteSettings(name: routeSettings.name, arguments: routeSettings.arguments),
          transitionsBuilder: (_, animation, ___, child) => rootPagesAnimation(animation, child),
          pageBuilder: (_, __, ___) => RootView());
    case RouterPaths.defaultSchedule:
      return MaterialPageRoute(
          settings: RouteSettings(name: routeSettings.name, arguments: routeSettings.arguments),
          builder: (_) => SessionScheduleView(sessionCode: routeSettings.arguments as String?));
    case RouterPaths.gradeDetails:
      return MaterialPageRoute(
          settings: RouteSettings(name: routeSettings.name),
          builder: (context) => GradesDetailsView(course: routeSettings.arguments! as Course));
    case RouterPaths.news:
      return PageRouteBuilder(
          settings: RouteSettings(name: routeSettings.name), pageBuilder: (_, __, ___) => NewsView());
    case RouterPaths.newsDetails:
      return PageRouteBuilder(
          settings: RouteSettings(name: routeSettings.name, arguments: routeSettings.arguments),
          pageBuilder: (_, __, ___) => NewsDetailsView(news: routeSettings.arguments! as News));
    case RouterPaths.newsAuthor:
      return PageRouteBuilder(
          settings: RouteSettings(name: routeSettings.name, arguments: routeSettings.arguments),
          pageBuilder: (_, __, ___) => AuthorView(
                authorId: routeSettings.arguments! as String,
              ));
    case RouterPaths.security:
      return MaterialPageRoute(settings: RouteSettings(name: routeSettings.name), builder: (_) => SecurityView());
    case RouterPaths.settings:
      return MaterialPageRoute(settings: RouteSettings(name: routeSettings.name), builder: (_) => SettingsView());
    case RouterPaths.contributors:
      return MaterialPageRoute(settings: RouteSettings(name: routeSettings.name), builder: (_) => ContributorsView());
    case RouterPaths.about:
      return MaterialPageRoute(settings: RouteSettings(name: routeSettings.name), builder: (_) => AboutView());
    case RouterPaths.chooseLanguage:
      return MaterialPageRoute(settings: RouteSettings(name: routeSettings.name), builder: (_) => ChooseLanguageView());
    default:
      return PageRouteBuilder(
          settings: RouteSettings(name: routeSettings.name),
          pageBuilder: (_, __, ___) => NotFoundView(pageName: routeSettings.name));
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
