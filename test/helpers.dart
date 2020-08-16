// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:notredame/core/services/navigation_service.dart';
import 'package:notredame/core/viewmodels/quick_links_viewmodel.dart';
import 'package:notredame/generated/l10n.dart';
import 'package:notredame/locator.dart';

import 'mock/services/navigation_service_mock.dart';

NavigationService setupNavigationServiceMock() {
  unregister<NavigationService>();
  final service = NavigationServiceMock();

  locator.registerSingleton<NavigationService>(service);

  return service;
}

QuickLinks setupQuickLinksMock() {
  unregister<QuickLinks>();
  final quickLink = QuickLinks(image: 'assets/github.png', name: 'test');

  return quickLink;
}

void unregister<T>() {
  if (locator.isRegistered<T>()) {
    locator.unregister<T>();
  }
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
