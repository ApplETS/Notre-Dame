// Flutter imports:
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:flutter_siren/flutter_siren.dart';
import 'package:pub_semver/pub_semver.dart';

// SERVICES

class SirenFlutterService {
  late Siren _siren;

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
      {required String title,
      required String message,
      String buttonUpgradeText = 'Upgrade',
      String buttonCancelText = 'Cancel',
      bool forceUpgrade = false}) async {
    return _siren.promptUpdate(context,
        title: title,
        message: message,
        buttonUpgradeText: buttonUpgradeText,
        buttonCancelText: buttonCancelText,
        forceUpgrade: forceUpgrade);
  }
}
