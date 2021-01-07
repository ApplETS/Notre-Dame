// FLUTTER / DART / THIRD-PARTIES
import 'package:stacked/stacked.dart';

// SERVICE
import 'package:notredame/core/managers/user_repository.dart';
import 'package:notredame/core/services/navigation_service.dart';

// OTHER
import 'package:notredame/locator.dart';
import 'package:notredame/core/constants/router_paths.dart';

class StartUpViewModel extends BaseViewModel {
  /// Used to authenticate the user
  final UserRepository _userRepository = locator<UserRepository>();

  /// Used to redirect on the dashboard.
  final NavigationService _navigationService = locator<NavigationService>();

  /// Try to silent authenticate the user then redirect to [LoginView] or [DashboardView]
  Future handleStartUp() async {
    final bool isLogin = await _userRepository.silentAuthenticate();

    if (isLogin) {
      _navigationService.pushNamed(RouterPaths.dashboard);
    } else {
      _navigationService.pushNamed(RouterPaths.login);
    }
  }
}
