// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';

// Project imports:
import 'package:notredame/data/repositories/author_repository.dart';
import 'package:notredame/data/repositories/broadcast_message_repository.dart';
import 'package:notredame/data/repositories/course_repository.dart';
import 'package:notredame/data/repositories/news_repository.dart';
import 'package:notredame/data/repositories/quick_link_repository.dart';
import 'package:notredame/data/repositories/settings_repository.dart';
import 'package:notredame/data/repositories/user_repository.dart';
import 'package:notredame/data/services/analytics_service.dart';
import 'package:notredame/data/services/auth_service.dart';
import 'package:notredame/data/services/cache_service.dart';
import 'package:notredame/data/services/in_app_review_service.dart';
import 'package:notredame/data/services/launch_url_service.dart';
import 'package:notredame/data/services/navigation_service.dart';
import 'package:notredame/data/services/networking_service.dart';
import 'package:notredame/data/services/preferences_service.dart';
import 'package:notredame/data/services/remote_config_service.dart';
import 'package:notredame/data/services/signets-api/signets_api_client.dart';
import 'package:notredame/data/services/signets_client.dart';
import 'package:notredame/locator.dart';
import 'data/mocks/repositories/author_repository_mock.dart';
import 'data/mocks/repositories/broadcast_message_repository_mock.dart';
import 'data/mocks/repositories/course_repository_mock.dart';
import 'data/mocks/repositories/news_repository_mock.dart';
import 'data/mocks/repositories/quick_links_repository_mock.dart';
import 'data/mocks/repositories/settings_repository_mock.dart';
import 'data/mocks/repositories/user_repository_mock.dart';
import 'data/mocks/services/analytics_service_mock.dart';
import 'data/mocks/services/auth_service_mock.dart';
import 'data/mocks/services/cache_service_mock.dart';
import 'data/mocks/services/flutter_secure_storage_mock.dart';
import 'data/mocks/services/in_app_review_service_mock.dart';
import 'data/mocks/services/launch_url_service_mock.dart';
import 'data/mocks/services/navigation_service_mock.dart';
import 'data/mocks/services/networking_service_mock.dart';
import 'data/mocks/services/preferences_service_mock.dart';
import 'data/mocks/services/remote_config_service_mock.dart';
import 'data/mocks/services/signets_api_mock.dart';
import 'data/mocks/services/signets_client_mock.dart';

/// Unregister the service [T] from GetIt
void unregister<T extends Object>() {
  if (locator.isRegistered<T>()) {
    locator.unregister<T>();
  }
}

/// Load the l10n classes. Take the [child] widget to test
Widget localizedWidget(
        {required Widget child, bool useScaffold = true, String locale = 'en', double textScaleFactor = 0.9}) =>
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
SignetsAPIClientMock setupSignetsApiMock() {
  unregister<SignetsAPIClient>();
  final service = SignetsAPIClientMock();

  locator.registerSingleton<SignetsAPIClient>(service);

  return service;
}

/// Load a mock of the [NewsRepository]
NewsRepositoryMock setupNewsRepositoryMock() {
  unregister<NewsRepository>();
  final service = NewsRepositoryMock();

  locator.registerSingleton<NewsRepository>(service);

  return service;
}

/// Load a mock of the [AuthorRepository]
AuthorRepositoryMock setupAuthorRepositoryMock() {
  unregister<AuthorRepository>();
  final service = AuthorRepositoryMock();

  locator.registerSingleton<AuthorRepository>(service);

  return service;
}

/// Load a mock of the [InAppReviewService]
InAppReviewServiceMock setupInAppReviewServiceMock() {
  unregister<InAppReviewService>();
  final service = InAppReviewServiceMock();

  locator.registerSingleton<InAppReviewService>(service);

  return service;
}

/// Load a mock of the [AnalyticsService]
AnalyticsServiceMock setupAnalyticsServiceMock() {
  unregister<AnalyticsService>();
  final service = AnalyticsServiceMock();

  locator.registerSingleton<AnalyticsService>(service);

  return service;
}

