// FLUTTER / DART / THIRD-PARTIES
import 'dart:async';
import 'package:feature_discovery/feature_discovery.dart';
import 'package:feedback/feedback.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:flutter_config/flutter_config.dart';

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

  // Initialize firebase
  await Firebase.initializeApp();

  // Manage the settings
  final SettingsManager settingsManager = locator<SettingsManager>();
  await settingsManager.fetchLanguageAndThemeMode();

  if (kDebugMode) {
    FlutterConfig.loadEnvVariables();
  }
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
          child: FeatureDiscovery(
            recordStepsInSharedPreferences: false,
            child: MaterialApp(
              title: 'ÉTS Mobile',
              theme: AppTheme.lightTheme(),
              darkTheme: AppTheme.darkTheme(),
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
              onGenerateRoute: generateRoute,
            ),
          ),
        );
      }),
    );
  }
}
