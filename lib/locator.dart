// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:notredame/core/services/github_api.dart';
import 'package:notredame/core/managers/dashboard_manager.dart';

// SERVICES
import 'package:notredame/core/services/navigation_service.dart';
import 'package:notredame/core/services/analytics_service.dart';
import 'package:notredame/core/services/mon_ets_api.dart';
import 'package:notredame/core/services/preferences_service.dart';
import 'package:notredame/core/services/signets_api.dart';
import 'package:notredame/core/services/rive_animation_service.dart';

// MANAGERS
import 'package:notredame/core/managers/user_repository.dart';
import 'package:notredame/core/managers/course_repository.dart';
import 'package:notredame/core/managers/cache_manager.dart';
import 'package:notredame/core/managers/settings_manager.dart';

GetIt locator = GetIt.instance;

void setupLocator() {
  // Services
  locator.registerLazySingleton(() => NavigationService());
  locator.registerLazySingleton(() => AnalyticsService());
  locator.registerLazySingleton(() => RiveAnimationService());
  locator.registerLazySingleton(() => MonETSApi(http.Client()));
  locator.registerLazySingleton(() => GithubApi());
  locator.registerLazySingleton(() => SignetsApi());
  locator.registerLazySingleton(() => const FlutterSecureStorage());
  locator.registerLazySingleton(() => PreferencesService());

  // Managers
  locator.registerLazySingleton(() => UserRepository());
  locator.registerLazySingleton(() => CourseRepository());
  locator.registerLazySingleton(() => CacheManager());
  locator.registerLazySingleton(() => SettingsManager());
  locator.registerLazySingleton(() => DashboardManager());

  // Other
  locator.registerLazySingleton(() => Logger());
}
