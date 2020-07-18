// FLUTTER / DART / THIRD-PARTIES
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;

// SERVICES
import 'package:notredame/core/services/navigation_service.dart';
import 'package:notredame/core/services/analytics_service.dart';
import 'package:notredame/core/services/mon_ets_api.dart';

GetIt locator = GetIt.instance;

void setupLocator() {
  locator.registerLazySingleton(() => NavigationService());
  locator.registerLazySingleton(() => AnalyticsService());
  locator.registerLazySingleton(() => MonETSApi(http.Client()));
}
