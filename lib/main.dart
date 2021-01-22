// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// ROUTER
import 'package:notredame/ui/router.dart';

// SERVICES
import 'package:notredame/core/services/navigation_service.dart';
import 'package:notredame/core/services/analytics_service.dart';

// UTILS
import 'package:notredame/locator.dart';
import 'package:notredame/generated/l10n.dart';
import 'package:notredame/ui/utils/app_theme.dart';

// VIEW
import 'package:notredame/ui/views/startup_view.dart';
import 'package:oktoast/oktoast.dart';

void main() {
  setupLocator();

  runApp(ETSMobile());
}

class ETSMobile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return OKToast(
      backgroundColor: Colors.grey,
      duration: const Duration(seconds: 3),
      position: ToastPosition.bottom,
      child: MaterialApp(
        title: 'ÉTS Mobile',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        localizationsDelegates: const [
          AppIntl.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppIntl.delegate.supportedLocales,
        navigatorKey: locator<NavigationService>().navigatorKey,
        navigatorObservers: [
          locator<AnalyticsService>().getAnalyticsObserver(),
        ],
        home: StartUpView(),
        onGenerateRoute: AppRouter.generateRoute,
      ),
    );
  }
}
