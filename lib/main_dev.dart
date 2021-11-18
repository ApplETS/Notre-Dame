// FLUTTER / DART / THIRD-PARTIES
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

// APP
import 'package:notredame/app.dart';

// UTILS
import 'package:notredame/core/utils/app_config.dart';

/// Here is the entry point for the dev env (ca.etsmtl.applets.etsmobile.dev)
/// application.
Future<void> main() async {
  final devAppConfig =
      AppConfig(appName: 'ÉTSMobile Dev', flavor: 'dev');

  final etsMobile = await initializeApp(devAppConfig);

  runZonedGuarded(() {
    runApp(etsMobile);
  }, (error, stackTrace) {
    FirebaseCrashlytics.instance.recordError(error, stackTrace);
  });
}
