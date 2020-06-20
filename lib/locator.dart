// FLUTTER / DART / THIRD-PARTIES
import 'package:get_it/get_it.dart';

// SERVICES
import 'package:notredame/core/services/navigation_service.dart';

GetIt locator = GetIt.instance;

void setupLocator() {
  locator.registerLazySingleton(() => NavigationService());
}
