// FLUTTER / DART / THIRD-PARTIES
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

// APP
import 'package:notredame/app.dart';

// UTILS
import 'package:notredame/core/utils/app_config.dart';

/// Here is the entry point for the production (ca.etsmtl.applets.etsmobile)
/// application.
Future<void> main() async {
  final prodAppConfig =
      AppConfig(appName: 'ÉTSMobile', flavor: 'prod');

  final etsMobile = await initializeApp(prodAppConfig);

  runZonedGuarded(() {
    runApp(etsMobile);
  }, (error, stackTrace) {
    FirebaseCrashlytics.instance.recordError(error, stackTrace);
  });
}
