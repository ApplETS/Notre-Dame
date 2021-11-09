// FLUTTER / DART / THIRD-PARTIES
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

// APP
import 'package:notredame/app.dart';

// UTILS
import 'package:notredame/core/utils/app_config.dart';

Future<void> main() async {
  final prodAppConfig = AppConfig(appName: 'ÉTSMobile Production', flavor: 'prod');
  
  final etsMobile = await initializeApp(prodAppConfig);
  
  runZonedGuarded(() {
    runApp(
      etsMobile
    );
  }, (error, stackTrace) {
    FirebaseCrashlytics.instance.recordError(error, stackTrace);
  });
}
