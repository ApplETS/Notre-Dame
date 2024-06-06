// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:ets_api_clients/clients.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:calendar_view/calendar_view.dart';
import 'package:feature_discovery/feature_discovery.dart';
import 'package:feedback/feedback.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_config/flutter_config.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

// Project imports:
import 'package:notredame/core/constants/custom_feedback_localization.dart';
import 'package:notredame/core/managers/settings_manager.dart';
import 'package:notredame/core/services/analytics_service.dart';
import 'package:notredame/core/services/app_widget_service.dart';
import 'package:notredame/core/services/navigation_service.dart';
import 'package:notredame/core/services/remote_config_service.dart';
import 'package:notredame/firebase_options.dart';
import 'package:notredame/locator.dart';
import 'package:notredame/ui/router.dart';
import 'package:notredame/ui/utils/app_theme.dart';
import 'package:notredame/ui/views/outage_view.dart';
import 'package:notredame/ui/views/startup_view.dart';
import 'package:notredame/ui/widgets/custom_feedback.dart';

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

  // init home widget
  final AppWidgetService appWidgetService = locator<AppWidgetService>();
  await appWidgetService.init();

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
    final RemoteConfigService remoteConfigService =
        locator<RemoteConfigService>();
    final bool outage = remoteConfigService.outage;
    return ChangeNotifierProvider<SettingsManager>(
      create: (_) => settingsManager,
      child: Consumer<SettingsManager>(builder: (context, model, child) {
        return BetterFeedback(
          mode: FeedbackMode.navigate,
          feedbackBuilder: (context, onSubmit, scrollController) =>
              CustomFeedbackForm(
            onSubmit: onSubmit,
            scrollController: scrollController ?? ScrollController(),
          ),
          localizationsDelegates: [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            CustomFeedbackLocalizationsDelegate(),
          ],
          localeOverride: model.locale,
          child: FeatureDiscovery(
            recordStepsInSharedPreferences: false,
            child: CalendarControllerProvider(
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
                ],
                home: outage ? OutageView() : StartUpView(),
                onGenerateRoute: generateRoute,
              ),
            ),
          ),
        );
      }),
    );
  }
}
