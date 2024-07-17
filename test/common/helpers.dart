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
import 'package:notredame/features/app/analytics/analytics_service.dart';
import 'package:notredame/features/app/analytics/remote_config_service.dart';
import 'package:notredame/features/app/error/internal_info_service.dart';
import 'package:notredame/features/app/integration/github_api.dart';
import 'package:notredame/features/app/integration/launch_url_service.dart';
import 'package:notredame/features/app/integration/networking_service.dart';
import 'package:notredame/features/app/monets_api/monets_api_client.dart';
import 'package:notredame/features/app/navigation/navigation_service.dart';
import 'package:notredame/features/app/presentation/rive_animation_service.dart';
import 'package:notredame/features/app/repository/author_repository.dart';
import 'package:notredame/features/app/repository/course_repository.dart';
import 'package:notredame/features/app/repository/news_repository.dart';
import 'package:notredame/features/app/repository/quick_link_repository.dart';
import 'package:notredame/features/app/repository/user_repository.dart';
import 'package:notredame/features/app/signets-api/signets_api_client.dart';
import 'package:notredame/features/app/storage/cache_manager.dart';
import 'package:notredame/features/app/storage/preferences_service.dart';
import 'package:notredame/features/app/storage/siren_flutter_service.dart';
import 'package:notredame/features/more/feedback/in_app_review_service.dart';
import 'package:notredame/features/more/settings/settings_manager.dart';
import 'package:notredame/utils/locator.dart';
import '../features/app/analytics/analytics_service_mock.dart';
import '../features/app/analytics/remote_config_service_mock.dart';
import '../features/app/error/internal_info_service_mock.dart';
import '../features/app/integration/mocks/github_api_mock.dart';
import '../features/app/integration/mocks/launch_url_service_mock.dart';
import '../features/app/integration/mocks/networking_service_mock.dart';
import '../features/app/monets_api/mocks/mon_ets_api_mock.dart';
import '../features/app/navigation/navigation_service_mock.dart';
import '../features/app/presentation/rive_animation_service_mock.dart';
import '../features/app/repository/mocks/author_repository_mock.dart';
import '../features/app/repository/mocks/course_repository_mock.dart';
import '../features/app/repository/mocks/news_repository_mock.dart';
import '../features/app/repository/mocks/quick_links_repository_mock.dart';
import '../features/app/repository/mocks/user_repository_mock.dart';
import '../features/app/signets_api/mocks/signets_api_mock.dart';
import '../features/app/storage/mocks/cache_manager_mock.dart';
import '../features/app/storage/mocks/flutter_secure_storage_mock.dart';
import '../features/app/storage/mocks/preferences_service_mock.dart';
import '../features/app/storage/mocks/siren_flutter_service_mock.dart';
import '../features/more/feedback/mocks/in_app_review_service_mock.dart';
import '../features/more/settings/mocks/settings_manager_mock.dart';

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
InAppReviewService setupInAppReviewServiceMock() {
  unregister<InAppReviewService>();
  final service = InAppReviewServiceMock();

  locator.registerSingleton<InAppReviewService>(service);

  return service;
}

/// Load a mock of the [MonETSAPIClient]
MonETSAPIClientMock setupMonETSApiMock() {
  unregister<MonETSAPIClient>();
  final service = MonETSAPIClientMock();

  locator.registerSingleton<MonETSAPIClient>(service);

  return service;
}

/// Load a mock of the [AnalyticsService]
AnalyticsServiceMock setupAnalyticsServiceMock() {
  unregister<AnalyticsService>();
  final service = AnalyticsServiceMock();

  locator.registerSingleton<AnalyticsService>(service);

  return service;
}

/// Load a mock of the [RiveAnimationService]
RiveAnimationServiceMock setupRiveAnimationServiceMock() {
  unregister<RiveAnimationService>();
  final service = RiveAnimationServiceMock();

  locator.registerSingleton<RiveAnimationService>(service);

  return service;
}

/// Load a mock of the [InternalInfoService]
InternalInfoServiceMock setupInternalInfoServiceMock() {
  unregister<InternalInfoService>();
  final service = InternalInfoServiceMock();

  locator.registerSingleton<InternalInfoService>(service);

  return service;
}

/// Load a mock of the [SirenFlutterService]
SirenFlutterServiceMock setupSirenFlutterServiceMock() {
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
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
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

/// Load a mock of the [GithubApi]
GithubApiMock setupGithubApiMock() {
  unregister<GithubApi>();
  final service = GithubApiMock();

  locator.registerSingleton<GithubApi>(service);

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

/// Load a mock of the [CacheManager]
CacheManagerMock setupCacheManagerMock() {
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
PreferencesServiceMock setupPreferencesServiceMock() {
  unregister<PreferencesService>();
  final service = PreferencesServiceMock();

  locator.registerSingleton<PreferencesService>(service);

  return service;
}

/// Load a mock of the [SettingsManager]
SettingsManagerMock setupSettingsManagerMock() {
  unregister<SettingsManager>();
  final service = SettingsManagerMock();

  locator.registerSingleton<SettingsManager>(service);

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
    messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
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

bool getCalendarViewEnabled() {
  final RemoteConfigService remoteConfigService =
      locator<RemoteConfigService>();
  return remoteConfigService.scheduleListViewDefault;
}
