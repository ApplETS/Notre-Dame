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

import 'core/managers/settings_manager.dart';

void main() {
  setupLocator();

  runApp(ETSMobile());
}

class ETSMobile extends StatefulWidget {
  @override
  _ETSMobileState createState() => _ETSMobileState();
}

class _ETSMobileState extends State<ETSMobile> {
  /// Manage the settings
  final SettingsManager _settingsManager = locator<SettingsManager>();

  @override
  void initState() {
    super.initState();
    _settingsManager.addListener(() {
      setState(() {});
    });
  }

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
        themeMode: _settingsManager.themeMode,
        localizationsDelegates: const [
          AppIntl.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        locale: _settingsManager?.locale,
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
