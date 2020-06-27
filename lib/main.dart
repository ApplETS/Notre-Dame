// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';

// ROUTER
import 'package:notredame/core/constants/router_paths.dart';
import 'package:notredame/ui/router.dart';

// SERVICES
import 'package:notredame/core/services/navigation_service.dart';
import 'package:notredame/core/services/analytics_service.dart';

// UTILS
import 'package:notredame/locator.dart';
import 'package:notredame/ui/utils/app_theme.dart';

void main() {
  setupLocator();

  runApp(ETSMobile());
}

class ETSMobile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ÉTS Mobile',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      navigatorKey: locator<NavigationService>().navigatorKey,
      navigatorObservers: [
        locator<AnalyticsService>().getAnalyticsOberser(),
      ],
      initialRoute: RouterPaths.login,
      onGenerateRoute: Router.generateRoute,
    );
  }
}
