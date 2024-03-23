// Flutter imports:
import 'package:flutter/services.dart';

// Package imports:
import 'package:rive/rive.dart';

// Project imports:
import 'package:notredame/core/utils/animation_exception.dart';

/// Manage the rive animation for the application
class RiveAnimationService {
  Future<Artboard> loadRiveFile({required String riveFileName}) async {
    final bytes = await rootBundle.load("assets/animations/$riveFileName.riv");

    try {
      final file = RiveFile.import(bytes);

      // get the main artboard
      return file.mainArtboard;
    } on Exception {
      throw const AnimationException(
          prefix: "loadRiveFile",
          message:
              "Impossible to load the rive file. The file is most likely not found or corrupted. Check if the file is located in /assets/animations/*.riv");
    }
  }

  void addControllerToAnimation(
      {required Artboard artboard,
      RiveAnimationController<dynamic>? controller}) {
    try {
      controller ??= SimpleAnimation(artboard.animations[0].name);
      artboard.addController(controller);
    } catch (e) {
      throw AnimationException(
          prefix: "addControllerToAnimation",
          message:
              "The animation controller was not able to attach to the artboard.",
          nestedException: e as Exception);
    }
  }
}
