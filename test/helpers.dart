// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// OTHER
import 'package:notredame/locator.dart';
import 'package:notredame/generated/l10n.dart';

// SERVICES
import 'package:notredame/core/services/navigation_service.dart';
import 'package:notredame/core/services/analytics_service.dart';
import 'package:notredame/core/services/mon_ets_api.dart';
import 'package:notredame/core/services/signets_api.dart';
import 'package:notredame/core/managers/user_repository.dart';
import 'package:notredame/core/managers/cache_manager.dart';

// MOCKS
import 'mock/managers/cache_manager_mock.dart';
import 'mock/managers/user_repository_mock.dart';
import 'mock/services/analytics_service_mock.dart';
import 'mock/services/flutter_secure_storage_mock.dart';
import 'mock/services/mon_ets_api_mock.dart';
import 'mock/services/navigation_service_mock.dart';
import 'mock/services/signets_api_mock.dart';

/// Unregister the service [T] from GetIt
void unregister<T>() {
  if (locator.isRegistered<T>()) {
    locator.unregister<T>();
  }
}

/// Load the l10n classes. Take the [child] widget to test
Widget localizedWidget({@required Widget child, String locale = 'en'}) =>
    MaterialApp(
      localizationsDelegates: const [
        AppIntl.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      locale: Locale(locale),
      home: Scaffold(body: child),
    );

/// Load a mock of the [AnalyticsService]
AnalyticsService setupAnalyticsServiceMock() {
  unregister<AnalyticsService>();
  final service = AnalyticsServiceMock();

  locator.registerSingleton<AnalyticsService>(service);

  return service;
}

/// Load a mock of the [NavigationService]
NavigationService setupNavigationServiceMock() {
  unregister<NavigationService>();
  final service = NavigationServiceMock();

  locator.registerSingleton<NavigationService>(service);

  return service;
}

/// Load a mock of the [MonETSApi]
MonETSApi setupMonETSApiMock() {
  unregister<MonETSApi>();
  final service = MonETSApiMock();

  locator.registerSingleton<MonETSApi>(service);

  return service;
}

/// Load a mock of the [FlutterSecureStorage]
FlutterSecureStorage setupFlutterSecureStorageMock() {
  unregister<FlutterSecureStorage>();
  final service = FlutterSecureStorageMock();

  locator.registerSingleton<FlutterSecureStorage>(service);

  return service;
}

/// Load a mock of the [UserRepository]
UserRepository setupUserRepositoryMock() {
  unregister<UserRepository>();
  final service = UserRepositoryMock();

  locator.registerSingleton<UserRepository>(service);

  return service;
}

/// Load the Internationalization class
Future<AppIntl> setupAppIntl() async {
  return AppIntl.load(const Locale('en'));
}

/// Load a mock of the [SignetsApi]
SignetsApi setupSignetsApiMock() {
  unregister<SignetsApi>();
  final service = SignetsApiMock();

  locator.registerSingleton<SignetsApi>(service);

  return service;
}

/// Load a mock of the [CacheManager]
CacheManager setupCacheManagerMock() {
  unregister<CacheManager>();
  final service = CacheManagerMock();

  locator.registerSingleton<CacheManager>(service);

  return service;
}
