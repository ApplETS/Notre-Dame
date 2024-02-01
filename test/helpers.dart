// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:ets_api_clients/clients.dart';
import 'package:ets_api_clients/testing.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';

// Project imports:
import 'package:notredame/core/managers/cache_manager.dart';
import 'package:notredame/core/managers/course_repository.dart';
import 'package:notredame/core/managers/quick_link_repository.dart';
import 'package:notredame/core/managers/settings_manager.dart';
import 'package:notredame/core/managers/user_repository.dart';
import 'package:notredame/core/services/analytics_service.dart';
import 'package:notredame/core/services/app_widget_service.dart';
import 'package:notredame/core/services/github_api.dart';
import 'package:notredame/core/services/in_app_review_service.dart';
import 'package:notredame/core/services/internal_info_service.dart';
import 'package:notredame/core/services/launch_url_service.dart';
import 'package:notredame/core/services/navigation_service.dart';
import 'package:notredame/core/services/networking_service.dart';
import 'package:notredame/core/services/preferences_service.dart';
import 'package:notredame/core/services/remote_config_service.dart';
import 'package:notredame/core/services/rive_animation_service.dart';
import 'package:notredame/core/services/siren_flutter_service.dart';
import 'package:notredame/locator.dart';
import 'mock/managers/cache_manager_mock.dart';
import 'mock/managers/course_repository_mock.dart';
import 'mock/managers/quick_links_repository_mock.dart';
import 'mock/managers/settings_manager_mock.dart';
import 'mock/managers/user_repository_mock.dart';
import 'mock/services/analytics_service_mock.dart';
import 'mock/services/app_widget_service_mock.dart';
import 'mock/services/flutter_secure_storage_mock.dart';
import 'mock/services/github_api_mock.dart';
import 'mock/services/in_app_review_service_mock.dart';
import 'mock/services/internal_info_service_mock.dart';
import 'mock/services/launch_url_service_mock.dart';
import 'mock/services/navigation_service_mock.dart';
import 'mock/services/networking_service_mock.dart';
import 'mock/services/preferences_service_mock.dart';
import 'mock/services/remote_config_service_mock.dart';
import 'mock/services/rive_animation_service_mock.dart';
import 'mock/services/siren_flutter_service_mock.dart';

/// Return the path of the [goldenName] file.
String goldenFilePath(String goldenName) => "./goldenFiles/$goldenName.png";

/// Unregister the service [T] from GetIt
void unregister<T extends Object>() {
  if (locator.isRegistered<T>()) {
    locator.unregister<T>();
  }
}

