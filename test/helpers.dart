// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// OTHER
import 'package:notredame/locator.dart';
import 'package:notredame/generated/l10n.dart';

// SERVICES
import 'package:notredame/core/services/navigation_service.dart';

// MOCKS
import 'mock/services/navigation_service_mock.dart';

NavigationService setupNavigationServiceMock() {
  final service = NavigationServiceMock();
  
  locator.registerSingleton<NavigationService>(service);

  return service;
}

Widget localizedWidget({Widget child, String locale = 'en'}) => MaterialApp(
  localizationsDelegates: [
    AppIntl.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  locale: Locale(locale),
  home: child,
);