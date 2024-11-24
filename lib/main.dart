// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:calendar_view/calendar_view.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

// Project imports:
import 'package:notredame/features/app/analytics/analytics_service.dart';
import 'package:notredame/features/app/analytics/remote_config_service.dart';
import 'package:notredame/features/app/error/outage/outage_view.dart';
import 'package:notredame/features/app/integration/firebase_options.dart';
import 'package:notredame/features/app/navigation/navigation_service.dart';
import 'package:notredame/features/app/navigation/router.dart';
import 'package:notredame/features/app/navigation/navigation_history_observer.dart';
import 'package:notredame/features/app/startup/startup_view.dart';
import 'package:notredame/features/ets/events/api-client/hello_api_client.dart';
import 'package:notredame/features/more/settings/settings_manager.dart';
import 'package:notredame/utils/app_theme.dart';
import 'package:notredame/utils/locator.dart';

Future<void> main() async {
  setupLocator();
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final RemoteConfigService remoteConfigService =
      locator<RemoteConfigService>();
  await remoteConfigService.initialize();

  // Manage the settings
  final SettingsManager settingsManager = locator<SettingsManager>();
  await settingsManager.fetchLanguageAndThemeMode();

  // Initialize hello
  final HelloAPIClient helloApiClient = locator<HelloAPIClient>();
  helloApiClient.apiLink = remoteConfigService.helloApiUrl;

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

  const ETSMobile(this.settingsManager, {super.key});

  @override
  Widget build(BuildContext context) {
    addEdgeToEdgeEffect();
    final RemoteConfigService remoteConfigService = locator<RemoteConfigService>();
    final bool outage = remoteConfigService.outage;
    return ChangeNotifierProvider<SettingsManager>(
      create: (_) => settingsManager,
      child: Consumer<SettingsManager>(builder: (context, model, child) {
        return CalendarControllerProvider(
          controller: EventController(),
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
              NavigationHistoryObserver(),
            ],
            home: outage ? OutageView() : StartUpView(),
            onGenerateRoute: generateRoute,
          ),
        );
      }),
    );
  }

  void addEdgeToEdgeEffect() {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarContrastEnforced: false,
      systemNavigationBarIconBrightness: Brightness.dark,
      statusBarColor: Colors.transparent,
      statusBarBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.dark,
    ));
  }
}
