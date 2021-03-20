// FLUTTER / DART / THIRD-PARTIES
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rive/rive.dart';

// OTHER
import 'package:notredame/core/utils/animation_exception.dart';

/// Manage the rive animation for the application
class RiveAnimationService {
  Future<Artboard> loadRiveFile({@required String riveFileName}) async {
    final bytes = await rootBundle.load("assets/animations/$riveFileName.riv");
    final file = RiveFile();

    if (file.import(bytes)) {
      // get the main artboard
      return file.mainArtboard;
    }

    throw const AnimationException(
        prefix: "loadRiveFile",
        message:
            "Impossible to load the rive file. The file is most likely not found or corrupted. Check if the file is located in /assets/animations/*.riv");
  }

  void addControllerToAnimation(
      {@required Artboard artboard,
      RiveAnimationController<dynamic> controller}) {
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