void setupFlutterToastMock([WidgetTester? tester]) {
  const MethodChannel channel = MethodChannel('PonnamKarthik/fluttertoast');

  TestDefaultBinaryMessenger messenger;

  if (tester != null) {
    messenger = tester.binding.defaultBinaryMessenger;
  } else {
    messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  }

  messenger.setMockMethodCallHandler(channel, (MethodCall methodCall) async {
    if (methodCall.method == 'showToast') {
      return true;
    }
    return false;
  });
}

/// Load a mock of the [NavigationService]
NavigationServiceMock setupNavigationServiceMock() {
  unregister<NavigationService>();
  final service = NavigationServiceMock();

  locator.registerSingleton<NavigationService>(service);

  return service;
}

/// Load a mock of the [FlutterSecureStorage]
FlutterSecureStorageMock setupFlutterSecureStorageMock() {
  unregister<FlutterSecureStorage>();
  final service = FlutterSecureStorageMock();

  locator.registerSingleton<FlutterSecureStorage>(service);

  return service;
}

/// Load a mock of the [UserRepository]
UserRepositoryMock setupUserRepositoryMock() {
  unregister<UserRepository>();
  final service = UserRepositoryMock();

  locator.registerSingleton<UserRepository>(service);

  return service;
}

/// Load the Internationalization class
Future<AppIntl> setupAppIntl() async {
  return AppIntl.delegate.load(const Locale('en'));
}

/// Load a mock of the [CacheService]
CacheServiceMock setupCacheManagerMock() {
  unregister<CacheService>();
  final service = CacheServiceMock();

  locator.registerSingleton<CacheService>(service);

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
PreferencesServiceMock setupPreferencesServiceMock() {
  unregister<PreferencesService>();
  final service = PreferencesServiceMock();

  locator.registerSingleton<PreferencesService>(service);

  return service;
}

/// Load a mock of the [SettingsRepository]
SettingsRepositoryMock setupSettingsRepositoryMock() {
  unregister<SettingsRepository>();
  final service = SettingsRepositoryMock();

  locator.registerSingleton<SettingsRepository>(service);

  return service;
}

/// Load a mock of the [CourseRepository]
CourseRepositoryMock setupCourseRepositoryMock() {
  unregister<CourseRepository>();
  final service = CourseRepositoryMock();

  locator.registerSingleton<CourseRepository>(service);

  return service;
}

/// Load a mock of the [NetworkingService]
/// Will also stub the first value of changeConnectivityStream
NetworkingServiceMock setupNetworkingServiceMock() {
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
    messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  }

  messenger.setMockMethodCallHandler(channel, (MethodCall methodCall) async {
    if (methodCall.method == 'isAvailable') {
      return true;
    }
    return false;
  });
}

/// Load a mock of the [LaunchUrlService]
LaunchUrlServiceMock setupLaunchUrlServiceMock() {
  unregister<LaunchUrlService>();
  final service = LaunchUrlServiceMock();

  locator.registerSingleton<LaunchUrlService>(service);

  return service;
}

/// Load a mock of the [RemoteConfigService]
RemoteConfigServiceMock setupRemoteConfigServiceMock() {
  unregister<RemoteConfigService>();
  final service = RemoteConfigServiceMock();

  locator.registerSingleton<RemoteConfigService>(service);

  return service;
}

/// Load a mock of the [QuickLinkRepository]
QuickLinkRepositoryMock setupQuickLinkRepositoryMock() {
  unregister<QuickLinkRepository>();
  final repository = QuickLinkRepositoryMock();

  locator.registerSingleton<QuickLinkRepository>(repository);

  return repository;
}

AuthServiceMock setupAuthServiceMock() {
  unregister<AuthService>();
  final repository = AuthServiceMock();

  locator.registerSingleton<AuthService>(repository);

  return repository;
}

bool getCalendarViewEnabled() {
  final RemoteConfigService remoteConfigService = locator<RemoteConfigService>();
  return remoteConfigService.scheduleListViewDefault;
}

BroadcastMessageRepositoryMock setupBroadcastMessageRepositoryMock() {
  unregister<BroadcastMessageRepository>();
  final BroadcastMessageRepositoryMock repository = BroadcastMessageRepositoryMock();

  locator.registerSingleton<BroadcastMessageRepository>(repository);

  return repository;
}

SignetsClientMock setupSignetsClientMock() {
  unregister<SignetsClient>();
  final service = SignetsClientMock();

  locator.registerSingleton<SignetsClient>(service);

  return service;
}
