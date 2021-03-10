// FLUTTER / DART / THIRD-PARTIES
import 'dart:async';
import 'package:feedback/feedback.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:oktoast/oktoast.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:provider/provider.dart';

// ROUTER
import 'package:notredame/ui/router.dart';

// SERVICES
import 'package:notredame/core/services/navigation_service.dart';
import 'package:notredame/core/services/analytics_service.dart';

// UTILS
import 'package:notredame/locator.dart';
import 'package:notredame/ui/utils/app_theme.dart';

// MANAGER
import 'package:notredame/core/managers/settings_manager.dart';

// VIEW
import 'package:notredame/ui/views/startup_view.dart';

Future<void> main() async {
  setupLocator();
  WidgetsFlutterBinding.ensureInitialized();

  /// Manage the settings
  final SettingsManager settingsManager = locator<SettingsManager>();
  await settingsManager.fetchLanguageAndThemeMode();

  runZonedGuarded(() {
    runApp(
      ETSMobile(settingsManager),
    );
  }, (error, stackTrace) {
    FirebaseCrashlytics.instance.recordError(error, stackTrace);
  });
}

class ETSMobile extends StatelessWidget {
  /// Manage the settings
  final SettingsManager settingsManager;

  const ETSMobile(this.settingsManager);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SettingsManager>(
      create: (_) => settingsManager,
      child: Consumer<SettingsManager>(builder: (context, model, child) {
        return BetterFeedback(
          localeOverride: model.locale,
          child: OKToast(
            backgroundColor: Colors.grey,
            duration: const Duration(seconds: 3),
            position: ToastPosition.bottom,
            child: MaterialApp(
              title: 'ÉTS Mobile',
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: model.themeMode,
              localizationsDelegates: const [
                AppIntl.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              locale: model.locale,
              supportedLocales: AppIntl.supportedLocales,
              navigatorKey: locator<NavigationService>().navigatorKey,
              navigatorObservers: [
                locator<AnalyticsService>().getAnalyticsObserver(),
              ],
              home: StartUpView(),
              onGenerateRoute: AppRouter.generateRoute,
            ),
          ),
        );
      }),
    );
  }
}
