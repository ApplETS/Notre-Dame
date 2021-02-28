// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'package:stacked/stacked.dart';
import 'package:oktoast/oktoast.dart';

// MANAGER
import 'package:notredame/core/managers/cache_manager.dart';
import 'package:notredame/core/managers/user_repository.dart';

//SERVICE
import 'package:notredame/core/services/navigation_service.dart';

// OTHERS
import 'package:notredame/core/constants/router_paths.dart';
import 'package:notredame/generated/l10n.dart';
import 'package:notredame/locator.dart';

class MoreViewModel extends FutureViewModel {
  /// Cache manager
  final CacheManager _cacheManager = locator<CacheManager>();

  /// Used to redirect on the dashboard.
  final NavigationService _navigationService = locator<NavigationService>();

  String _appVersion;

  /// Get the application version
  String get appVersion => _appVersion;

  @override
  Future futureToRun() async {
    setBusy(true);
    await PackageInfo.fromPlatform()
        .then((value) => _appVersion = value.version);
    setBusy(false);
    return true;
  }

  /// Used to logout user, delete cache, and return to login
  Future<void> logout(BuildContext context) async {
    await _cacheManager.empty();
    UserRepository().logOut();
    // Dismiss alertDialog
    Navigator.of(context).pop();
    _navigationService.pushNamedAndRemoveUntil(RouterPaths.login);
    showToast(AppIntl.of(context).login_msg_logout_success);
  }
}
