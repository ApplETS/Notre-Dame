// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:oktoast/oktoast.dart';

// MANAGER
import 'package:notredame/core/managers/cache_manager.dart';
import 'package:notredame/core/managers/user_repository.dart';

// VIEWS
import 'package:notredame/ui/views/startup_view.dart';

// OTHERS
import 'package:notredame/generated/l10n.dart';
import '../../locator.dart';

class MoreViewModel extends BaseViewModel {
  /// Cache manager
  final CacheManager _cacheManager = locator<CacheManager>();

  Future<void> logout(BuildContext context) async {
    await _cacheManager.empty();
    UserRepository().logOut();
    Navigator.pushAndRemoveUntil(context,
        MaterialPageRoute(builder: (BuildContext context) {
      return StartUpView();
    }), (Route<dynamic> route) => false);
    showToast(AppIntl.of(context).login_msg_logout_success);
  }
}
