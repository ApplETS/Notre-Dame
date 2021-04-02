// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:logger/logger.dart';

// OTHER
import 'package:notredame/locator.dart';

// SERVICES
import 'package:notredame/core/services/navigation_service.dart';
import 'package:notredame/core/services/analytics_service.dart';
import 'package:notredame/core/services/rive_animation_service.dart';
import 'package:notredame/core/services/mon_ets_api.dart';
import 'package:notredame/core/services/signets_api.dart';
import 'package:notredame/core/managers/user_repository.dart';
import 'package:notredame/core/managers/cache_manager.dart';
import 'package:notredame/core/services/preferences_service.dart';
import 'package:notredame/core/managers/course_repository.dart';
import 'package:notredame/core/managers/settings_manager.dart';

// MOCKS
import 'mock/managers/cache_manager_mock.dart';
import 'mock/managers/course_repository_mock.dart';
import 'mock/managers/settings_manager_mock.dart';
import 'mock/managers/user_repository_mock.dart';
import 'mock/services/analytics_service_mock.dart';
import 'mock/services/flutter_secure_storage_mock.dart';
import 'mock/services/mon_ets_api_mock.dart';
import 'mock/services/navigation_service_mock.dart';
import 'mock/services/preferences_service_mock.dart';
import 'mock/services/rive_animation_service_mock.dart';
import 'mock/services/signets_api_mock.dart';

/// Return the path of the [goldenName] file.
String goldenFilePath(String goldenName) => "./goldenFiles/$goldenName.png";

/// Unregister the service [T] from GetIt
void unregister<T>() {
  if (locator.isRegistered<T>()) {
    locator.unregister<T>();
  }
}

/// Load the l10n classes. Take the [child] widget to test
Widget localizedWidget(
        {@required Widget child,
        bool useScaffold = true,
        String locale = 'en',
        double textScaleFactor = 0.9}) =>
    RepaintBoundary(
      child: MaterialApp(
        localizationsDelegates: const [
          AppIntl.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        locale: Locale(locale),
        home: useScaffold ? Scaffold(body: child) : child,
      ),
    );

/// Load a mock of the [AnalyticsService]
AnalyticsService setupAnalyticsServiceMock() {
  unregister<AnalyticsService>();
  final service = AnalyticsServiceMock();

  locator.registerSingleton<AnalyticsService>(service);

  return service;
}

/// Load a mock of the [AnalyticsService]
RiveAnimationService setupRiveAnimationServiceMock() {
  unregister<RiveAnimationService>();
  final service = RiveAnimationServiceMock();

  locator.registerSingleton<RiveAnimationService>(service);

  return service;
}

void setupFlutterToastMock() {
  const MethodChannel channel = MethodChannel('PonnamKarthik/fluttertoast');

  channel.setMockMethodCallHandler((MethodCall methodCall) async {
    if(methodCall.method == 'showToast') {
      return true;
    }
  });
}

void tearDownFlutterToastMock() {
  const MethodChannel channel = MethodChannel('PonnamKarthik/fluttertoast');

  channel.setMockMethodCallHandler(null);
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
  return AppIntl.delegate.load(const Locale('en'));
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

/// Load the [Logger]
Logger setupLogger() {
  unregister<Logger>();
  final service = Logger();
  Logger.level = Level.error;

  locator.registerSingleton<Logger>(service);

  return service;
}

/// Load a mock of the [PreferencesService]
PreferencesService setupPreferencesServiceMock() {
  unregister<PreferencesService>();
  final service = PreferencesServiceMock();

  locator.registerSingleton<PreferencesService>(service);

  return service;
}

/// Load a mock of the [SettingsManager]
SettingsManager setupSettingsManagerMock() {
  unregister<SettingsManager>();
  final service = SettingsManagerMock();

  locator.registerSingleton<SettingsManager>(service);

  return service;
}

/// Load a mock of the [CourseRepository]
CourseRepository setupCourseRepositoryMock() {
  unregister<CourseRepository>();
  final service = CourseRepositoryMock();

  locator.registerSingleton<CourseRepository>(service);

  return service;
}
