// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/cupertino.dart';
import 'package:flutter_siren/flutter_siren.dart';

// SERVICES
import 'package:pub_semver/pub_semver.dart';

class SirenFlutterService {
  Siren _siren;

  SirenFlutterService() {
    _siren = Siren();
  }

  // Check if update is available
  Future<bool> updateIsAvailable() async {
    return _siren.updateIsAvailable();
  }

  // The local version of the app coming from Siren package
  Future<Version> get localVersion async {
    final local = await _siren.localVersion;
    return Version.parse(local.toString());
  }

  // The store version of the app coming from Siren package
  Future<Version> get storeVersion async {
    final store = await _siren.storeVersion;
    return Version.parse(store.toString());
  }

  // Relay prompt update info to Siren package
  Future<void> promptUpdate(BuildContext context,
      {String title,
      String message,
      String buttonUpgradeText,
      String buttonCancelText,
      bool forceUpgrade = false}) async {
    return _siren.promptUpdate(context,
        title: title,
        message: message,
        buttonUpgradeText: buttonUpgradeText,
        buttonCancelText: buttonCancelText,
        forceUpgrade: forceUpgrade);
  }
}