/// Load the l10n classes. Take the [child] widget to test
Widget localizedWidget(
        {required Widget child,
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

/// Load a mock of the [SignetsAPIClient]
SignetsAPIClient setupSignetsApiMock() {
  unregister<SignetsAPIClient>();
  final service = SignetsAPIClientMock();

  locator.registerSingleton<SignetsAPIClient>(service);

  return service;
}

/// Load a mock of the [InAppReviewService]
InAppReviewService setupInAppReviewServiceMock() {
  unregister<InAppReviewService>();
  final service = InAppReviewServiceMock();

  locator.registerSingleton<InAppReviewService>(service);

  return service;
}

/// Load a mock of the [MonETSAPIClient]
MonETSAPIClient setupMonETSApiMock() {
  unregister<MonETSAPIClient>();
  final service = MonETSAPIClientMock();

  locator.registerSingleton<MonETSAPIClient>(service);

  return service;
}

/// Load a mock of the [AnalyticsService]
AnalyticsService setupAnalyticsServiceMock() {
  unregister<AnalyticsService>();
  final service = AnalyticsServiceMock();

  locator.registerSingleton<AnalyticsService>(service);

  return service;
}

/// Load a mock of the [RiveAnimationService]
RiveAnimationService setupRiveAnimationServiceMock() {
  unregister<RiveAnimationService>();
  final service = RiveAnimationServiceMock();

  locator.registerSingleton<RiveAnimationService>(service);

  return service;
}

/// Load a mock of the [InternalInfoService]
InternalInfoService setupInternalInfoServiceMock() {
  unregister<InternalInfoService>();
  final service = InternalInfoServiceMock();

  locator.registerSingleton<InternalInfoService>(service);

  return service;
}

/// Load a mock of the [SirenFlutterService]
SirenFlutterService setupSirenFlutterServiceMock() {
  unregister<SirenFlutterService>();
  final service = SirenFlutterServiceMock();

  locator.registerSingleton<SirenFlutterService>(service);

  return service;
}

void setupFlutterToastMock([WidgetTester? tester]) {
  const MethodChannel channel = MethodChannel('PonnamKarthik/fluttertoast');

  TestDefaultBinaryMessenger messenger;

  if (tester != null) {
    messenger = tester.binding.defaultBinaryMessenger;
  } else {
    messenger =
        TestDefaultBinaryMessengerBinding.instance!.defaultBinaryMessenger;
  }

  messenger.setMockMethodCallHandler(channel, (MethodCall methodCall) async {
    if (methodCall.method == 'showToast') {
      return true;
    }
    return false;
  });
}

/// Load a mock of the [AppWidgetService]
AppWidgetService setupAppWidgetServiceMock() {
  unregister<AppWidgetService>();
  final service = AppWidgetServiceMock();

  locator.registerSingleton<AppWidgetService>(service);

  return service;
}

/// Load a mock of the [NavigationService]
NavigationService setupNavigationServiceMock() {
  unregister<NavigationService>();
  final service = NavigationServiceMock();

  locator.registerSingleton<NavigationService>(service);

  return service;
}

/// Load a mock of the [GithubApi]
GithubApi setupGithubApiMock() {
  unregister<GithubApi>();
  final service = GithubApiMock();

  locator.registerSingleton<GithubApi>(service);

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

/// Load a mock of the [NetworkingService]
/// Will also stub the first value of changeConnectivityStream
NetworkingService setupNetworkingServiceMock() {
  unregister<NetworkingService>();
  final service = NetworkingServiceMock();

  locator.registerSingleton<NetworkingService>(service);

  NetworkingServiceMock.stubChangeConnectivityStream(service);
  NetworkingServiceMock.stubHasConnectivity(service);

  return service;
}

void setupInAppReviewMock([WidgetTester? tester]) {
  const MethodChannel channel = MethodChannel('dev.britannio.in_app_review');

  TestDefaultBinaryMessenger messenger;

  if (tester != null) {
    messenger = tester.binding.defaultBinaryMessenger;
  } else {
    messenger =
        TestDefaultBinaryMessengerBinding.instance!.defaultBinaryMessenger;
  }

  messenger.setMockMethodCallHandler(channel, (MethodCall methodCall) async {
    if (methodCall.method == 'isAvailable') {
      return true;
    }
    return false;
  });
}

/// Load a mock of the [LaunchUrlService]
LaunchUrlService setupLaunchUrlServiceMock() {
  unregister<LaunchUrlService>();
  final service = LaunchUrlServiceMock();

  locator.registerSingleton<LaunchUrlService>(service);

  return service;
}

/// Load a mock of the [RemoteConfigService]
RemoteConfigService setupRemoteConfigServiceMock() {
  unregister<RemoteConfigService>();
  final service = RemoteConfigServiceMock();

  locator.registerSingleton<RemoteConfigService>(service);

  return service;
}

/// Load a mock of the [QuickLinkRepository]
QuickLinkRepository setupQuickLinkRepositoryMock() {
  unregister<QuickLinkRepository>();
  final repository = QuickLinkRepositoryMock();

  locator.registerSingleton<QuickLinkRepository>(repository);

  return repository;
}

bool getCalendarViewEnabled() {
  final RemoteConfigService remoteConfigService =
      locator<RemoteConfigService>();
  return remoteConfigService.scheduleListViewDefault;
}
