// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';

// ROUTER
import 'package:notredame/core/constants/router_paths.dart';
import 'package:notredame/ui/router.dart';
import 'package:notredame/core/services/navigation_service.dart';

// OTHER
import 'package:notredame/locator.dart';
import 'core/services/analytics_service.dart';

void main() {
  setupLocator();

  runApp(ETSMobile());
}

class ETSMobile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ÉTS Mobile',
      navigatorKey: locator<NavigationService>().navigatorKey,
      navigatorObservers: [
        locator<AnalyticsService>().getAnalyticsOberser(),
      ],
      initialRoute: RouterPaths.login,
      onGenerateRoute: Router.generateRoute,
    );
  }
}
