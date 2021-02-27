// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';
import 'package:notredame/ui/views/startup_view.dart';
import 'package:stacked/stacked.dart';
import 'package:oktoast/oktoast.dart';

// MANAGER
import 'package:notredame/core/managers/cache_manager.dart';
import 'package:notredame/core/managers/user_repository.dart';

//SERVICE
import 'package:notredame/core/services/navigation_service.dart';

// VIEWS
import 'package:notredame/ui/views/login_view.dart';

// OTHERS
import 'package:notredame/core/constants/router_paths.dart';
import 'package:notredame/generated/l10n.dart';
import '../../locator.dart';

class MoreViewModel extends BaseViewModel {
  /// Cache manager
  final CacheManager _cacheManager = locator<CacheManager>();

  /// Used to redirect on the dashboard.
  final NavigationService _navigationService = locator<NavigationService>();

  /// Used to logout user, delete cache, and return to login
  Future<void> logout(BuildContext context) async {
    await _cacheManager.empty();
    UserRepository().logOut();
    // Dismiss alertDialog
    Navigator.of(context, rootNavigator: true)
        .pop();
    _navigationService.pushNamedAndRemoveUntil(
        RouterPaths.login
    );
    showToast(AppIntl.of(context).login_msg_logout_success);
  }
}
