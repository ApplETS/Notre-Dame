// FLUTTER / DART / THIRD-PARTIES
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

// APP
import 'package:notredame/app.dart';

// UTILS
import 'package:notredame/core/utils/app_config.dart';

Future<void> main() async {
  final betaAppConfig = AppConfig(appName: 'ÉTSMobile Bêta', flavor: 'beta');
  
  final etsMobile = await initializeApp(betaAppConfig);
  runZonedGuarded(() {
    runApp(
      etsMobile
    );
  }, (error, stackTrace) {
    FirebaseCrashlytics.instance.recordError(error, stackTrace);
  });
}
