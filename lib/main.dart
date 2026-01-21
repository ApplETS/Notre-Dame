// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:calendar_view/calendar_view.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

// Project imports:
import 'package:notredame/data/models/firebase_options.dart';
import 'package:notredame/data/repositories/settings_repository.dart';
import 'package:notredame/data/services/analytics_service.dart';
import 'package:notredame/data/services/hello/hello_service.dart';
import 'package:notredame/data/services/navigation_service.dart';
import 'package:notredame/data/services/remote_config_service.dart';
import 'package:notredame/l10n/app_localizations.dart';
import 'package:notredame/locator.dart';
import 'package:notredame/router.dart';
import 'package:notredame/ui/core/themes/app_theme.dart';
import 'package:notredame/ui/outage/widgets/outage_view.dart';
import 'package:notredame/ui/startup/widgets/startup_view.dart';

Future<void> main() async {
  setupLocator();

  runZonedGuarded(
        () async {
      WidgetsFlutterBinding.ensureInitialized();

      // Initialize firebase
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
      final analyticsService = locator<AnalyticsService>();
      await analyticsService.setUserProperties();

      final RemoteConfigService remoteConfigService = locator<RemoteConfigService>();
      await remoteConfigService.initialize();

      // Manage the settings
      final SettingsRepository settingsManager = locator<SettingsRepository>();
      await settingsManager.fetchLanguageAndThemeMode();

      // Initialize hello
      final HelloService helloApiClient = locator<HelloService>();
      helloApiClient.apiLink = remoteConfigService.helloApiUrl;

      runApp(ETSMobile(settingsManager));
    },
        (error, stackTrace) {
      FirebaseCrashlytics.instance.recordError(error, stackTrace);
    },
  );
}

class ETSMobile extends StatelessWidget {
  /// Manage the settings
  final SettingsRepository settingsManager;

  const ETSMobile(this.settingsManager, {super.key});

  @override
  Widget build(BuildContext context) {
    final RemoteConfigService remoteConfigService = locator<RemoteConfigService>();
    final bool outage = remoteConfigService.outage;
    return ChangeNotifierProvider<SettingsRepository>(
      create: (_) => settingsManager,
      child: Consumer<SettingsRepository>(
        builder: (context, model, child) {
          return CalendarControllerProvider(
            controller: EventController(),
            child: MaterialApp(
              title: 'ÉTS Mobile',
              theme: AppTheme.light,
              darkTheme: AppTheme.dark,
              themeMode: model.themeMode,
              debugShowCheckedModeBanner: false,
              localizationsDelegates: const [
                AppIntl.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              locale: model.locale,
              supportedLocales: AppIntl.supportedLocales,
              navigatorKey: locator<NavigationService>().navigatorKey,
              navigatorObservers: [locator<AnalyticsService>().getAnalyticsObserver()],
              home: outage ? OutageView() : StartUpView(),
              onGenerateRoute: generateRoute,
            ),
          );
        },
      ),
    );
  }
}