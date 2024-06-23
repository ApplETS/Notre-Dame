// Package imports:
import 'package:ets_api_clients/clients.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:notredame/features/app/repository/author_repository.dart';
import 'package:notredame/features/app/repository/news_repository.dart';

// Project imports:
import 'package:notredame/features/app/storage/cache_manager.dart';
import 'package:notredame/features/app/repository/course_repository.dart';
import 'package:notredame/features/app/repository/quick_link_repository.dart';
import 'package:notredame/features/more/settings/settings_manager.dart';
import 'package:notredame/features/app/repository/user_repository.dart';
import 'package:notredame/features/app/analytics/analytics_service.dart';
import 'package:notredame/features/app/widgets/app_widget_service.dart';
import 'package:notredame/features/app/integration/github_api.dart';
import 'package:notredame/features/more/feedback/in_app_review_service.dart';
import 'package:notredame/features/app/error/internal_info_service.dart';
import 'package:notredame/features/app/integration/launch_url_service.dart';
import 'package:notredame/features/app/navigation/navigation_service.dart';
import 'package:notredame/features/app/integration/networking_service.dart';
import 'package:notredame/features/app/storage/preferences_service.dart';
import 'package:notredame/features/app/analytics/remote_config_service.dart';
import 'package:notredame/features/app/presentation/rive_animation_service.dart';
import 'package:notredame/features/app/storage/siren_flutter_service.dart';

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
  locator.registerLazySingleton(() => NewsRepository());
  locator.registerLazySingleton(() => AuthorRepository());

  // Other
  locator.registerLazySingleton(() => SignetsAPIClient());
  locator.registerLazySingleton(() => MonETSAPIClient());
  locator.registerLazySingleton(() => HelloAPIClient());
  locator.registerLazySingleton(() => Logger());
}
