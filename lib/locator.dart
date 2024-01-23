// Package imports:
import 'package:ets_api_clients/clients.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
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

GetIt locator = GetIt.instance;

void setupLocator() {
  // Services
  locator.registerLazySingleton(() => NavigationService());
  locator.registerLazySingleton(() => AnalyticsService());
  locator.registerLazySingleton(() => RiveAnimationService());
  locator.registerLazySingleton(() => InternalInfoService());
  locator.registerLazySingleton(() => GithubApi());
  locator.registerLazySingleton(() => const FlutterSecureStorage());
  locator.registerLazySingleton(() => PreferencesService());
  locator.registerLazySingleton(() => NetworkingService());
  locator.registerLazySingleton(() => SirenFlutterService());
  locator.registerLazySingleton(() => AppWidgetService());
  locator.registerLazySingleton(() => InAppReviewService());
  locator.registerLazySingleton(() => RemoteConfigService());
  locator.registerLazySingleton(() => LaunchUrlService());

  // Managers
  locator.registerLazySingleton(() => UserRepository());
  locator.registerLazySingleton(() => CourseRepository());
  locator.registerLazySingleton(() => CacheManager());
  locator.registerLazySingleton(() => SettingsManager());
  locator.registerLazySingleton(() => QuickLinkRepository());

  // Other
  locator.registerLazySingleton(() => SignetsAPIClient());
  locator.registerLazySingleton(() => MonETSAPIClient());
  locator.registerLazySingleton(() => Logger());
}
