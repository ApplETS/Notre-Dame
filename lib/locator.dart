// Package imports:
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
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
import 'package:notredame/data/services/hello/hello_service.dart';
import 'package:notredame/data/services/in_app_review_service.dart';
import 'package:notredame/data/services/launch_url_service.dart';
import 'package:notredame/data/services/navigation_service.dart';
import 'package:notredame/data/services/networking_service.dart';
import 'package:notredame/data/services/preferences_service.dart';
import 'package:notredame/data/services/remote_config_service.dart';
import 'package:notredame/data/services/signets-api/signets_api_client.dart';

GetIt locator = GetIt.instance;

void setupLocator() {
  // Services
  locator.registerLazySingleton(() => NavigationService());
  locator.registerLazySingleton(() => AnalyticsService());
  locator.registerLazySingleton(() => const FlutterSecureStorage());
  locator.registerLazySingleton(() => PreferencesService());
  locator.registerLazySingleton(() => NetworkingService());
  locator.registerLazySingleton(() => InAppReviewService());
  locator.registerLazySingleton(() => RemoteConfigService());
  locator.registerLazySingleton(() => LaunchUrlService());
  locator.registerLazySingleton(() => AuthService());

  // Managers
  locator.registerLazySingleton(() => UserRepository());
  locator.registerLazySingleton(() => CourseRepository());
  locator.registerLazySingleton(() => CacheService());
  locator.registerLazySingleton(() => SettingsRepository());
  locator.registerLazySingleton(() => QuickLinkRepository());
  locator.registerLazySingleton(() => NewsRepository());
  locator.registerLazySingleton(() => AuthorRepository());
  locator.registerLazySingleton(() => BroadcastMessageRepository());

  // Other
  locator.registerLazySingleton(() => SignetsAPIClient());
  locator.registerLazySingleton(() => HelloService());
  locator.registerLazySingleton(() => Logger());
}
